-- break-filter.lua - Spec
-- Purpose:
--   Convert consecutive blank lines (3+) to LaTeX \vspace commands.
--   Handles scene transitions and spacing in novel formatting.
--   Formula: N = blank_lines - 2 (so 3 blank lines = 1\baselineskip, 4 = 2\baselineskip, etc.)
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Div(elem) -> nil | pandoc.Block
-- Behavior:
--   - Works with preprocessed markdown that converts blank lines to vspace divs
--   - Detects Div blocks with class "vspace" 
--   - Converts to LaTeX \vspace{N\baselineskip} where N is from data-lines attribute
--   - Also supports legacy "break" class for backward compatibility
-- Internal usage (created by pre-processor):
--   ::: {.vspace data-lines="2"}
--   :::
-- Examples:
--   4 consecutive blank lines -> vspace div with data-lines="2" -> \vspace{2\baselineskip}
--   3 consecutive blank lines -> vspace div with data-lines="1" -> \vspace{1\baselineskip}

if not FORMAT:match('latex') then return {} end

local function break_Div(elem)
  local classes = elem.classes
  local attributes = elem.attributes
  
  -- Check if this div has the "vspace" or "break" class (for backward compatibility)
  local has_vspace_class = false
  for _, class in ipairs(classes) do
    if class == "vspace" or class == "break" then
      has_vspace_class = true
      break
    end
  end
  
  if not has_vspace_class then return nil end
  
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