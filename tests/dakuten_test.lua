-- test_dakuten.lua
-- Minimal unit tests for dakuten.lua without requiring pandoc binary.

-- Arrange: stub pandoc environment and load filter
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  RawInline = function(fmt, s) return { t = 'RawInline', format = fmt, text = s } end,
}
_G.pandoc = pandoc
local filter = dofile((... and (...):gsub("[^/\\]+$", "dakuten.lua")) or "dakuten.lua")
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

local dakuten = "\227\130\153" -- U+3099 combining dakuten
local voiced = "\227\130\155"  -- U+309B voiced sound mark (゛)

-- Tests

-- 1) No dakuten: unchanged (nil)
do
  local elem = make_elem("ただのテキスト")
  local out = Str(elem)
  assert_true(out == nil, "No combining dakuten: should return nil (unchanged)")
end

-- 2) Single combining dakuten: あ + U+3099 -> \dakuten{あ}
do
  local input = "あ" .. dakuten
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Single combining: should return a single element")
  assert_equal(arr[1].t, "RawInline", "Single combining: element type should be RawInline")
  assert_equal(arr[1].format, "latex", "Single combining: RawInline format should be latex")
  assert_equal(arr[1].text, "\\dakuten{あ}", "Single combining: latex text mismatch")
end

-- 2b) Single voiced mark: あ + ゛(U+309B) -> \dakuten{あ}
do
  local input = "あ" .. voiced
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Single voiced mark: should return a single element")
  assert_equal(arr[1].t, "RawInline", "Single voiced mark: element type should be RawInline")
  assert_equal(arr[1].format, "latex", "Single voiced mark: RawInline format should be latex")
  assert_equal(arr[1].text, "\\dakuten{あ}", "Single voiced mark: latex text mismatch")
end

-- 3) Multiple occurrences: がぎ -> \dakuten{か}\dakuten{き}
do
  local input = "か" .. dakuten .. "き" .. dakuten
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 2, "Multiple combining: should return two elements")
  assert_equal(arr[1].t, "RawInline", "Multiple combining: first element type")
  assert_equal(arr[1].text, "\\dakuten{か}", "Multiple combining: first latex text")
  assert_equal(arr[2].t, "RawInline", "Multiple combining: second element type")
  assert_equal(arr[2].text, "\\dakuten{き}", "Multiple combining: second latex text")
end

-- 4) Mixed with surrounding text: "A" .. あ゙ .. "B"
do
  local input = "A" .. "あ" .. dakuten .. "B"
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Mixed text: should return three elements")
  assert_equal(arr[1].t, "Str", "Mixed text: first element type")
  assert_equal(arr[1].text, "A", "Mixed text: first text")
  assert_equal(arr[2].t, "RawInline", "Mixed text: second element type")
  assert_equal(arr[2].text, "\\dakuten{あ}", "Mixed text: second latex text")
  assert_equal(arr[3].t, "Str", "Mixed text: third element type")
  assert_equal(arr[3].text, "B", "Mixed text: third text")
  assert_equal(concat_text(out), "A\\dakuten{あ}B", "Mixed text: concatenated output mismatch")
end

-- 4b) Mixed with voiced mark: "A" .. あ゛ .. "B"
do
  local input = "A" .. "あ" .. voiced .. "B"
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Mixed voiced: should return three elements")
  assert_equal(arr[1].t, "Str", "Mixed voiced: first element type")
  assert_equal(arr[1].text, "A", "Mixed voiced: first text")
  assert_equal(arr[2].t, "RawInline", "Mixed voiced: second element type")
  assert_equal(arr[2].text, "\\dakuten{あ}", "Mixed voiced: second latex text")
  assert_equal(arr[3].t, "Str", "Mixed voiced: third element type")
  assert_equal(arr[3].text, "B", "Mixed voiced: third text")
end

-- 5) Precomposed kana (が) should be unchanged
do
  local elem = make_elem("が")
  local out = Str(elem)
  assert_true(out == nil, "Precomposed kana: should return nil (unchanged)")
end

-- 6) Empty string: unchanged
do
  local elem = make_elem("")
  local out = Str(elem)
  assert_true(out == nil, "Empty string: should return nil (unchanged)")
end

-- 7) Lone combining dakuten: returns Str with same text (new object)
do
  local lone = dakuten
  local elem = make_elem(lone)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Lone combining: should return single element")
  assert_equal(arr[1].t, "Str", "Lone combining: element type should be Str")
  assert_equal(arr[1].text, lone, "Lone combining: text should be unchanged")
end

-- 8) 4-byte UTF-8 base char + U+3099 -> \dakuten{base}
do
  local base4 = "𠀋" -- U+2000B (4-byte in UTF-8)
  local input = base4 .. dakuten
  local elem = make_elem(input)
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "4-byte base: should return a single element")
  assert_equal(arr[1].t, "RawInline", "4-byte base: element type should be RawInline")
  assert_equal(arr[1].format, "latex", "4-byte base: RawInline format should be latex")
  assert_equal(arr[1].text, "\\dakuten{" .. base4 .. "}", "4-byte base: latex text mismatch")
end

-- Summary
if fails == 0 then
  print(("OK - %d assertions"):format(tests_run))
  os.exit(0)
else
  io.stderr:write(("FAILED - %d failed, %d total assertions\n"):format(fails, tests_run))
  os.exit(1)
end
