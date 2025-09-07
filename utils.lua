-- utils.lua
-- Common utilities for pandoc novel filters
-- Purpose: Reduce code duplication and standardize common operations

local utils = {}

-- Check if the current output format is LaTeX
function utils.is_latex()
  return FORMAT and FORMAT:match('latex')
end

-- Early return helper for non-LaTeX formats
function utils.latex_only_filter(filter_table)
  if not utils.is_latex() then
    return {}
  end
  return filter_table
end

-- Process a string element with a transformation function
-- Returns nil if no changes, single element if one result, array if multiple
function utils.process_str_element(elem, transform_fn)
  if not elem or elem.t ~= 'Str' then
    return nil
  end
  
  local result = transform_fn(elem.text)
  
  if not result then
    return nil
  end
  
  if type(result) == 'string' then
    if result == elem.text then
      return nil -- No change
    end
    return pandoc.Str(result)
  end
  
  if type(result) == 'table' then
    if #result == 0 then
      return pandoc.Str('')
    elseif #result == 1 then
      return result[1]
    else
      return result
    end
  end
  
  return result
end

-- Find the last occurrence of a substring within a range
function utils.last_index_of(hay, needle, from, to_)
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

-- Create a LaTeX RawInline element
function utils.latex_inline(latex_code)
  return pandoc.RawInline('latex', latex_code)
end

-- Create a LaTeX RawBlock element
function utils.latex_block(latex_code)
  return pandoc.RawBlock('latex', latex_code)
end

-- Safely get UTF-8 functions with fallback
function utils.get_utf8()
  return rawget(_G, 'utf8') or {}
end

-- Standard pattern for processing text with markers
-- opener: opening marker (e.g., "《《")
-- closer: closing marker (e.g., "》》")
-- transform_fn: function to transform the content between markers
function utils.process_paired_markers(text, opener, closer, transform_fn)
  local opener_len = #opener
  local closer_len = #closer
  
  if not text:find(opener, 1, true) or not text:find(closer, 1, true) then
    return nil
  end
  
  local out = {}
  local i = 1
  local text_len = #text
  
  while i <= text_len do
    local open_pos = text:find(opener, i, true)
    if not open_pos then
      if i <= text_len then
        table.insert(out, pandoc.Str(text:sub(i)))
      end
      break
    end
    
    -- Add text before opener
    if open_pos > i then
      table.insert(out, pandoc.Str(text:sub(i, open_pos - 1)))
    end
    
    local close_pos = text:find(closer, open_pos + opener_len, true)
    if not close_pos then
      -- Unbalanced: add the rest as-is
      table.insert(out, pandoc.Str(text:sub(open_pos)))
      break
    end
    
    local content = text:sub(open_pos + opener_len, close_pos - 1)
    local transformed = transform_fn(content)
    if transformed then
      table.insert(out, transformed)
    end
    
    i = close_pos + closer_len
  end
  
  return out
end

return utils