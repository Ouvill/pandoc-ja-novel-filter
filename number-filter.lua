-- number-filter.lua - Spec
-- Purpose:
--   Convert half-width numbers according to custom project rules:
--   - 2-digit numbers: wrap with {\small\tatechuyoko{XX}}
--   - 1-digit or 3+ digit numbers: convert to full-width equivalents
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Scans elem.text for sequences of ASCII digits (0-9)
--   - 2-digit sequences get wrapped with RawInline('latex', "{\small\tatechuyoko{XX}}")
--   - Other digit sequences convert each digit to full-width equivalent
--   - Non-matching segments remain as Str
--   - Returns nil when no digits found, single Inline for one chunk, array for multiple chunks
-- Examples:
--   "5" -> "５"
--   "12" -> {\small\tatechuyoko{12}}
--   "123" -> "１２３"
--   "今日は12月3日です" -> "今日は{\small\tatechuyoko{12}}月３日です"

-- Only for LaTeX output
if not FORMAT:match('latex') then return {} end

-- Full-width digit conversion table
local halfwidth_to_fullwidth = {
  ['0'] = '０', ['1'] = '１', ['2'] = '２', ['3'] = '３', ['4'] = '４',
  ['5'] = '５', ['6'] = '６', ['7'] = '７', ['8'] = '８', ['9'] = '９'
}

local function convert_to_fullwidth(digits)
  local result = ""
  for i = 1, #digits do
    local digit = digits:sub(i, i)
    result = result .. (halfwidth_to_fullwidth[digit] or digit)
  end
  return result
end

local function make_tatechuyoko(digits)
  return pandoc.RawInline('latex', string.format('{\\small\\tatechuyoko{%s}}', digits))
end

local function number_Str(elem)
  local s = elem.text
  
  -- Check if there are any digits
  if not s:find('[0-9]') then
    return nil
  end
  
  local out = {}
  local i = 1
  local N = #s
  
  while i <= N do
    -- Find next digit sequence
    local digit_start = s:find('[0-9]', i)
    if not digit_start then
      -- No more digits, add remaining text
      if i <= N then
        table.insert(out, pandoc.Str(s:sub(i)))
      end
      break
    end
    
    -- Add text before digits
    if digit_start > i then
      table.insert(out, pandoc.Str(s:sub(i, digit_start - 1)))
    end
    
    -- Find end of digit sequence
    local digit_end = digit_start
    while digit_end <= N and s:sub(digit_end, digit_end):match('[0-9]') do
      digit_end = digit_end + 1
    end
    digit_end = digit_end - 1
    
    local digits = s:sub(digit_start, digit_end)
    local digit_count = #digits
    
    if digit_count == 2 then
      -- 2-digit: wrap with \small{\tatechuyoko{}}
      table.insert(out, make_tatechuyoko(digits))
    else
      -- 1-digit or 3+ digits: convert to full-width
      table.insert(out, pandoc.Str(convert_to_fullwidth(digits)))
    end
    
    i = digit_end + 1
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
  Str = number_Str,
}