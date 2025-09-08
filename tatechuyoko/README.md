# Tatechuyoko Filters

縦書きでの半角英数字記号を縦中横処理するためのPandocフィルタ集

## 概要

縦書きの日本語文書で半角英数字記号が90度回転してしまう問題を解決し、適切な縦中横（tatechuyoko）処理を行います。

## フィルタ構成

- **halfwidth-letter-filter.lua** - 半角英字処理（A-Z, a-z）
- **halfwidth-number-filter.lua** - 半角数字処理（0-9）
- **halfwidth-symbol-filter.lua** - 半角記号処理（!と?のみ）
- **tatechuyoko-utils.lua** - 共通ユーティリティ関数

## 処理仕様

### 文字種別処理

- **半角英字**: A-Z, a-z
- **半角数字**: 0-9
- **半角記号**: ! と ? のみ（LaTeX干渉回避のため）

### 文字数別処理ルール

- **1文字**: `a` → `\tatechuyoko*{a}`
- **2文字連続**: `ab` → `{\small\tatechuyoko*{ab}}`
- **3文字以上**: `abc` → `\tatechuyoko*{a}\tatechuyoko*{b}\tatechuyoko*{c}`

### 処理対象要素

- **段落（Para）**: 段落内の直接子Str要素
- **見出し（Header）**: 見出し内の直接子Str要素
- **HTML要素内は処理されない**: `<span>abc</span>` → 処理対象外（markdown形式）

## 使用方法

### 個別フィルタ使用

```bash
pandoc input.md \
  --lua-filter=tatechuyoko/halfwidth-letter-filter.lua \
  --lua-filter=tatechuyoko/halfwidth-number-filter.lua \
  --lua-filter=tatechuyoko/halfwidth-symbol-filter.lua \
  -t latex
```

### ja-novel-filter統合使用（推奨）

```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -t latex
```

## 制限事項

### 対応形式
- **LaTeX出力のみ**: `-t latex` でのみ動作
- **markdown形式推奨**: HTML要素の除外が正しく動作

### GFM形式での制限
⚠️ **GFM形式（`-f gfm`）使用時の注意**: 
HTML要素（`<span>`など）内の文字も処理されてしまいます。
markdown形式（`-f markdown`）の使用を推奨します。

### 記号処理の制限
LaTeX構文との干渉を避けるため、処理対象記号を!と?のみに限定しています。
`@`, `#`, `$`, `%`, `&`, `{`, `}`, `_`, `^`などは処理されません。