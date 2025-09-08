-- halfwidth-symbol-filter.lua
-- Convert half-width symbols to tatechuyoko for vertical typesetting  
-- Handles: ASCII symbols (!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~)

local tatechuyoko_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'tatechuyoko-utils.lua')

local filter_func = tatechuyoko_utils.create_tatechuyoko_filter('[!-/:-@%[-`{-~]', 'half-width symbols')

return {
  { Para = filter_func, Header = filter_func }
}