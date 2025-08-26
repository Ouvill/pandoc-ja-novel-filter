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

-- Returns a filter table compatible with Pandoc.
local function dakuten_Str(elem)
  if not FORMAT:match('latex') then return nil end

  -- The combining dakuten (濁点) is U+3099.
  -- In UTF-8, this is E3 82 99.
  -- In Lua string escapes, this is \227\130\153.
  local combining_dakuten = "\227\130\153"
  -- The standalone voiced sound mark (゛) is U+309B.
  -- In UTF-8, this is E3 82 9B (Lua: \227\130\155).
  local voiced_mark = "\227\130\155"

  -- Pattern to match one UTF-8 character.
  -- This covers ASCII, and multi-byte characters.
  local utf8_char = "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

  -- Patterns to find: a UTF-8 character followed by either combining dakuten or voiced mark.
  -- We capture the base character.
  local pattern_comb = "(" .. utf8_char .. ")" .. combining_dakuten
  local pattern_mark = "(" .. utf8_char .. ")" .. voiced_mark

  if not elem.text:find(combining_dakuten) and not elem.text:find(voiced_mark) then
    return nil
  end

  local new_elems = {}
  local s = elem.text
  while true do
    -- Find earliest of the two patterns
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

    local latex_command = "\\dakuten{" .. base_char .. "}"
    table.insert(new_elems, pandoc.RawInline('latex', latex_command))

    s = s:sub(m_end + 1)
  end

  if #new_elems == 0 then
    return pandoc.Str('')
  elseif #new_elems == 1 then
    return new_elems[1]
  else
    return new_elems
  end
end

return {
  Str = dakuten_Str,
}
