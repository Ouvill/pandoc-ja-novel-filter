-- kakuyomu_ruby.lua - Spec
-- Purpose:
--   Convert Kakuyomu-style ruby annotations to LaTeX pxrubrica's \ruby[g]{base}{ruby}.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Supported input forms:
--   A) Implicit base (kanji-only): <...KANJI_RUN>《yomi》
--      - The base is the longest contiguous kanji run right before 《》.
--   B) Explicit base marker: ｜base《yomi》 or |base《yomi》
--      - base may include non-kanji.
-- Behavior:
--   - Replaces the matched base+reading with RawInline('latex', "\\ruby[g]{base}{yomi}").
--   - Preserves surrounding text as Str and supports multiple occurrences per Str.
-- Returns:
--   - nil when there’s no 《》 pair; Inline/Inline[] when transformed.
-- Edge cases:
--   - Unbalanced brackets: leaves text unchanged for that segment.
--   - Implicit mode only matches CJK Unified Ideographs (U+3400–U+9FFF) and CJK Compatibility Ideographs (U+F900–U+FAFF).
-- Examples:
--   冴えない彼女《ヒロイン》 -> 冴えない\\ruby[g]{彼女}{ヒロイン}
--   あいつの｜etc《えとせとら》 -> あいつの\\ruby[g]{etc}{えとせとら}
--   この際｜紅蓮の炎《ヘルフレイム》に -> この際\\ruby[g]{紅蓮の炎}{ヘルフレイム}に

-- Only for LaTeX output
if not FORMAT:match('latex') then return {} end

local function make_ruby(base, yomi)
  return pandoc.RawInline('latex', string.format('\\ruby[g]{%s}{%s}', base, yomi))
end

-- Utilities
local function toText(e)
  if e.t == 'Str' then return e.text end
  return nil
end

-- We'll operate on Str elements and can return a list of inlines.
local function ruby_Str(elem)
  local s = elem.text
  if not s:find('《', 1, true) or not s:find('》', 1, true) then return elem end

  local function last_index_of(hay, needle, from, to_)
    local pos = from or 1
    local last = nil
    while true do
      local i = hay:find(needle, pos, true)
      if not i or (to_ and i > to_) then break end
      last = i
      pos = i + 1
    end
    return last
  end

  local out = {}
  local i = 1
  local N = #s
  local utf8 = rawget(_G, 'utf8') or {}

  while i <= N do
    local ob = s:find('《', i, true)
    if not ob then
      table.insert(out, pandoc.Str(s:sub(i)))
      break
    end
    local cb = s:find('》', ob + #('《'), true)
    if not cb then
      table.insert(out, pandoc.Str(s:sub(i)))
      break
    end

    local ruby_text = s:sub(ob + #('《'), cb - 1)

    -- Determine base start/end
    local base_start, base_end
    -- Prefer explicit bar if present between i and ob-1
    local bar_full = last_index_of(s, '｜', i, ob - 1)
    local bar_half = last_index_of(s, '|', i, ob - 1)
    local bar_pos, bar_len
    if bar_full and (not bar_half or bar_full > bar_half) then
      bar_pos, bar_len = bar_full, #('｜')
    elseif bar_half then
      bar_pos, bar_len = bar_half, 1
    end
    if bar_pos then
      base_start = bar_pos + bar_len
      base_end = ob - 1
      -- Emit text before bar
      if bar_pos > i then
        table.insert(out, pandoc.Str(s:sub(i, bar_pos - 1)))
      end
    else
      -- Implicit: Kanji-only trailing run immediately before ob
      if utf8 and utf8.offset and utf8.codepoint then
        local posb = ob - 1
        local start_byte = nil
        while posb > 0 do
          local cp_start = utf8.offset(s, -1, posb + 1)
          if not cp_start then break end
          local ch = s:sub(cp_start, posb)
          local ucp = utf8.codepoint(ch)
          local is_kanji = (ucp >= 0x3400 and ucp <= 0x9FFF) or (ucp >= 0xF900 and ucp <= 0xFAFF)
          if is_kanji then
            start_byte = cp_start
            posb = cp_start - 1
          else
            break
          end
        end
        if start_byte then
          base_start = start_byte
          base_end = ob - 1
          if base_start > i then
            table.insert(out, pandoc.Str(s:sub(i, base_start - 1)))
          end
        end
      end
    end

    if base_start and base_start <= base_end then
      local base = s:sub(base_start, base_end)
      table.insert(out, make_ruby(base, ruby_text))
      i = cb + #('》')
    else
      -- Could not resolve base; output up to cb and continue
      table.insert(out, pandoc.Str(s:sub(i, cb)))
      i = cb + #('》')
    end
  end

  if #out == 1 then return out[1] end
  return out
end

return {
  Str = ruby_Str,
}
