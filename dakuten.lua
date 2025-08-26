-- Returns a filter table compatible with Pandoc.
local function dakuten_Str(elem)
  if not FORMAT:match('latex') then return nil end

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

  if not elem.text:find(combining_dakuten) then
    return nil
  end

  local new_elems = {}
  local s = elem.text
  while true do
    local m_start, m_end, base_char = s:find(pattern)

    if not m_start then
      if #s > 0 then
        table.insert(new_elems, pandoc.Str(s))
      end
      break
    end

    if m_start > 1 then
      table.insert(new_elems, pandoc.Str(s:sub(1, m_start - 1)))
    end

    local latex_command = "\\dakuten{" .. base_char .. "}"
    table.insert(new_elems, pandoc.RawInline('latex', latex_command))

    s = s:sub(m_end + 1)
  end

  if #new_elems == 0 then
    return pandoc.Str('')
  elseif #new_elems == 1 then
    return new_elems[1]
  else
    return new_elems
  end
end

return {
  Str = dakuten_Str,
}
