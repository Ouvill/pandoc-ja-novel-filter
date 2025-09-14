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

local filter = dofile("flexwave-filter.lua")
local Str = filter.Str

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
        {"〜〜", "\\flexwave{2}"},
        {"〜〜〜", "\\flexwave{3}"},
        {"〜〜〜〜", "\\flexwave{4}"},
        {"あ〜いう", "あ〜いう"},
        {"あ〜〜いう", "あ\\flexwave{2}いう"},
        {"〜〜え〜〜お", "\\flexwave{2}え\\flexwave{2}お"},
        {"〜え〜〜お〜", "〜え\\flexwave{2}お〜"},
        {"普通の文字", "普通の文字"},
        {"", ""},
    }

    local total_assertions = 0
    local passed_assertions = 0

    for i, test in ipairs(tests) do
        local input_text, expected = test[1], test[2]
        local input_str = create_str(input_text)
        local result = Str(input_str)

        local actual
        if not result then
            actual = input_text
        elseif type(result) == "table" and result.t then
            -- Single element
            if result.t == "Str" then
                actual = result.text
            elseif result.t == "RawInline" then
                actual = result.text
            end
        elseif type(result) == "table" and #result > 0 then
            -- Array of elements
            actual = elements_to_text(result)
        else
            actual = input_text
        end

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

local function test_str_element()
    local input_str = create_str("〜〜〜テスト〜〜")
    local result = Str(input_str)
    local expected = "\\flexwave{3}テスト\\flexwave{2}"
    local actual = elements_to_text(result)

    if actual == expected then
        print("✓ Str element test passed")
        return true
    else
        print(string.format("✗ Str element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local function test_complex_str_element()
    local input_str = create_str("見出し〜〜〜")
    local result = Str(input_str)
    local expected = "見出し\\flexwave{3}"
    local actual = elements_to_text(result)

    if actual == expected then
        print("✓ Complex Str element test passed")
        return true
    else
        print(string.format("✗ Complex Str element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local success = test_continuous_wave_replacement() and test_str_element() and test_complex_str_element()

if success then
    print("\n🎉 All continuous wave filter tests passed!")
    os.exit(0)
else
    print("\n❌ Some continuous wave filter tests failed!")
    os.exit(1)
end