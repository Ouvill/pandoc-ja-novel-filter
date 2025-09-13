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

- **半角英字**: A-Z, a-z（個別処理のみ、グループ化なし）
- **半角数字**: 0-9（2文字のみグループ化）
- **半角記号**: ! と ? のみ（2-6文字をグループ化、LaTeX干渉回避のため）

### 文字数別処理ルール

#### 半角英字（個別処理）
- **1文字**: `a` → `\tatechuyoko*{a}`
- **2文字以上**: `abc` → `\tatechuyoko*{a}\tatechuyoko*{b}\tatechuyoko*{c}`

#### 半角数字（2文字のみグループ化）
- **1文字**: `1` → `\tatechuyoko*{1}`
- **2文字**: `12` → `\scalebox{1.0}[0.85]{\tatechuyoko*{12}}`
- **3文字以上**: `123` → `\tatechuyoko*{1}\tatechuyoko*{2}\tatechuyoko*{3}`

#### 半角記号（動的スケーリング）
- **1文字**: `!` → `\tatechuyoko*{!}`
- **2文字**: `!!` → `\scalebox{1.0}[0.85]{\tatechuyoko*{!!}}`
- **3文字**: `!!!` → `\scalebox{1.0}[0.70]{\tatechuyoko*{!!!}}`
- **4文字**: `!!!!` → `\scalebox{1.0}[0.55]{\tatechuyoko*{!!!!}}`
- **5文字以上**: `!!!!!` → `\scalebox{1.0}[0.40]{\tatechuyoko*{!!!!!}}`（最小値0.40）

### スケーリング仕様
縦書きレイアウトにおいて、連続文字の縦方向幅を文字数に応じて動的調整：
- 横スケール: 1.0固定
- 縦スケール: 2文字目から0.85倍、以降0.15倍ずつ減少（最小0.40倍）

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