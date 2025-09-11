-- 波線フィルター (Wave Dash Filter)
-- 
-- 仕様:
-- - 波線(〜)が2つ以上連続している場合、連続する個数分だけ波ダッシュ(〰)に置換
-- - 波線(〜)が1つの場合は置換しない
-- 
-- 例:
-- 〜        -> 〜 (変更なし)
-- 〜〜      -> 〰〰
-- 〜〜〜    -> 〰〰〰
-- あ〜〜いう -> あ〰〰いう

local function replace_waves_with_dash(str)
    local result = ""
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
                result = result .. string.rep("〰", count)
            else
                result = result .. string.rep("〜", count)
            end
            i = i + count
        else
            result = result .. char
            i = i + 1
        end
    end
    return result
end

local function process_inlines(inlines)
    for i = 1, #inlines do
        if inlines[i].t == "Str" then
            inlines[i].text = replace_waves_with_dash(inlines[i].text)
        end
    end
    return inlines
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