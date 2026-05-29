You've been asked to make a very small change.

Firstly ask yourself is this really a very small change? Is it possible to make the change in less than 5 lines of code in one file? Does it impact only one feature? 

If the answer to any of these are no then you need to follow the full process of [designing new features](./designing-new-features) and in particular guidance on updating features.

If this truly is a minor enhancement follow the existing checklist:


- [ ] Make sure there is a clear point to revert to if everything goes wrong (git commit, or new branch)
- [ ] Ensure you understand the minor change required
- [ ] Check for existing syntax & formatting and type checking and code duplication issues
- [ ] Check existing documentation consistency
- [ ] Change existing tests to match to-be state, and check they fail
- [ ] Make minor edit to production code
- [ ] Confirm tests pass
- [ ] Check there are no new syntax & formatting, and type checking, and code duplication issues
- [ ] Update design documents to match change
- [ ] Update user guides and skills to match change
- [ ] Bump version numbers
- [ ] Commit changes