-- basic-tatechuyoko-utils.lua
-- Basic tatechuyoko utilities that process all characters individually

local basic_tatechuyoko_utils = {}

-- Basic tatechuyoko processor - processes all characters individually with \tatechuyoko*{}
-- pattern: Lua pattern for matching target characters
-- description: For debugging/comments
function basic_tatechuyoko_utils.create_basic_tatechuyoko_filter(pattern, description)
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
        -- Process each matching character individually
        table.insert(result, pandoc.RawInline('latex', string.format('\\tatechuyoko*{%s}', char)))
        i = i + 1
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
function basic_tatechuyoko_utils.create_span_handler()
  return function(elem)
    -- Return span element unchanged to prevent processing of contents
    return elem
  end
end

return basic_tatechuyoko_utils