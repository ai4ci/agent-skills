
Integrating [uv](https://docs.astral.sh/uv/) and `uvx` (the ultra-fast Python project and tool manager written in Rust) replaces slow `pip` operations, eliminates manual virtual environment management, and completely simplifies your local environment tracking. 

---
## Validation tools (Python with uv):

### Syntax & Formatting Validation
- Ruff (`uv run ruff format` / `uv run ruff check`): A blazing-fast Rust-based linter and formatter. It instantly parses code, replaces Black/Flake8, and formats your file tree dynamically. [3]
### Strict Type-Checking
- mypy (`uv run mypy .`): Validates strict static typing signatures across your code paths.
### Testing & Assertion
- pytest (`uv run pytest --junitxml=report.xml`): Runs your validation suites without manual virtual environment activations. [2]
### Logging
- Use the Python standard library `logging` module as the default. Add `structlog` only when the project explicitly needs structured JSON logging beyond the built-in handlers and formatters.
### Dependency & Vulnerability Scans
- Pip-audit (`uvx pip-audit`): Runs in an ephemeral container using `uvx` to audit locked packages against the PyPA vulnerability database without cluttering your environment.
- Unused dependencies: deptry (`uv run deptry .`): Finds missing declarations, unused dependencies, and transitive leaks inside your workspace. [3, 5, 6]
### Code coverage
- coverage.py (`uv run coverage run -m pytest && uv run coverage xml`): Evaluates your total file execution path.
### Documentation consistency
- pydoclint (`uv run pydoclint .`): A specialized linter that strictly cross-references Python docstrings (Google/Sphinx style) against code parameters to prevent documentation drift.
## Code duplication
- jscpd (`bunx jscpd "src/**/*.py"`): Scans and isolates identical code sequences.
### Profiling
- cProfile (`uv run python -m cProfile -o profile.prof main.py`): Performs zero-overhead execution trace dumps.

---

## Project Setup (Python with uv) using `em`

Use `uv` as the Python toolchain, but expose it through the project-local `em` script. `pyproject.toml` is the source of truth for tool configuration. `em` is the source of truth for how the project is run, tested, checked, and documented.

### 1. Initialise and install dependencies

```bash
# Initialize project structure
uv init .

# Add primary/runtime dependencies
uv add pydantic requests

# Add all developer and verification tools directly to development groups
uv add --dev ruff mypy pytest deptry coverage pydoclint mkdocs-material mkdocstrings[python]
```

`uv` creates and maintains `.venv` and `uv.lock` for you. Keep that behaviour inside the normal project workflow and do not wrap it in extra ad-hoc shell scripts.

---

### 2. Configuration Files

#### `pyproject.toml`

Your `pyproject.toml` consolidates tool arguments natively into a unified configuration file. 

```toml
[project]
name = "python-agentic-app"
version = "0.1.0"
description = "Python workspace verified via uv"
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0.0",
    "requests>=2.31.0",
]

[tool.uv]
# Ensures dev dependencies stay explicitly tracked
dev-dependencies = [
    "coverage>=7.0.0",
    "deptry>=0.12.0",
    "mkdocs-material>=9.5.0",
    "mkdocstrings[python]>=0.24.0",
    "mypy>=1.8.0",
    "pydoclint>=0.3.0",
    "pytest>=8.0.0",
    "ruff>=0.2.0",
]

[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "W", "I"]

[tool.mypy]
strict = true
ignore_missing_imports = true
exclude = [".venv", "docs", "tests"]

[tool.pydoclint]
style = "google"
check-type-hints = true
check-return-types = true
```

#### `mkdocs.yml`

Configures MkDocs alongside `mkdocstrings` to dynamically extract your verified code headers into documentation. [11]

```yaml
site_name: Python API Documentation
theme:
  name: material

plugins:
  - search
  - mkdocstrings:
      handlers:
        python:
          paths: [src]
          options:
            show_source: true
            show_root_heading: true
```

### 3. `em` command mapping

| `em` command | Python command | Notes |
| --- | --- | --- |
| `em run` | `uv run python -m your_package` or `uv run your-console-script` | Set the project entrypoint once in `em` and keep it documented. |
| `em test` | `uv run pytest` | Use `tee` so output goes to the terminal and `.agents/em/test-output`. |
| `em check` | `uv run ruff check . && uv run mypy . && uv run deptry . && uvx pip-audit` | Add or remove checks to match the project. |
| `em doc` | `uv run pydoclint . && uv run mkdocs build --strict` | Capture warnings and errors in `.agents/em/docs-output`. |

---

### 4. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  uv run python -m your_package >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  uv run pytest 2>&1 | tee "$TEST_LOG"
}

cmd_check() {
  ensure_em_dir
  {
    uv run ruff check .
    uv run mypy .
    uv run deptry .
    uvx pip-audit
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  {
    uv run pydoclint .
    uv run mkdocs build --strict
  } >"$DOC_LOG" 2>&1
}
```

Replace `your_package` with the real module or console script. Avoid per-agent variations. The entrypoint belongs in `em`.

### 5. Hooks and CI

CI and local hooks should invoke `./em check` and `./em test`. File-scoped hook commands are fine, but they should reuse the same toolchain and configuration already exercised by `em`.
