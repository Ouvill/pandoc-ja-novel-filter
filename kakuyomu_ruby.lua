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

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

local function make_ruby(base, yomi)
  return utils.latex_inline(string.format('\\ruby[g]{%s}{%s}', base, yomi))
end

local function process_ruby_text(text)
  if not text:find('《', 1, true) or not text:find('》', 1, true) then 
    return nil 
  end

  local out = {}
  local i = 1
  local text_len = #text
  local utf8 = utils.get_utf8()

  while i <= text_len do
    local ob = text:find('《', i, true)
    if not ob then
      table.insert(out, pandoc.Str(text:sub(i)))
      break
    end
    local cb = text:find('》', ob + #('《'), true)
    if not cb then
      table.insert(out, pandoc.Str(text:sub(i)))
      break
    end

    local ruby_text = text:sub(ob + #('《'), cb - 1)

    -- Determine base start/end
    local base_start, base_end
    -- Prefer explicit bar if present between i and ob-1
    local bar_full = utils.last_index_of(text, '｜', i, ob - 1)
    local bar_half = utils.last_index_of(text, '|', i, ob - 1)
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
        table.insert(out, pandoc.Str(text:sub(i, bar_pos - 1)))
      end
    else
      -- Implicit: Kanji-only trailing run immediately before ob
      if utf8 and utf8.offset and utf8.codepoint then
        local posb = ob - 1
        local start_byte = nil
        while posb > 0 do
          local cp_start = utf8.offset(text, -1, posb + 1)
          if not cp_start then break end
          local ch = text:sub(cp_start, posb)
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
            table.insert(out, pandoc.Str(text:sub(i, base_start - 1)))
          end
        end
      end
    end

    if base_start and base_start <= base_end then
      local base = text:sub(base_start, base_end)
      table.insert(out, make_ruby(base, ruby_text))
      i = cb + #('》')
    else
      -- Could not resolve base; output up to cb and continue
      table.insert(out, pandoc.Str(text:sub(i, cb)))
      i = cb + #('》')
    end
  end

  return out
end

local function ruby_Str(elem)
  return utils.process_str_element(elem, process_ruby_text)
end

return utils.latex_only_filter({
  Str = ruby_Str,
})
