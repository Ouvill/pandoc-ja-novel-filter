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

local known_handlers = {
  'Str','Space','SoftBreak','LineBreak','Emph','Strong','Strikeout','Superscript','Subscript',
  'SmallCaps','Code','Quoted','Cite','Span','Link','Image','Note','RawInline','Math','Para',
  'Plain','LineBlock','CodeBlock','RawBlock','BlockQuote','OrderedList','BulletList','DefinitionList',
  'Header','HorizontalRule','Table','Div','Null',
  -- Top-level hooks
  'Meta','Pandoc',
}

local function snapshot()
  local snap = {}
  for _, name in ipairs(known_handlers) do
    local fn = rawget(_G, name)
    if type(fn) == 'function' then snap[name] = fn end
  end
  return snap
end

local function include(fname)
  local before = snapshot()
  -- Prefer path relative to this file; fall back to working dir
  local ok, ret = pcall(dofile, BASE .. fname)
  if not ok then
    ok, ret = pcall(dofile, fname)
  end
  if ok and type(ret) == 'table' then
    table.insert(collected, ret)
  end
  -- Collect global handler changes as a delta filter
  local after = snapshot()
  local delta = {}
  for _, name in ipairs(known_handlers) do
    if after[name] and after[name] ~= before[name] then
      delta[name] = after[name]
    end
  end
  if next(delta) ~= nil then
    table.insert(collected, delta)
  end
  -- Restore previous globals to avoid interference
  for _, name in ipairs(known_handlers) do
    if before[name] ~= after[name] then
      _G[name] = before[name]
    end
  end
end

-- Load individual filters here (order matters)
include('dakuten.lua')
include('kakuyomu_ruby.lua')

-- Add more filters as needed, for example:
-- include('ruby.lua')
-- include('emphasis.lua')

if #collected > 0 then return collected end
