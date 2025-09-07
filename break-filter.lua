-- break-filter.lua - Convert full-width space lines to LaTeX vspace
-- Purpose:
--   Handle scene break formatting for novel typesetting
-- Behavior:
--   - Lines with only full-width spaces (　) are converted to \vspace{\baselineskip}
--   - Multiple consecutive full-width space lines are combined: total spaces = \vspace{N\baselineskip}

local utils = dofile((debug.getinfo(1, 'S').source:match('@(.*)') or ''):gsub('[^/\\]*$', '') .. 'utils.lua')

local function is_fullwidth_space_line(para)
  if not para or para.t ~= "Para" or #para.content == 0 then
    return false
  end
  
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
  if not para or not para.content then
    return 0
  end
  
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

local function process_document(doc)
  if not utils.is_latex() then
    return doc
  end
  
  if not doc or not doc.blocks then
    return doc
  end
  
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
      if total_spaces > 0 then
        local vspace_cmd = string.format("\\vspace{%d\\baselineskip}", total_spaces)
        table.insert(new_blocks, utils.latex_block(vspace_cmd))
      end
      
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
  { Pandoc = process_document }
}