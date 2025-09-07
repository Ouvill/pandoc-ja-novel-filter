-- dakuten.lua - Spec
-- Purpose:
--   Convert a base character followed by a voiced sound mark to LaTeX \dakuten{...}.
--   Supports both the combining dakuten (U+3099) and the standalone mark (U+309B "゛").
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Scans elem.text and replaces each occurrence of:
--       <UTF-8 char> + U+3099  (combining dakuten)
--       <UTF-8 char> + U+309B  (voiced mark "゛")
--     with RawInline('latex', "\\dakuten{<UTF-8 char>}").
--   - Non-matching segments remain as Str.
--   - Returns:
--       nil when there’s no target (so upstream keeps elem unchanged),
--       a single Inline when exactly one chunk is produced,
--       or an array of Inlines when split is required.
-- Rationale for early nil:
--   Keeps composition-friendly semantics among multiple filters.
-- Edge cases:
--   - Empty string: returns nil (no change).
--   - Precomposed kana like "が" are NOT changed (no decomposition performed).
--   - Works with 1–4 byte UTF-8 base characters.
-- Interactions:
--   - Should run before filters that could restructure Str content unrelatedly.
-- Examples:
--   "あ\227\130\153" (あ + U+3099) => \dakuten{あ}
--   "あ\227\130\155" (あ + U+309B) => \dakuten{あ}

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

-- Dakuten character constants
local COMBINING_DAKUTEN = "\227\130\153"  -- U+3099
local VOICED_MARK = "\227\130\155"         -- U+309B "゛"
local UTF8_CHAR_PATTERN = "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

local function process_dakuten_text(text)
  if not text:find(COMBINING_DAKUTEN) and not text:find(VOICED_MARK) then
    return nil
  end

  local pattern_comb = "(" .. UTF8_CHAR_PATTERN .. ")" .. COMBINING_DAKUTEN
  local pattern_mark = "(" .. UTF8_CHAR_PATTERN .. ")" .. VOICED_MARK

  local new_elems = {}
  local s = text
  
  while true do
    local c_s, c_e, c_base = s:find(pattern_comb)
    local m_s, m_e, m_base = s:find(pattern_mark)
    local m_start, m_end, base_char
    
    if c_s and m_s then
      if c_s <= m_s then
        m_start, m_end, base_char = c_s, c_e, c_base
      else
        m_start, m_end, base_char = m_s, m_e, m_base
      end
    elseif c_s then
      m_start, m_end, base_char = c_s, c_e, c_base
    elseif m_s then
      m_start, m_end, base_char = m_s, m_e, m_base
    end

    if not m_start then
      if #s > 0 then
        table.insert(new_elems, pandoc.Str(s))
      end
      break
    end

    if m_start > 1 then
      table.insert(new_elems, pandoc.Str(s:sub(1, m_start - 1)))
    end

    table.insert(new_elems, utils.latex_inline("\\dakuten{" .. base_char .. "}"))
    s = s:sub(m_end + 1)
  end

  return new_elems
end

local function dakuten_Str(elem)
  return utils.process_str_element(elem, process_dakuten_text)
end

return utils.latex_only_filter({
  Str = dakuten_Str,
})
