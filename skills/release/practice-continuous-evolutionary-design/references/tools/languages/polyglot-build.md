When utilizing [Panache](https://github.com/jolars/panache) as an orchestrator, it extracts code segments into ephemeral text streams and feeds them to CLI engines via standard input (`stdin`). For tools like `ruff` or `shfmt`, you must explicitly supply trailing dashes (`-`) or strict placeholder configurations directly within your `panache.toml` to prevent the binaries from silently failing or attempting to scan the disk for files.

---
## Polyglot Validation Tools & Orchestration (Quarto / RMarkdown):

### Core Mixed-Content Router

To enable language-aware formatting and linting of embedded code chunks without flattening Pandoc-specific syntaxes, use Panache as the master orchestrator. Configure your root `panache.toml` file to handle your specific high-speed toolchains:

```toml
# ==============================================================================
# Panache Unified Orchestration Config (panache.toml)
# Placed at the project root to map polyglot code block execution.
# ==============================================================================

[format]
# Enforces standard Markdown paragraph text wrapping
text-width = 80
end-of-line = "lf"

[formatters]
# Note: Panache passes blocks via stdin. Explicitly define configuration shapes:
r          = "air format -"
python     = "ruff format --stdin-filename=cell.py -"
bash       = "shfmt -i 2 -sr -"
sql        = "sleek"
javascript = "prettier --parser babel"

[linters]
# Maps internal code fences to static code analysis engines
r          = "jarl check -"
python     = "ruff check --stdin-filename=cell.py -"
```

### Logging

- Use the host language default inside each code block rather than inventing a cross-language logging abstraction. Default to `logger` for R chunks, Python `logging` for Python chunks, `pino` for JavaScript or TypeScript chunks, structured shell logging functions for Bash chunks, and database-native logging for SQL chunks. Keep render-level diagnostics in Quarto or RMarkdown build logs.

---

## Multi-Language Formatting Rules for Agents

### 1. R Code Blocks

- Target Engine: [Air](https://github.com/posit-dev/air) via `air format -`.
- Rule Constraint: Formats native pipes (`|>`) and tidyverse conventions to a strict 2-space baseline with persistent line-breaks enabled. [6]

### 2. Python Code Blocks

- Target Engine: [Ruff](https://docs.astral.sh/uv/) via `ruff format --stdin-filename=cell.py -`.
- Rule Constraint: The `--stdin-filename` flag is mandatory. It forces Ruff to process standard input streams as Python syntax, ensuring PEP 8 conformity and strict 88-character wrapping. [7]

### 3. Bash/Shell Code Blocks

- Target Engine: `shfmt` via `shfmt -i 2 -sr -`.
- Rule Constraint: The trailing dash `-` forces the binary to intercept standard input, aligning block control indentation loops to 2 spaces and streamlining output redirections.

### 4. SQL Code Blocks

- Target Engine: `sleek` or `sql-formatter`.
- Rule Constraint: Normalizes query text structures inside blocks, converting primary clauses to uppercase and structuring joins on the left margin.

### 5. JavaScript Code Blocks

- Target Engine: `prettier --parser babel`.
- Rule Constraint: Instructs Prettier to evaluate arbitrary JavaScript string components, guaranteeing trailing comma arrays and uniform quoting primitives.

---

## Project Setup (Polyglot Markdown) with `em`

Use `panache` as the formatter and linter router for mixed-language Markdown files, but expose the workflow through `em`.

### 1. Dependency Installation

```bash
uv tool install panache
uv tool install air-formatter

bun add --dev prettier sql-formatter
```

Ensure the underlying language tools are also installed and available on `PATH`, for example `ruff`, `shfmt`, `jarl`, and `sqlfluff` or `sleek`.

---

### 2. `em` command mapping

| `em` command | Polyglot command | Notes |
| --- | --- | --- |
| `em run` | `quarto render`, `Rscript -e "rmarkdown::render(...)"`, or the repository render command | Use the repository's main render entrypoint. |
| `em test` | Notebook smoke tests or downstream language-specific tests | Pick one documented command and keep it stable. |
| `em check` | `panache lint . && panache format --check .` | This is the primary quality gate for mixed-language docs. |
| `em doc` | `quarto render` or site/book generation | If the main artefact is the documentation, `em run` and `em doc` may intentionally share the same renderer. |

### 3. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  quarto render >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  quarto render --to html 2>&1 | tee "$TEST_LOG"
}

cmd_check() {
  ensure_em_dir
  {
    panache lint .
    panache format --check .
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  quarto render >"$DOC_LOG" 2>&1
}
```

### 4. Hooks and CI

Hooks may format staged `.qmd`, `.Rmd`, or `.md` files directly with `panache format`. CI should call `./em check` and the repository's chosen `./em run` or `./em test` workflow.
