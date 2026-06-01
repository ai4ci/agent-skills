You've been asked to migrate a project to emergent design or set up a new emergent design project

## Prerequisites

1. Code structure analysis tool: Graphify: R-enabled version: `uv tool install robchallen/graphifyy && graphify install`
2. Code summarization tool: Repomix explorer `npm install -g repomix && npx skills add yamadashy/repomix -g`
3. Emergent design projects must be version controlled with `git`. If the project is not already versioned controlled, a `git init` must be performed.

## Make code quality and build tools available

Select and install a suite of [build tools](../tools/language-specific-build-tools.md) relevant for the project (n.b. you may need build tools for more than one language).

## Project structure

Set up the following folder structure in the root of the project:

1. `design`
	 	* `SCOPE.md`: implemented and planned features
	 	* `features`:  as-is and to-be features
	 	* `external-interfaces`: user interface, api and database structures
	 	* `test-scripts` - test scripts
	 	* `prototypes` - prototypes
	 	* `implementation/plans` - detailed plans for implementation of new features
	 	* `implementation/issues` - issue summaries
	 	* `implementation/debt` - technical debt records
2. `architecture`
	 	* `FRAMEWORK.md` - overarching technical framework description.
	 	* `decision-records` - architectural decision records
	 	* `STANDARDS.md` - code standards
3. Production code (language specific layout)
	 	* Source code
	 	* Unit tests
	 	* Test data
	 	* Integration tests
	 	* Continuous integration workflows
4. `skills` - (see `create-new-skill` meta skill)
	 	* `installing-<project>` - installation instructions
	 	* `getting-started-with-<project>` - instructions on downstream use of the project
	 	* `extending-<project>` - instructions on extending the project
	 	* Other skill directories will be created as needed.
5. Documentation (language specific layout - usually `docs`)
	 	* User documentation
	 	* `README.md`
	 	* `CONTRIBUTING.md`
6. `em` working directory:
        * `.agents/em` - Location for output of code quality and design quality checks.

The following bash commands should do this (substituting <project> for the project name):

```bash
mkdir -p design
touch design/SCOPE.md
mkdir -p design/features 
mkdir -p design/external-interfaces
mkdir -p design/test-scripts
mkdir -p design/prototypes
mkdir -p design/implementation
mkdir -p design/implementation/debt
mkdir -p design/implementation/issues
mkdir -p design/implementation/plans
mkdir -p architecture
touch architecture/FRAMEWORK.md
mkdir architecture/decision-records
touch architecture/STANDARDS.md
mkdir -p skills
mkdir -p skills/installing-<project>
mkdir -p skills/getting-started-with-<project>
mkdir -p skills/extending-<project>
```

## Setup the `em` script

The [`em` script](../tools/em-script.md) is unified interface to build tools specific for this project, and must be found in the root of the project. A skeleton `em` script is as follows:

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
    echo "  test    Builds and runs all automated tests and code coverage (outputs to terminal and $TEST_LOG)"
    echo "  doc     Runs documentation tools (logs warnings/errors to $DOC_LOG)"
    echo "  check   Runs linters and code quality checks (logs report to $CHECK_LOG)"
    echo "  design   Runs design consistency checks (logs report to $DESIGN_LOG)"
    echo "  bump    Updates the version number of the project"
    echo "  help    Show this help message"
}

# --- Sub-command Implementations ---

cmd_run() {
    echo "Starting 'run' command..."
    ensure_em_dir

    # TODO: Add your project's build and execute logic here
    # Example: npm run build && npm start >> "$RUN_LOG" 2>&1
    # Setup logging to allow TRACE and DEBUG logging.
    
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
    # TODO: Include code coverage
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
    # Also code duplication tools.
    {
        echo "Code Quality Report - $(date)"
        echo "-----------------------------------"
        echo "[STUB] Linter tool reports go here"
        # Example command: shellcheck em
    } > "$CHECK_LOG"

    echo "Code quality check complete. Report written to $CHECK_LOG"
}

cmd_design() {
    echo "Starting 'design' command..."
    ensure_em_dir

    echo "Running design consistency checks..." > "DESIGN_LOG"

    # TODO: This path is true for this specific project but will need to be configured correctly per
    # project. If the project is using a standards conformant agent harness and the skills are installed
    # on a per project basis then this should work.
    ".agents/skills/emergent-design-methodology/scripts/design-check.R" | tee -a "$DESIGN_LOG"

}

cmd_bump() {
    echo "Bumping code version..."
    
    # TODO: Add your project specific version management here
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
    design)
        cmd_design "$@"
        ;;
    bump)
        cmd_bump "$@"
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


### Create an `em` launcher (if missing)

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

## Establish a baseline

Run tests and code coverage checks and validate that their output in `.agents/em` is as expected for the maturity level of the project. In legacy projects you may find very many errors.

## Setup code base analysis tools

[Repomix](https://github.com/yamadashy/repomix) packs your entire repository into a single, AI-friendly file. Perfect for when you need to ingest the codebase in one go. 

It can be used without installation via `npx` and it comes with an agent skill that will be used for exploration:

```
npx skills add yamadashy/repomix --skill repomix-explorer
```
[Graphify](https://github.com/robchallen/graphify) is a code structure analysis tool. It helps AI coding assistants understand multi-modal codebases by building a queryable knowledge graph from code, docs, papers and diagrams.

This fork has support for R as well as other mainstream languages:

```
uv tool install robchallen/graphifyy && graphify install
```
