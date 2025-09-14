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

local function replace_continuous_waves(text)
    local result = {}
    local i = 1
    local utf8_len = utf8.len(text)

    while i <= utf8_len do
        local char_start = utf8.offset(text, i)
        local char_end = utf8.offset(text, i + 1)
        if char_end then
            char_end = char_end - 1
        else
            char_end = #text
        end
        local char = text:sub(char_start, char_end)

        if char == "〜" then
            -- Find the end of consecutive waves
            local count = 0
            local j = i
            while j <= utf8_len do
                local next_start = utf8.offset(text, j)
                local next_end = utf8.offset(text, j + 1)
                if next_end then
                    next_end = next_end - 1
                else
                    next_end = #text
                end
                local next_char = text:sub(next_start, next_end)
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
                    table.insert(result, pandoc.Str(string.rep("〜", count)))
                end
            else
                table.insert(result, pandoc.Str("〜"))
            end
            i = j
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