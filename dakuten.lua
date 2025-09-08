-- dakuten.lua - Composite Dakuten Filter
-- Purpose:
--   Combines both combining dakuten (U+3099) and voiced mark (U+309B) filters.
--   This is a wrapper that loads and chains the two specialized filters.
-- Output target:
--   LaTeX only (inactive for non-LaTeX formats).
-- Composition:
--   - combining-dakuten-filter.lua: Handles U+3099 combining dakuten
--   - voiced-mark-filter.lua: Handles U+309B voiced sound mark
-- Usage:
--   Can be used as a single filter or part of ja-novel-filter.lua
-- Examples:
--   "あ\227\130\153" (あ + U+3099) => \dakuten{あ}
--   "あ\227\130\155" (あ + U+309B) => \dakuten{あ}

local dir = (debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '')

-- Load filters safely
local function load_filter(name)
  local ok, filter = pcall(dofile, dir .. name)
  return ok and filter or pcall(dofile, name) and dofile(name)
end

-- Return array of filters (combining dakuten first, then voiced mark)
return {
  load_filter('combining-dakuten-filter.lua'),
  load_filter('voiced-mark-filter.lua')
}
