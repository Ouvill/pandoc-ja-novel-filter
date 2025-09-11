local function test_gsub()
    local str = "〜〜〜"
    print("Original: " .. str)
    local result = str:gsub("〜〜+", function(match)
        print("Matched: " .. match .. " (length: " .. utf8.len(match) .. ")")
        return string.rep("〰", utf8.len(match))
    end)
    print("Result: " .. result)
end

test_gsub()
