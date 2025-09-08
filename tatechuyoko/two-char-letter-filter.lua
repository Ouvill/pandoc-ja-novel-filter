-- two-char-letter-filter.lua
-- Groups exactly 2 consecutive half-width letters with {\small\tatechuyoko*{}}
-- Must be applied BEFORE basic tatechuyoko filters

local two_char_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'two-char-tatechuyoko-utils.lua')

Str = two_char_utils.create_two_char_tatechuyoko_filter('[A-Za-z]', 'two-char letters')

-- Skip HTML span elements
function Span(elem)
  return nil
end