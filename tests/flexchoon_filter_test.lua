-- Mock pandoc module for testing
pandoc = {}
function pandoc.Str(text)
    return {t = "Str", text = text}
end
function pandoc.RawInline(format, text)
    return {t = "RawInline", format = format, text = text}
end

-- Set FORMAT for testing
FORMAT = "latex"

dofile("flexchoon-filter.lua")

local function create_str(text)
    return {t = "Str", text = text}
end

local function create_para(inlines)
    return {t = "Para", content = inlines}
end

-- Helper function to convert element array back to text for testing
local function elements_to_text(elements)
    local result = ""
    for _, elem in ipairs(elements) do
        if elem.t == "Str" then
            result = result .. elem.text
        elseif elem.t == "RawInline" then
            result = result .. elem.text
        end
    end
    return result
end

local function test_continuous_choon_replacement()
    local tests = {
        {"ー", "ー"},
        {"ーー", "\\flexchoon{2}"},
        {"ーーー", "\\flexchoon{3}"},
        {"ーーーー", "\\flexchoon{4}"},
        {"あーいう", "あーいう"},
        {"あーーいう", "あ\\flexchoon{2}いう"},
        {"ーーえーーお", "\\flexchoon{2}え\\flexchoon{2}お"},
        {"ーえーーおー", "ーえ\\flexchoon{2}おー"},
        {"普通の文字", "普通の文字"},
        {"", ""},
    }

    local total_assertions = 0
    local passed_assertions = 0

    for i, test in ipairs(tests) do
        local input_text, expected = test[1], test[2]
        local para = create_para({create_str(input_text)})
        local result = Para(para)
        local actual = elements_to_text(result.content)

        total_assertions = total_assertions + 1
        if actual == expected then
            passed_assertions = passed_assertions + 1
            print(string.format("✓ Test %d passed: '%s' -> '%s'", i, input_text, actual))
        else
            print(string.format("✗ Test %d failed: '%s' -> expected '%s', got '%s'", i, input_text, expected, actual))
        end
    end

    print(string.format("\nContinuous choon filter tests: %d/%d assertions passed", passed_assertions, total_assertions))
    return passed_assertions == total_assertions
end

local function test_plain_element()
    local plain = {t = "Plain", content = {create_str("ーーーテストーー")}}
    local result = Plain(plain)
    local expected = "\\flexchoon{3}テスト\\flexchoon{2}"
    local actual = elements_to_text(result.content)

    if actual == expected then
        print("✓ Plain element test passed")
        return true
    else
        print(string.format("✗ Plain element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local function test_header_element()
    local header = {t = "Header", content = {create_str("見出しーーー")}}
    local result = Header(header)
    local expected = "見出し\\flexchoon{3}"
    local actual = elements_to_text(result.content)

    if actual == expected then
        print("✓ Header element test passed")
        return true
    else
        print(string.format("✗ Header element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local success = test_continuous_choon_replacement() and test_plain_element() and test_header_element()

if success then
    print("\n🎉 All continuous choon filter tests passed!")
    os.exit(0)
else
    print("\n❌ Some continuous choon filter tests failed!")
    os.exit(1)
end