-- kakuyomu_ruby_test.lua
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  RawInline = function(fmt, s) return { t = 'RawInline', format = fmt, text = s } end,
}
_G.pandoc = pandoc
local filter = dofile((... and (...):gsub("[^/\\]+$", "kakuyomu_ruby.lua")) or "kakuyomu_ruby.lua")
local Str = filter[1].Str

local fails, tests = 0, 0
local function assert_eq(a, b, msg)
  tests = tests + 1
  if a ~= b then
    fails = fails + 1
    io.stderr:write("FAIL: ", msg or "", "\n  expected: ", tostring(b), "\n  actual:   ", tostring(a), "\n")
  end
end
local function assert_true(c, msg)
  tests = tests + 1
  if not c then fails = fails + 1; io.stderr:write("FAIL: ", msg or "", "\n") end
end

local function flatten(x)
  if x == nil then return nil end
  if type(x) == 'table' and x.t then return { x } end
  return x
end

-- 1) Implicit: Kanji-only base
do
  local input = { t='Str', text = '冴えない彼女《ヒロイン》の育てかた' }
  local out = Str(input)
  local arr = flatten(out)
  assert_true(#arr >= 1, 'implicit: should produce at least one element')
  local combined = {}
  for _, e in ipairs(arr) do
    if e.t == 'Str' then table.insert(combined, e.text)
    elseif e.t == 'RawInline' and e.format == 'latex' then table.insert(combined, e.text)
    end
  end
  local text = table.concat(combined)
  assert_true(text:find('\\ruby{彼女}{ヒロイン}'), 'implicit: ruby command present')
end

-- 2) Explicit: fullwidth bar ｜
do
  local input = { t='Str', text = 'あいつの｜etc《えとせとら》' }
  local out = Str(input)
  local arr = flatten(out)
  local text = ''
  for _, e in ipairs(arr) do
    if e.t == 'Str' then text = text .. e.text
    elseif e.t == 'RawInline' and e.format == 'latex' then text = text .. e.text
    end
  end
  assert_true(text:find('\\ruby{etc}{えとせとら}'), 'explicit fullwidth bar: ruby command')
end

-- 3) Explicit: halfwidth bar |
do
  local input = { t='Str', text = 'この際｜紅蓮の炎《ヘルフレイム》に焼かれて果てろ！' }
  local out = Str(input)
  local arr = flatten(out)
  local text = ''
  for _, e in ipairs(arr) do
    if e.t == 'Str' then text = text .. e.text
    elseif e.t == 'RawInline' and e.format == 'latex' then text = text .. e.text
    end
  end
  assert_true(text:find('\\ruby{紅蓮の炎}{ヘルフレイム}'), 'explicit bar: ruby command')
end

if fails == 0 then
  print(('OK - %d assertions'):format(tests))
  os.exit(0)
else
  io.stderr:write(('FAILED - %d failed, %d total assertions\n'):format(fails, tests))
  os.exit(1)
end
