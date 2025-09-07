#!/usr/bin/env lua5.3
-- preprocess-blank-lines.lua
-- Pre-processor for detecting consecutive blank lines in Markdown
-- and converting them to vspace div markers for break-filter.lua
--
-- Usage: lua5.3 preprocess-blank-lines.lua input.md output.md
-- Or:    lua5.3 preprocess-blank-lines.lua input.md | pandoc --lua-filter=ja-novel-filter.lua -o output.pdf

local function process_blank_lines(input_file, output_file)
  local file = io.open(input_file, 'r')
  if not file then
    error("Cannot open input file: " .. input_file)
  end
  
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  
  -- Process consecutive blank lines
  local output = {}
  local i = 1
  while i <= #lines do
    local line = lines[i]
    if line == '' then
      -- Count consecutive blank lines
      local blank_count = 0
      local j = i
      while j <= #lines and lines[j] == '' do
        blank_count = blank_count + 1
        j = j + 1
      end
      
      if blank_count >= 3 then
        -- Replace with vspace marker (N = blank_lines - 2)
        local vspace_lines = blank_count - 2
        table.insert(output, '')
        table.insert(output, '::: {.vspace data-lines="' .. vspace_lines .. '"}')
        table.insert(output, ':::')
        table.insert(output, '')
      else
        -- Keep original blank lines
        for k = 1, blank_count do
          table.insert(output, '')
        end
      end
      i = j
    else
      table.insert(output, line)
      i = i + 1
    end
  end
  
  -- Write output
  if output_file then
    local out_file = io.open(output_file, 'w')
    if not out_file then
      error("Cannot open output file: " .. output_file)
    end
    for _, line in ipairs(output) do
      out_file:write(line .. '\n')
    end
    out_file:close()
  else
    -- Write to stdout
    for _, line in ipairs(output) do
      print(line)
    end
  end
end

-- Main execution
local input_file = arg and arg[1]
local output_file = arg and arg[2]

if not input_file then
  print("Usage: lua5.3 preprocess-blank-lines.lua input.md [output.md]")
  print("If output.md is not specified, writes to stdout")
  os.exit(1)
end

process_blank_lines(input_file, output_file)