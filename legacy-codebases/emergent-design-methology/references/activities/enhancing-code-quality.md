You've been asked to start improving code quality most likely in a legacy project during migration to a emergent design.

Use the [`em` script](../tools/em-script.md) as a unified interface to the project to help you with this tasks.

There often a very large number of code quality issues in legacy project and this requires an iterative approach.

## Prerequisites

The design folders and language specific tooling have been setup and should be well populated, or the most relevant parts populated (if not see [exploring-legacy-code](./exploring-legacy-code.md)) with SCOPE.md covering the main.

## Determine next iteration priority

In the absence of specific instructions you have to decide what is the first.

* Establish with the developer where the major pain points are in terms of bugs or desired improvements, and focus in-code commenting, retrospective prototyping, logging and improving test coverage for these areas of code.
* There are likely low cost, low value quick wins in terms of ensuring all function parameters and return values are documented.
* Make a small number of fixes and repeat.


```
/graphify query "<question>"                          # BFS traversal - broad context
/graphify query "<question>" --dfs                    # DFS - trace a specific path
/graphify path "AuthModule" "Database"                # shortest path between two concepts
/graphify explain "SwinTransformer"                   # plain-language explanation of a node
```

### Iteratively improve quality

There often a very large number of code quality issues and prioritising ones to fix may be difficult.

- [ ] Use the `graphify` skill to build a queryable knowledge graph from existing code to identify highly connected parts of the code base, and map functions and features.
- [ ] identify from the outputs of the [design-check.R](../../scripts/design-check.R) script areas of the code which have poor design documnetation.
- [ ] Use the [`em` script](../tools/em-script.md) to check for areas with poor test coverage.

Using the most connected components from the `graphify` graph, with missing design documentation and poor test coverage.

- [ ] Get a view of this part of the codebase with the `repomix-explorer` skill.
- [ ] Identify candidates for retrospective prototyping (see [prototyping](./prototyping-features.md)).
- [ ] [Retrofit automated testing](./implementing-test-cases.md) usig design test-scripts.
- [ ] Extract specifications for external interfaces from user or API documentation (see the [external interfaces example](../../examples/README.md)).
- [ ] Insert [developer comments and logging statements](./developer-comments-and-logging.md) into production code, including links design features and test-scripts.
- [ ] Ensure user facing and API documentation is complete.
- [ ] Address gaps in function level documentation are addressed.

### refactoring:
- moving code to where it most logically belongs
- removing duplicate code
- making names self-documenting
- splitting monolithic methods into smaller pieces
- re-arranging inheritance hierarchies

### Maintaining quality (longer term)

As you get each aspect of code quality under control, for example no undocumented method parameters, setup git pre-commit hooks to test the codebase on every change, with a view to maintaining that quality standard.

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook
```
