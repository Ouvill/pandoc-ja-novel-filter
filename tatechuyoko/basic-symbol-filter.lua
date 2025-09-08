-- basic-symbol-filter.lua
-- Processes all half-width symbols individually with \tatechuyoko*{}
-- Should be applied AFTER two-character grouping filters

local basic_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'basic-tatechuyoko-utils.lua')

Str = basic_utils.create_basic_tatechuyoko_filter('[!-/:-@%[-`{-~]', 'basic symbols')

-- Skip HTML span elements
function Span(elem)
  return nil
end