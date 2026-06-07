You've been asked to review some changes made to the project.

If the changed file(s) was not specified then assume the changes are the unstaged changes in the repository

- [ ] Use git diff to examine the new changes

## Option 1: Changes involving production code:

Does the change involve production code? If no skip to option 2.

Is it clear what the change is trying to achieve? Can you update a feature to accomodate the change? If not discuss with the developer.

- [ ] Use the [change analysis script](../../scripts/analyse-change.R) which takes positional arguments for the changed files, or no arguments to look at changes since the last time `em design` was run.
- [ ] Use `graphify` (as a skill) to query the graph and identify connections to changed files

If the number of affected files is large you **MUST** recommend that the changes are moved into a new branch before proceeding.

- [ ] Update affected design documents with intention of change, and update linked test scripts
- [ ] Update affected tests to accomodate changes in test-scripts
- [ ] Run tests and make sure they pass. If not you **MUST** discuss the failure with the developer. **DO NOT** fix failures without discussion.
- [ ] When tests pass run code quality checks and fix linting issues. (`em check`)
- [ ] Update user documentation and skills if necessary.
- [ ] Update design graph (`em design`)
- [ ] Bump version
- [ ] Commit

## Option 2: Changes affecting design only

**DO NOT** update production code

Do you have a clear revert point? If not consider committing work in progress changes in a new branch so you can revert to the current state,

- [ ] Use the [change analysis script](../../scripts/analyse-change.R) which takes positional arguments for the changed files, or no arguments to look at changes since the last time `em design` was run.
- [ ] Analyse first degree affected documents to see if they need to change.
- [ ] Change status of affected design documents to draft and propose adjustments.
- [ ] Create an implementation plan to track changes to implementation code resulting from design changes.
- [ ] Review the implementation plan with the developer with a view to executing it.
