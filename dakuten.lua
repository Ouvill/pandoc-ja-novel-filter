-- dakuten.lua
-- Converts characters with combining dakuten (e.g., "あ゙") to a LaTeX command.
-- For example, "あ゙" becomes "\dakuten{あ}".
-- This filter is intended for LaTeX output.

if FORMAT:match 'latex' then
  function Str(elem)
    -- The combining dakuten (濁点) is U+3099.
    -- In UTF-8, this is E3 82 99.
    -- In Lua string escapes, this is \227\130\153.
    local combining_dakuten = "\227\130\153"

    -- Pattern to match one UTF-8 character.
    -- This covers ASCII, and multi-byte characters.
    local utf8_char = "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

    -- The full pattern to find is a UTF-8 character followed by a combining dakuten.
    -- We capture the base character.
    local pattern = "(" .. utf8_char .. ")" .. combining_dakuten

    -- We only need to process the string if it contains a combining dakuten.
    if elem.text:find(combining_dakuten) then
      local new_elems = {}
      local s = elem.text
      while true do
        -- Find the next occurrence of the pattern.
        local m_start, m_end, base_char = s:find(pattern)

        if not m_start then
          -- No more matches, add the rest of the string if it's not empty.
          if #s > 0 then
            table.insert(new_elems, pandoc.Str(s))
          end
          break
        end

        -- Add the text before the match, if any.
        if m_start > 1 then
          table.insert(new_elems, pandoc.Str(s:sub(1, m_start - 1)))
        end

        -- Create the LaTeX command as a RawInline element
        -- to prevent Pandoc from escaping the backslash.
        local latex_command = "\\dakuten{" .. base_char .. "}"
        table.insert(new_elems, pandoc.RawInline('latex', latex_command))

        -- Continue searching from the character after the match.
        s = s:sub(m_end + 1)
      end

      if #new_elems > 1 then
        return new_elems
      elseif #new_elems == 1 then
        return new_elems[1]
      else
        return pandoc.Str('')
      end
    end
    -- If no combining dakuten was found, return the element unchanged.
    return elem
  end
end
