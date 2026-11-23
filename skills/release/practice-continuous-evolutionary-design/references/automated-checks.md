Automated code and design quality checks are an integral part of  continuous evolutionary design.

Their usage is coordinated by the [`em` script](./tools/em-script.md) which performs a project specific set of actions and reports the output in the `.agents/em` directory.

The code quality checks are output in these specific files:

`em run`: `.agents/em/run-output`

* Output of running project with default inputs
* Detailed log files

`em test`: `.agents/em/test-output`

* Test output
* Test coverage

`em check`: `.agents/em/check-output`

* Duplicated code
* Syntax and formatting validation
* Strict type checking

`em doc`: `.agents/em/doc-output`

* Documentation consistency and completeness

`em design`: `.agents/em/design-output`

* Design quality checking

The tools and outputs are project specific but [defaults are described here](./tools/language-specific-build-tools.md)

`em` outputs in `.agents/em` are intended to be easily versioned using git, so their output should be line oriented and predictably ordered. This allows changes from previous runs can be easily inspected with `git diff` (or for timestamped log files `diff -u -I 'your-timestamp-regex' <(git show HEAD:.agents/em/log) .agents/em/log`)
