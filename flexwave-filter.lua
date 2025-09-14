-- 連続波線フィルター (Continuous Wave Filter)
-- 
-- 仕様:
-- - 波線(〜)が1つの場合は置換しない
-- - 波線(〜)が2つ以上連続している場合、\flexwave{数}に変換
-- 
-- 例:
-- 〜        -> 〜 (変更なし)
-- 〜〜      -> \flexwave{2}
-- 〜〜〜    -> \flexwave{3}
-- あ〜〜いう -> あ\flexwave{2}いう

local function replace_continuous_waves(str)
    local result = {}
    local i = 1
    while i <= utf8.len(str) do
        local char = utf8.char(utf8.codepoint(str, utf8.offset(str, i)))
        if char == "〜" then
            local count = 0
            local j = i
            while j <= utf8.len(str) do
                local next_char = utf8.char(utf8.codepoint(str, utf8.offset(str, j)))
                if next_char == "〜" then
                    count = count + 1
                    j = j + 1
                else
                    break
                end
            end
            if count >= 2 then
                if FORMAT == "latex" then
                    table.insert(result, pandoc.RawInline('latex', '\\flexwave{' .. count .. '}'))
                else
                    table.insert(result, pandoc.Str("〜〜" .. string.rep("〜", count - 2)))
                end
            else
                table.insert(result, pandoc.Str("〜"))
            end
            i = i + count
        else
            table.insert(result, pandoc.Str(char))
            i = i + 1
        end
    end
    return result
end

local function process_inlines(inlines)
    local new_inlines = {}
    for i = 1, #inlines do
        if inlines[i].t == "Str" then
            local processed = replace_continuous_waves(inlines[i].text)
            for _, item in ipairs(processed) do
                table.insert(new_inlines, item)
            end
        else
            table.insert(new_inlines, inlines[i])
        end
    end
    return new_inlines
end

function Para(el)
    el.content = process_inlines(el.content)
    return el
end

function Plain(el)
    el.content = process_inlines(el.content)
    return el
end

function Header(el)
    el.content = process_inlines(el.content)
    return el
end

return {{Para = Para, Plain = Plain, Header = Header}}