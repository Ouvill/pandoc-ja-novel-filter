-- two-char-number-filter.lua
-- Groups exactly 2 consecutive half-width numbers with {\small\tatechuyoko*{}}
-- Must be applied BEFORE basic tatechuyoko filters

local two_char_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'two-char-tatechuyoko-utils.lua')

Str = two_char_utils.create_two_char_tatechuyoko_filter('[0-9]', 'two-char numbers')

-- Preserve HTML span elements unchanged
Span = two_char_utils.create_span_handler()