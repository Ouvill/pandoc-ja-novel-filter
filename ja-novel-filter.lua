-- ja-novel-filter.lua - Spec
-- Purpose:
--   Aggregate multiple Japanese text filters into a single entry point for Pandoc.
-- Behavior:
--   - Loads sibling Lua filter files and combines their functions
--   - Handles different filter types (Str-based and Pandoc-based) properly
-- Order (current):
--   1) dakuten.lua  2) kenten-filter.lua  3) kakuyomu_ruby.lua  4) number-filter.lua  5) break-filter.lua

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

local function safely_include_filter(filename)
  local full_path = script_dir .. filename
  local ok, filter_result = pcall(dofile, full_path)
  
  if not ok then
    -- Fallback: try current directory
    ok, filter_result = pcall(dofile, filename)
  end
  
  if ok and type(filter_result) == 'table' then
    return filter_result
  end
  return nil
end

-- Load individual filters
local dakuten_filter = safely_include_filter('dakuten.lua')
local kenten_filter = safely_include_filter('kenten-filter.lua')
local ruby_filter = safely_include_filter('kakuyomu_ruby.lua')
local number_filter = safely_include_filter('number-filter.lua')
local break_filter = safely_include_filter('break-filter.lua')

-- Combined filter functions
local combined_filter = {}

-- Combine Str processors
function combined_filter.Str(elem)
  if dakuten_filter and dakuten_filter.Str then
    elem = dakuten_filter.Str(elem) or elem
  end
  
  if kenten_filter and kenten_filter.Str then
    local result = kenten_filter.Str(elem)
    if result then elem = result end
  end
  
  if ruby_filter and ruby_filter.Str then
    local result = ruby_filter.Str(elem)
    if result then elem = result end
  end
  
  if number_filter and number_filter.Str then
    local result = number_filter.Str(elem)
    if result then elem = result end
  end
  
  return elem
end

-- Handle Pandoc-level processing (break-filter)
function combined_filter.Pandoc(doc)
  if break_filter and break_filter[1] and break_filter[1].Pandoc then
    return break_filter[1].Pandoc(doc)
  end
  return doc
end

return { combined_filter }
