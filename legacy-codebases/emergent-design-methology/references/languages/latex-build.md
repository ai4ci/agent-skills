Here is your LaTeX validation framework, expanded and refactored to align with the exact layout, structure, and visual style used across your previous language specifications.

---

## Validation tools (LaTeX):

## Syntax & Formatting Validation

- latexindent (`latexindent -w document.tex`): The definitive formatting engine for LaTeX documents. It cleanly normalizes deep nesting structures, standardizes indentation blocks, wraps paragraphs systematically, and can be configured via YAML rules.

## Deep Namespace & Syntax Checking

- ChkTeX (`chktex -w document.tex`): A high-performance static analysis linter for LaTeX. It isolates typographic errors, illegal character escapes, unclosed bracket clusters, and math-mode syntax traps, outputting clean text logs for automated agent parsing.
- lacheck (`lacheck document.tex`): A complementary structural syntax checker. It focuses strictly on finding mismatched context environments, broken macro clusters, and invalid font switching behaviors.

## Direct Compilation Checking (No PDF Generation Overhead)

- Native Engine Draft-Run (`pdflatex -draftmode -interaction=nonstopmode document.tex`): The internal parser check built straight into the native engine. It runs a lightning-fast dry-run compilation that populates reference tables and checks structural packages without the overhead of rendering physical target pages.

## Testing & Assertion

- l3build (`l3build check`): The standard regression testing and assertion toolchain for LaTeX workflows. It headlessly compiles document segments, cross-references internal structures, evaluates package dependency chains, and outputs machine-readable assertion reports.

## Dependency & Vulnerability Scans

- Texlive-chktex / custom rules (Embedded): Static regex checking routines actively scan package imports (`\usepackage`) to flag insecure execution practices, deprecated macro libraries, and shell-escape properties (`-shell-escape`).

## Code coverage

- l3build target metrics: Measures configuration pathway testing parameters. It captures exact execution coverage loops over core macro files (`.dtx` / `.sty`) and pipes results into structured trace summaries.

## Documentation consistency

- DocStrip (`tex document.ins`): The native documentation and package generation utility. It automatically extracts inline programming explanations from master files and strips away non-functional text structures to ensure source comments match deployed package architectures.

## Code duplication

- jscpd (`bunx jscpd "src/**/*.tex"`): Identifies copy-pasted layout tables, repeated mathematical configurations, or duplicate macro blocks across separate chapters and document segments.

## Profiling

- Native TeX Profiling (`pdflatex -traceonly document.tex`): Direct performance tracking. Captures deep memory management valuations, engine font allocations, and macro expansion stack trace timestamps directly into a trace log file.

---

## Project Setup (LaTeX) with `em`

For LaTeX projects, the primary artefact is usually documentation. `em` should still present the same build interface, but `run` should build the main deliverable and `doc` should report documentation warnings or package-doc generation issues.

## 1. Dependency Installation

Install the core LaTeX tools used by the repository:

```bash
# On Debian/Ubuntu-based systems
sudo apt-get update && sudo apt-get install -y texlive-extra-utils chktex lacheck texlive-latex-extra latexmk

# On macOS systems via Homebrew (MacTeX utility core package layer)
brew install --cask mactex-no-gui
```

---

## 2. Configuration Files

## `localindentconfig.yaml`

Place this configuration at the root of your project workspace to govern global indent settings and layout behaviors for `latexindent`:

```yaml
# latexindent configuration file (localindentconfig.yaml)
defaultIndent: "  "
indentAfterHeadings:
  part: 1
  chapter: 1
  section: 1
indentAfterItems:
  item: 1
modifyLineBreaks:
  textWrapOptions:
    columns: 80
    blocksOfText: 1
```

## `.chktexrc`

Configure your ChkTeX ignore paths and operational warnings at your workspace root to filter out non-critical stylistic complaints:

```ini
# ChkTeX Configuration File (.chktexrc)
CmdLine
{
    # Silence specific non-critical typographic style warnings
    -w1 -w3 -w8
}
```

## `.prettierignore` / Global Exclusions

Ensure auxiliary compiler files, log artifacts, and intermediate font maps are safely bypassed during formatting checks:

```text
.git/
*.aux
*.log
*.out
*.toc
*.pdf
```

---

## 3. `em` command mapping

| `em` command | LaTeX command | Notes |
| --- | --- | --- |
| `em run` | `latexmk -pdf main.tex` | Build the primary PDF or report artefact. |
| `em test` | `l3build check` or a draft compile smoke test | Use `l3build` for package projects. |
| `em check` | `latexindent` check + `chktex` + `pdflatex -draftmode` | Run syntax and formatting gates without a full render when possible. |
| `em doc` | `tex document.ins`, `latexmk`, or other package-doc build | If the main deliverable is already the documentation, log that clearly. |

## 4. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  latexmk -pdf main.tex >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  if [ -f build.lua ]; then
    l3build check 2>&1 | tee "$TEST_LOG"
  else
    pdflatex -draftmode -interaction=nonstopmode main.tex 2>&1 | tee "$TEST_LOG"
  fi
}

cmd_check() {
  ensure_em_dir
  {
    latexindent -n -c=. ./*.tex
    chktex ./*.tex
    pdflatex -draftmode -interaction=nonstopmode main.tex
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  if [ -f document.ins ]; then
    tex document.ins >"$DOC_LOG" 2>&1
  else
    echo "Primary artefact is the documentation. Use 'em run' to build it." >"$DOC_LOG"
  fi
}
```

## 5. Hooks and CI

Hooks may format staged `.tex` files directly. CI should call `./em check` and either `./em test` or `./em run`, depending on whether the project is a package or a document.
