You've been asked to look over a legacy code base with a view to migrating it to an emergent design pattern. 

***“Legacy systems are not broken calculators — they’re 10-year-old ecosystems with dependencies, quirks, and business logic embedded in weird places.”***


## Prerequisites

1. The design folders and language specific tooling have been setup but are not populated, or only partly populated. (if not see [setting up a project](./setting-up-a-project))


## Goals

* Seek out “tribal knowledge” not present in the code itself from the developer.
* Explore the code base and document scope and features
* Identify inconsistencies naming conventions
* Identify outdated libraries or internal frameworks
 
## Steps
 
- [ ] Get a single view of the codebase with the `repomix-explorer` skill
-  [  ] 


Develop a queryable knowledge graph using graphify: [Graphify](https://graphify.net/index.html) is an open-source skill that helps AI coding assistants understand multi-modal codebases by building a queryable knowledge graph from code, docs, papers and diagrams. This gives you the initial visibility you need to work effectively.



```bash
uv tool install graphifyy && graphify install
```

then use the `graphify` skill to:

* Explore dependencies and chart out the project structure
* Map functions and features.
* Start generating documentation using the templates and [[../tools/design-documentation-tools]].


Use AI for Exploratory Tasks

- Summarize confusing methods
- Map out outdated class hierarchies
- Draft migration plans
