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

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

local function make_kenten(content)
  return utils.latex_inline(string.format('\\kenten{%s}', content))
end

local function kenten_Str(elem)
  return utils.process_str_element(elem, function(text)
    local result = utils.process_paired_markers(text, '《《', '》》', make_kenten)
    return result
  end)
end

return utils.latex_only_filter({
  Str = kenten_Str,
})
