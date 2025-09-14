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

local function process_inlines(inlines)
    local result = {}
    for i = 1, #inlines do
        if inlines[i].t == "Str" and FORMAT == "latex" then
            local text = inlines[i].text
            local chars = {}

            -- Convert to UTF-8 character array
            for p, c in utf8.codes(text) do
                table.insert(chars, utf8.char(c))
            end

            local new_chars = {}
            local i = 1
            while i <= #chars do
                if chars[i] == "ー" then
                    -- Count consecutive choons
                    local count = 0
                    local j = i
                    while j <= #chars and chars[j] == "ー" do
                        count = count + 1
                        j = j + 1
                    end

                    if count >= 2 then
                        table.insert(result, pandoc.RawInline('latex', '\\flexchoon{' .. count .. '}'))
                    else
                        table.insert(result, pandoc.Str("ー"))
                    end
                    i = j
                else
                    -- Collect non-choon characters
                    local text_part = ""
                    while i <= #chars and chars[i] ~= "ー" do
                        text_part = text_part .. chars[i]
                        i = i + 1
                    end
                    if text_part ~= "" then
                        table.insert(result, pandoc.Str(text_part))
                    end
                end
            end
        else
            table.insert(result, inlines[i])
        end
    end
    return result
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