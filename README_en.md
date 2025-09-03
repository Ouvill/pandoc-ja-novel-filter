# Pandoc Novel Filter

[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](tests/)

This repository contains a collection of Pandoc Lua filters designed specifically for processing Japanese novels and converting them to LaTeX/PDF format with proper typographic support.

## Features

- **Dakuten Support**: Convert combining dakuten characters to proper LaTeX commands
- **Ruby Annotations**: Convert Kakuyomu-style ruby notation (`漢字《かんじ》`) to LaTeX ruby
- **Emphasis Marks**: Convert Kakuyomu-style emphasis (`《《強調》》`) to LaTeX kenten (dots)
- **Number Formatting**: Convert half-width numbers according to custom project rules
- **Combined Filter**: Use all filters together with a single command

## Installation

1. Clone this repository:
```bash
git clone https://github.com/Ouvill/pandoc-novel-filter.git
cd pandoc-novel-filter
```

2. Ensure you have Pandoc installed:
```bash
pandoc --version
```

3. For LaTeX output, you'll need a LaTeX distribution with Japanese support (e.g., TeX Live with `pxrubrica` package)

## Filters

### 1. dakuten.lua

Converts characters with combining dakuten marks (e.g., "あ゙", "ア゙") into LaTeX `\dakuten{...}` commands for proper typesetting.

**Example:**
- Input: `あ゙い゙ぐ`
- Output: `\dakuten{あ}\dakuten{い}ぐ`

### 2. kakuyomu_ruby.lua

Converts Kakuyomu-style ruby annotations to LaTeX `\ruby[g]{base}{reading}` commands using the `pxrubrica` package.

**Supported formats:**
- Implicit base: `冴えない彼女《ヒロイン》` → `冴えない\ruby[g]{彼女}{ヒロイン}`
- Explicit base: `｜紅蓮の炎《ヘルフレイム》` → `\ruby[g]{紅蓮の炎}{ヘルフレイム}`

### 3. kenten-filter.lua

Converts Kakuyomu-style emphasis marks (`《《...》》`) to LaTeX `\kenten{...}` commands for adding emphasis dots above text.

**Example:**
- Input: `《《重要》》な情報`
- Output: `\kenten{重要}な情報`

### 4. number-filter.lua

Converts half-width numbers according to custom project rules. For 2-digit numbers, wraps them with `\small{\tatechuyoko{}}` for proper vertical typesetting. For 1-digit or 3+ digit numbers, converts them to full-width equivalents.

**Examples:**
- 1-digit: `5` → `５`
- 2-digit: `12` → `\small{\tatechuyoko{12}}`
- 3+ digits: `123` → `１２３`
- Mixed: `今日は12月3日です` → `今日は\small{\tatechuyoko{12}}月３日です`

### 5. ja-novel-filter.lua

A combined entry point that loads all individual filters in the correct order. This is the recommended way to use multiple filters together.

**Filter order:**
1. dakuten.lua
2. kenten-filter.lua  
3. kakuyomu_ruby.lua
4. number-filter.lua

## Usage

### Basic Usage

**Single filter:**
```bash
pandoc input.md --lua-filter=dakuten.lua -o output.tex
pandoc input.md --lua-filter=number-filter.lua -o output.tex
```

**All filters (recommended):**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex
```

### LaTeX Setup

Create a preamble file for proper Japanese typesetting:

**preamble.tex:**
```latex
\usepackage{pxrubrica}
\usepackage{bxghost}

% Dakuten command
\newcommand{\dakuten}[1]{%
    \jghostguarded{%
        \leavevmode\hbox to 1\zw{%
            \rensuji{\hbox to 1\zw{#1\hspace*{-.25\zw}゛}}%
        }%
    }%
}

% Tatechuyoko command for 2-digit numbers
\newcommand{\tatechuyoko}[1]{\rensuji{#1}}
```

**Complete command:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -H preamble.tex -o output.pdf
```

### Example Input

```markdown
# 小説のサンプル

「い゙ぐい゙ぐ」と言いながら、主人公は走った。

冴えない彼女《ヒロイン》の育てかた という作品がある。

この際｜紅蓮の炎《ヘルフレイム》に焼かれて果てろ！

おじいさんは山へ《《柴刈り》》に出かけました。

今日は12月3日、気温は25度です。番号は1番から99番まで、1000個あります。
```

This will be converted to proper LaTeX commands for professional Japanese novel typesetting.

## Testing

Run the test suite to verify all filters work correctly:

```bash
lua5.3 tests/dakuten_test.lua
lua5.3 tests/kakuyomu_ruby_test.lua  
lua5.3 tests/kenten_filter_test.lua
lua5.3 tests/number_filter_test.lua
```

## Requirements

- Pandoc 2.7+ with Lua filter support
- For LaTeX output: TeX Live with `pxrubrica` and `bxghost` packages
- Lua 5.3+ (for running tests)

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is open source. Please check the repository for license details.