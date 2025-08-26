-- kenten-filter.lua - Spec
-- Purpose:
--   Convert Kakuyomu-style emphasis (bouten/kenten) written as 《《...》》 to LaTeX \kenten{...}.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Handler:
--   Str(elem) -> nil | pandoc.Inline | pandoc.Inline[]
-- Behavior:
--   - Finds 《《 and the next matching 》》 within the same Str and replaces the content with RawInline('latex', "\\kenten{...}").
--   - Preserves surrounding text as Str; supports multiple occurrences per Str.
--   - Unbalanced markers are left as-is (no change).
-- Requirements:
--   - pxrubrica package must be loaded in LaTeX preamble (\\usepackage{pxrubrica}).
-- Examples:
--   おじいさんは山へ《《柴刈り》》に出かけました。 -> おじいさんは山へ\\kenten{柴刈り}に出かけました。

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
