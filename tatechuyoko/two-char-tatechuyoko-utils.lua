-- two-char-tatechuyoko-utils.lua
-- Two-character grouping utilities for tatechuyoko processing

local two_char_tatechuyoko_utils = {}

-- Two-character tatechuyoko processor
-- Only groups exactly 2 consecutive characters, leaves everything else unchanged
-- pattern: Lua pattern for matching target characters
-- description: For debugging/comments
function two_char_tatechuyoko_utils.create_two_char_tatechuyoko_filter(pattern, description)
  return function(elem)
    if FORMAT ~= "latex" then
      return nil
    end
    
    local text = elem.text
    if not text:find(pattern) then
      return nil
    end
    
    local result = {}
    local i = 1
    local len = #text
    
    while i <= len do
      local char = text:sub(i, i)
      
      if char:match(pattern) then
        -- Find the end of consecutive characters
        local j = i + 1
        while j <= len and text:sub(j, j):match(pattern) do
          j = j + 1
        end
        
        local sequence = text:sub(i, j - 1)
        local sequence_length = j - i
        
        if sequence_length == 2 then
          -- Exactly 2 consecutive characters - group them with {\small\tatechuyoko*{}}
          table.insert(result, pandoc.RawInline('latex', string.format('{\\small\\tatechuyoko*{%s}}', sequence)))
          i = j
        else
          -- Not exactly 2 characters - leave unchanged for other filters to handle
          table.insert(result, pandoc.Str(sequence))
          i = j
        end
      else
        -- Non-matching character - find end of non-matching sequence
        local non_matching = char
        local j = i + 1
        
        while j <= len and not text:sub(j, j):match(pattern) do
          non_matching = non_matching .. text:sub(j, j)
          j = j + 1
        end
        
        table.insert(result, pandoc.Str(non_matching))
        i = j
      end
    end
    
    return result
  end
end

-- Function to create a Span handler that preserves span elements unchanged
function two_char_tatechuyoko_utils.create_span_handler()
  return function(elem)
    -- Return span element unchanged to prevent processing of contents
    return elem
  end
end

return two_char_tatechuyoko_utils