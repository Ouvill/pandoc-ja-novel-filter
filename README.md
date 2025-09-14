# Pandoc小説フィルタ

[![Tests](https://img.shields.io/badge/tests-passing-brightgreen)](tests/)

このリポジトリには、日本語小説を処理し、適切なタイポグラフィーサポートでLaTeX/PDF形式に変換するためのPandoc Luaフィルタのコレクションが含まれています。

## 機能

- **濁点サポート**: 結合濁点文字を適切なLaTeXコマンドに変換
- **ルビ注釈**: カクヨム形式のルビ記法（`漢字《かんじ》`）をLaTeXルビに変換
- **圏点**: カクヨム形式の強調記法（`《《強調》》`）をLaTeX圏点に変換
- **縦中横処理**: 半角英数字記号を縦書きに適した縦中横処理
- **波線処理**: 連続する波線（〜）を`\flexwave{数}`コマンドに変換
- **長音処理**: 連続する長音（ー）を`\flexchoon{数}`コマンドに変換
- **統合フィルタ**: 単一のコマンドですべてのフィルタを使用

## TIPS

本フィルターは、MarkdownからLaTeXへの変換に特化していました。Textデータを改行を維持したままMarkdownに変換したい場合は以下のコマンドで行えます。以下のコマンドは、行末の不要な空白を削除し、各行の末尾に2つのスペースを追加してMarkdownの改行として認識させます。

```bash
sed -e 's/[[:space:]]\+$//' -e 's/$/  /' input.txt > output.md
```

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

### 4. tatechuyoko/（縦中横フィルタ）

半角英数字記号を縦書きに適した縦中横処理で変換します。

**halfwidth-letter-filter.lua（英字）:**
- 1文字: `a` → `\tatechuyoko*{a}`
- 2文字連続: `ab` → `{\small\tatechuyoko*{ab}}`
- 3文字以上: `abc` → `\tatechuyoko*{a}\tatechuyoko*{b}\tatechuyoko*{c}`

**halfwidth-number-filter.lua（数字）:**
- 1文字: `5` → `\tatechuyoko*{5}`
- 2文字連続: `12` → `{\small\tatechuyoko*{12}}`
- 3文字以上: `123` → `\tatechuyoko*{1}\tatechuyoko*{2}\tatechuyoko*{3}`

**halfwidth-symbol-filter.lua（記号）:**
- !と?のみ処理: `!` → `\tatechuyoko*{!}`
- LaTeX問題記号は除外: `@#$%&`など

### 5. ja-novel-filter.lua（統合フィルタ）

すべての個別フィルタを正しい順序で読み込む統合エントリーポイント。複数のフィルタを一緒に使用する推奨方法です。

**フィルタ順序:**
1. voiced-mark-filter.lua
2. kenten-filter.lua
3. kakuyomu_ruby.lua
4. tatechuyoko/halfwidth-letter-filter.lua
5. tatechuyoko/halfwidth-number-filter.lua
6. tatechuyoko/halfwidth-symbol-filter.lua
7. flexwave-filter.lua
8. flexchoon-filter.lua

### 6. flexwave-filter.lua（波線フィルタ）

連続する波線（〜）を`\flexwave{数}`コマンドに変換します。単独の波線は変換しません。

**例:**
- 入力: `〜` → `〜`（変更なし）
- 入力: `〜〜` → `\flexwave{2}`
- 入力: `〜〜〜` → `\flexwave{3}`
- 入力: `あ〜〜いう` → `あ\flexwave{2}いう`

### 7. flexchoon-filter.lua（長音フィルタ）

連続する長音（ー）を`\flexchoon{数}`コマンドに変換します。単独の長音は変換しません。

**例:**
- 入力: `ー` → `ー`（変更なし）
- 入力: `ーー` → `\flexchoon{2}`
- 入力: `ーーー` → `\flexchoon{3}`
- 入力: `あーーいう` → `あ\flexchoon{2}いう`

## 使用方法

### 基本的な使用方法

**単一フィルタ:**
```bash
pandoc input.md --lua-filter=dakuten.lua -o output.tex
pandoc input.md --lua-filter=number-filter.lua -o output.tex
pandoc input.md --lua-filter=flexwave-filter.lua -o output.tex
pandoc input.md --lua-filter=flexchoon-filter.lua -o output.tex
```

**すべてのフィルタ（推奨）:**
```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex
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

場面が変わって、次の日の朝。

さらに大きな時間の流れを表現。

今日は12月3日、気温は25度です。Chapter 1: Test! これはABC？

長い波線〜〜〜で間を表現したり、短い波線〜で語尾を伸ばしたりする。

「サーバーー」とか「コンピューーータ」みたいに長音が連続することもある。
```

これは、プロフェッショナルな日本語小説組版のための適切なLaTeXコマンドに変換されます。

## テスト

すべてのフィルタが正しく動作することを確認するためのテストスイートを実行：

```bash
lua tests/dakuten_test.lua
lua tests/kakuyomu_ruby_test.lua
lua tests/kenten_filter_test.lua
lua tests/number_filter_test.lua
lua tests/flexwave_filter_test.lua
lua tests/flexchoon_filter_test.lua
```

## 要件

- Luaフィルタサポート付きのPandoc 2.7以上
- LaTeX出力用：`pxrubrica`および`bxghost`パッケージ付きのTeX Live
- Lua 5.3以上（テスト実行用）

## 貢献

貢献を歓迎します！イシューやプルリクエストをお気軽に送信してください。

## ライセンス

このプロジェクトはオープンソースです。ライセンスの詳細については、リポジトリをご確認ください。
