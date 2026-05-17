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

## Project Setup (R):

Here is the complete summary of all configuration files and environment scripts required to enable strict R linting, unified formatting rules, and automated validation.

### 1. Dependency Installation

R environments use the native package manager to track system extensions, while utilizing `uv` for Rust-backed tools:

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

#### `.prettierignore` / Global Exclusions

Maintain your global file block targets to filter out build artifacts:

```text
renv/
.git/
data/
scratch/
*.csv
*.xml
```

---

### 3. Integrated Scripts (`package.json` proxy layer)

Route standard script paths into a `package.json` manifest to provide your automated agents with a uniform execution pattern:

```json
"scripts": {
  "lint": "Rscript -e \"write.csv(as.data.frame(lintr::lint_dir(path = '.')), 'lint-errors.csv', row.names = FALSE)\"",
  "format": "air format .",
  "format:check": "air format --check .",
  "docs:generate": "Rscript -e \"devtools::document()\""
}
```


---
### 4. Running the Ecosystem Commands

- `bun run lint` — Runs deep semantic linting and exports issues to a flat CSV file.
- `bun run format` — Instantly applies formatting modifications matching your `air.toml` file.
- `bun run format:check` — Throws an error code if formatting conventions are violated.
- `bun run docs:generate` — Compiles inline comment properties into `.Rd` references.

---

## Git Workflow Integration (R expansion)

Incorporate R's validation tools into your root `lefthook.yml` file to handle your data analysis files seamlessly alongside your other languages:

```yaml
pre-commit:
  commands:
    # Task 1: Check and fix R code formatting layout via Air
    format-r:
      glob: "*.R"
      run: uvx --from air-formatter air format {staged_files} && git add {staged_files}

    # Task 2: Validate code logic and compile structural JUnit reports
    lint-r:
      glob: "*.R"
      run: Rscript -e "if(any(nrow(lintr::lint_dir())) > 0) stop('Lint failures found.')"
```

---
