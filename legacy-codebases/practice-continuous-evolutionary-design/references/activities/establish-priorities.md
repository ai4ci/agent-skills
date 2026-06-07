In the absence of specific instructions you have to decide what is the first part of the codebase to address.

- [ ] Review `design/SCOPE.md` and `design/issues`.
- [ ] Establish with the developer where the major pain points are in terms of bugs or biggest wins in terms of desired improvements.
- [ ] Use the `graphify` skill to build a queryable knowledge graph from existing code to identify highly connected parts of the code base, and map functions and features.
- [ ] Use the [`em` script](../tools/em-script.md) to check for areas with poor test coverage.
- [ ] identify from the outputs of the [design-check.R](../../scripts/design-check.R) script areas of the code which have poor design documentation.

Prioritise improving highly connected parts of the code which have poor existing testing.

