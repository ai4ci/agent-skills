You've been asked to fix an issue.

Use the [`em` script](../tools/em-script.md) as a unified interface to the project to help you with this task.

It is critical to avoid a bug-fixing doom-loop of unproven assumption of cause, making unrealted quick fixes for wrong reasons, adding code complexity and unnecessary changes, leading to more errors, more complex causes, extra edge cases, etc.

## Before debugging

- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Check for existing syntax & formatting and type checking and code duplication issues.
- [ ] Check current design consistency.
- [ ] Ensure you have a completely documented description of the issue in `/design/implementation/issues` which follows the [example linked to from here](../../examples/README.md).

The issue must be adequately described to be able to code a failing test case that replicates the issue. If the issue is inadequately described your job is to refine the issue with the developer until you can implement a failing test case that replicates the issue.

## While debugging

* Replicate issue by coding up a failing test case.
* Research the cause of the issue and document this in the design issue.
* Do not speculate as to the cause based on similar patterns.
* Do not implement fixes without **clear evidence** for cause documented.

Establishing evidence:

* Add [developer comments and logging](./developer-comments-and-logging.md) for this issue in the suspect implementation code to expose internal state.
* Run failing test, review the logs and examine state to determine cause - observe exactly what's happening inside the function, which variables have unexpected values, and where things are breaking.
* Repeat this until you have a proven defect.

Implementing fixes:

* Touch only what you must. Clean up only your own mess.
* Do not refactor unrelated code that happens to be nearby. 
* **Seek help from the developer if you cannot fix the issue in 3 attempts**

# After debugging

- [ ] Confirm all tests pass
- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Re-check documentation consistency
- [ ] Update design documents to match fixed issues
- [ ] Update user guides and skills to match fixed issue
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
