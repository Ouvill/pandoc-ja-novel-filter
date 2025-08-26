-- ja-novel-filter.lua
-- Aggregate Japanese novel filters for Pandoc.
-- This file loads individual Lua filters that register global handlers
-- (e.g., Str, Para, etc.). Use this single file with --lua-filter.

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

local collected = {}

local function include(fname)
  -- Prefer path relative to this file; fall back to working dir
  local ok, ret = pcall(dofile, BASE .. fname)
  if not ok then
    ok, ret = pcall(dofile, fname)
  end
  if ok and type(ret) == 'table' then
    table.insert(collected, ret)
  end
end

-- Load individual filters here
include('dakuten.lua')

-- Add more filters as needed, for example:
-- include('ruby.lua')
-- include('emphasis.lua')

-- If some included filters registered global handlers (Str, Para, ...),
-- gather them into a filter table so everything composes nicely.
local known_handlers = {
  'Str','Space','SoftBreak','LineBreak','Emph','Strong','Strikeout','Superscript','Subscript',
  'SmallCaps','Code','Quoted','Cite','Span','Link','Image','Note','RawInline','Math','Para',
  'Plain','LineBlock','CodeBlock','RawBlock','BlockQuote','OrderedList','BulletList','DefinitionList',
  'Header','HorizontalRule','Table','Div','Null',
  -- Top-level hooks
  'Meta','Pandoc',
}

local global_filter = {}
for _, name in ipairs(known_handlers) do
  if type(_G[name]) == 'function' then
    global_filter[name] = _G[name]
  end
end
if next(global_filter) ~= nil then
  table.insert(collected, global_filter)
end

if #collected > 0 then
  return collected
end
