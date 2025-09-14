-- flexchoon-filter.lua - Spec
-- Purpose:
--   Convert consecutive choon (ー) characters to LaTeX \flexchoon{count}.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Single choon (ー) remains unchanged.
--   - Two or more consecutive choon become \flexchoon{count}.
--   - Preserves surrounding text as Str; supports multiple occurrences per Str.
-- Examples:
--   ー        -> ー (変更なし)
--   ーー      -> \flexchoon{2}
--   ーーー    -> \flexchoon{3}
--   あーーいう -> あ\flexchoon{2}いう

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

local function make_flexchoon(count)
  return utils.latex_inline('\\flexchoon{' .. count .. '}')
end

local function process_choon_text(text)
  if not text:find('ー', 1, true) then
    return nil
  end

  local result = {}
  local utf8 = utils.get_utf8()
  local chars = {}

  -- Convert to UTF-8 character array
  if utf8.codes and utf8.char then
    for p, c in utf8.codes(text) do
      table.insert(chars, utf8.char(c))
    end
  else
    -- Fallback for older Lua
    for i = 1, #text do
      table.insert(chars, text:sub(i, i))
    end
  end

  local i = 1
  while i <= #chars do
    if chars[i] == "ー" then
      -- Count consecutive choons
      local count = 0
      local j = i
      while j <= #chars and chars[j] == "ー" do
        count = count + 1
        j = j + 1
      end

      if count >= 2 then
        table.insert(result, make_flexchoon(count))
      else
        table.insert(result, pandoc.Str("ー"))
      end
      i = j
    else
      -- Collect non-choon characters
      local text_part = ""
      while i <= #chars and chars[i] ~= "ー" do
        text_part = text_part .. chars[i]
        i = i + 1
      end
      if text_part ~= "" then
        table.insert(result, pandoc.Str(text_part))
      end
    end
  end

  return result
end

local function flexchoon_Str(elem)
  return utils.process_str_element(elem, process_choon_text)
end

return utils.latex_only_filter({
  Str = flexchoon_Str,
})