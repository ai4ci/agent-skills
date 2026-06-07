You've been asked to start improving code quality most likely in a legacy project during migration to a continuous evolutionary design.

Use the [`em` script](../tools/em-script.md) as a unified interface to the project to help you with this tasks.

There often a very large number of code quality issues in legacy project and this requires an iterative approach.

## Prerequisites

The design folders and language specific tooling have been setup and should be well populated, or the most relevant parts populated (if not see [exploring-legacy-code](./exploring-legacy-code.md)) with SCOPE.md covering the main features of the project.

You know where to focus your attention, if not follow the guide for [establishing priorities](./establish-priorities.md), Using the most connected components from the `graphify` graph, with missing design documentation and poor test coverage.

## Before starting

- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Check for existing syntax & formatting and type checking and code duplication issues (`em check`)
- [ ] Check existing documentation consistency (`em doc`)
- [ ] Check for existing design issues (`em design`) particularly with regards to missing "IMPLEMENTS" and "TESTS" linkage, and inadequate developer `EM:` comments.

## Iteratively improve quality

There often a very large number of code quality issues: pick a small number of fixes and iterate using the outputs of the `em` script to measure progress.

Get an overview of the relevant part of the codebase with `repomix` skill.

### Highest value

- [ ] [Retrofit automated testing](./implementing-test-cases.md) using design test-scripts (issues from `em test` particularly code coverage) (if not already done).
- [ ] Identify and fix code linting issues (`em check` output).
- [ ] Refactoring out major code duplications (where covered by tests).

### Lower value quick wins

- [ ] Maintain and improve links between production code and design (`em design` issues).
- [ ] Extract specifications for external interfaces from user or API documentation (see the [external interfaces example](../../examples/README.md)).
- [ ] Insert [developer comments and logging statements](../developer-comments-and-logging.md) into production code, including developer documentation links to features and test-scripts.
- [ ] Ensure user facing and API documentation is up to date
- [ ] Address gaps in function level documentation are addressed (issues from `em doc`).

### Larger changes

- [ ] Identify candidates for archaeological prototyping, or prototypes in draft status (see [prototyping](./prototyping-features.md)), and implement.
- [ ] Plan out technical debt refactoring involving:
  - moving code to where it most logically belongs
  - removing duplicate code
  - making names self-documenting
  - splitting monolithic methods into smaller pieces
  - re-arranging inheritance hierarchies

### Maintaining quality (longer term)

As you get each aspect of code quality under control, for example no undocumented method parameters, setup git pre-commit hooks to test the codebase on every change, with a view to maintaining that quality standard. (Using e.g. lefthook)

```
