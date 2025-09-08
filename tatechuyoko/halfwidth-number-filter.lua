-- halfwidth-number-filter.lua  
-- Convert half-width numbers to tatechuyoko for vertical typesetting
-- Handles: 0-9

local tatechuyoko_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'tatechuyoko-utils.lua')

local filter_func = tatechuyoko_utils.create_tatechuyoko_filter('[0-9]', 'half-width numbers')

return {
  { Para = filter_func, Header = filter_func, Plain = filter_func }
}