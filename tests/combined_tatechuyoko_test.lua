#!/usr/bin/env lua
-- combined_tatechuyoko_test.lua
-- Test suite for combined tatechuyoko filters

-- Simple test framework
local function test_case(name, expected, actual)
    if expected == actual then
        print("✓ " .. name)
        return true
    else
        print("✗ " .. name)
        print("  Expected: " .. expected)
        print("  Actual:   " .. actual)
        return false
    end
end

-- Test helper function to run pandoc with multiple filters
local function test_combined_filters(input)
    local cmd = string.format('echo -n "%s" | pandoc --lua-filter=tatechuyoko/halfwidth-letter-filter.lua --lua-filter=tatechuyoko/halfwidth-number-filter.lua --lua-filter=tatechuyoko/halfwidth-symbol-filter.lua -f markdown -t latex 2>/dev/null',
                             input)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    -- Remove newlines that pandoc adds for line wrapping in LaTeX output
    return result:gsub("\n", "")
end

print("=== Combined Tatechuyoko Filter Tests ===")

local passed = 0
local total = 0

-- Combined filter tests
print("\n--- Combined Filter Tests ---")

total = total + 1
if test_case("Single letter, number, symbol", 
             "\\tatechuyoko*{a}\\tatechuyoko*{1}\\tatechuyoko*{!}",
             test_combined_filters("a1!")) then
    passed = passed + 1
end

total = total + 1
if test_case("Two each type",
             "\\tatechuyoko*{a}\\tatechuyoko*{b}\\scalebox{1.0}[0.85]{\\tatechuyoko*{12}}\\scalebox{1.0}[0.85]{\\tatechuyoko*{!!}}",
             test_combined_filters("ab12!!")) then
    passed = passed + 1
end

total = total + 1
if test_case("Three each type",
             "\\tatechuyoko*{a}\\tatechuyoko*{b}\\tatechuyoko*{c}\\tatechuyoko*{1}\\tatechuyoko*{2}\\tatechuyoko*{3}\\scalebox{1.0}[0.70]{\\tatechuyoko*{!!!}}",
             test_combined_filters("abc123!!!")) then
    passed = passed + 1
end

total = total + 1
if test_case("Mixed with Japanese text", 
             "これは\\tatechuyoko*{a}\\tatechuyoko*{1}\\tatechuyoko*{!}テストです",
             test_combined_filters("これはa1!テストです")) then
    passed = passed + 1
end

total = total + 1
if test_case("Separated sequences", 
             "\\tatechuyoko*{a} \\tatechuyoko*{1} \\tatechuyoko*{!}",
             test_combined_filters("a 1 !")) then
    passed = passed + 1
end

total = total + 1
if test_case("Two-char sequences separated",
             "\\tatechuyoko*{a}\\tatechuyoko*{b} \\scalebox{1.0}[0.85]{\\tatechuyoko*{12}}\\scalebox{1.0}[0.85]{\\tatechuyoko*{!!}}",
             test_combined_filters("ab 12 !!")) then
    passed = passed + 1
end

total = total + 1
if test_case("Complex mixed pattern",
             "テスト\\tatechuyoko*{A}\\tatechuyoko*{B}\\tatechuyoko*{C}データ\\scalebox{1.0}[0.85]{\\tatechuyoko*{12}}番\\tatechuyoko*{!}@\\#",
             test_combined_filters("テストABCデータ12番!@#")) then
    passed = passed + 1
end

-- Real world examples
print("\n--- Real World Examples ---")

total = total + 1
if test_case("Version number",
             "バージョン\\tatechuyoko*{v}\\tatechuyoko*{1}.\\tatechuyoko*{2}.\\tatechuyoko*{3}",
             test_combined_filters("バージョンv1.2.3")) then
    passed = passed + 1
end

total = total + 1
if test_case("Email-like pattern",
             "メール\\tatechuyoko*{u}\\tatechuyoko*{s}\\tatechuyoko*{e}\\tatechuyoko*{r}@\\tatechuyoko*{e}\\tatechuyoko*{x}\\tatechuyoko*{a}\\tatechuyoko*{m}\\tatechuyoko*{p}\\tatechuyoko*{l}\\tatechuyoko*{e}.\\tatechuyoko*{c}\\tatechuyoko*{o}\\tatechuyoko*{m}",
             test_combined_filters("メールuser@example.com")) then
    passed = passed + 1
end

total = total + 1
if test_case("Price format",
             "価格\\$\\tatechuyoko*{1}\\tatechuyoko*{2}\\tatechuyoko*{3}\\tatechuyoko*{4}.\\scalebox{1.0}[0.85]{\\tatechuyoko*{56}}",
             test_combined_filters("価格\\$1234.56")) then
    passed = passed + 1
end

-- Summary
print(string.format("\n=== Test Summary ==="))
print(string.format("Passed: %d/%d tests", passed, total))

if passed == total then
    print("🎉 All combined tests passed!")
    os.exit(0)
else
    print("❌ Some combined tests failed!")
    os.exit(1)
end