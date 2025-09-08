-- ja-novel-filter.lua
-- Loads and chains multiple Japanese novel filters
-- Usage: pandoc input.md --lua-filter=ja-novel-filter.lua -t latex

local dir = debug.getinfo(1, 'S').source:match('@(.*/)')  or ''

-- Load filters safely
local function load_filter(name)
  local ok, filter = pcall(dofile, dir .. name)
  return ok and filter or pcall(dofile, name) and dofile(name)
end

-- Return array of filters (Pandoc's preferred method)
return {
  load_filter('dakuten.lua'),
  load_filter('kenten-filter.lua'),
  load_filter('kakuyomu_ruby.lua'),
  load_filter('tatechuyoko/halfwidth-letter-filter.lua')[1],
  load_filter('tatechuyoko/halfwidth-number-filter.lua')[1],
  load_filter('tatechuyoko/halfwidth-symbol-filter.lua')[1],
  load_filter('break-filter.lua')[1]
}
