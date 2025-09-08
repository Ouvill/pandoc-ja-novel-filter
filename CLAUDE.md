# Claude Code Development Guide

## プロジェクト概要
日本語小説をPandocで処理し、適切なタイポグラフィーでLaTeX/PDF変換するためのLuaフィルタ集

## ファイル構成
- `ja-novel-filter.lua`: 統合フィルタ（推奨使用）
- `dakuten.lua`: 濁点処理
- `kakuyomu_ruby.lua`: ルビ注釈処理
- `kenten-filter.lua`: 圏点処理
- `number-filter.lua`: 数字フォーマット
- `break-filter.lua`: 改行・場面転換処理
- `utils.lua`: 共通ユーティリティ関数

## テスト実行
```bash
# 個別テスト
lua5.3 tests/dakuten_test.lua
lua5.3 tests/kakuyomu_ruby_test.lua
lua5.3 tests/kenten_filter_test.lua
lua5.3 tests/number_filter_test.lua
lua5.3 tests/break_filter_test.lua

# 全テスト実行（手動）
for test in tests/*_test.lua; do lua5.3 "$test"; done
```

## 使用例
```bash
# 統合フィルタ使用（推奨）
pandoc input.md --lua-filter=ja-novel-filter.lua -o output.tex

# 単独フィルタ使用
pandoc input.md --lua-filter=dakuten.lua -o output.tex
```

## 開発時の注意点
1. フィルタの実行順序は重要（ja-novel-filter.luaで定義済み）
2. Lua 5.3以上が必要
3. テストデータは `testdata/` ディレクトリに配置
4. 新機能追加時は対応するテストファイルも作成
5. LaTeX出力にはpxrubrica, bxghostパッケージが必要

## デバッグ
- `print()` を使用してデバッグ出力
- テストファイルで単体テスト実行
- `pandoc --lua-filter=filter.lua --to=native` でAST確認可能