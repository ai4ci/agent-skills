Use this checklist to structure any interaction with the codebase when implementing features:

Use the [`em` script](../tools/em-script.md) as a unified interface to the project to help you with this tasks.

## Before editing production code

- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Ensure you understand task and have got permission to go ahead
- [ ] Check design documents updated to match newly implemented features / issues
- [ ] Check for existing syntax & formatting and type checking and code duplication issues
- [ ] Check existing documentation consistency
- [ ] Implement tests against updated test-scripts, and check they fail

## While editing production code

- **Touch only what you must. Clean up only your own mess.**
- Fail fast input validation when type safety cannot be guaranteed.
- Include [developer comments and logging](./developer-comments-and-logging.md) in your new code.
- Include linkage to design documentation in code comments: `// [IMPLEMENTS](/design/test-scripts/XXX.md)` or `// [IMPLEMENTS](/design/feature/YYY.md)`
- Do not refactor unrelated code that happens to be nearby. 
- Scope creep hides real changes inside noise.
- Remove only the imports, helpers, or dead code that *your* change rendered unnecessary.
- Before finishing, ask: would a senior engineer find this over-complicated? If yes, simplify before shipping.
- Code changes must be covered by a test case.

# After editing production code

- [ ] Confirm tests pass
- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Re-check documentation consistency
- [ ] Update user guides and skills to match  newly implemented features / issue
- [ ] Bump version numbers
- [ ] Commit changes


