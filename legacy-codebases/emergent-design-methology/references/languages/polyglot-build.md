When utilizing Panache as an orchestrator, it extracts code segments into ephemeral text streams and feeds them to CLI engines via standard input (`stdin`). For tools like `ruff` or `shfmt`, you must explicitly supply trailing dashes (`-`) or strict placeholder configurations directly within your `panache.toml` to prevent the binaries from silently failing or attempting to scan the disk for files.

---
## Polyglot Validation Tools & Orchestration (Quarto / RMarkdown):

## Core Mixed-Content Router

To enable language-aware formatting and linting of embedded code chunks without flattening Pandoc-specific syntaxes, use Panache as the master orchestrator. Configure your root `panache.toml` file to handle your specific high-speed toolchains: [2]

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

---

## Multi-Language Formatting Rules for Agents

## 1. R Code Blocks

- Target Engine: [Air](https://github.com/posit-dev/air) via `air format -`.
- Rule Constraint: Formats native pipes (`|>`) and tidyverse conventions to a strict 2-space baseline with persistent line-breaks enabled. [6]

## 2. Python Code Blocks

- Target Engine: [Ruff](https://docs.astral.sh/uv/) via `ruff format --stdin-filename=cell.py -`.
- Rule Constraint: The `--stdin-filename` flag is mandatory. It forces Ruff to process standard input streams as Python syntax, ensuring PEP 8 conformity and strict 88-character wrapping. [7]

## 3. Bash/Shell Code Blocks

- Target Engine: `shfmt` via `shfmt -i 2 -sr -`.
- Rule Constraint: The trailing dash `-` forces the binary to intercept standard input, aligning block control indentation loops to 2 spaces and streamlining output redirections.

## 4. SQL Code Blocks

- Target Engine: `sleek` or `sql-formatter`.
- Rule Constraint: Normalizes query text structures inside blocks, converting primary clauses to uppercase and structuring joins on the left margin.

## 5. JavaScript Code Blocks

- Target Engine: `prettier --parser babel`.
- Rule Constraint: Instructs Prettier to evaluate arbitrary JavaScript string components, guaranteeing trailing comma arrays and uniform quoting primitives.

---

## Project Setup (Polyglot Markdown):

## 1. Dependency Installation

Install Panache along with the target formatting binaries using your local project tools:

```bash
# Install the Rust-powered orchestrator and R formatter via uv
uv tool install panache
uv tool install air-formatter

# Install web and shell syntax formatting utilities via bun
bun add --dev prettier sql-formatter

# Ensure system paths have native binaries available
# e.g., ruff, shfmt, sleek, or jarl
```

---

## 2. Integrated Scripts (`package.json` proxy layer)

Map your multi-language checking routines into your core `package.json` setup to supply your automation scripts with a uniform validation workflow:

```json
"scripts": {
  "lint": "panache lint .",
  "format": "panache format .",
  "format:check": "panache format --check ."
}
```

---

## 3. Running the Ecosystem Commands

- `bun run lint` — Sequentially executes language-specific diagnostics (like `jarl` and `ruff`) across all embedded code cells in parallel, tracking down unused variables or circular hooks.
- `bun run format` — Extracts individual code fences into temporary memory layers, formats them using your custom configuration tools, and swaps the valid code back into the parent Markdown file.
- `bun run format:check` — Scans `.qmd` and `.Rmd` workspaces, returning a non-zero exit code if either text blocks or raw code cells violate structure guidelines. [4, 5, 8]

---

## Git Workflow Integration (Polyglot expansion)

Incorporate polyglot routing validation blocks directly into your project's `lefthook.yml` file to handle your raw analytical workbooks securely beside your source codebase:

```yaml
pre-commit:
  commands:
    # Task 1: Check and auto-correct multi-language code fences via Panache
    format-polyglot:
      glob: "*.{qmd,Rmd,md}"
      run: panache format {staged_files} && git add {staged_files}

    # Task 2: Lint text structures and run structural cell validations
    lint-polyglot:
      glob: "*.{qmd,Rmd,md}"
      run: panache lint {staged_files}
```

