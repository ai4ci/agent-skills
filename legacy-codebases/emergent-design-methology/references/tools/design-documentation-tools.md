
## Quality assuring design

* 
* All features described in `design/SCOPE.md` has a link to a markdown file in `design/features`
* All files in `design/features`
* The directory structure of `design/implementation/notes` mirrors that of the production source code directory.
* All markdown files in `design/implementation/notes` subdirectories have a 1:1 relationship with source code files.
* All source code files have an corresponding `design/implementation/notes` markdown file.
* All markdown files in design have been checked with [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) and [lychee](https://github.com/lycheeverse/lychee) for structural consistency and broken links

## Validation tools

### 1. Markdown documentation

Markdown files (`.md`, `.qmd`, `.Rmd`) are frequently updated by agents generating READMEs or documentation files. Unvalidated Markdown often suffers from broken links, malformed tables, and structural inconsistency. [3, 4]

* All-in-One Linting & Formatting: DavidAnson/markdownlint-cli2 (`markdownlint-cli2`)
  * _Agentic Value:_ This is a blazingly fast, configuration-driven Markdown syntax linter. It catches common structural errors like incorrect header nesting (e.g., `# H1` followed directly by `### H3`), missing alt text on images, and trailing whitespaces. It natively supports outputting errors to a clean JSON array file.
  * _Command:_ `markdownlint-cli2 "**/*.md" --json`

* Hyperlink Validation & Link-Rot Prevention: Lychee (`lychee`)
  * _Agentic Value:_ A high-performance concurrent link checker written in Rust. It reads Markdown structures instantly to validate all embedded internal files, relative directory paths, and external HTTP hyperlinks. It outputs a deterministic JSON data log of broken URLs so the agent knows exactly which links need updating.
  * _Command:_ `lychee --format json -o link-report.json "**/*.md"`

### 2. Architecture diagramming

The optimal CLI architecture diagramming suite for an automated AI agent skill consists of the following tools:

#### Mermaid.js (`.mmd`, `.mermaid`)

Because it uses a highly intuitive, markdown-like declarative text syntax, Mermaid is often the easiest diagram format for an LLM to generate natively.

* Headless Compiler & Syntax Validator: @mermaid-js/mermaid-cli (`mmdc`)
  * _Agentic Value:_ This is a pure command-line wrapper around Mermaid that runs headlessly via Puppeteer. It serves a critical dual purpose: passing a file to it validates the syntax structure (throwing a non-zero exit code if the agent breaks a bracket layout), and successful passes compile the text directly into structured SVG or PNG graphics for external documentation files.
  * _Command:_ `npx mmdc -i architecture.mmd -o architecture.svg`

#### PlantUML (`.puml`, `.plantuml`)

Get plantuml: <https://github.com/plantuml/plantuml/releases>
Reference guide: <http://alphadoc.plantuml.com/raw/markdown/en/index-full>

PlantUML is the industry standard for deep software engineering maps (like UML class layouts, database schemas, and multi-actor sequence traces).

* Local Compilation Engine: PlantUML CLI (`plantuml`)
  * _Agentic Value:_ PlantUML requires a local Java runtime environment and Graphviz. Running the jar package with the `-syntax` flag runs an instant linting check over the script layout without executing the heavy layout engine, returning immediate feedback on missing closures or bad connectors.
  * _Command (Syntax Check):_ `java -jar plantuml.jar -syntax diagram.puml`
  * _Command (Headless Render):_ `java -jar plantuml.jar -tsvg diagram.puml`

#### Graphviz / DOT Language (`.dot`, `.gv`)

Graphviz is a more general purpose tool that the others. When an agent needs to programmatically construct highly complex network nodes, cluster maps, or automated code call-graphs.

* Native Layout Compiler: Graphviz CLI (`dot`)
  * _Agentic Value:_ Written in C, the native `dot` tool operates with near-instant execution speed inside a Linux container. Running it with the syntax-only check flag (`-v`) validates that node declarations, subgraph wrappers, and edge paths conform to strict DOT standards before attempting to draw shapes.
  * _Command (Syntax Check):_ `dot -v -o /dev/null diagram.dot`
  * _Command (Headless Render):_ `dot -Tsvg diagram.dot -o network.svg`

---
