# The Continuous Evolutionary Design Manifesto

## Philosophy

Software development is often divided into two extremes: rigid enterprise processes and completely unstructured scripting. **Continuous Evolutionary Design** bridges this gap. It is a philosophy and framework designed for AI-assisted software evolution, built especially for solo developers, researchers, and domain experts. 

The goal of this approach is not to force enterprise overhead onto rapid scientific or creative workflows, but to seamlessly upgrade codebases into highly maintainable, readable, and reusable assets that can be rapidly assimilated by both humans and future AI agents.

---

## The Five Pillars of Continuous Evolutionary Design

### 1. Zero-Friction Unified Interface
No developer or AI agent should have to guess how to run, test, check, or document a project. We mandate a single, language-independent wrapper in the project root: the `em` script. Whether the project is built in Java, Python, TypeScript, R, or is a complex polyglot, the commands remain identical:
* `em setup` to bootstrap the environment.
* `em run` to execute.
* `em test` to verify.
* `em check` to validate quality.
* `em design` to check consistency.
* `em doc` to build the references.

### 2. Design-Driven Co-Evolution
Code is never created in a vacuum, nor should its architecture live only in Git commit histories or private chats. The design document structure in the `design/` folder co-evolves with the production code:
* **Scope and Architecture** are declared early and updated iteratively.
* **Features and Test-Scripts** are written as prospective prototypes.
* **Traceable Links** connect implementation code directly to design artifacts via explicit comments:
  * `[IMPLEMENTS](/design/features/XXX.md)`
  * `[REPRODUCES](/design/implementation/issues/YYY.md)`

### 3. Agent-Friendly Readability (`EM:`)
We write code to be read. Because AI agents now pair-program alongside human developers, codebase readability is a first-class engineering metric.
* Active production code maintains a **10% to 25% density** of developer-focused comments.
* These comments are prefixed with `EM:` (e.g., `// EM: check caching layer availability`), allowing automated tools to compile and check design-to-code alignment.
* We reject the philosophy that code should be self documenting as the result of experts working in single programming languages. As jack-of-all-trades polyglot developers we say that orientation through code documentation is critical to collaboration.

### 4. Non-Interactive Observability
When code fails, it must fail loudly and informatively. We enforce robust trace and debug-level logging throughout the runtime paths. If a runtime error occurs, logs should tell the story without requiring an interactive debugger.

### 5. Collaborative Care and the Escape Route
AI agents operate as the "clean-up crew" and quality guardians, working respectfully alongside human developers who may be under time pressure.
* **Respect Unstaged Work**: Never destroy or modify unstaged developer work-in-progress without consent.
* **Always Have an Escape Route**: Commit changes incrementally and verify each step using `./em check` and `./em test`.

---

## Related Documentation
* [Project Maturity Guide](./project-maturity.md)
* [The em Script Specifications](./tools/em-script.md)
* [Developer Comments and Logging Standards](./developer-comments-and-logging.md)
* [Design Documentation Folder Structure](./design-documentation.md)
