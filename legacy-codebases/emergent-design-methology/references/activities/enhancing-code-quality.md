You've been asked generally to migrate a legacy project to emergent design or you are fixing a specific code quality issue.

Use the [`em` script](../tools/em-script) as a unified interface to the project to help you with this tasks.

## Step 1 - establish a baseline

If not already up to date run code quality checks

## Step 2 - determine priority


```
/graphify query "<question>"                          # BFS traversal - broad context
/graphify query "<question>" --dfs                    # DFS - trace a specific path
/graphify path "AuthModule" "Database"                # shortest path between two concepts
/graphify explain "SwinTransformer"                   # plain-language explanation of a node
```

### Iteratively improve quality

* There often a very large number of code quality issues and prioritising ones to fix may be difficult.
* There are likely low cost, low value quick wins in terms of ensuring all function parameters and return values are documented.
* Establish with the developer where the major pain points are in terms of bugs or desired improvements, and focus in-code commenting, retrospective prototyping, logging and improving test coverage for these areas of code.
* Make a small number of fixes and repeat.
* Document the "why" behind technical debt (sometimes it exists for good reasons)



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
