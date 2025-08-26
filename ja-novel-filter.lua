-- ja-novel-filter.lua
-- Aggregate Japanese novel filters for Pandoc.
-- This file loads individual Lua filters which RETURN filter tables.
-- It returns an array of filters to be applied in order.

-- Resolve this script's directory so we can dofile other filters reliably
local function script_dir()
  local info = debug and debug.getinfo and debug.getinfo(1, 'S')
  local src = info and info.source or ''
  if src:sub(1, 1) == '@' then src = src:sub(2) end
  -- Try POSIX-style path
  local dir = src:match('(.*/)')
  if dir then return dir end
  -- Fallback for Windows-style path
  dir = src:match('(.-\\)')
  return dir or ''
end

local BASE = script_dir()

local filters = {}

local function include(fname)
  local ok, ret = pcall(dofile, BASE .. fname)
  if not ok then ok, ret = pcall(dofile, fname) end
  if ok and type(ret) == 'table' then table.insert(filters, ret) end
end

-- Load individual filters here (order matters)
include('dakuten.lua')
include('kenten-filter.lua')
include('kakuyomu_ruby.lua')

-- Add more filters as needed, for example:
-- include('ruby.lua')
-- include('emphasis.lua')

return filters
