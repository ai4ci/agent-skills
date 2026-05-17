This is the preferred set of tools to support agentic R code generation. 

---
## Validation tools (R):

### Syntax & Formatting Validation
- [Air CLI Tool](https://github.com/posit-dev/air) (`air format --check .`): A high-speed, Rust-powered R formatter by Posit. It provides deterministic formatting, standardizes line wraps, and formats files via `uv` without requiring global system changes.
## Deep Namespace & Syntax Checking
- [lintr](https://lintr.r-lib.org/) (`Rscript -e "lintr::lint_dir()"`): Performs deep semantic evaluation. It catches complex programming issues like undefined object namespaces, unexported properties, and unused packages.
- [Jarl](https://github.com/etiennebacher/jarl) (`jarl check .`): A blazingly fast R linter built in Rust. Heavily influenced by `lintr` rules, it runs orders of magnitude faster and supports automated syntax fixes via the CLI.
- `codetools` (`Rscript -e "codetools::checkUsagePackage('pkg')"`): Native programmatic utility to inspect package environments for incorrect scoping or symbol assignment failures.
### Testing & Assertion
- testthat (`Rscript -e "testthat::test_local(reporter = testthat::JunitReporter$new(file = 'test-results.xml'))"`): The definitive testing suite framework for R. Emits machine-readable JUnit XML outputs containing exact stack traces.
- `devtools::run_examples()`: Executes code chunks defined within your documentation example segments to confirm they run without crashes.
### Dependency & Vulnerability Scans
- renv (`Rscript -e "renv::status()"`): Validates lockfile integrity, flags missing dependencies, and tracks environment drift.
### Code coverage
- covr (`Rscript -e "write.csv(as.data.frame(covr::package_coverage()), 'coverage.csv')"`): Evaluates test coverage pathways across local files and dumps execution maps directly into structured tables.
### Documentation consistency
- roxygen2 (`Rscript -e "devtools::document()"`): Translates inline comment structures into formal `.Rd` documentation layout files, highlighting broken crosses or missing parameter definitions.
### Code duplication
- jscpd (`bunx jscpd "R/**/*.R"`): Scans R script directories to isolate duplicate structural token patterns.
## Profiling
- profvis (`Rscript`): `Rscript -e "p <- profvis::profvis({ source('script.R') }); saveRDS(p, 'profile.rds')"`

---

## Project Setup (R) with `em`

Use the project-local `em` script to standardise how an R project is run, tested, checked, and documented. Keep tool configuration in the native R files. Keep orchestration in `em`.

### 1. Dependency Installation

R environments use the native package manager to track packages, while tools such as Air and Jarl provide fast CLI checks:

```bash
# Install core verification and testing tools inside R
Rscript -e "install.packages(c('devtools', 'lintr', 'testthat', 'covr', 'roxygen2', 'renv'))"

curl --proto '=https' --tlsv1.2 -LsSf https://github.com/posit-dev/air/releases/latest/download/air-installer.sh | sh

# Install high-speed Rust binary tools using uv
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/etiennebacher/jarl/releases/latest/download/jarl-installer.sh | sh

```

---

### 2. Configuration Files

#### `air.toml`

Place this configuration at the root of your project directory to dictate global syntax layout rules for the Air formatter:

```toml
[format]
# Enforces a maximum character wrap per line (tidyverse standard)
line-width = 80

# Sets the precise count of spaces to shift an indented block
indent-width = 2
indent-style = "space"
line-ending = "lf"

# Keeps manual line breaks like split pipes intact
persistent-line-breaks = true
default-exclude = true

# Explicit project boundaries the AI engine must skip
exclude = [
  "renv/",      # Isolated local library snapshots
  ".git/",      # Hidden version control trees
  "data/",      # Large localized analysis data blocks
  "scratch/"    # Temporary exploratory scripts
]
```

#### `.lintr`

Configures `lintr` constraints to keep style complaints from conflicting with your Air formatting settings:

```yaml
always_allow_assignment: true
line_length_linter: null
object_usage_linter: ~
```

---

### 3. `em` command mapping

| `em` command | R command                                                                                              | Notes                                                                   |
| ------------ | ------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| `em run`     | `Rscript scripts/run.R` or `Rscript -e "source('main.R')"`                                             | Pick one project entrypoint and keep it documented in `em`.             |
| `em test`    | `Rscript -e "testthat::test_dir('tests/testthat')"`                                                    | Prefer a deterministic script or package test entrypoint.               |
| `em check`   | `air format --check . && jarl check . && Rscript -e "quit(status = length(lintr::lint_dir('.')) > 0)"` | Add `renv::status()` when the project uses `renv.lock`.                 |
| `em doc`     | `Rscript -e "devtools::document()"`                                                                    | For package projects, this should update `.Rd` output and log warnings. |

### 4. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  Rscript scripts/run.R >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  Rscript -e "testthat::test_dir('tests/testthat')" 2>&1 | tee "$TEST_LOG"
}

cmd_check() {
  ensure_em_dir
  {
    air format --check .
    jarl check .
    Rscript -e "quit(status = length(lintr::lint_dir('.')) > 0)"
    [ ! -f renv.lock ] || Rscript -e "quit(status = renv::status()$synchronized == FALSE)"
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  Rscript -e "devtools::document()" >"$DOC_LOG" 2>&1
}
```

### 5. Hooks and CI

Use `./em check` and `./em test` in CI. Hooks may still format staged files directly with `air`, but the full project contract should remain the `em` interface.
