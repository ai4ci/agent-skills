
Integrating [uv](https://docs.astral.sh/uv/) and `uvx` (the ultra-fast Python project and tool manager written in Rust) replaces slow `pip` operations, eliminates manual virtual environment management, and completely simplifies your local environment tracking. 

---
## Validation tools (Python with uv):

### Syntax & Formatting Validation
- Ruff (`uv run ruff format` / `uv run ruff check`): A blazing-fast Rust-based linter and formatter. It instantly parses code, replaces Black/Flake8, and formats your file tree dynamically. [3]
### Strict Type-Checking
- mypy (`uv run mypy .`): Validates strict static typing signatures across your code paths.
### Testing & Assertion
- pytest (`uv run pytest --junitxml=report.xml`): Runs your validation suites without manual virtual environment activations. [2]
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

## Project Setup (Python with uv):

This approach uses a centralized `pyproject.toml` managed completely via `uv`. 
### 1. Initialize and Install Dependencies [4]

To set up a greenfield project or convert an existing directory, run the initialization command to generate your layout, then add the package structures using `uv`:

```bash
# Initialize project structure
uv init .

# Add primary/runtime dependencies
uv add pydantic requests

# Add all developer and verification tools directly to development groups
uv add --dev ruff mypy pytest deptry coverage pydoclint mkdocs-material mkdocstrings[python]
```

_(Note: `uv` will instantly build a tracking `.venv` and maintain a deterministic `uv.lock` file in the background)._

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

### 3. Running Ecosystem Commands Natively via `uv` 

`uv run` automatically locks and matches your execution context to the internal project tree without requiring tool prefix activations: 

- **Lint and check docstrings on a target file:** `uv run ruff check src/main.py && uv run pydoclint src/main.py`
- **Format a targeted path or directory:**: `uv run ruff format src/main.py`
- **Run an isolated strict type compliance evaluation:** `uv run mypy src/main.py`
- **Compile inline docstrings into documentation markdown files:** `uv run mkdocs build --site-dir docs`

---

## Git Workflow Integration (Python with uv) [9]

Update your root `lefthook.yml` workflow configuration file to evaluate your Python codebase natively using `uv run`:

```yaml
pre-commit:
  commands:
    # Task 1: Check and fix Python code formatting via ruff
    format-python:
      glob: "*.py"
      run: uv run ruff format {staged_files} && git add {staged_files}

    # Task 2: Validate code compliance and check documentation parameters
    lint-python:
      glob: "*.py"
      run: uv run ruff check {staged_files} && uv run pydoclint {staged_files} && uv run mypy {staged_files}
```

