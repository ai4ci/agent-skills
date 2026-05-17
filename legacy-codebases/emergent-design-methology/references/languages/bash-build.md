For an agentic AI validation skill, Bash is arguably the most critical language to lock down with strict tooling. The toolchain must prioritize strict syntax checking, safety flag enforcement, and deterministic code execution. 

---

## Validation tools (Bash):

### Syntax & Formatting Validation
- shfmt (`shfmt -i 2 -sr -d .`): A high-performance shell script formatter and parser written in Go. It cleanly normalizes shell scripts, enforces consistent indentation, standardizes switch cases, and can stream unified diffs directly to the terminal context window.
### Deep Namespace & Syntax Checking
- ShellCheck (`shellcheck -f json script.sh`): The definitive industry-standard static analysis engine for shell scripts. It catches runtime traps, quote escapes, and unassigned variables, while exporting errors as structured JSON records for automated parsing and patching.
### Direct Syntax Checking (No Execution)
- Native Bash Dry-Run (`bash -n script.sh`): The internal parser check built directly into the Bash binary. It acts as an instant, zero-overhead first line of defense that validates block structures, loops, and statement closures without executing the script.
### Testing & Assertion
- Bats-core (`bats -f junit tests/ > test-results.xml`): The Bash Automated Testing System. It executes native shell unit assertions, verifies command exit codes, tracks file system side-effects, and outputs standardized JUnit XML test matrix files.
### Dependency & Vulnerability Scans
- ShellCheck (Secure Coding Rules) (Embedded): Integrated rule matrices natively flag unsafe practices, code injection vectors, and hardcoded secrets within the static analysis step.
### Code coverage
- kcov (`kcov --include-path=. ./coverage-dir bats tests/`): A specialized, low-overhead coverage engine. It intercepts shell code execution via a native Linux debugger engine and pipes the output into standard Cobertura XML profiles.
### Documentation consistency
- shdoc (`shdoc < script.sh > docs.md`): A documentation generator that parses inline code comments (resembling JSDoc layouts) within shell scripts and compiles them into clean Markdown reference files.
### Code duplication
- jscpd (`bunx jscpd "src/**/*.sh"`): Scans script trees to target duplicate bash structural blocks.
### Profiling
- Native Bash Tracing (`BASH_XTRACEFD=3 bash -x script.sh 3> trace.log`): Direct runtime profiling. Captures step-by-step execution metrics and timestamps directly from the environment core.

---
## Project Setup (Bash):

Here is the complete summary of the environment installation patterns, formatting specifications, and fail-safe directives required to secure Bash scripts inside automated environments.
### 1. Dependency Installation

Install all core shell validation binaries natively using your local operating system package manager, or orchestrate them headlessly inside build environments:

```bash
# On Debian/Ubuntu-based systems
sudo apt-get update && sudo apt-get install -y shellcheck shfmt bats kcov

# On macOS systems via Homebrew
brew install shellcheck shfmt bats-core kcov
```

---
### 2. Configuration Files

#### `.editorconfig`

Because `shfmt` honors standard `.editorconfig` matrices, place this file at your project root to enforce global shell script formatting rules across all tools:

```ini
[*.sh]
# Enforces a standardized layout for shell scripts
extended_syntax = true
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
```

#### `.shellcheckrc`

Configure ShellCheck exclusions at your workspace root to disable rules that conflict with custom environmental profiles or older POSIX standards:

```ini
# ShellCheck Configuration File (.shellcheckrc)
# Disable warning about using local variables in specific formats
disable=SC2034,SC2155

# Enforce strict error reporting rules globally
extended-analysis=true
```

---

## 3. `em` command mapping

| `em` command | Bash command | Notes |
| --- | --- | --- |
| `em run` | `./scripts/run.sh` or `./main.sh` | Pick one project entrypoint and keep it explicit in `em`. |
| `em test` | `bats tests` | Stream to terminal and `.agents/em/test-output`. |
| `em check` | `bash -n` + `shellcheck` + `shfmt -d` | This is the main quality gate for Bash projects. |
| `em doc` | `shdoc` or another shell doc generator | If the project has no doc generator, log that clearly rather than silently succeeding. |

## 4. Example `em` command bodies

```bash
cmd_run() {
  ensure_em_dir
  ./main.sh >"$RUN_LOG" 2>&1
}

cmd_test() {
  ensure_em_dir
  bats tests 2>&1 | tee "$TEST_LOG"
}

cmd_check() {
  ensure_em_dir
  {
    find . -name '*.sh' -exec bash -n {} \;
    find . -name '*.sh' -exec shellcheck {} \;
    shfmt -i 2 -sr -d .
  } 2>&1 | tee "$CHECK_LOG"
}

cmd_doc() {
  ensure_em_dir
  find . -name '*.sh' -exec sh -c 'shdoc < "$1"' _ {} \; >"$DOC_LOG" 2>&1
}
```

## 5. Hooks and CI

Hooks may format changed shell files directly with `shfmt`, but CI and full project validation should call `./em check` and `./em test`.

---

## The Agentic Bash "Safety First" Directive

Every shell script generated or modified by an automated validation system must explicitly declare a strict fail-safe directive block at the absolute top of the file:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `-e`: Immediately exits if any command returns a non-zero exit status (halts cascading failures).
- `-u`: Exits instantly if the script attempts to evaluate an unassigned variable (prevents destructive commands).
- `-o pipefail`: Propagates pipeline errors, forcing execution to fail if _any_ command within a pipe chain fails.

