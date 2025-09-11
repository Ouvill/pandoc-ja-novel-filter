dofile("wave-dash-filter.lua")

local function create_str(text)
    return {t = "Str", text = text}
end

local function create_para(inlines)
    return {t = "Para", content = inlines}
end

local function test_wave_replacement()
    local tests = {
        {"〜", "〜"},
        {"〜〜", "〰〰"},
        {"〜〜〜", "〰〰〰"},
        {"〜〜〜〜", "〰〰〰〰"},
        {"あ〜いう", "あ〜いう"},
        {"あ〜〜いう", "あ〰〰いう"},
        {"〜〜え〜〜お", "〰〰え〰〰お"},
        {"〜え〜〜お〜", "〜え〰〰お〜"},
        {"普通の文字", "普通の文字"},
        {"", ""},
    }

    local total_assertions = 0
    local passed_assertions = 0

    for i, test in ipairs(tests) do
        local input_text, expected = test[1], test[2]
        local para = create_para({create_str(input_text)})
        local result = Para(para)
        local actual = result.content[1].text
        
        total_assertions = total_assertions + 1
        if actual == expected then
            passed_assertions = passed_assertions + 1
            print(string.format("✓ Test %d passed: '%s' -> '%s'", i, input_text, actual))
        else
            print(string.format("✗ Test %d failed: '%s' -> expected '%s', got '%s'", i, input_text, expected, actual))
        end
    end

    print(string.format("\nWave dash filter tests: %d/%d assertions passed", passed_assertions, total_assertions))
    return passed_assertions == total_assertions
end

local function test_plain_element()
    local plain = {t = "Plain", content = {create_str("〜〜〜テスト〜〜")}}
    local result = Plain(plain)
    local expected = "〰〰〰テスト〰〰"
    local actual = result.content[1].text
    
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
    local expected = "見出し〰〰〰"
    local actual = result.content[1].text
    
    if actual == expected then
        print("✓ Header element test passed")
        return true
    else
        print(string.format("✗ Header element test failed: expected '%s', got '%s'", expected, actual))
        return false
    end
end

local success = test_wave_replacement() and test_plain_element() and test_header_element()

if success then
    print("\n🎉 All wave dash filter tests passed!")
    os.exit(0)
else
    print("\n❌ Some wave dash filter tests failed!")
    os.exit(1)
end