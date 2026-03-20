# Creating scripts

You think its a good idea to encapsulate a deterministic action, that needs no user input which
is being created as part of a skill as a script.

Done correctly this will lead to reliability and reproducability of the skill.

There might be many scripts like this called by a single skills workflow.

## Before you start

- Is there an easy way to do this using a single bash command? or a single `uvx` python, `bunx` javascript, or `Rscript -e "..."` command?
- Is there anthing non-deterministic about this action?
- Could this ever need user input?
- Is there an inbuilt tool or available MCP server that meets this need?

If **yes** to any of the above then go back and think whether this is really a good idea.

## Requirements for a script

Remember that you (or a model like you) are the primary user of this script, and that it will be called
in the context of the skill workflow. Be clear about what the purpose of the script is, and keep
it tightly scoped, but you do not need to implement every edge case. You can assume the user (you) will
retry on failure if they are given enough information.

### Self contained scripts

Example script templates, that use a path to a config file as an example, the `--config` option is
just for example and may not be needed in your case. These examples are standalone, automatically
include dependencies, output to file or console, and give meaningful results from a `--help` option

#### R scripts

```R
#!/usr/bin/env Rscript

# Handle dependencies
dependencies <- c("optparse", "yaml")
for (dep in dependencies) {
  if (!requireNamespace(dep, quietly = TRUE)) {
    install.packages(dep, repos = "https://cloud.r-project.org")
  }
}

# 1. Define options
option_list <- list(
  optparse::make_option(
    c("-o", "--output"),
    type = "character",
    default = NULL,
    help = "an output file (defaults to stdout)",
    metavar = "FILE"
  ),
  # Example parameter
  optparse::make_option(
    c("-c", "--config"),
    type = "character",
    default = NULL,
    help = "path to a YAML configuration file",
    metavar = "FILE"
  )
)

opt_parser <- optparse::OptionParser(
  option_list = option_list,
  description = "Example script for YAML processing and CLI output"
)
opt <- optparse::parse_args(opt_parser)

# 2. Required parameter check
if (is.null(opt$config)) {
  optparse::print_help(opt_parser)
  stop("\nError: --config must be supplied", call. = FALSE)
}

# 3. Handle output connection
if (is.null(opt$output)) {
  conn <- stdout()
} else {
  conn <- tryCatch(
    {
      out_dir <- dirname(opt$output)
      if (out_dir != "." && !dir.exists(out_dir)) {
        dir.create(out_dir, recursive = TRUE)
      }
      file(opt$output, "w")
    },
    error = function(e) {
      stop(opt$output, " could not be opened for writing: ", e$message, call. = FALSE)
    }
  )
}

# 4. Example task specific logic
# This is where your implementation will differ:
config_data <- tryCatch(
  {
    # read_yaml converts YAML into a native R list
    yaml::read_yaml(opt$config)
  },
  error = function(e) {
    stop("Failed to parse YAML file ", opt$config, ": ", e$message, call. = FALSE)
  }
)
writeLines(paste("Processing complete for config:", opt$config), conn)

# 5. Tidy up
# Close connection if it's a file
try(close(conn), silent = TRUE)

```


#### uv python scripts (with PEP723)

```python
# /// script
# dependencies = [
#   "pyyaml",
# ]
# ///

import optparse
import sys
import os
import yaml  # Added for YAML parsing

def main():
    # 1. Define options
    parser = optparse.OptionParser(
        description="... document script purpose ...",
        usage="usage: %prog [options]"
    )

    parser.add_option(
        "-o", "--output",
        dest="output",
        type="string",
        default=None,
        help="an output file (defaults to stdout)",
        metavar="FILE"
    )

    # Example parameter
    parser.add_option(
        "-c", "--config",
        dest="config",
        help="path to a YAML configuration file",
        metavar="FILE"
    )

    (opt, args) = parser.parse_args()

    # 2. Required parameter check
    if opt.config is None:
        parser.print_help()
        sys.exit("\nError: --config must be supplied")

    # 3. Handle output connection
    conn = sys.stdout
    if opt.output:
        try:
            # Create directory if it doesn't exist (Mirrors R's dir.create)
            out_dir = os.path.dirname(opt.output)
            if out_dir and not os.path.exists(out_dir):
                os.makedirs(out_dir)

            conn = open(opt.output, "w")
        except Exception as e:
            sys.exit(f"Error: {opt.output} could not be opened for writing: {e}")

    # 4. Example task specific logic
    # This is where your implementation will differ:
    try:
        with open(opt.config, 'r') as f:
            # safe_load is recommended for security
            config_data = yaml.safe_load(f)
            print(f"Loaded config: {config_data}")
    except Exception as e:
        sys.exit(f"Error: Failed to parse YAML file {opt.config}: {e}")


    # 5. Tidy up
    if conn is not sys.stdout:
        conn.close()

if __name__ == "__main__":
    main()

```

