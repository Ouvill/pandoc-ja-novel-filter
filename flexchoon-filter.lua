-- 連続長音フィルター (Continuous Choon Filter)
--
-- 仕様:
-- - 長音(ー)が1つの場合は置換しない
-- - 長音(ー)が2つ以上連続している場合、\flexchoon{数}に変換
--
-- 例:
-- ー        -> ー (変更なし)
-- ーー      -> \flexchoon{2}
-- ーーー    -> \flexchoon{3}
-- あーーいう -> あ\flexchoon{2}いう

local function replace_continuous_choons(str)
    local result = {}
    local i = 1
    while i <= utf8.len(str) do
        local char = utf8.char(utf8.codepoint(str, utf8.offset(str, i)))
        if char == "ー" then
            local count = 0
            local j = i
            while j <= utf8.len(str) do
                local next_char = utf8.char(utf8.codepoint(str, utf8.offset(str, j)))
                if next_char == "ー" then
                    count = count + 1
                    j = j + 1
                else
                    break
                end
            end
            if count >= 2 then
                if FORMAT == "latex" then
                    table.insert(result, pandoc.RawInline('latex', '\\flexchoon{' .. count .. '}'))
                else
                    table.insert(result, pandoc.Str("ーー" .. string.rep("ー", count - 2)))
                end
            else
                table.insert(result, pandoc.Str("ー"))
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
            local processed = replace_continuous_choons(inlines[i].text)
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