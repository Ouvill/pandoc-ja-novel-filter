-- halfwidth-symbol-filter.lua
-- Convert half-width symbols to tatechuyoko for vertical typesetting  
-- Handles: ASCII symbols (!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~)

local tatechuyoko_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'tatechuyoko-utils.lua')

Str = tatechuyoko_utils.create_tatechuyoko_filter('[!-/:-@%[-`{-~]', 'half-width symbols')

-- Skip HTML span elements  
function Span(elem)
  return nil
end