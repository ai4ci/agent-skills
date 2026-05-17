
Emergent design projects must be version controlled with `git`. If the project is not already versioned controlled, a `git init` must be performed.
## Project structure

* 1) `design`
	- `SCOPE.md`
	- `features`:  (as-is and to-be) - ([[feature]] template)
	- `issues`
	- `external-interfaces`: api and database structures
	- `test-scripts` - ([[test-script]] template)
	- `prototypes` -  ([[prototype]] template)
	- `methods` - ([[method]] template)
	- `implementation` 
		- `OVERVIEW.md`
		- `notes` - as-is notes ([[implementation-notes]] template)
		- `COMPONENT-APIS.md` - Internal interfaces
* 2) `architecture`
	- `FRAMEWORK.md`
	- `decision-records` ([[adr]] template)
	- `STANDARDS.md`
* 3) Production code (language specific layout)
	- Source code
	- Unit tests
	- Test data
	- Integration tests
	- Continuous integration workflows
* 4) `skills` - (see `create-new-skill` meta skill)
	- `installing-<project>` - installation instructions
	- `getting-started-with-<project>` - instructions on downstream use of the project
	- `extending-<project>` - instructions on extending the project
- 5) Documentation (language specific layout - usually `docs`)
	- User documentation
	- `README.md`
	- `CONTRIBUTING.md`

```bash
mkdir -p design
touch design/SCOPE.md
mkdir -p design/features 
mkdir -p design/external-interfaces
mkdir -p design/test-scripts
mkdir -p design/prototypes
mkdir -p design/methods
mkdir -p design/implementation
touch implementation/OVERVIEW.md
mkdir -p design/implementation/notes
touch -p design/implementation/COMPONENT-APIS.md
mkdir -p architecture
touch architecture/FRAMEWORK.md
mkdir architecture/decision-records
touch architecture/STANDARDS.md
mkdir -p skills
mkdir -p skills/installing-<project>
mkdir -p skills/getting-started-with-<project>
mkdir -p skills/extending-<project>
```
## The `em` script - A unified interface to build tools

`em` is a bash script that must exist in the root of a emergent design project. Its purpose is to provide a language independent interface to basic build tools. It is created by you as an AI agent and **MUST** provide at least the following features, which both you and the developer will use:

* `em` on its own or `em --help` provides a list of supported sub-commands.
* `em run` builds and executes the project using a sane set of defaults, logging output to `.agents/em/log`
* `em test` builds and runs all the automated test scripts associated with a project writing output to terminal and to a file `.agents/em/test-output`
* `em doc` runs documentation tools reporting warnings and errors to `.agents/em/docs-output`
* `em check` runs linters and code quality checks providing a report to `.agents/em/check-output`

`em` outputs in `.agents/em` are intended to be easily versioned using git. This enables a checkpoint for test results or code quality checks to be managed with the code so that failing test results, changes from the committed versions can be easily inspected with `git diff` (or for timestamped log files `diff -u -I 'your-timestamp-regex' <(git show HEAD:.agents/em/log) .agents/em/log`)

Optionally the `em` script can contain any additional commands that you or the developer find useful to implement for streamlining the build of the project. You might want to implement a `--delta` flag such that the output of the `run`/`test`/`check`/`doc` sub-commands is compared to pre-existing results. Just so long as it is documented.

A skeleton `em` script is as follows:

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration & Paths ---
EM_DIR=".agents/em"
RUN_LOG="$EM_DIR/log"
TEST_LOG="$EM_DIR/test-output"
DOC_LOG="$EM_DIR/docs-output"
CHECK_LOG="$EM_DIR/check-output"

# --- Helper Functions ---
ensure_em_dir() {
    mkdir -p "$EM_DIR"
}

show_help() {
    echo "Usage: em <command> [options]"
    echo ""
    echo "Supported sub-commands:"
    echo "  run     Builds and executes the project (logs to $RUN_LOG)"
    echo "  test    Builds and runs all automated tests (outputs to terminal and $TEST_LOG)"
    echo "  doc     Runs documentation tools (logs warnings/errors to $DOC_LOG)"
    echo "  check   Runs linters and code quality checks (logs report to $CHECK_LOG)"
    echo "  help    Show this help message"
}

# --- Sub-command Implementations ---

cmd_run() {
    echo "Starting 'run' command..."
    ensure_em_dir

    # TODO: Add your project's build and execute logic here
    # Example: npm run build && npm start >> "$RUN_LOG" 2>&1
    
    echo "Executing project with default configurations..." >> "$RUN_LOG"
    
    # Simulate work
    echo "[STUB] Project execution logic goes here" >> "$RUN_LOG"
    echo "Run complete. Output logged to $RUN_LOG"
}

cmd_test() {
    echo "Starting 'test' command..."
    ensure_em_dir

    # Using 'tee' to send output to both the terminal and the log file
    echo "Building and running automated tests..." | tee "$TEST_LOG"
    
    # TODO: Add your project's test suite command here
    # Example: pytest 2>&1 | tee -a "$TEST_LOG"
    
    echo "[STUB] Test suite execution logic goes here" | tee -a "$TEST_LOG"
    echo "Test suite complete. Output saved to $TEST_LOG"
}

cmd_doc() {
    echo "Starting 'doc' command..."
    ensure_em_dir

    echo "Running documentation tools..."
    
    # TODO: Add your project's documentation tool here (e.g., Doxygen, Sphinx, TypeDoc)
    # Redirect stderr (warnings/errors) to the doc log, stdout to /dev/null or terminal
    {
        echo "[STUB] Documentation tool warnings/errors will appear below:"
        # Example command: sphinx-build -b html docs/ source/ 2>&1 >/dev/null
    } > "$DOC_LOG"

    echo "Documentation generation complete. Warnings/errors logged to $DOC_LOG"
}

cmd_check() {
    echo "Starting 'check' command..."
    ensure_em_dir

    echo "Running linters and code quality checks..."
    
    # TODO: Add your project's linters here (e.g., eslint, flake8, shellcheck)
    {
        echo "Code Quality Report - $(date)"
        echo "-----------------------------------"
        echo "[STUB] Linter tool reports go here"
        # Example command: shellcheck em
    } > "$CHECK_LOG"

    echo "Code quality check complete. Report written to $CHECK_LOG"
}

# --- Main Argument Parsing ---

# If no arguments are passed, default to help
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Parse the first argument as the sub-command
COMMAND="$1"
shift # Remove the command from the argument list, leaving sub-arguments in "$@"

case "$COMMAND" in
    run)
        cmd_run "$@"
        ;;
    test)
        cmd_test "$@"
        ;;
    doc)
        cmd_doc "$@"
        ;;
    check)
        cmd_check "$@"
        ;;
    --help|help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$COMMAND'" >&2
        echo "" >&2
        show_help >&2
        exit 1
        ;;
esac
```

Language specific frameworks 
### `em` launcher

A launcher script must be installed to `~/.local/bin/em` which allows the project specific `em` command to be run from anywhere in the emergent project directory. 

```bash
#!/bin/bash

# Get the absolute path of the current directory
current_dir=$(pwd)

# Loop upwards until the root directory is reached
while [ "$current_dir" != "$HOME" ]; do
    # Check if the file "em" exists and is executable in the current loop directory
    if [ -x "$current_dir/em" ]; then
        # Move into the target directory
        cd "$current_dir" || exit 1
        # Execute the script with all passed arguments
        exec "./em" "$@"
    fi
    # Move up one level in the directory tree
    current_dir="${current_dir%/*}"
done

echo "Error: 'em' script not found in the current or any parent directories." >&2
exit 1
```
