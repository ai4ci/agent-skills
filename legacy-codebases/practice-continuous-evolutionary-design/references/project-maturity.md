A mature continuous evolutionary design project has the following characteristics:

* A fully maintained [design documentation folder](./design-documentation.md) with features, test-scripts, prototypes reflecting the scope of the project, and which is automatically quality checked, with the results recorded in `.agents/em/design-output`.
* A production codebase that is automatically tested with very high code coverage, with the results recorded in `.agents/em/test-output`.
* Production code that passes a full code quality check including formatting, linting, code duplication checks, with the results recorded in `.agents/em/check-output` (see [automated checks](./automated-checks.md)).
* Exposes a language independent consistent mechanism to test the production code (the [`em` script](./tools/em-script.md)).
* Contains tools to help connect design and production code: `.agents/em/files.tsv`, `.agents/em/links.tsv` and `.agents/em/implementation-notes.json` maintained by the [design-check.R](../scripts/design-check.R) script.
* Contains skills that help AI agents use the code: `skills/`

**Practical tip:** Inspect the `.agents/em` folder contents to see the outputs of the `em` scripts. A mature project will have very good code coverage and few defects. A greenfield rpoject may not have any checks made yet. A legacy project will have potentially very many quality issues and incomplete test coverage.
