#!/bin/bash
# run_tests.sh - Test runner for all pandoc novel filters

echo "🧪 Running Pandoc Novel Filter Test Suite"
echo "========================================="

# Set color codes
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

passed_tests=0
total_tests=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_file="$2"
    
    echo -e "\n${YELLOW}🔍 Running $test_name...${NC}"
    
    if lua "$test_file"; then
        echo -e "${GREEN}✅ $test_name PASSED${NC}"
        ((passed_tests++))
    else
        echo -e "${RED}❌ $test_name FAILED${NC}"
    fi
    ((total_tests++))
}

# Change to project root directory
cd "$(dirname "$0")"

# Run individual filter tests
echo -e "\n📋 Individual Filter Tests"
echo "-------------------------"

if [ -f "tests/dakuten_test.lua" ]; then
    run_test "Dakuten Filter" "tests/dakuten_test.lua"
fi

if [ -f "tests/kakuyomu_ruby_test.lua" ]; then
    run_test "Kakuyomu Ruby Filter" "tests/kakuyomu_ruby_test.lua"
fi

if [ -f "tests/kenten_filter_test.lua" ]; then
    run_test "Kenten Filter" "tests/kenten_filter_test.lua"
fi

if [ -f "tests/number_filter_test.lua" ]; then
    run_test "Number Filter" "tests/number_filter_test.lua"
fi


# Run tatechuyoko filter tests
echo -e "\n🔤 Tatechuyoko Filter Tests"
echo "---------------------------"

if [ -f "tests/tatechuyoko_test.lua" ]; then
    run_test "Individual Tatechuyoko Filters" "tests/tatechuyoko_test.lua"
fi

if [ -f "tests/combined_tatechuyoko_test.lua" ]; then
    run_test "Combined Tatechuyoko Filters" "tests/combined_tatechuyoko_test.lua"
fi

# Test Summary
echo -e "\n📊 Test Summary"
echo "==============="
echo "Passed: $passed_tests/$total_tests test suites"

if [ $passed_tests -eq $total_tests ]; then
    echo -e "${GREEN}🎉 All test suites completed!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some test suites had failures${NC}"
    exit 1
fi