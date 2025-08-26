-- kenten_filter_test.lua
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  RawInline = function(fmt, s) return { t = 'RawInline', format = fmt, text = s } end,
}
_G.pandoc = pandoc

local filter = dofile((... and (...):gsub("[^/\\]+$", "kenten-filter.lua")) or "kenten-filter.lua")
local Str = filter.Str

local fails, tests = 0, 0
local function assert_true(c, msg) tests=tests+1; if not c then fails=fails+1; io.stderr:write('FAIL: ',msg or '',"\n") end end
local function assert_eq(a,b,msg) tests=tests+1; if a~=b then fails=fails+1; io.stderr:write('FAIL: ',msg or '',"\n  expected: ",tostring(b),"\n  actual:   ",tostring(a),"\n") end end

local function concat(out)
  if out == nil then return '' end
  if out.t then return out.text or '' end
  local s=''; for _,e in ipairs(out) do s=s..(e.text or '') end; return s
end

-- 1) Simple emphasis
do
  local input = { t='Str', text = 'おじいさんは山へ《《柴刈り》》に出かけました。' }
  local out = Str(input)
  local s = ''
  if out.t then s = out.text elseif out then for _,e in ipairs(out) do s = s .. (e.text or '') end end
  assert_true(s:find('\\kenten%{柴刈り%}'), 'simple: kenten emitted')
end

-- 2) Mixed text
do
  local input = { t='Str', text = 'A《《中点》》B《《圏点》》C' }
  local out = Str(input)
  local parts = {}
  if out.t then parts = { out } else parts = out end
  local latexes = {}
  for _,e in ipairs(parts) do if e.t=='RawInline' then table.insert(latexes, e.text) end end
  assert_eq(latexes[1], '\\kenten{中点}', 'mixed: first kenten')
  assert_eq(latexes[2], '\\kenten{圏点}', 'mixed: second kenten')
end

-- 3) Unbalanced: leave as-is
do
  local input = { t='Str', text = '未閉じ《《そのまま' }
  local out = Str(input)
  assert_true(out == nil or (out.t=='Str' and out.text=='未閉じ《《そのまま'), 'unbalanced: unchanged or same text')
end

if fails==0 then print(('OK - %d assertions'):format(tests)); os.exit(0) else io.stderr:write(('FAILED - %d failed, %d total assertions\n'):format(fails,tests)); os.exit(1) end
