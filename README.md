# Pandoc小説フィルタ

[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](tests/)

このリポジトリには、日本語小説を処理し、適切なタイポグラフィーサポートでLaTeX/PDF形式に変換するためのPandoc Luaフィルタのコレクションが含まれています。

## 機能

- **濁点サポート**: 結合濁点文字を適切なLaTeXコマンドに変換
- **ルビ注釈**: カクヨム形式のルビ記法（`漢字《かんじ》`）をLaTeXルビに変換
- **圏点**: カクヨム形式の強調記法（`《《強調》》`）をLaTeX圏点に変換
- **数字フォーマット**: 半角数字を独自のルールに従って変換
- **統合フィルタ**: 単一のコマンドですべてのフィルタを使用

## インストール

1. このリポジトリをクローン:
```bash
git clone https://github.com/Ouvill/pandoc-novel-filter.git
cd pandoc-novel-filter
```

2. Pandocがインストールされていることを確認:
```bash
pandoc --version
```

3. LaTeX出力には、日本語サポート付きのLaTeX配布版（例：`pxrubrica`パッケージ付きのTeX Live）が必要です

## フィルタ

### 1. dakuten.lua（濁点フィルタ）

結合濁点文字（例：「あ゙」「ア゙」）を適切な組版のためのLaTeX `\dakuten{...}` コマンドに変換します。

**例:**
- 入力: `あ゙い゙ぐ`
- 出力: `\dakuten{あ}\dakuten{い}ぐ`

### 2. kakuyomu_ruby.lua（ルビフィルタ）

カクヨム形式のルビ注釈を`pxrubrica`パッケージを使用したLaTeX `\ruby[g]{base}{reading}` コマンドに変換します。

**サポート形式:**
- 暗黙ベース: `冴えない彼女《ヒロイン》` → `冴えない\ruby[g]{彼女}{ヒロイン}`
- 明示ベース: `｜紅蓮の炎《ヘルフレイム》` → `\ruby[g]{紅蓮の炎}{ヘルフレイム}`

### 3. kenten-filter.lua（圏点フィルタ）

カクヨム形式の強調記法（`《《...》》`）をテキストの上に強調点を追加するLaTeX `\kenten{...}` コマンドに変換します。

**例:**
- 入力: `《《重要》》な情報`
- 出力: `\kenten{重要}な情報`

### 4. number-filter.lua（数字フィルタ）

半角数字を独自のルールに従って変換します。2桁の数字は縦組みに適した`{\small\tatechuyoko*{}}`で囲み、1桁または3桁以上の数字は全角数字に変換します。

**例:**
- 1桁: `5` → `５`
- 2桁: `12` → `{\small\tatechuyoko*{12}}`
- 3桁以上: `123` → `１２３`
- 混合: `今日は12月3日です` → `今日は{\small\tatechuyoko*{12}}月３日です`

### 5. break-filter.lua（場面転換フィルタ）

Markdownで3行以上連続する空白行を場面転換として自動検出し、LaTeX `\vspace{N\baselineskip}` コマンドに変換します。空白行数から2を引いた値が空白の高さになります（N = 空白行数 - 2）。

**使用方法:**
前処理が必要です。以下のコマンドで空白行を自動検出して変換できます：
```bash
lua5.3 preprocess-blank-lines.lua input.md | pandoc --lua-filter=ja-novel-filter.lua -o output.pdf
```

**変換例:**
```markdown
本文1



本文2
```
上記の4行の空白は `\vspace{2\baselineskip}` に変換されます（4行 - 2 = 2）。

**注意:** 3行未満の空白行はそのまま保持されます。3行以上の空白行のみが場面転換として検出されます。

### 6. ja-novel-filter.lua（統合フィルタ）

すべての個別フィルタを正しい順序で読み込む統合エントリーポイント。複数のフィルタを一緒に使用する推奨方法です。

**フィルタ順序:**
1. dakuten.lua
2. kenten-filter.lua  
3. kakuyomu_ruby.lua
4. number-filter.lua
5. break-filter.lua

## 使用方法

### 基本的な使用方法

**単一フィルタ:**
```bash
pandoc input.md --lua-filter=dakuten.lua -o output.tex
pandoc input.md --lua-filter=number-filter.lua -o output.tex
```

**すべてのフィルタ（推奨）:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex
```

**場面転換を含む小説の処理（空白行の自動検出）:**
```bash
# 前処理で空白行を検出してからPandocで変換
lua5.3 preprocess-blank-lines.lua input.md | pandoc --lua-filter=ja-novel-filter.lua -o output.pdf

# または段階的に処理
lua5.3 preprocess-blank-lines.lua input.md preprocessed.md
pandoc preprocessed.md --lua-filter=ja-novel-filter.lua -o output.pdf
```

### LaTeX設定

適切な日本語組版のためのプリアンブルファイルを作成：

**preamble.tex:**
```latex
\usepackage{pxrubrica}
\usepackage{bxghost}

% 濁点コマンド
\newcommand{\dakuten}[1]{%
    \jghostguarded{%
        \leavevmode\hbox to 1\zw{%
            \rensuji{\hbox to 1\zw{#1\hspace*{-.25\zw}゛}}%
        }%
    }%
}

```

**完全なコマンド:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -H preamble.tex -o output.pdf
```

### 入力例

```markdown
# 小説のサンプル

「い゙ぐい゙ぐ」と言いながら、主人公は走った。

冴えない彼女《ヒロイン》の育てかた という作品がある。

この際｜紅蓮の炎《ヘルフレイム》に焼かれて果てろ！

おじいさんは山へ《《柴刈り》》に出かけました。

今日は12月3日、気温は25度です。番号は1番から99番まで、1000個あります。
```

これは、プロフェッショナルな日本語小説組版のための適切なLaTeXコマンドに変換されます。

## テスト

すべてのフィルタが正しく動作することを確認するためのテストスイートを実行：

```bash
lua5.3 tests/dakuten_test.lua
lua5.3 tests/kakuyomu_ruby_test.lua  
lua5.3 tests/kenten_filter_test.lua
lua5.3 tests/number_filter_test.lua
```

## 要件

- Luaフィルタサポート付きのPandoc 2.7以上
- LaTeX出力用：`pxrubrica`および`bxghost`パッケージ付きのTeX Live
- Lua 5.3以上（テスト実行用）

## 貢献

貢献を歓迎します！イシューやプルリクエストをお気軽に送信してください。

## ライセンス

このプロジェクトはオープンソースです。ライセンスの詳細については、リポジトリをご確認ください。
