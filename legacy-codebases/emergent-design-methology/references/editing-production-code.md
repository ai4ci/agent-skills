Use this checklist to structure any interaction with the codebase when implementing features or fixing issues:

## Before editing production code
- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Ensure you understand task and have got permission to go ahead
- [ ] Check for existing syntax & formatting and type checking and code duplication issues
- [ ] Check existing documentation consistency
- [ ] Implement tests, and check they fail

# After editing production code
- [ ] Confirm tests pass
- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Re-check documentation consistency
- [ ] Update design documents to match newly implemented features / issues
- [ ] Update user guides and skills to match  newly implemented features / issue
- [ ] Bump version numbers
- [ ] Commit changes

The appropriate tools to support syntax & formatting and type checking, code duplication and documentation consistency will depend on the project - read one of the following guides:

* Bash: [[bash-build]]
* Java: [[java-build]]
* Python: [[python-build]]
* R: [[r-build]]
* SQL: [[sql-build]]
* Typescript: [[typescript-build]]
* Polyglot: [[polyglot-build]]
