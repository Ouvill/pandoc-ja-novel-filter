-- basic-number-filter.lua
-- Processes all half-width numbers individually with \tatechuyoko*{}
-- Should be applied AFTER two-character grouping filters

local basic_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'basic-tatechuyoko-utils.lua')

Str = basic_utils.create_basic_tatechuyoko_filter('[0-9]', 'basic numbers')

-- Preserve HTML span elements unchanged
Span = basic_utils.create_span_handler()