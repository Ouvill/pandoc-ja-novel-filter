-- combining-dakuten-filter.lua - Spec
-- Purpose:
--   Convert a base character followed by combining dakuten (U+3099) to LaTeX \dakuten{...}.
--   Only handles the combining dakuten, not the standalone voiced mark.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Scans elem.text and replaces each occurrence of:
--       <UTF-8 char> + U+3099  (combining dakuten)
--     with RawInline('latex', "\\dakuten{<UTF-8 char>}").
--   - Non-matching segments remain as Str.
--   - Returns:
--       nil when there's no target (so upstream keeps elem unchanged),
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

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

-- Combining dakuten character constant
local COMBINING_DAKUTEN = "\227\130\153"  -- U+3099
local UTF8_CHAR_PATTERN = "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

local function process_combining_dakuten_text(text)
  if not text:find(COMBINING_DAKUTEN) then
    return nil
  end

  local pattern = "(" .. UTF8_CHAR_PATTERN .. ")" .. COMBINING_DAKUTEN

  local new_elems = {}
  local s = text
  
  while true do
    local m_start, m_end, base_char = s:find(pattern)
    
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

local function combining_dakuten_Str(elem)
  return utils.process_str_element(elem, process_combining_dakuten_text)
end

return utils.latex_only_filter({
  Str = combining_dakuten_Str,
})