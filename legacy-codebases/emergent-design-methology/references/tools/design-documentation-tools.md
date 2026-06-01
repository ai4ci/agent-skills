## Quality assuring design

The [design-check.R](../../scripts/design-check.R) script analyses design documents and implementation code.

1. Extract metadata from yaml in design documentation files and stores it in `.agents/em/files.tsv`
2. Find links between design documentation and implementation code and stores it in `.agents/em/links.tsv`
3. Extracts implementation developer comments and stores it in `.agents/em/implementation-notes.json`

The script enforces a set of constraints that make sure that design documents are correctly linked to production code and test cases. The links use markdown links (relative or absolute from the root of the project) with the following alt texts, e.g. `[FEATURE](/design/feature/feat-001.md)`:

- "FEATURE" which features are relevant:
  - source: Various design artifacts, especially prototype, test-scripts.
  - target: A feature: `/design/features/AAA.md`
- "TEST" which test scripts relate to a feature:
  - source: usually a feature
  - target: A test-script: `/design/test-scripts/BBB.md`
- "PROTOTYPE" which prototypes relate to a feature:
  - source: usually a feature
  - target: A prototype: `/design/prototypes/CCC.md`
- "INTERFACE" which external interfaces relate to a feature:
  - source: usually a feature
  - target: A specification of an external interface: `/design/external-interfaces/DDD.md`
- "REPRODUCES" which test cases reproduce and issue:
  - source: test case
  - target: An implementation issue: `/design/implementation/issues/EEE.md`
- "TESTDATA" which test data is produced by a prototype or used by a test-script
  - source: a test script (uses) or prototype (produces)
  - target: A test data file (langague specific location)
- "IMPLEMENTS" which features does production code implement or test scripts are implemented by test code.
  - source: production code or test case.
  - target: A design feature `/design/features/AAA.md`, test-script `/design/test-scripts/BBB.md`, prototype `/design/prototypes/CCC.md` or external interfaces `/design/external-interfaces/DDD.md`

## Quality checks on design graph

The [design-check.R](../../scripts/design-check.R) script produces specific warnings:

### Structural defects

- `[Defect] Broken links`
- `[Defect] Links with incorrect target type`
- `[Defect] Links with incorrect source type`

## Design defects ----

- `[Defect] Features not in SCOPE`: All non deprecated features must be linked to from SCOPE.md
- `[Defect] Design artifacts without correct metadata`: All design artifacts have status and target-version
- `[Defect] Design artifacts without linked feature`: design artifacts must be linked to a feature (except issues)
- `[Defect] Final features not linking to test-scripts`: When a feature has a final status it must link to one or more test-scripts
- `[Defect] Open issues not reproduced as a test case`: Open issues must have linked reproducible test cases

## Design improvement targets ----

- `[Advisory] Final features without implementation`: Features without implementation
- `[Advisory] Final test scripts without implementation`: Tests without implementation
- `[Advisory] Final features or test scripts without prototype or interface`: Features or test-scripts without prototypes or external interfaces.
- `[Advisory] Implementation files with no links to design, test-scripts or issues`: Implementation files not linked to designs, test-scripts or issues
- `[Advisory] Implementation files with comments < 10% or > 25%`: Implementation files 10-25% EM comments

## Other validation tools

* Use lychee for link checking outside of design documentation links: (`https://github.com/lycheeverse/lychee`), with the `--root-dir` option set to the root of the project `lychee --root-dir . .`.
* Use all-in-One linting & formatting: DavidAnson/markdownlint-cli2 (`markdownlint-cli2`) is a markdown syntax linter.

## Architecture diagramming

The optimal CLI architecture diagramming suite for an automated AI agent skill consists of the following tools:

### Mermaid.js (`.mmd`, `.mermaid`)

Because it uses a highly intuitive, markdown-like declarative text syntax, Mermaid is often the easiest diagram format for an LLM to generate natively.

* Headless Compiler & Syntax Validator: @mermaid-js/mermaid-cli (`mmdc`)
  * _Agentic Value:_ This is a pure command-line wrapper around Mermaid that runs headlessly via Puppeteer. It serves a critical dual purpose: passing a file to it validates the syntax structure (throwing a non-zero exit code if the agent breaks a bracket layout), and successful passes compile the text directly into structured SVG or PNG graphics for external documentation files.
  * _Command:_ `npx mmdc -i architecture.mmd -o architecture.svg`

### PlantUML (`.puml`, `.plantuml`)

Get plantuml: <https://github.com/plantuml/plantuml/releases>
Reference guide: <http://alphadoc.plantuml.com/raw/markdown/en/index-full>

PlantUML is the industry standard for deep software engineering maps (like UML class layouts, database schemas, and multi-actor sequence traces).

* Local Compilation Engine: PlantUML CLI (`plantuml`)
  * _Agentic Value:_ PlantUML requires a local Java runtime environment and Graphviz. Running the jar package with the `-syntax` flag runs an instant linting check over the script layout without executing the heavy layout engine, returning immediate feedback on missing closures or bad connectors.
  * _Command (Syntax Check):_ `java -jar plantuml.jar -syntax diagram.puml`
  * _Command (Headless Render):_ `java -jar plantuml.jar -tsvg diagram.puml`

### Graphviz / DOT Language (`.dot`, `.gv`)

Graphviz is a more general purpose tool that the others. When an agent needs to programmatically construct highly complex network nodes, cluster maps, or automated code call-graphs.

* Native Layout Compiler: Graphviz CLI (`dot`)
  * _Agentic Value:_ Written in C, the native `dot` tool operates with near-instant execution speed inside a Linux container. Running it with the syntax-only check flag (`-v`) validates that node declarations, subgraph wrappers, and edge paths conform to strict DOT standards before attempting to draw shapes.
  * _Command (Syntax Check):_ `dot -v -o /dev/null diagram.dot`
  * _Command (Headless Render):_ `dot -Tsvg diagram.dot -o network.svg`

---
