-- kenten-filter.lua
-- Convert Kakuyomu emphasis marks 《《 ... 》》 into LaTeX \kenten{...}
-- Requires pxrubrica (\usepackage{pxrubrica}) in LaTeX preamble.

if not FORMAT:match('latex') then return {} end

local function make_kenten(s)
  return pandoc.RawInline('latex', string.format('\\kenten{%s}', s))
end

local function kenten_Str(elem)
  local s = elem.text
  if not s:find('《《', 1, true) or not s:find('》》', 1, true) then return nil end

  local out = {}
  local i, N = 1, #s
  local OPEN, CLOSE = '《《', '》》'
  local LO, LC = #OPEN, #CLOSE

  while i <= N do
    local ob = s:find(OPEN, i, true)
    if not ob then
      -- No more markers
      if i <= N then table.insert(out, pandoc.Str(s:sub(i))) end
      break
    end
    -- Emit text before marker
    if ob > i then table.insert(out, pandoc.Str(s:sub(i, ob - 1))) end

    local cb = s:find(CLOSE, ob + LO, true)
    if not cb then
      -- Unbalanced: emit the rest as-is
      table.insert(out, pandoc.Str(s:sub(ob)))
      break
    end

    local content = s:sub(ob + LO, cb - 1)
    table.insert(out, make_kenten(content))
    i = cb + LC
  end

  if #out == 0 then return pandoc.Str('') end
  if #out == 1 then return out[1] end
  return out
end

return {
  Str = kenten_Str,
}
