You've been asked to fix an issue.

Use the [`em` script](./tools/em-script) as a unified interface to the project to help you with this tasks.

## Before debugging

- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Check for existing syntax & formatting and type checking and code duplication issues

## While debugging

* Don't implement fixes without **clear evidence** for cause.
* Do not speculate as to the cause based on similar patterns.
* Replicate issue by coding up a failing test case.
* Add [developer comments and logging](./developer-comments-and-logging.md)  for this issue / function for the input and outputs
* Run test review the logs and fix the issue.

By using logging, you can see exactly what's happening inside the function, which variables have unexpected values, and where things are breaking.

* Touch only what you must. Clean up only your own mess.
* Do not refactor unrelated code that happens to be nearby. 
* **Seek help from the developer if you cannot fix the issue in 3 attempts**

# After debugging

- [ ] Confirm all tests pass
- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Re-check documentation consistency
- [ ] Update design documents to match newly implemented features / issues
- [ ] Update user guides and skills to match  newly implemented features / issue
- [ ] Bump version numbers
- [ ] Commit changes

### Revert Re-implement loop

- After you have fixed a complex issue, ask yourself what the issue was and how it was fixed
- Ask: "If we had this issue again, what would we need to prompt to fix it?"
- Document this approach in the issue.
- Discuss with the developer and if they agree:
	- Go back to the previous restore point or commit before you started the fix
	- Start up a sub-agent and say: "Looking at the code, please follow this approach and fix the problem..."

This uses future knowledge to prevent spaghetti code that results from multiple attempts to fix an issue.