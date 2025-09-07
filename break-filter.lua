-- break-filter.lua - Spec
-- Purpose:
--   Convert fenced div blocks with break class to LaTeX \vspace commands.
--   Provides a way to represent multiple consecutive blank lines in Markdown that
--   survive Pandoc's processing and create proper spacing in LaTeX output.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Div(elem) -> nil | pandoc.Block
-- Behavior:
--   - Detects Div blocks with class "break"
--   - Converts to LaTeX \vspace{N\baselineskip} where N is from data-lines attribute
--   - If data-lines is not specified or invalid, defaults to 1
-- Usage in Markdown:
--   ::: {.break data-lines="2"}
--   :::
--   
--   ::: {.break data-lines="3"}
--   :::
--   
--   ::: {.break}
--   :::
-- Examples:
--   ::: {.break data-lines="2"} becomes \vspace{2\baselineskip}
--   ::: {.break} becomes \vspace{1\baselineskip}

if not FORMAT:match('latex') then return {} end

local function break_Div(elem)
  local classes = elem.classes
  local attributes = elem.attributes
  
  -- Check if this div has the "break" class
  local has_break_class = false
  for _, class in ipairs(classes) do
    if class == "break" then
      has_break_class = true
      break
    end
  end
  
  if not has_break_class then return nil end
  
  -- Get the number of lines from data-lines attribute
  local lines = attributes["data-lines"]
  local num = 1 -- default
  
  if lines then
    local parsed_num = tonumber(lines)
    if parsed_num and parsed_num > 0 then
      num = parsed_num
    end
  end
  
  return pandoc.RawBlock('latex', string.format('\\vspace{%d\\baselineskip}', num))
end

return {
  Div = break_Div
}