#!/usr/bin/env lua
-- tatechuyoko_test.lua
-- Test suite for tatechuyoko filters

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

-- Test helper function to run pandoc with filter
local function test_filter(input, filter_name)
    local cmd = string.format('echo "%s" | pandoc --lua-filter=%s.lua -f markdown -t latex 2>/dev/null', 
                             input, filter_name)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result:gsub("\n$", "") -- Remove trailing newline
end

print("=== Tatechuyoko Filter Tests ===")

local passed = 0
local total = 0

-- Letter filter tests
print("\n--- Half-width Letter Filter Tests ---")

total = total + 1
if test_case("Single letter", "\\tatechuyoko*{a}", test_filter("a", "halfwidth-letter-filter")) then
    passed = passed + 1
end

total = total + 1  
if test_case("Two letters", "{\\small\\tatechuyoko*{ab}}", test_filter("ab", "halfwidth-letter-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Three letters", "\\tatechuyoko*{a}\\tatechuyoko*{b}\\tatechuyoko*{c}", 
             test_filter("abc", "halfwidth-letter-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Four letters", "\\tatechuyoko*{a}\\tatechuyoko*{b}\\tatechuyoko*{c}\\tatechuyoko*{d}", 
             test_filter("abcd", "halfwidth-letter-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Mixed case", "\\tatechuyoko*{A}\\tatechuyoko*{b}\\tatechuyoko*{C}", 
             test_filter("AbC", "halfwidth-letter-filter")) then
    passed = passed + 1
end

-- Number filter tests  
print("\n--- Half-width Number Filter Tests ---")

total = total + 1
if test_case("Single number", "\\tatechuyoko*{1}", test_filter("1", "halfwidth-number-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Two numbers", "{\\small\\tatechuyoko*{12}}", test_filter("12", "halfwidth-number-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Three numbers", "\\tatechuyoko*{1}\\tatechuyoko*{2}\\tatechuyoko*{3}", 
             test_filter("123", "halfwidth-number-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Four numbers", "\\tatechuyoko*{1}\\tatechuyoko*{2}\\tatechuyoko*{3}\\tatechuyoko*{4}", 
             test_filter("1234", "halfwidth-number-filter")) then
    passed = passed + 1
end

-- Symbol filter tests
print("\n--- Half-width Symbol Filter Tests ---")

total = total + 1
if test_case("Single symbol", "\\tatechuyoko*{!}", test_filter("!", "halfwidth-symbol-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Two symbols", "{\\small\\tatechuyoko*{!!}}", test_filter("!!", "halfwidth-symbol-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Three symbols", "\\tatechuyoko*{!}\\tatechuyoko*{!}\\tatechuyoko*{!}", 
             test_filter("!!!", "halfwidth-symbol-filter")) then
    passed = passed + 1
end

total = total + 1
if test_case("Mixed symbols", "\\tatechuyoko*{!}\\tatechuyoko*{@}\\tatechuyoko*{#}", 
             test_filter("!@#", "halfwidth-symbol-filter")) then
    passed = passed + 1
end

-- Mixed content tests
print("\n--- Mixed Content Tests ---")

total = total + 1
local mixed_expected = "これは\\tatechuyoko*{a}テスト\\tatechuyoko*{1}です\\tatechuyoko*{!}"
if test_case("Japanese with half-width mixed", mixed_expected,
             test_filter("これはaテスト1です!", "halfwidth-letter-filter")) then
    passed = passed + 1
end

-- Summary
print(string.format("\n=== Test Summary ==="))
print(string.format("Passed: %d/%d tests", passed, total))

if passed == total then
    print("🎉 All tests passed!")
    os.exit(0)
else
    print("❌ Some tests failed!")
    os.exit(1)
end