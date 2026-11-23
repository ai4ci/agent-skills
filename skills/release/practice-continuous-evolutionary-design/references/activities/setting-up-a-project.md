You've been asked to migrate a project to continuous evolutionary design or set up a new continuous evolutionary design project

## Prerequisites

Continuous evolutionary design projects must be version controlled with `git`. If the project is not already versioned controlled, a `git init` must be performed.

## Step 1: High level scope and architecture

Determine the high level purpose of this project and its technical architecture. For a green field project this is a question of interviewing the user. For a legacy project this is a question of reviewing the existing documentation and README.

Document at:
* `design/SCOPE.md`
* `architecture/FRAMEWORK.md`

## Step 2: Make code quality and build tools available

- [ ] Define the setup logic in the `em` script's `setup` subcommand to install prerequisites, verify runtimes, and download dependencies.
- [ ] If the script needs to run commands requiring elevated privileges (such as `sudo apt install` or global system package managers), the agent **must** pause and explicitly bring this to the user's attention before proceeding.
- [ ] For user-level tools, `em setup` can automate steps like:
  - Installing [Repomix](https://github.com/yamadashy/repomix):
    ```bash
    npm install -g repomix
    npx skills add yamadashy/repomix --skill repomix-explorer
    ```
  - Installing [Graphify](https://github.com/robchallen/graphify):
    ```bash
    uv tool install robchallen/graphifyy
    graphify install
    ```
  - Resolving project-level language packages (e.g. `npm install`, `uv sync`, or `mvn dependency:resolve`).

Both graphify and repomix need to be told about files to ignore.

- [ ] place a `.graphifyignore` and a `.repomixignore` file in the project root using the following example:

```
# Add patterns to ignore here, one per line
# Files that you do want in git but pollute the code graph or repomix view:

# for example language specific code style configuration files
checkstyle.xml
code-style.xml

# These ignore files
.repomixignore
.graphifyignore

# you don't want repomix to bundle graphify's output.
graphify-out/
# or graphify to analyse repomix's output.
repomix-output.xml
# N.b. these are the default locations.

# Exclude the output of em scripts or skill files bundled with this project:
.agents/

# Maybe the design directory itself is not wanted (e.g. for graphify)
# design/
```

- [ ] install a hook for graphify to rebuild its project graph on git commit: `graphify hook install`

## Step 2: Setup project structure

- [ ] Set up the [design documentation](../design-documentation.md) folder structure in the root of the project using the following bash commands should do this (substituting <project> for the project name):

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

## Step 4: Setup the `em` script

The [`em` script](../tools/em-script.md) is unified interface to build tools specific for this project and its architecture, which stores outputs in a specific location `.agents/em`, and must be found in the root of the project. A skeleton `em` script is as follows:

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# --- Configuration & Paths ---
EM_DIR=".agents/em"
RUN_LOG="$EM_DIR/run-output"
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
    echo "  setup   Installs prerequisites, checks runtime versions, and resolves dependencies"
    echo "  run     Builds and executes the project (logs to $RUN_LOG)"
    echo "  test    Builds and runs all automated tests and code coverage (outputs to terminal and $TEST_LOG)"
    echo "  doc     Runs documentation tools (logs warnings/errors to $DOC_LOG)"
    echo "  check   Runs linters and code quality checks (logs report to $CHECK_LOG)"
    echo "  design  Runs design consistency checks (logs report to $DESIGN_LOG)"
    echo "  bump    Updates the version number of the project"
    echo "  help    Show this help message"
}

# --- Sub-command Implementations ---

cmd_setup() {
    echo "Starting 'setup' command..."
    
    # TODO: Add environment validation and prerequisite installation.
    # If sudo is required, alert the user first!
    # Example:
    # if ! command -v some_tool &> /dev/null; then
    #     echo "WARNING: 'some_tool' is missing. Elevated privileges (sudo) may be needed to install it."
    #     sudo apt install -y some_tool
    # fi
    
    echo "Setup complete."
}

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

    echo "Running design consistency checks..." > "$DESIGN_LOG"

    # TODO: This path is true for this specific project but will need to be configured correctly per
    # project. If the project is using a standards conformant agent harness and the skills are installed
    # on a per project basis then this should work.
    .agents/skills/practice-continuous-evolutionary-design/scripts/design-check.R  --dir=. | tee -a "$DESIGN_LOG"

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
    setup)
        cmd_setup "$@"
        ;;
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

- [ ] Configure project specific `em` script with language specific tooling.
- [ ] Confirm `em` script performs [all the automated checks](../automated-checks.md)

### Step 5: Create an `em` launcher (if missing)

- [ ] install a launcher script to `~/.local/bin/em` which allows the project specific `em` command to be run from anywhere in the emergent project directory.

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

## Step 6: Migrate existing design documentation (Legacy project only).

- [ ] Review existing design documentation from common locations in the project, and refactor into continuous evolutionary design structure as draft `design/features`.
- [ ] Check for open github issues on the project and summarise in the `design/implementation/issues` folder.

## Step 7: Establish a baseline

- [ ] Run tests and code coverage checks and validate that their output in `.agents/em` is as expected for the maturity level of the project. (N.B. In legacy projects you may find very many errors.)
- [ ] Run `em design` to baseline the design folder
- [ ] Run `graphify update` to baseline the code graph

## Step 8: Commit baseline.

## Step 9: Maintaining quality (Green field only)

- [ ] In a greenfield project setup git pre-commit hooks to test the codebase on every change, with a view to maintaining that quality standard. (Using e.g. lefthook)
