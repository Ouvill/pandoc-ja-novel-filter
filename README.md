# Pandoc Novel Filter

This repository contains a Pandoc Lua filter for processing novels.

## dakuten.lua

This filter converts characters with a combining dakuten (e.g., "あ゙", "ア゙") into a LaTeX command `\dakuten{...}`. This is useful for typesetting novels with specific formatting for voiced sounds.

For example, the input `あ゙` will be converted to `\dakuten{あ}` in the LaTeX output.

### Usage

To use this filter, specify it with the `--lua-filter` option in your Pandoc command:

```bash
pandoc input.md --lua-filter=dakuten.lua -o output.tex
```

Or for PDF output:

```bash
pandoc input.md --lua-filter=dakuten.lua -o output.pdf
```

You will also need to define the `\dakuten` command in your LaTeX preamble. For example, you can add this to a `preamble.tex` file and include it with `-H preamble.tex`:

**preamble.tex:**
```latex
\usepackage{bxghost}
\newcommand{\dakuten}[1]{%
    \jghostguarded{%
        \leavevmode\hbox to 1\zw{%
            \rensuji{\hbox to 1\zw{#1\hspace*{-.25\zw}゛}}%
        }%
    }%
}
```

Then, the full command would be:
```bash
pandoc input.md --lua-filter=dakuten.lua -H preamble.tex -o output.pdf
```

This example uses the `pxrubrica` package to place the dakuten as ruby text. You can customize the `\dakuten` command to achieve your desired visual effect.

## ja-novel-filter.lua (combined)

If you want to use multiple Japanese novel filters through a single entry point, use `ja-novel-filter.lua` which aggregates individual filters (e.g., `dakuten.lua`). Place additional filter files alongside it and add `include('your-filter.lua')` lines inside `ja-novel-filter.lua`.

Usage:

```bash
pandoc input.md --lua-filter=ja-novel-filter.lua -H preamble.tex -o output.pdf
```

This loads `dakuten.lua` internally, so you don't need to list it separately on the command line.
