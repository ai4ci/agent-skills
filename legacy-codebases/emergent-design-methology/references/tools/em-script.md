## The `em` script - A unified interface to build tools

`em` is a bash script that must exist in the root of a emergent design project. 

Its purpose is to provide a language independent interface to basic build tools, very similar to mise tasks, to make sure both you and a human developer are running the same test, build tools, and code quality checks.

It is preferred over language specific tools, for consistency and to support polyglot projects.

It is created by you as an AI agent and **MUST** provide at least the following features, which both you and the developer will use:

* `em` on its own or `em --help` provides a list of supported sub-commands.
* `em run` builds and executes the project using a sane set of defaults, logging output to `.agents/em/log`. Sets logging to most verbose setting. 
* `em test` builds and runs all the automated test scripts associated with a project writing output to terminal and to a file `.agents/em/test-output`. Includes code coverage metrics
* `em doc` runs documentation tools reporting warnings and errors to `.agents/em/docs-output`
* `em check` run linters and code quality checks providing a report to `.agents/em/check-output` including code duplication reports, and design consistency checks.
* `em bump` bumps minor version numbers of the code and makes sure that versions are consistent across the project.

## Outputs

`em` outputs in `.agents/em` are intended to be easily versioned using git. This enables a checkpoint for test results or code quality checks to be managed with the code so that failing test results, changes from the committed versions can be easily inspected with `git diff` (or for timestamped log files `diff -u -I 'your-timestamp-regex' <(git show HEAD:.agents/em/log) .agents/em/log`)

## Extensions

Optionally the `em` script can contain any additional commands that you or the developer find useful to implement for streamlining the build of the project. You might want to implement a `--delta` flag such that the output of the `run`/`test`/`check`/`doc` sub-commands is compared to pre-existing results. Extensions to `em` are sensible, Just so long as it is self documenting.

