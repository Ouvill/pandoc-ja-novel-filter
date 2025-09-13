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

dofile("continuouswave-filter.lua")

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

local function test_continuous_wave_replacement()
    local tests = {
        {"〜", "〜"},
        {"〜〜", "\\continuouswave{2}"},
        {"〜〜〜", "\\continuouswave{3}"},
        {"〜〜〜〜", "\\continuouswave{4}"},
        {"あ〜いう", "あ〜いう"},
        {"あ〜〜いう", "あ\\continuouswave{2}いう"},
        {"〜〜え〜〜お", "\\continuouswave{2}え\\continuouswave{2}お"},
        {"〜え〜〜お〜", "〜え\\continuouswave{2}お〜"},
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

    print(string.format("\nContinuous wave filter tests: %d/%d assertions passed", passed_assertions, total_assertions))
    return passed_assertions == total_assertions
end

local function test_plain_element()
    local plain = {t = "Plain", content = {create_str("〜〜〜テスト〜〜")}}
    local result = Plain(plain)
    local expected = "\\continuouswave{3}テスト\\continuouswave{2}"
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
    local header = {t = "Header", content = {create_str("見出し〜〜〜")}}
    local result = Header(header)
    local expected = "見出し\\continuouswave{3}"
    local actual = elements_to_text(result.content)

    if actual == expected then
        print("✓ Header element test passed")
        return true
    else
        print(string.format("✗ Header element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local success = test_continuous_wave_replacement() and test_plain_element() and test_header_element()

if success then
    print("\n🎉 All continuous wave filter tests passed!")
    os.exit(0)
else
    print("\n❌ Some continuous wave filter tests failed!")
    os.exit(1)
end