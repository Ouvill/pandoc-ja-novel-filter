-- break_filter_test.lua
FORMAT = 'latex'

local pandoc = {
  RawBlock = function(format, text) return { t = 'RawBlock', format = format, text = text } end,
}
_G.pandoc = pandoc

local filter = dofile((... and (...):gsub("[^/\\]+$", "break-filter.lua")) or "break-filter.lua")
local Div = filter.Div

local fails, tests = 0, 0
local function assert_true(c, msg) tests=tests+1; if not c then fails=fails+1; io.stderr:write('FAIL: ',msg or '',"\n") end end
local function assert_eq(a,b,msg) tests=tests+1; if a~=b then fails=fails+1; io.stderr:write('FAIL: ',msg or '',"\n  expected: ",tostring(b),"\n  actual:   ",tostring(a),"\n") end end

-- Helper function to create a Div element
local function create_div(classes, attributes)
  return {
    t = 'Div',
    classes = classes or {},
    attributes = attributes or {}
  }
end

-- 1) Div with break class and data-lines="2"
do
  local input = create_div({"break"}, {["data-lines"] = "2"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with data-lines=2 produces output')
  assert_eq(out.format, 'latex', 'break div format is latex')
  assert_eq(out.text, '\\vspace{2\\baselineskip}', 'break div with data-lines=2 text correct')
end

-- 2) Div with break class and data-lines="3"
do
  local input = create_div({"break"}, {["data-lines"] = "3"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with data-lines=3 produces output')
  assert_eq(out.text, '\\vspace{3\\baselineskip}', 'break div with data-lines=3 text correct')
end

-- 3) Div with break class but no data-lines (default to 1)
do
  local input = create_div({"break"}, {})
  local out = Div(input)
  assert_true(out ~= nil, 'break div default produces output')
  assert_eq(out.text, '\\vspace{1\\baselineskip}', 'break div default text correct')
end

-- 4) Div with break class and invalid data-lines (should default to 1)
do
  local input = create_div({"break"}, {["data-lines"] = "abc"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with invalid data-lines produces output')
  assert_eq(out.text, '\\vspace{1\\baselineskip}', 'break div with invalid data-lines defaults to 1')
end

-- 5) Div with break class and zero data-lines (should default to 1)
do
  local input = create_div({"break"}, {["data-lines"] = "0"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with data-lines=0 produces output')
  assert_eq(out.text, '\\vspace{1\\baselineskip}', 'break div with data-lines=0 defaults to 1')
end

-- 6) Div without break class should return nil
do
  local input = create_div({"other-class"}, {["data-lines"] = "2"})
  local out = Div(input)
  assert_true(out == nil, 'div without break class returns nil')
end

-- 7) Div with break class among other classes
do
  local input = create_div({"some-class", "break", "another-class"}, {["data-lines"] = "5"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with multiple classes produces output')
  assert_eq(out.text, '\\vspace{5\\baselineskip}', 'break div with multiple classes text correct')
end

-- 8) Large number should work
do
  local input = create_div({"break"}, {["data-lines"] = "10"})
  local out = Div(input)
  assert_true(out ~= nil, 'break div with data-lines=10 produces output')
  assert_eq(out.text, '\\vspace{10\\baselineskip}', 'break div with data-lines=10 text correct')
end

if fails==0 then print(('OK - %d assertions'):format(tests)); os.exit(0) else io.stderr:write(('FAILED - %d failed, %d total assertions\n'):format(fails,tests)); os.exit(1) end