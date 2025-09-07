-- break-filter.lua - Convert full-width space lines to LaTeX vspace
-- Purpose:
--   Handle scene break formatting for novel typesetting
-- Behavior:
--   - Lines with only full-width spaces (　) are converted to \vspace{\baselineskip}
--   - Multiple consecutive full-width space lines are combined: total spaces = \vspace{N\baselineskip}

local function is_fullwidth_space_line(para)
  if para.t ~= "Para" then
    return false
  end
  
  if #para.content == 0 then
    return false
  end
  
  -- Handle various content structures
  local text = ""
  for _, elem in ipairs(para.content) do
    if elem.t == "Str" then
      text = text .. elem.text
    elseif elem.t == "Space" then
      text = text .. " "
    elseif elem.t == "SoftBreak" or elem.t == "LineBreak" then
      -- Ignore breaks within paragraph
    else
      -- Other elements mean this is not a pure space line
      return false
    end
  end
  
  -- Check if text contains only full-width spaces and regular whitespace
  return text:match("^[　%s]*$") and text:find("　")
end

local function count_fullwidth_spaces_in_para(para)
  local count = 0
  for _, elem in ipairs(para.content) do
    if elem.t == "Str" then
      for _ in elem.text:gmatch("　") do
        count = count + 1
      end
    end
  end
  return count
end

function Pandoc(doc)
  local new_blocks = {}
  local i = 1
  
  while i <= #doc.blocks do
    local block = doc.blocks[i]
    
    if is_fullwidth_space_line(block) then
      -- Count consecutive full-width space lines and total spaces
      local total_spaces = 0
      local j = i
      
      while j <= #doc.blocks and is_fullwidth_space_line(doc.blocks[j]) do
        local space_count = count_fullwidth_spaces_in_para(doc.blocks[j])
        total_spaces = total_spaces + space_count
        j = j + 1
      end
      
      -- Create single vspace command for all consecutive lines
      local vspace_cmd = string.format("\\vspace{%d\\baselineskip}", total_spaces)
      table.insert(new_blocks, pandoc.RawBlock("latex", vspace_cmd))
      
      -- Skip all processed lines
      i = j
    else
      -- Regular block - keep as is
      table.insert(new_blocks, block)
      i = i + 1
    end
  end
  
  return pandoc.Pandoc(new_blocks, doc.meta)
end

return {
  { Pandoc = Pandoc }
}