-- test_number_filter.lua
-- Unit tests for number-filter.lua

-- Arrange: stub pandoc environment and load filter
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  RawInline = function(fmt, s) return { t = 'RawInline', format = fmt, text = s } end,
}
_G.pandoc = pandoc
local filter = dofile((... and (...):gsub("[^/\\]+$", "number-filter.lua")) or "number-filter.lua")
local Str = filter.Str

-- Simple test framework
local fails = 0
local tests_run = 0

local function assert_true(cond, msg)
  tests_run = tests_run + 1
  if not cond then
    fails = fails + 1
    io.stderr:write("FAIL: ", msg or "(no message)", "\n")
  end
end

local function assert_equal(actual, expected, msg)
  tests_run = tests_run + 1
  if actual ~= expected then
    fails = fails + 1
    io.stderr:write(("FAIL: %s\n  expected: %s\n  actual:   %s\n")
      :format(msg or "(no message)", tostring(expected), tostring(actual)))
  end
end

local function assert_len(tbl, expected, msg)
  tests_run = tests_run + 1
  if #tbl ~= expected then
    fails = fails + 1
    io.stderr:write(("FAIL: %s\n  expected length: %d\n  actual length:   %d\n")
      :format(msg or "(no message)", expected, #tbl))
  end
end

local function is_elem(x)
  return type(x) == 'table' and x.t ~= nil
end

local function is_array_of_elems(x)
  return type(x) == 'table' and x.t == nil and (x[1] == nil or is_elem(x[1]))
end

local function flatten(result)
  if result == nil then return nil end
  if is_elem(result) then return { result } end
  if is_array_of_elems(result) then return result end
  error("Unexpected result shape from Str()")
end

local function concat_text(result)
  local parts = {}
  for _, e in ipairs(flatten(result)) do
    if e.t == 'Str' then
      table.insert(parts, e.text)
    elseif e.t == 'RawInline' and e.format == 'latex' then
      table.insert(parts, e.text)
    else
      table.insert(parts, "<" .. tostring(e.t) .. ">")
    end
  end
  return table.concat(parts)
end

local function make_elem(s)
  return { t = 'Str', text = s }
end

-- Tests

-- 1) No digits: unchanged (nil)
do
  local elem = make_elem("ただのテキスト")
  local out = Str(elem)
  assert_true(out == nil, "No digits: should return nil (unchanged)")
end

-- 2) Single digit: convert to full-width
do
  local elem = make_elem("5")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Single digit: should return a single element")
  assert_equal(arr[1].t, "Str", "Single digit: element type should be Str")
  assert_equal(arr[1].text, "５", "Single digit: should convert to full-width")
end

-- 3) All single digits
do
  local tests = {
    ["0"] = "０", ["1"] = "１", ["2"] = "２", ["3"] = "３", ["4"] = "４",
    ["5"] = "５", ["6"] = "６", ["7"] = "７", ["8"] = "８", ["9"] = "９"
  }
  for input, expected in pairs(tests) do
    local elem = make_elem(input)
    local out = Str(elem)
    local arr = flatten(out)
    assert_len(arr, 1, "Digit " .. input .. ": should return single element")
    assert_equal(arr[1].text, expected, "Digit " .. input .. ": conversion")
  end
end

-- 4) Two digits: wrap with \small{\tatechuyoko*{}}
do
  local elem = make_elem("12")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Two digits: should return a single element")
  assert_equal(arr[1].t, "RawInline", "Two digits: element type should be RawInline")
  assert_equal(arr[1].format, "latex", "Two digits: format should be latex")
  assert_equal(arr[1].text, "{\\small\\tatechuyoko*{12}}", "Two digits: latex command")
end

-- 5) Three digits: convert to full-width
do
  local elem = make_elem("123")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Three digits: should return a single element")
  assert_equal(arr[1].t, "Str", "Three digits: element type should be Str")
  assert_equal(arr[1].text, "１２３", "Three digits: should convert to full-width")
end

