You are updating production code, which may be legacy code or new code, or documenting production code as part of an exploration.

## Developer focused documentation

Emergent design projects must be easy to understand for new AI agents and human developers alike and must be easy to debug non-interactively through logging.

Your role is to add comments to implementation code that explain the code to AI and humans alike.

To help extract comments and track provenance emergent design comments must be prefixed with `EM:`. e.g. `// EM: this is an emergent design java comment`. `EM:` comments can be extracted from source files with `cat srcfile | grep "EM:"`. The [design-check.R](../../scripts/design-check.R) script will automatically extract `EM:` style comments and place them in `.agents/em/implementation-notes.json`

Follow these standards:

- [ ] Between 10-25% of active production code should be developer focused `EM:` comments
- [ ] `EM:` comments describe the algorithm and control flow of the program.

## Links to design

You may be implementing new features into production code, or retrofitting design based on existing production code, or implementing new testing as a result of test-scripts, or reproducing issues documented in design.

Design artifacts provide context for the code and in a mature project implementation code can be traced back to design artifacts. This linkage is in the production code as a comment that uses a markdown style link with alt text of "IMPLEMENTS" or "REPRODUCES". These links are extracted by the [design-check.R](../../scripts/design-check.R) script and placed in `.agents/em/links.tsv`.

Follow these standards:

- [ ] "IMPLEMENTS" style links will be have a target of a feature or test script. E.g. `# [IMPLEMENTS](/design/feature/XXX.md)`, or `# [IMPLEMENTS](/design/test-script/YYY.md)` (bash style comments)
- [ ] "REPRODUCES" style links connect tests to the description of the issue. E.g. `# [REPRODUCES](/design/implementation/issues/ZZZ.md)` (bash style comments)

## Logging

Whe you are implementing new production code or retrofitting design to existing code improving the visibility of the code execution path is critical to maintaining and debugging code.

Follow these standards:

- [ ] All production code has trace level (or debug) logging which includes flow and current variables wherever runtime errors are likely.
