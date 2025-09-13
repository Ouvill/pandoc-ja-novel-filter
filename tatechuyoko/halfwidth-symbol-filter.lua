-- halfwidth-symbol-filter.lua
-- Convert half-width symbols to tatechuyoko for vertical typesetting  
-- Handles: ! and ? only (to avoid LaTeX conflicts)

local tatechuyoko_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'tatechuyoko-utils.lua')

-- Symbol config: group consecutive symbols (for !!! or !!!! etc.)
local symbol_config = {group_lengths = {2, 3, 4, 5, 6}}
local filter_func = tatechuyoko_utils.create_tatechuyoko_filter('[!?]', symbol_config, 'half-width symbols (! and ?)')

return {
  { Para = filter_func, Header = filter_func, Plain = filter_func }
}