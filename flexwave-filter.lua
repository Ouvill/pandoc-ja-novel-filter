-- flexwave-filter.lua - Spec
-- Purpose:
--   Convert consecutive wave (〜) characters to LaTeX \flexwave{count}.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Single wave (〜) remains unchanged.
--   - Two or more consecutive waves become \flexwave{count}.
--   - Preserves surrounding text as Str; supports multiple occurrences per Str.
-- Examples:
--   〜        -> 〜 (変更なし)
--   〜〜      -> \flexwave{2}
--   〜〜〜    -> \flexwave{3}
--   あ〜〜いう -> あ\flexwave{2}いう

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

local function make_flexwave(count)
  return utils.latex_inline('\\flexwave{' .. count .. '}')
end

local function process_wave_text(text)
  if not text:find('〜', 1, true) then
    return nil
  end

  local result = {}
  local utf8 = utils.get_utf8()
  local i = 1
  local utf8_len = utf8.len and utf8.len(text) or #text

  while i <= utf8_len do
    local char_start, char_end, char

    if utf8.offset then
      char_start = utf8.offset(text, i)
      char_end = utf8.offset(text, i + 1)
      if char_end then
        char_end = char_end - 1
      else
        char_end = #text
      end
      char = text:sub(char_start, char_end)
    else
      -- Fallback for older Lua
      char = text:sub(i, i)
    end

    if char == "〜" then
      -- Find the end of consecutive waves
      local count = 0
      local j = i
      while j <= utf8_len do
        local next_char
        if utf8.offset then
          local next_start = utf8.offset(text, j)
          local next_end = utf8.offset(text, j + 1)
          if next_end then
            next_end = next_end - 1
          else
            next_end = #text
          end
          next_char = text:sub(next_start, next_end)
        else
          next_char = text:sub(j, j)
        end

        if next_char == "〜" then
          count = count + 1
          j = j + 1
        else
          break
        end
      end

      if count >= 2 then
        table.insert(result, make_flexwave(count))
      else
        table.insert(result, pandoc.Str("〜"))
      end
      i = j
    else
      table.insert(result, pandoc.Str(char))
      i = i + 1
    end
  end

  return result
end

local function flexwave_Str(elem)
  return utils.process_str_element(elem, process_wave_text)
end

return utils.latex_only_filter({
  Str = flexwave_Str,
})