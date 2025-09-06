# Pandoc Japanese Novel Filter

**ALWAYS** follow these instructions first and only search for additional information if these instructions are incomplete or found to be in error.

Pandoc Japanese Novel Filter is a collection of Pandoc Lua filters designed for processing Japanese novels and converting them to LaTeX/PDF format with proper typographic support. The filters handle dakuten marks, ruby annotations, emphasis marks, and number formatting according to Japanese typesetting conventions.

## Working Effectively

### Bootstrap and Dependencies
- Install required dependencies:
  - `sudo apt-get update && sudo apt-get -y install pandoc lua5.3 lua5.4`
  - For LaTeX/PDF output: `sudo apt-get -y install texlive-latex-base texlive-latex-extra texlive-fonts-recommended`
  - Pandoc 2.7+ with Lua filter support is required (repository works with Pandoc 3.1.3)
  - Lua 5.3+ is required for running tests

### Testing and Validation  
- Run all tests: Each test takes < 0.005 seconds. NEVER CANCEL.
  - `lua5.3 tests/dakuten_test.lua`
  - `lua5.3 tests/kakuyomu_ruby_test.lua`
  - `lua5.3 tests/kenten_filter_test.lua`
  - `lua5.3 tests/number_filter_test.lua`
- Test pandoc conversion (takes < 0.030 seconds): NEVER CANCEL.
  - `pandoc testdata/input.md --lua-filter=ja-novel-filter.lua -o output.tex`
- Validate output: `diff output.tex testdata/objective.tex` should show no differences
- Full validation script completes in < 0.200 seconds

### Usage Commands
- **Single filter usage:**
  - `pandoc input.md --lua-filter=dakuten.lua -o output.tex`
  - `pandoc input.md --lua-filter=kakuyomu_ruby.lua -o output.tex`
  - `pandoc input.md --lua-filter=kenten-filter.lua -o output.tex`
  - `pandoc input.md --lua-filter=number-filter.lua -o output.tex`
- **Combined filter usage (recommended):**
  - `pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex`
- **LaTeX/PDF output with proper Japanese support:**
  - Create `preamble.tex` with required LaTeX packages (see README.md)
  - `pandoc input.md --lua-filter=ja-novel-filter.lua -H preamble.tex -o output.pdf`

## Validation Scenarios

### ALWAYS Test These Scenarios After Making Changes:
1. **Run complete test suite:** All 4 test files must pass with OK status
2. **Test individual filters:** Each filter must convert testdata/input.md without errors
3. **Test combined filter:** ja-novel-filter.lua must produce output matching testdata/objective.tex exactly
4. **Test with sample Japanese text:** Verify dakuten marks (あ゙), ruby annotations (漢字《かんじ》), emphasis marks (《《重要》》), and number formatting work correctly

### Expected Behavior:
- Dakuten filter: Converts combining dakuten (あ゙) to `\dakuten{あ}`
- Ruby filter: Converts 漢字《かんじ》 to `\ruby[g]{漢字}{かんじ}`
- Kenten filter: Converts 《《重要》》 to `\kenten{重要}`
- Number filter: Converts 12 to `\small{\tatechuyoko{12}}`, single digits to full-width

## Common Tasks and Timing

### Build and Test (Total: < 0.200 seconds)
- Tests run in < 0.005 seconds each. NEVER CANCEL. Set timeout to 30+ seconds.
- Pandoc conversions complete in < 0.030 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- Full validation with all tests and conversions: < 0.200 seconds

### File Structure Reference
```
.
├── README.md                    # Japanese documentation  
├── README_en.md                 # English documentation
├── ja-novel-filter.lua          # Combined filter entry point
├── dakuten.lua                  # Dakuten mark processing
├── kakuyomu_ruby.lua           # Ruby annotation processing  
├── kenten-filter.lua           # Emphasis mark processing
├── number-filter.lua           # Number formatting
├── testdata/
│   ├── input.md                # Sample input for testing
│   └── objective.tex           # Expected output for validation
├── tests/                      # Unit tests for each filter
│   ├── dakuten_test.lua
│   ├── kakuyomu_ruby_test.lua
│   ├── kenten_filter_test.lua
│   └── number_filter_test.lua
└── .devcontainer/              # Development container setup
```

### Key Development Patterns
- **Filter loading order in ja-novel-filter.lua:** dakuten → kenten → ruby → number
- **All filters return Pandoc AST elements:** Use `pandoc.Str()` and `pandoc.RawInline('latex', text)`
- **Tests use mock pandoc environment:** No need for actual pandoc binary to run unit tests
- **LaTeX output format:** All filters target LaTeX format specifically

## Troubleshooting

### Common Issues:
- **"File not found" errors:** Ensure you're in the repository root directory
- **LaTeX compilation fails:** Japanese text requires `pxrubrica` and `bxghost` LaTeX packages
- **Tests fail:** Check Lua version (requires 5.3+) and file paths
- **Filter doesn't work:** Verify pandoc version (requires 2.7+) and lua-filter support

### LaTeX Package Requirements:
For full PDF generation with Japanese support, install additional packages:
- **Basic LaTeX:** `texlive-latex-base texlive-latex-extra`
- **Japanese packages:** `pxrubrica` and `bxghost` (may require TeX Live full installation)
- **Basic PDF test:** `echo "test" | pandoc -o test.pdf` should work after installing texlive-latex-extra

## Development Workflow

### Making Changes:
1. **ALWAYS** run existing tests first to establish baseline
2. **Make minimal changes** to individual filter files
3. **Test immediately** after each change using individual filter tests
4. **Validate output** by comparing with testdata/objective.tex
5. **Run full test suite** before committing changes
6. **Test with real Japanese text** to ensure functionality works correctly

### Adding New Features:
1. Add tests to appropriate test file in tests/ directory
2. Implement feature in individual filter file
3. Update ja-novel-filter.lua if filter order needs adjustment
4. Update testdata/input.md and testdata/objective.tex if needed
5. Test with various Japanese text patterns to ensure robustness

This repository has excellent test coverage and fast execution times. All operations complete in under 0.200 seconds, making it ideal for rapid development and testing.