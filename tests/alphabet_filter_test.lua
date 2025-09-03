-- alphabet_filter_test.lua
-- Unit tests for alphabet-filter.lua

-- Arrange: stub pandoc environment and load filter
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  RawInline = function(fmt, s) return { t = 'RawInline', format = fmt, text = s } end,
}
_G.pandoc = pandoc
local filter = dofile((... and (...):gsub("[^/\\]+$", "alphabet-filter.lua")) or "alphabet-filter.lua")
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

local function make_elem(s)
  return { t = 'Str', text = s }
end

-- Tests

-- 1) No ASCII letters or symbols: unchanged (nil)
do
  local elem = make_elem("ただの日本語テキスト123")
  local out = Str(elem)
  assert_true(out == nil, "No ASCII letters: should return nil (unchanged)")
end

-- 2) Single letter: unchanged (nil)
do
  local elem = make_elem("A")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Single letter: should return a single element")
  assert_equal(arr[1].t, "Str", "Single letter: element type should be Str")
  assert_equal(arr[1].text, "A", "Single letter: should remain unchanged")
end

-- 3) Two letters: unchanged
do
  local elem = make_elem("AB")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Two letters: should return a single element")
  assert_equal(arr[1].t, "Str", "Two letters: element type should be Str")
  assert_equal(arr[1].text, "AB", "Two letters: should remain unchanged")
end

-- 4) Exactly three letters: convert to full-width
do
  local elem = make_elem("ABC")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Three letters: should return a single element")
  assert_equal(arr[1].t, "Str", "Three letters: element type should be Str")
  assert_equal(arr[1].text, "ＡＢＣ", "Three letters: should convert to full-width")
end

-- 5) Four letters: unchanged
do
  local elem = make_elem("ABCD")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Four letters: should return a single element")
  assert_equal(arr[1].t, "Str", "Four letters: element type should be Str")
  assert_equal(arr[1].text, "ABCD", "Four letters: should remain unchanged")
end

-- 6) Five letters: unchanged
do
  local elem = make_elem("ABCDE")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Five letters: should return a single element")
  assert_equal(arr[1].t, "Str", "Five letters: element type should be Str")
  assert_equal(arr[1].text, "ABCDE", "Five letters: should remain unchanged")
end

-- 7) Mixed case three letters: convert to full-width
do
  local elem = make_elem("aBc")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Mixed case three letters: should return a single element")
  assert_equal(arr[1].t, "Str", "Mixed case three letters: element type should be Str")
  assert_equal(arr[1].text, "ａＢｃ", "Mixed case three letters: should convert to full-width")
end

-- 8) Three symbols: convert to full-width
do
  local elem = make_elem("!@#")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Three symbols: should return a single element")
  assert_equal(arr[1].t, "Str", "Three symbols: element type should be Str")
  assert_equal(arr[1].text, "！＠＃", "Three symbols: should convert to full-width")
end

-- 9) Mixed letters and symbols (3 chars): convert to full-width
do
  local elem = make_elem("A@B")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Mixed 3 chars: should return a single element")
  assert_equal(arr[1].t, "Str", "Mixed 3 chars: element type should be Str")
  assert_equal(arr[1].text, "Ａ＠Ｂ", "Mixed 3 chars: should convert to full-width")
end

-- 10) Text with embedded 3-char sequence
do
  local elem = make_elem("今日はABCです")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Embedded 3-char: should return three elements")
  assert_equal(arr[1].t, "Str", "Embedded 3-char: first element type")
  assert_equal(arr[1].text, "今日は", "Embedded 3-char: first text")
  assert_equal(arr[2].t, "Str", "Embedded 3-char: second element type")
  assert_equal(arr[2].text, "ＡＢＣ", "Embedded 3-char: second text should be full-width")
  assert_equal(arr[3].t, "Str", "Embedded 3-char: third element type")
  assert_equal(arr[3].text, "です", "Embedded 3-char: third text")
end

-- 11) Multiple sequences with different lengths
do
  local elem = make_elem("AB ABC ABCD")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 5, "Multiple sequences: should return five elements")
  assert_equal(arr[1].t, "Str", "Multiple sequences: first element type")
  assert_equal(arr[1].text, "AB", "Multiple sequences: first text (2 chars, unchanged)")
  assert_equal(arr[2].t, "Str", "Multiple sequences: second element type")
  assert_equal(arr[2].text, " ", "Multiple sequences: second text (space)")
  assert_equal(arr[3].t, "Str", "Multiple sequences: third element type")
  assert_equal(arr[3].text, "ＡＢＣ", "Multiple sequences: third text (3 chars, full-width)")
  assert_equal(arr[4].t, "Str", "Multiple sequences: fourth element type")
  assert_equal(arr[4].text, " ", "Multiple sequences: fourth text (space)")
  assert_equal(arr[5].t, "Str", "Multiple sequences: fifth element type")
  assert_equal(arr[5].text, "ABCD", "Multiple sequences: fifth text (4 chars, unchanged)")
end

-- 12) Sequential different-length sequences
do
  local elem = make_elem("AABCDDDD")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Sequential sequences: should return one element")
  assert_equal(arr[1].t, "Str", "Sequential sequences: element type")
  assert_equal(arr[1].text, "AABCDDDD", "Sequential sequences: 8 chars should remain unchanged")
end

-- 13) Numbers should not be converted (they have their own filter)
do
  local elem = make_elem("123")
  local out = Str(elem)
  assert_true(out == nil, "Numbers only: should return nil (unchanged)")
end

-- 14) Mixed numbers and letters: numbers are handled by separate filter
do
  local elem = make_elem("A1B")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 3, "Mixed letters and numbers: should return three elements")
  assert_equal(arr[1].text, "A", "Mixed: first char should remain unchanged (1 char)")
  assert_equal(arr[2].text, "1", "Mixed: middle should be unchanged number")
  assert_equal(arr[3].text, "B", "Mixed: last char should remain unchanged (1 char)")
end

-- 15) Edge case: empty string
do
  local elem = make_elem("")
  local out = Str(elem)
  assert_true(out == nil, "Empty string: should return nil (unchanged)")
end

-- 16) Only spaces
do
  local elem = make_elem("   ")
  local out = Str(elem)
  assert_true(out == nil, "Only spaces: should return nil (unchanged)")
end

-- 17) All uppercase alphabet (26 chars): unchanged
do
  local elem = make_elem("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
  local out = Str(elem)
  local arr = flatten(out)
  assert_len(arr, 1, "Full alphabet: should return one element")
  assert_equal(arr[1].text, "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "Full alphabet: should remain unchanged")
end

-- 18) Common 3-letter words
do
  local tests = {
    ["the"] = "ｔｈｅ",
    ["and"] = "ａｎｄ", 
    ["but"] = "ｂｕｔ",
    ["THE"] = "ＴＨＥ",
    ["API"] = "ＡＰＩ",
    ["URL"] = "ＵＲＬ"
  }
  for input, expected in pairs(tests) do
    local elem = make_elem(input)
    local out = Str(elem)
    local arr = flatten(out)
    assert_len(arr, 1, "3-letter word " .. input .. ": should return single element")
    assert_equal(arr[1].text, expected, "3-letter word " .. input .. ": conversion")
  end
end

-- Summary
if fails == 0 then
  print(("OK - %d assertions"):format(tests_run))
  os.exit(0)
else
  io.stderr:write(("FAILED - %d failed, %d total assertions\n"):format(fails, tests_run))
  os.exit(1)
end