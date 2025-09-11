# Claude Code Development Guide

## プロジェクト概要
日本語小説をPandocで処理し、適切なタイポグラフィーでLaTeX/PDF変換するためのLuaフィルタ集

## ファイル構成
- `ja-novel-filter.lua`: 統合フィルタ（推奨使用）
- `dakuten.lua`: 濁点処理
- `kakuyomu_ruby.lua`: ルビ注釈処理
- `kenten-filter.lua`: 圏点処理
- `tatechuyoko/`: 縦中横処理（半角英数字記号）
  - `halfwidth-letter-filter.lua`: 半角英字の縦中横処理
  - `halfwidth-number-filter.lua`: 半角数字の縦中横処理
  - `halfwidth-symbol-filter.lua`: 半角記号の縦中横処理（!と?のみ）
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
1. **テスト実行必須**: フィルタ変更後は該当する全てのテストを実行すること
2. フィルタの実行順序は重要（ja-novel-filter.luaで定義済み）
3. Lua 5.3以上が必要
4. テストデータは `testdata/` ディレクトリに配置
5. **新機能追加時は対応するテストファイルも作成**
6. LaTeX出力にはpxrubrica, bxghostパッケージが必要
7. HTML要素内の文字は処理しない設計（markdown形式推奨）
8. **フィルタファイル冒頭に仕様コメント記述必須**: 処理内容、変換例を含む説明
9. **コメントの保守**: コード変更時は仕様コメントも同時に更新し、陳腐化を防ぐ

## 縦中横フィルタ（tatechuyoko/）について
- 統合フィルタ方式を採用（Para/Header要素レベル処理）
- GFM形式ではHTML要素除外が困難（制限事項として文書化済み）
- 記号処理はLaTeX干渉回避のため!と?のみに限定

## デバッグ
- `print()` を使用してデバッグ出力
- テストファイルで単体テスト実行
- `pandoc --lua-filter=filter.lua --to=native` でAST確認可能