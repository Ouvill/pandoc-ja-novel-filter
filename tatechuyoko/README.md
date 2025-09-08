# Tatechuyoko Filters

縦書きでの半角英数字記号を縦中横処理するためのPandocフィルタ集

## 概要

縦書きの日本語文書で半角英数字記号が90度回転してしまう問題を解決し、適切な縦中横（tatechuyoko）処理を行います。

## フィルタ構成

### 統合フィルタ（推奨）

各文字種の完全な処理を1つのフィルタで行います：

- **halfwidth-letter-filter.lua** - 半角英字処理
- **halfwidth-number-filter.lua** - 半角数字処理  
- **halfwidth-symbol-filter.lua** - 半角記号処理

### 分割フィルタ（高度な用途）

処理を2段階に分けた柔軟なアプローチ：

#### 2文字グルーピング
- **two-char-letter-filter.lua** - 2文字英字グループ化
- **two-char-number-filter.lua** - 2文字数字グループ化
- **two-char-symbol-filter.lua** - 2文字記号グループ化

#### 基本処理
- **basic-letter-filter.lua** - 全英字を個別処理
- **basic-number-filter.lua** - 全数字を個別処理
- **basic-symbol-filter.lua** - 全記号を個別処理

### ユーティリティ

- **tatechuyoko-utils.lua** - 統合フィルタ用共通関数
- **two-char-tatechuyoko-utils.lua** - 2文字処理用関数
- **basic-tatechuyoko-utils.lua** - 基本処理用関数

## 動作仕様

- **1文字**: `a` → `\tatechuyoko*{a}`
- **2文字連続のみ**: `ab` → `{\small\tatechuyoko*{ab}}`
- **3文字以上**: `abc` → `\tatechuyoko*{a}\tatechuyoko*{b}\tatechuyoko*{c}`

## 使用方法

### 統合フィルタ（簡単）

```bash
pandoc input.md \
  --lua-filter=tatechuyoko/halfwidth-letter-filter.lua \
  --lua-filter=tatechuyoko/halfwidth-number-filter.lua \
  --lua-filter=tatechuyoko/halfwidth-symbol-filter.lua \
  -t latex
```

### 分割フィルタ（詳細制御）

```bash
pandoc input.md \
  --lua-filter=tatechuyoko/two-char-letter-filter.lua \
  --lua-filter=tatechuyoko/two-char-number-filter.lua \
  --lua-filter=tatechuyoko/two-char-symbol-filter.lua \
  --lua-filter=tatechuyoko/basic-letter-filter.lua \
  --lua-filter=tatechuyoko/basic-number-filter.lua \
  --lua-filter=tatechuyoko/basic-symbol-filter.lua \
  -t latex
```

## 注意事項

- LaTeX出力形式でのみ動作します
- HTML要素（`<span>`など）内の文字はスキップされます
- 分割フィルタ使用時は、2文字処理を基本処理より先に実行してください