#### bun javascript scripts
```
#!/usr/bin/env bun
import { OptionParser } from "option-parser";
import yaml from "js-yaml";
import { dirname } from "path";
import { mkdir } from "node:fs/promises";
import fs from "node:fs";

async function main() {
  const parser = new OptionParser();

  // 1. Define options (Mirrors R's option_list)
  parser.addOption("o", "output", "an output file (defaults to stdout)", "output")
        .setOptional();

  # Example parameter
  parser.addOption("c", "config", "path to a YAML configuration file", "config")
        .setOptional(); // We check for null manually to mirror your R logic

  parser.addOption("h", "help", "show help", "help")
        .setHelp();

  const opt = parser.parse();

  // 2. Required parameter check (Mirrors R's stop logic)
  if (!opt.config) {
    console.log(parser.getHelp());
    console.error("Error: --config must be supplied");
    process.exit(1);
  }

  // 3. Handle output connection (stdout vs file)
  let conn;
  if (!opt.output) {
    conn = process.stdout;
  } else {
    try {
      const outDir = dirname(opt.output);
      if (outDir !== "." && !fs.existsSync(outDir)) {
        await mkdir(outDir, { recursive: true });
      }
      conn = fs.createWriteStream(opt.output);
    } catch (e) {
      console.error(`Error: ${opt.output} could not be opened: ${e.message}`);
      process.exit(1);
    }
  }

  // 4. Example task specific logic
  // This is where your implementation will differ:
  let configData;
  try {
    const fileContent = await Bun.file(opt.config).text();
    configData = yaml.load(fileContent);
  } catch (e) {
    console.error(`Error: Failed to parse YAML file ${opt.config}: ${e.message}`);
    process.exit(1);
  }
  conn.write(`Processing complete for config: ${opt.config}\n`);

  // 5. Tidy up
  if (opt.output) {
    conn.end();
  }
}

main();

```

### Essential criteria:
- keep it simple, and I mean simple.
- regard this script as a single stateless function.
- expect simple inputs and fail fast on invalid input.
- output to `stdout` or file.
- document the script with purpose, expected inputs and outputs with a `--help` option.
- for destructive or stateful operations, a `--dry-run` flag lets the agent preview what will happen.

### Good practice:
- write a seperate test script in an `eval/scripts/` subdirectory of the skill, and reference the process for executing the test within the script comments
- the test script must not leave any trace of itself after running
- run the test script whenever changing the main script
- if the script needs private information then source them from environment variables and document them in the skill prerequisites, failing fast if not available.

### Things to avoid:
- **NEVER** embed secrets or API tokens in a script. Assume script will be shared widely as part of the skill, and be publically available on github.
- do not embed complex decision logic or multiple workflow steps in a script, do that in the skill itself.
- do not use complex dependencies that require installation.
- do not exhaustively catch all possible edge cases.
- do not expect complex structured input to be properly formatted.

## General guidance

Pick the best tool for the job but prefer bash, then javascript (via `bun`), then R (via `Rscript`) or python (via `uv`). Document script running dependencies (`uv`, `bun` in the skill prerequisites section, any bash dependencies like `jq`).

Put test data if needed in the `eval/scripts/` subdirectory of the skill.

Ensure that the tests are running the main script from the root of the skill so for example:

```bash
#!/usr/bin/env bash
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT="scripts/<...main-script-name...>"

run_script() {
  (
    cd "$SKILL_DIR"
    "$SCRIPT" "$@"
  )
}
```

If a script is more than 100 lines of bash it is probably doing something too complex, and maybe should be broken down into multiple scripts and workflow steps in the skill.
