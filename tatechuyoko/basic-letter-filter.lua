-- basic-letter-filter.lua
-- Processes all half-width letters individually with \tatechuyoko*{}
-- Should be applied AFTER two-character grouping filters

local basic_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'basic-tatechuyoko-utils.lua')

Str = basic_utils.create_basic_tatechuyoko_filter('[A-Za-z]', 'basic letters')

-- Preserve HTML span elements unchanged
Span = basic_utils.create_span_handler()