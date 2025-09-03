-- alphabet-filter.lua - Spec
-- Purpose:
--   Convert sequences of half-width alphabetic characters and symbols according to Japanese typesetting rules:
--   - Exactly 3 characters: convert to full-width equivalents
--   - All other lengths (1, 2, 4+): keep as half-width
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Scans elem.text for sequences of ASCII letters (a-z, A-Z) and common symbols
--   - For exactly 3-character sequences: converts to full-width equivalents
--   - For other lengths: keeps as half-width
--   - Non-matching segments remain as Str
--   - Returns nil when no conversion needed, single Inline for one chunk, array for multiple chunks
-- Examples:
--   "ABC" -> "ＡＢＣ" (3 chars -> full-width)
--   "AB" -> "AB" (2 chars -> unchanged)
--   "ABCD" -> "ABCD" (4 chars -> unchanged)
--   "test123ABC" -> "test123ＡＢＣ" (only 3-char sequence converted)

-- Only for LaTeX output
if not FORMAT:match('latex') then return {} end

-- Full-width character conversion table for ASCII letters and common symbols
local halfwidth_to_fullwidth = {
  -- Uppercase letters
  ['A'] = 'Ａ', ['B'] = 'Ｂ', ['C'] = 'Ｃ', ['D'] = 'Ｄ', ['E'] = 'Ｅ',
  ['F'] = 'Ｆ', ['G'] = 'Ｇ', ['H'] = 'Ｈ', ['I'] = 'Ｉ', ['J'] = 'Ｊ',
  ['K'] = 'Ｋ', ['L'] = 'Ｌ', ['M'] = 'Ｍ', ['N'] = 'Ｎ', ['O'] = 'Ｏ',
  ['P'] = 'Ｐ', ['Q'] = 'Ｑ', ['R'] = 'Ｒ', ['S'] = 'Ｓ', ['T'] = 'Ｔ',
  ['U'] = 'Ｕ', ['V'] = 'Ｖ', ['W'] = 'Ｗ', ['X'] = 'Ｘ', ['Y'] = 'Ｙ', ['Z'] = 'Ｚ',
  
  -- Lowercase letters
  ['a'] = 'ａ', ['b'] = 'ｂ', ['c'] = 'ｃ', ['d'] = 'ｄ', ['e'] = 'ｅ',
  ['f'] = 'ｆ', ['g'] = 'ｇ', ['h'] = 'ｈ', ['i'] = 'ｉ', ['j'] = 'ｊ',
  ['k'] = 'ｋ', ['l'] = 'ｌ', ['m'] = 'ｍ', ['n'] = 'ｎ', ['o'] = 'ｏ',
  ['p'] = 'ｐ', ['q'] = 'ｑ', ['r'] = 'ｒ', ['s'] = 'ｓ', ['t'] = 'ｔ',
  ['u'] = 'ｕ', ['v'] = 'ｖ', ['w'] = 'ｗ', ['x'] = 'ｘ', ['y'] = 'ｙ', ['z'] = 'ｚ',
  
  -- Common symbols
  ['!'] = '！', ['@'] = '＠', ['#'] = '＃', ['$'] = '＄', ['%'] = '％',
  ['^'] = '＾', ['&'] = '＆', ['*'] = '＊', ['('] = '（', [')'] = '）',
  ['-'] = '－', ['_'] = '＿', ['+'] = '＋', ['='] = '＝', ['['] = '［',
  [']'] = '］', ['{'] = '｛', ['}'] = '｝', ['|'] = '｜', ['\\'] = '＼',
  [':'] = '：', [';'] = '；', ['"'] = '＂', ["'"] = '＇', ['<'] = '＜',
  ['>'] = '＞', [','] = '，', ['.'] = '．', ['?'] = '？', ['/'] = '／'
}

local function convert_to_fullwidth(chars)
  local result = ""
  for i = 1, #chars do
    local char = chars:sub(i, i)
    result = result .. (halfwidth_to_fullwidth[char] or char)
  end
  return result
end

local function alphabet_Str(elem)
  local s = elem.text
  
  -- Check if there are any ASCII letters or symbols (excluding numbers)
  if not s:find('[A-Za-z!@#$%%^&*()%-_+={}|\\:";\'<>,.?/]') then
    return nil
  end
  
  local out = {}
  local i = 1
  local N = #s
  
  while i <= N do
    -- Find next sequence of ASCII letters and symbols (excluding numbers)
    local seq_start = s:find('[A-Za-z!@#$%%^&*()%-_+={}|\\:";\'<>,.?/]', i)
    if not seq_start then
      -- No more sequences, add remaining text
      if i <= N then
        table.insert(out, pandoc.Str(s:sub(i)))
      end
      break
    end
    
    -- Add text before sequence
    if seq_start > i then
      table.insert(out, pandoc.Str(s:sub(i, seq_start - 1)))
    end
    
    -- Find end of sequence (excluding numbers)
    local seq_end = seq_start
    while seq_end <= N and s:sub(seq_end, seq_end):match('[A-Za-z!@#$%%^&*()%-_+={}|\\:";\'<>,.?/]') do
      seq_end = seq_end + 1
    end
    seq_end = seq_end - 1
    
    local sequence = s:sub(seq_start, seq_end)
    local seq_length = #sequence
    
    if seq_length == 3 then
      -- Exactly 3 characters: convert to full-width
      table.insert(out, pandoc.Str(convert_to_fullwidth(sequence)))
    else
      -- Other lengths: keep as half-width
      table.insert(out, pandoc.Str(sequence))
    end
    
    i = seq_end + 1
  end
  
  if #out == 0 then
    return pandoc.Str('')
  elseif #out == 1 then
    return out[1]
  else
    return out
  end
end

return {
  Str = alphabet_Str,
}