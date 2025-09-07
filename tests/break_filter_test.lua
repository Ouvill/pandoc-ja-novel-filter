-- break_filter_test.lua
-- Unit tests for break-filter.lua without requiring pandoc binary.

-- Arrange: stub pandoc environment and load filter
FORMAT = 'latex'

local pandoc = {
  Str = function(s) return { t = 'Str', text = s } end,
  Para = function(content) return { t = 'Para', content = content } end,
  RawBlock = function(fmt, s) return { t = 'RawBlock', format = fmt, text = s } end,
  Pandoc = function(blocks, meta) return { t = 'Pandoc', blocks = blocks, meta = meta or {} } end,
}
_G.pandoc = pandoc
local filter = dofile((... and (...):gsub("[^/\\]+$", "break-filter.lua")) or "break-filter.lua")
local Pandoc = filter[1].Pandoc

-- Simple test framework
local fails = 0
local tests_run = 0

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

-- Helper functions
local function make_fullwidth_space_para(spaces)
  local content = { pandoc.Str(string.rep("　", spaces)) }
  return pandoc.Para(content)
end

local function make_text_para(text)
  local content = { pandoc.Str(text) }
  return pandoc.Para(content)
end

local function make_doc(blocks)
  return { blocks = blocks, meta = {} }
end

-- Tests

-- 1) Regular paragraph: unchanged
do
  local para = make_text_para("これは普通の段落です。")
  local doc = make_doc({ para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Regular paragraph: should have 1 block")
  assert_equal(result.blocks[1].t, "Para", "Regular paragraph: should remain Para")
  assert_equal(result.blocks[1].content[1].text, "これは普通の段落です。", "Regular paragraph: text should be unchanged")
end

-- 2) Single full-width space: convert to vspace
do
  local space_para = make_fullwidth_space_para(1)
  local doc = make_doc({ space_para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Single space: should have 1 block")
  assert_equal(result.blocks[1].t, "RawBlock", "Single space: should be RawBlock")
  assert_equal(result.blocks[1].format, "latex", "Single space: should be latex format")
  assert_equal(result.blocks[1].text, "\\vspace{1\\baselineskip}", "Single space: vspace command mismatch")
end

-- 3) Double full-width space: convert to vspace{2\baselineskip}
do
  local space_para = make_fullwidth_space_para(2)
  local doc = make_doc({ space_para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Double space: should have 1 block")
  assert_equal(result.blocks[1].t, "RawBlock", "Double space: should be RawBlock")
  assert_equal(result.blocks[1].text, "\\vspace{2\\baselineskip}", "Double space: vspace command mismatch")
end

-- 4) Triple full-width space: convert to vspace{3\baselineskip}
do
  local space_para = make_fullwidth_space_para(3)
  local doc = make_doc({ space_para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Triple space: should have 1 block")
  assert_equal(result.blocks[1].t, "RawBlock", "Triple space: should be RawBlock")
  assert_equal(result.blocks[1].text, "\\vspace{3\\baselineskip}", "Triple space: vspace command mismatch")
end

-- 5) Consecutive full-width space lines: combine total spaces
do
  local space1 = make_fullwidth_space_para(1)
  local space2 = make_fullwidth_space_para(2)
  local doc = make_doc({ space1, space2 })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Consecutive spaces: should combine to 1 block")
  assert_equal(result.blocks[1].t, "RawBlock", "Consecutive spaces: should be RawBlock")
  assert_equal(result.blocks[1].text, "\\vspace{3\\baselineskip}", "Consecutive spaces: should sum to 3 spaces")
end

-- 6) Mixed content: text + spaces + text
do
  local text1 = make_text_para("第一段落")
  local spaces = make_fullwidth_space_para(2)
  local text2 = make_text_para("第二段落")
  local doc = make_doc({ text1, spaces, text2 })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 3, "Mixed content: should have 3 blocks")
  assert_equal(result.blocks[1].t, "Para", "Mixed content: first should be Para")
  assert_equal(result.blocks[2].t, "RawBlock", "Mixed content: middle should be RawBlock")
  assert_equal(result.blocks[3].t, "Para", "Mixed content: last should be Para")
  assert_equal(result.blocks[2].text, "\\vspace{2\\baselineskip}", "Mixed content: vspace mismatch")
end

-- 7) Multiple consecutive groups of spaces
do
  local text1 = make_text_para("段落1")
  local space_group1a = make_fullwidth_space_para(1)
  local space_group1b = make_fullwidth_space_para(1)
  local text2 = make_text_para("段落2")
  local space_group2 = make_fullwidth_space_para(3)
  local text3 = make_text_para("段落3")
  
  local doc = make_doc({ text1, space_group1a, space_group1b, text2, space_group2, text3 })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 5, "Multiple groups: should have 5 blocks")
  assert_equal(result.blocks[2].text, "\\vspace{2\\baselineskip}", "Multiple groups: first group should sum to 2")
  assert_equal(result.blocks[4].text, "\\vspace{3\\baselineskip}", "Multiple groups: second group should be 3")
end

-- 8) Empty document
do
  local doc = make_doc({})
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 0, "Empty document: should remain empty")
end

-- 9) Only full-width spaces document
do
  local space1 = make_fullwidth_space_para(1)
  local space2 = make_fullwidth_space_para(2)
  local space3 = make_fullwidth_space_para(1)
  local doc = make_doc({ space1, space2, space3 })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Only spaces: should combine all to 1 block")
  assert_equal(result.blocks[1].text, "\\vspace{4\\baselineskip}", "Only spaces: should sum to 4")
end

-- 10) Mixed full-width space and text: should remain unchanged
do
  local mixed_content = { pandoc.Str("　これは文字も含みます") }
  local mixed_para = pandoc.Para(mixed_content)
  local doc = make_doc({ mixed_para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Mixed content: should have 1 block")
  assert_equal(result.blocks[1].t, "Para", "Mixed content: should remain Para")
  assert_equal(result.blocks[1].content[1].text, "　これは文字も含みます", "Mixed content: text should be unchanged")
end

-- 11) Full-width spaces at start of text: should remain unchanged
do
  local mixed_content = { pandoc.Str("　　文字も含む行") }
  local mixed_para = pandoc.Para(mixed_content)
  local doc = make_doc({ mixed_para })
  local result = Pandoc(doc)
  
  assert_len(result.blocks, 1, "Spaces with text: should have 1 block")
  assert_equal(result.blocks[1].t, "Para", "Spaces with text: should remain Para")
  assert_equal(result.blocks[1].content[1].text, "　　文字も含む行", "Spaces with text: should be unchanged")
end

-- Summary
if fails == 0 then
  print(("OK - %d assertions"):format(tests_run))
  os.exit(0)
else
  io.stderr:write(("FAILED - %d failed, %d total assertions\n"):format(fails, tests_run))
  os.exit(1)
end