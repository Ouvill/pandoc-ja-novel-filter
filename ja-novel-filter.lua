-- ja-novel-filter.lua - Spec
-- Purpose:
--   Aggregate multiple Japanese text filters into a single entry point for Pandoc.
-- Behavior:
--   - Loads sibling Lua filter files which each return a filter table (e.g., { Str=... }).
--   - Returns an array of those tables, preserving include order (earlier first).
-- Order (current):
--   1) dakuten.lua  2) kenten-filter.lua  3) kakuyomu_ruby.lua
--   Adjust include order if precedence needs to change.

-- Get the directory of the current script for reliable imports
local function get_script_dir()
  local info = debug and debug.getinfo and debug.getinfo(1, 'S')
  local src = info and info.source or ''
  if src:sub(1, 1) == '@' then src = src:sub(2) end
  local dir = src:match('(.*/)')
  if dir then return dir end
  dir = src:match('(.-\\)')
  return dir or ''
end

local script_dir = get_script_dir()
local filters = {}

local function safely_include_filter(filename)
  local full_path = script_dir .. filename
  local ok, filter_result = pcall(dofile, full_path)
  
  if not ok then
    -- Fallback: try current directory
    ok, filter_result = pcall(dofile, filename)
  end
  
  if ok and type(filter_result) == 'table' then
    table.insert(filters, filter_result)
  end
end

-- Load individual filters here (order matters)
safely_include_filter('dakuten.lua')
safely_include_filter('kenten-filter.lua')
safely_include_filter('kakuyomu_ruby.lua')
safely_include_filter('number-filter.lua')
safely_include_filter('break-filter.lua')

return filters
