You've been asked to look over a legacy code base with a view to migrating it to an emergent design pattern. 

***“Legacy systems are not broken calculators — they’re 10-year-old ecosystems with dependencies, quirks, and business logic embedded in weird places.”***

The design folders and language specific tooling have been setup but are most likely not populated, or only partly populated. (if not see [setting up a project](./setting-up-a-project.md))

## Goals

* Seek out “tribal knowledge” not present in the code itself by discussing with the developer.
* Explore the code base and document scope and features.
* Identify and document inconsistencies and technical debt (document the "why" behind technical debt - sometimes it exists for good reasons)
* Identify key areas of complex functionlity and retrospectively prototype.
* Plan introduction of automated testing by writing test-scripts.
* Identify and document external interfaces (UI and API).

## Steps
 
- [ ] Understand whether any migration has been attempted yet using the [design-check.R](../../scripts/design-check.R) script (see [design-documentation-tools](../tools/design-documentation-tools.md)).
- [ ] Read user documentation.
- [ ] Use the `graphify` skill to build a queryable knowledge graph from existing code to identify highly connected parts of the code base, and map functions and features.
- [ ] identify from the outputs of the [design-check.R](../../scripts/design-check.R) script areas of the code which have poor design documnetation.
- [ ] Use the [`em` script](../tools/em-script.md) to check for areas with poor test coverage.

Prioritise by using the most connected components from the `graphify` graph, which have missing design documentation and poor test coverage.

- [ ] Identify and document existing technical debt (see the [technical debt example](../../examples/README.md)
- [ ] Identify features and decompose them into managable chunks representing around 500 lines of code or fewer (see the [features example](../../examples/README.md) and update `SCOPE.md`.
- [ ] Identify candidates for retrospective prototyping (see [prototyping](./prototyping-features.md)).
- [ ]
- [ ] Extract specifications for external interfaces from user or API documentation (see the [external interfaces example](../../examples/README.md)).


