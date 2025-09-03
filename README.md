# Pandoc Novel Filter / Pandoc小説フィルタ

[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](tests/)

This repository contains a collection of Pandoc Lua filters designed specifically for processing Japanese novels and converting them to LaTeX/PDF format with proper typographic support.

このリポジトリには、日本語小説を処理し、適切なタイポグラフィーサポートでLaTeX/PDF形式に変換するためのPandoc Luaフィルタのコレクションが含まれています。

## Features / 機能

- **Dakuten Support**: Convert combining dakuten characters to proper LaTeX commands
- **Ruby Annotations**: Convert Kakuyomu-style ruby notation (`漢字《かんじ》`) to LaTeX ruby
- **Emphasis Marks**: Convert Kakuyomu-style emphasis (`《《強調》》`) to LaTeX kenten (dots)
- **Number Formatting**: Convert half-width numbers according to Japanese typesetting rules
- **Alphabet Filtering**: Convert exactly 3-character ASCII letter/symbol sequences to full-width
- **Combined Filter**: Use all filters together with a single command

- **濁点サポート**: 結合濁点文字を適切なLaTeXコマンドに変換
- **ルビ注釈**: カクヨム形式のルビ記法（`漢字《かんじ》`）をLaTeXルビに変換
- **圏点**: カクヨム形式の強調記法（`《《強調》》`）をLaTeX圏点に変換
- **数字フォーマット**: 半角数字を日本語組版ルールに従って変換
- **アルファベットフィルタ**: 3文字ちょうどのASCII英字・記号列を全角に変換
- **統合フィルタ**: 単一のコマンドですべてのフィルタを使用

## Installation / インストール

1. Clone this repository / このリポジトリをクローン:
```bash
git clone https://github.com/Ouvill/pandoc-novel-filter.git
cd pandoc-novel-filter
```

2. Ensure you have Pandoc installed / Pandocがインストールされていることを確認:
```bash
pandoc --version
```

3. For LaTeX output, you'll need a LaTeX distribution with Japanese support (e.g., TeX Live with `pxrubrica` package)
   LaTeX出力には、日本語サポート付きのLaTeX配布版（例：`pxrubrica`パッケージ付きのTeX Live）が必要です

## Filters / フィルタ

### 1. dakuten.lua / 濁点フィルタ

Converts characters with combining dakuten marks (e.g., "あ゙", "ア゙") into LaTeX `\dakuten{...}` commands for proper typesetting.

結合濁点文字（例：「あ゙」「ア゙」）を適切な組版のためのLaTeX `\dakuten{...}` コマンドに変換します。

**Example / 例:**
- Input / 入力: `あ゙い゙ぐ`
- Output / 出力: `\dakuten{あ}\dakuten{い}ぐ`

### 2. kakuyomu_ruby.lua / ルビフィルタ

Converts Kakuyomu-style ruby annotations to LaTeX `\ruby[g]{base}{reading}` commands using the `pxrubrica` package.

カクヨム形式のルビ注釈を`pxrubrica`パッケージを使用したLaTeX `\ruby[g]{base}{reading}` コマンドに変換します。

**Supported formats / サポート形式:**
- Implicit base / 暗黙ベース: `冴えない彼女《ヒロイン》` → `冴えない\ruby[g]{彼女}{ヒロイン}`
- Explicit base / 明示ベース: `｜紅蓮の炎《ヘルフレイム》` → `\ruby[g]{紅蓮の炎}{ヘルフレイム}`

### 3. kenten-filter.lua / 圏点フィルタ

Converts Kakuyomu-style emphasis marks (`《《...》》`) to LaTeX `\kenten{...}` commands for adding emphasis dots above text.

カクヨム形式の強調記法（`《《...》》`）をテキストの上に強調点を追加するLaTeX `\kenten{...}` コマンドに変換します。

**Example / 例:**
- Input / 入力: `《《重要》》な情報`
- Output / 出力: `\kenten{重要}な情報`

### 4. number-filter.lua / 数字フィルタ

Converts half-width numbers according to Japanese typesetting rules. For 2-digit numbers, wraps them with `\small{\tatechuyoko{}}` for proper vertical typesetting. For 1-digit or 3+ digit numbers, converts them to full-width equivalents.

半角数字を日本語組版ルールに従って変換します。2桁の数字は縦組みに適した`\small{\tatechuyoko{}}`で囲み、1桁または3桁以上の数字は全角数字に変換します。

**Examples / 例:**
- 1-digit / 1桁: `5` → `５`
- 2-digit / 2桁: `12` → `\small{\tatechuyoko{12}}`
- 3+ digits / 3桁以上: `123` → `１２３`
- Mixed / 混合: `今日は12月3日です` → `今日は\small{\tatechuyoko{12}}月３日です`

