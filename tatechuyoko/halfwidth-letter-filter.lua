-- halfwidth-letter-filter.lua
-- Convert half-width Latin letters to tatechuyoko for vertical typesetting
-- Handles: A-Z, a-z

local tatechuyoko_utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'tatechuyoko-utils.lua')

Para = tatechuyoko_utils.create_tatechuyoko_filter('[A-Za-z]', 'half-width letters')