-- 6) Four digits: convert to full-width
do
  local elem = make_elem("1234")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Four digits: should return a single element")
  assert_equal(arr[1].t, "Str", "Four digits: element type should be Str")
  assert_equal(arr[1].text, "１２３４", "Four digits: should convert to full-width")
end

-- 7) Mixed text with different digit patterns
do
  local elem = make_elem("今日は12月3日です")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 5, "Mixed text: should return five elements")
  assert_equal(arr[1].t, "Str", "Mixed text: first element type")
  assert_equal(arr[1].text, "今日は", "Mixed text: first text")
  assert_equal(arr[2].t, "RawInline", "Mixed text: second element type")
  assert_equal(arr[2].text, "{\\small\\tatechuyoko*{12}}", "Mixed text: tatechuyoko for 12")
  assert_equal(arr[3].t, "Str", "Mixed text: third element type") 
  assert_equal(arr[3].text, "月", "Mixed text: third text")
  assert_equal(arr[4].t, "Str", "Mixed text: fourth element type")
  assert_equal(arr[4].text, "３", "Mixed text: fourth text - full-width 3")
  assert_equal(arr[5].t, "Str", "Mixed text: fifth element type")
  assert_equal(arr[5].text, "日です", "Mixed text: fifth text")
end

-- 8) Multiple two-digit numbers
do
  local elem = make_elem("12と34")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Multiple 2-digits: should return three elements")
  assert_equal(arr[1].t, "RawInline", "Multiple 2-digits: first element type")
  assert_equal(arr[1].text, "{\\small\\tatechuyoko*{12}}", "Multiple 2-digits: first tatechuyoko")
  assert_equal(arr[2].t, "Str", "Multiple 2-digits: second element type")
  assert_equal(arr[2].text, "と", "Multiple 2-digits: second text")
  assert_equal(arr[3].t, "RawInline", "Multiple 2-digits: third element type")
  assert_equal(arr[3].text, "{\\small\\tatechuyoko*{34}}", "Multiple 2-digits: second tatechuyoko")
end

-- 9) Adjacent numbers with different rules
do
  local elem = make_elem("5123")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Adjacent numbers: should return single element")
  assert_equal(arr[1].t, "Str", "Adjacent numbers: element type")
  assert_equal(arr[1].text, "５１２３", "Adjacent numbers: all converted to full-width")
end

-- 10) Mixed adjacent: 12345
do
  local elem = make_elem("12345")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Five digits: should return single element")
  assert_equal(arr[1].t, "Str", "Five digits: element type")
  assert_equal(arr[1].text, "１２３４５", "Five digits: all converted to full-width")
end

-- 11) Empty string: unchanged
do
  local elem = make_elem("")
  local out = Str(elem)
  assert_true(out == nil, "Empty string: should return nil (unchanged)")
end

-- 12) Numbers at beginning and end
do
  local elem = make_elem("7年後の99")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Numbers at edges: should return three elements")
  assert_equal(arr[1].t, "Str", "Numbers at edges: first element type")
  assert_equal(arr[1].text, "７", "Numbers at edges: first text - full-width 7")
  assert_equal(arr[2].t, "Str", "Numbers at edges: second element type")
  assert_equal(arr[2].text, "年後の", "Numbers at edges: second text")
  assert_equal(arr[3].t, "RawInline", "Numbers at edges: third element type")
  assert_equal(arr[3].text, "{\\small\\tatechuyoko*{99}}", "Numbers at edges: tatechuyoko for 99")
end

-- 13) Only numbers
do
  local elem = make_elem("99")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Only 2-digit number: should return single element")
  assert_equal(arr[1].t, "RawInline", "Only 2-digit number: element type")
  assert_equal(arr[1].text, "{\\small\\tatechuyoko*{99}}", "Only 2-digit number: tatechuyoko")
end

-- Summary
if fails == 0 then
  print(("OK - %d assertions"):format(tests_run))
  os.exit(0)
else
  io.stderr:write(("FAILED - %d failed, %d total assertions\n"):format(fails, tests_run))
  os.exit(1)
end