### 5. alphabet-filter.lua / アルファベットフィルタ

Converts sequences of half-width ASCII letters and symbols according to Japanese typesetting rules. Only sequences of exactly 3 characters are converted to full-width equivalents; other lengths remain unchanged.

半角ASCII英字・記号列を日本語組版ルールに従って変換します。ちょうど3文字の列のみを全角に変換し、他の長さは変更されません。

**Rules / ルール:**
- Exactly 3 characters: convert to full-width / ちょうど3文字: 全角に変換
- Other lengths (1, 2, 4+): keep as half-width / 他の長さ（1, 2, 4+文字）: 半角のまま

**Examples / 例:**
- 3 characters / 3文字: `ABC` → `ＡＢＣ`, `!@#` → `！＠＃`
- 2 characters / 2文字: `AB` → `AB` (unchanged / 変更なし)
- 4+ characters / 4+文字: `ABCD` → `ABCD` (unchanged / 変更なし)
- Mixed / 混合: `今日はABCです` → `今日はＡＢＣです`

### 6. ja-novel-filter.lua / 統合フィルタ

A combined entry point that loads all individual filters in the correct order. This is the recommended way to use multiple filters together.

すべての個別フィルタを正しい順序で読み込む統合エントリーポイント。複数のフィルタを一緒に使用する推奨方法です。

**Filter order / フィルタ順序:**
1. dakuten.lua
2. kenten-filter.lua  
3. kakuyomu_ruby.lua
4. alphabet-filter.lua
5. number-filter.lua

## Usage / 使用方法

### Basic Usage / 基本的な使用方法

**Single filter / 単一フィルタ:**
```bash
pandoc input.md --lua-filter=dakuten.lua -o output.tex
pandoc input.md --lua-filter=number-filter.lua -o output.tex
pandoc input.md --lua-filter=alphabet-filter.lua -o output.tex
```

**All filters (recommended) / すべてのフィルタ（推奨）:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex
```

### LaTeX Setup / LaTeX設定

Create a preamble file for proper Japanese typesetting:

適切な日本語組版のためのプリアンブルファイルを作成：

**preamble.tex:**
```latex
\usepackage{pxrubrica}
\usepackage{bxghost}

% Dakuten command / 濁点コマンド
\newcommand{\dakuten}[1]{%
    \jghostguarded{%
        \leavevmode\hbox to 1\zw{%
            \rensuji{\hbox to 1\zw{#1\hspace*{-.25\zw}゛}}%
        }%
    }%
}

% Tatechuyoko command for 2-digit numbers / 2桁数字用縦中横コマンド
\newcommand{\tatechuyoko}[1]{\rensuji{#1}}
```

**Complete command / 完全なコマンド:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -H preamble.tex -o output.pdf
```

### Example Input / 入力例

```markdown
# 小説のサンプル

「い゙ぐい゙ぐ」と言いながら、主人公は走った。

冴えない彼女《ヒロイン》の育てかた という作品がある。

この際｜紅蓮の炎《ヘルフレイム》に焼かれて果てろ！

おじいさんは山へ《《柴刈り》》に出かけました。

今日は12月3日、気温は25度です。番号は1番から99番まで、1000個あります。

APIキーやHTMLタグ、URLなどの用語もあります。
```

This will be converted to proper LaTeX commands for professional Japanese novel typesetting.

これは、プロフェッショナルな日本語小説組版のための適切なLaTeXコマンドに変換されます。

## Testing / テスト

Run the test suite to verify all filters work correctly:

すべてのフィルタが正しく動作することを確認するためのテストスイートを実行：

```bash
lua5.3 tests/dakuten_test.lua
lua5.3 tests/kakuyomu_ruby_test.lua  
lua5.3 tests/kenten_filter_test.lua
lua5.3 tests/number_filter_test.lua
lua5.3 tests/alphabet_filter_test.lua
```

## Requirements / 要件

- Pandoc 2.7+ with Lua filter support
- For LaTeX output: TeX Live with `pxrubrica` and `bxghost` packages
- Lua 5.3+ (for running tests)

- Luaフィルタサポート付きのPandoc 2.7以上
- LaTeX出力用：`pxrubrica`および`bxghost`パッケージ付きのTeX Live
- Lua 5.3以上（テスト実行用）

## Contributing / 貢献

Contributions are welcome! Please feel free to submit issues and pull requests.

貢献を歓迎します！イシューやプルリクエストをお気軽に送信してください。

## License / ライセンス

This project is open source. Please check the repository for license details.

このプロジェクトはオープンソースです。ライセンスの詳細については、リポジトリをご確認ください。
