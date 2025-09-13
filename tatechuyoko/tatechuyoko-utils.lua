-- tatechuyoko-utils.lua
-- Common utilities for tatechuyoko processing

local tatechuyoko_utils = {}

-- Helper function to process text with tatechuyoko
-- config: table with group_lengths array specifying which lengths to group
local function process_str_text(text, pattern, config)
  local result = {}
  local i = 1
  local len = #text
  local group_lengths = config.group_lengths or {2}  -- default: group only 2 characters

  while i <= len do
    local char = text:sub(i, i)

    if char:match(pattern) then
      -- Find the end of consecutive characters
      local j = i + 1
      while j <= len and text:sub(j, j):match(pattern) do
        j = j + 1
      end

      local sequence = text:sub(i, j - 1)
      local sequence_length = j - i

      -- Check if this length should be grouped
      local should_group = false
      for _, group_length in ipairs(group_lengths) do
        if sequence_length == group_length then
          should_group = true
          break
        end
      end

      if should_group then
        -- Group the sequence
        table.insert(result, pandoc.RawInline('latex', string.format('\\scalebox{1}[0.8]{\\tatechuyoko*{%s}}', sequence)))
      else
        -- Handle each character individually
        for k = i, j - 1 do
          local single_char = text:sub(k, k)
          table.insert(result, pandoc.RawInline('latex', string.format('\\tatechuyoko*{%s}', single_char)))
        end
      end

      i = j
    else
      -- Non-matching character - find end of non-matching sequence
      local non_matching = char
      local j = i + 1

      while j <= len and not text:sub(j, j):match(pattern) do
        non_matching = non_matching .. text:sub(j, j)
        j = j + 1
      end

      table.insert(result, pandoc.Str(non_matching))
      i = j
    end
  end

  return result
end

-- Helper function to process content list (shared by Para and Header)
local function process_content(content, pattern, config)
  local modified = false
  local new_content = {}

  for _, elem in ipairs(content) do
    if elem.t == "Str" and elem.text:find(pattern) then
      local processed = process_str_text(elem.text, pattern, config)
      for _, item in ipairs(processed) do
        table.insert(new_content, item)
      end
      modified = true
    else
      table.insert(new_content, elem)
    end
  end

  return new_content, modified
end

-- Generic tatechuyoko processor for Para and Header elements
-- pattern: Lua pattern for matching target characters
-- config: table with group_lengths array specifying which lengths to group
-- description: For debugging/comments
function tatechuyoko_utils.create_tatechuyoko_filter(pattern, config, description)
  config = config or {group_lengths = {2}}  -- default config

  return function(elem)
    if FORMAT ~= "latex" then
      return nil
    end

    if elem.t == "Para" then
      local new_content, modified = process_content(elem.content, pattern, config)
      if modified then
        return pandoc.Para(new_content)
      end
    elseif elem.t == "Header" then
      local new_content, modified = process_content(elem.content, pattern, config)
      if modified then
        return pandoc.Header(elem.level, new_content, elem.attr)
      end
    elseif elem.t == "Plain" then
      local new_content, modified = process_content(elem.content, pattern, config)
      if modified then
        return pandoc.Plain(new_content)
      end
    end

    return nil
  end
end


return tatechuyoko_utils