You've been asked to look over a legacy code base with a view to migrating it to an continuous evolutionary design pattern. 

The design folders and language specific tooling have been setup but design is most likely not populated, or only partly populated. (if not see [setting up a project](./setting-up-a-project.md))

## Goals

* Seek out “tribal knowledge” not present in the code itself by discussing with the developer.
* Explore the code base and document scope, features and test-scripts.
* Identify and document inconsistencies and technical debt (document the "why" behind technical debt - sometimes it exists for good reasons)
* Identify key areas of complex functionlity and retrospectively prototype.
* Plan introduction of automated testing by writing test-scripts.
* Identify and document external interfaces (UI and API).

The principle goal is to document `SCOPE.md`, `design/features` and `design/test-scripts` that reflect the current state of the code base and user facing documentation.

If not already specified [establish priorities](./establish-priorities.md) as to which parts of the code base to look at first.

## Steps
 
- [ ] Understand whether any migration has been attempted yet using the [design-check.R](../../scripts/design-check.R) script (see [design-documentation-tools](../tools/design-documentation-tools.md)).
- [ ] Read user documentation.
- [ ] Use `repomix` to extract the part of the codebase you are examining into a single file (if not already done) and read it.
- [ ] Use `graphify` to build a queryable knowledge graph from existing code to help map functions and features (if not already done).
- [ ] identify from the outputs of the [design-check.R](../../scripts/design-check.R) script areas of the code which have poor design documentation. - paying attention to the section `[Advisory] No design artifacts link to implementation files` (if not already done).
- [ ] Use the [`em` script](../tools/em-script.md) to check for areas with poor test coverage (if not already done).

For priority areas:

- [ ] Identify and document existing technical debt (see the [technical debt example](../../examples/README.md)
- [ ] Identify features and decompose them into managable chunks representing around 500 lines of code or fewer (see the [features example](../../examples/README.md) and update `SCOPE.md`.
- [ ] Identify candidates for archaeological prototyping (see [prototyping](./prototyping-features.md)).
- [ ] Extract specifications for external interfaces from user or API documentation (see the [external interfaces example](../../examples/README.md)).
- [ ] Document existing test-scripts.

## Retrospective design documentation

* At this stage **ONLY** design documents and **DO NOT** update implementation code.
* Create design documents with a "draft" status and the correct current version.
* Link technical debt records to implementation code using "IMPACTS" design documentation links.
* Link features, prototypes and external-interfaces to implementation code using "IMPLEMENTED_BY" design documentation links.
* Link test-scripts to implementation code using "TESTED_BY" design documentation links.
* Document the "why" behind technical debt (sometimes it exists for good reasons)


By creating only forward links from design to production code and tests you will create design quality issues that will be flagged up by `em design` and the [design-check.R](../../scripts/design-check.R) script, for future processing. This is the intention.

