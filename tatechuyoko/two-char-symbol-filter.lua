-- two-char-symbol-filter.lua  
-- Groups exactly 2 consecutive half-width symbols with {\small\tatechuyoko*{}}
-- Must be applied BEFORE basic tatechuyoko filters

local two_char_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'two-char-tatechuyoko-utils.lua')

Str = two_char_utils.create_two_char_tatechuyoko_filter('[!-/:-@%[-`{-~]', 'two-char symbols')

-- Skip HTML span elements
function Span(elem)
  return nil
end