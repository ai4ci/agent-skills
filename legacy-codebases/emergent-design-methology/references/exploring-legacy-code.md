
***“Legacy systems are not broken calculators — they’re 10-year-old ecosystems with dependencies, quirks, and business logic embedded in weird places.”***

Your goals:
* Seek out “tribal knowledge” not present in the code itself from the developer.
* Explore the code base and document it
* Identify inconsistencies naming conventions
* Identify outdated libraries or internal frameworks

[Repomix](https://github.com/yamadashy/repomix) is a powerful tool that packs your entire repository into a single, AI-friendly file. Perfect for when you need to ingest the codebase in one go. Get a single view of the codebase with the `repomix-explorer` skill:

```
npx skills add yamadashy/repomix --skill repomix-explorer
```

Develop a queryable knowledge graph using graphify. [Graphify](https://graphify.net/index.html) is an open-source skill that helps AI coding assistants understand multi-modal codebases by building a queryable knowledge graph from code, docs, papers and diagrams. This gives you the initial visibility you need to work effectively.

```bash
uv tool install graphifyy && graphify install
```

then use the `graphify` skill to:

- Explore dependencies and chart out the project structure
- Map functions and features
- Start generating documentation using the templates and [[design-documentation-tools]].
