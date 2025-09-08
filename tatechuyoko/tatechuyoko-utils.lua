-- tatechuyoko-utils.lua
-- Common utilities for tatechuyoko processing

local tatechuyoko_utils = {}

-- Generic tatechuyoko processor
-- pattern: Lua pattern for matching target characters
-- description: For debugging/comments
function tatechuyoko_utils.create_tatechuyoko_filter(pattern, description)
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
          -- Exactly 2 consecutive characters - group them
          table.insert(result, pandoc.RawInline('latex', string.format('{\\small\\tatechuyoko*{%s}}', sequence)))
        else
          -- 1 char or 3+ chars - handle each character individually
          for k = i, j - 1 do
            local single_char = text:sub(k, k)
            table.insert(result, pandoc.RawInline('latex', string.format('\\tatechuyoko*{%s}', single_char)))
          end
        end
        
        i = j
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

return tatechuyoko_utils