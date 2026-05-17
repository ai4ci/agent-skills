# Design artefacts folder

This project design document repository is designed to support a multiagent non linear workflow, which supports both new and existing projects. The philosophy is to create an overall cost function that can be optimised through iteration, after which the favoured state will be a well architected fully working solution.

## 00-principles folder

Contains non negotiable constraints for the project as set of markdown files.
Each markdown file describes the principle(s) and how to check that it has been adhered to.
Non adherence has high cost.

## 01-ideas folder

Contains free form notes and research, forms the context for a structured interview process to establish project goals. Opportunities to enhance the project and increase overall value. Unprocessed new ideas have medium cost.

yaml frontmatter (may be missing in which case the status is `new`, and the source is `user`):

```yaml
---
source: user|ai
status: new|ai-review|user-review|rejected|processed
---
```

## 02-goals folder

Goals for the project as a whole as a set of markdown files. The whole set of goals defines the scope of the project. Each file describes a goal of the project, value of the goal, complexity of the goal and criteria to assess whether has been met. This would be where use-cases or other requirements are found. High value, low complexity goals are more favoured that low value, high complexity ones. Cost is a function of `planned` status and value.

yaml frontmatter:

```yaml
---
status: planned|in-progress|implemented|deprecated
value: essential|high|medium|low
complexity: high|medium|low
version: <an implemented or target version>
---
```

## 03-layers folder

A set of markdown files describing the architectural layers of the project, technical implementation constraints, or architecture decisions for those layers. The outermost layer is the public interface to the project, middle layers define orchestration, and the lowermost is internal data structures and utilities. This would be where interaction diagrams will be found if there are any, and architectural decision records.

## 04-components folder

A set of markdown files describing the individual components of the solution and their layer. A component in the outermost layers might help to satisfy a goal, by interacting with other components in lower layers. This is where class or function level design, or UML class diagrams will be found, and includes inputs and outputs, and interactions with other components. It should be possible to trace a route through component interactions back to one or many goals. Dependencies between components should be directed from outer to innermost layers.

yaml frontmatter:

```yaml
---
status: planned|in-progress|implemented|deprecated|needs-review
layer: <layer-name>
implementation: <project file-path to implementation (optional)>
---
```

## 05-test-designs folder

A set of markdown files, each referencing a component, and describing how to test the component, what data to use, what success looks like, and (if necessary) how to run the tests. This is where unit test design would be found. The test design should be informed by the upstream (or higher layer) components that call this one. Missing test designs incur a cost (they should be 1:1 with components).

yaml frontmatter:

```yaml
---
status: planned|in-progress|implemented|deprecated|needs-review
component: <component-name>
issue: <issue-name (optional)>
implementation: <project file-path to implementation (optional)>
---
```

## 06-workflows folder

A set of markdown files detailing step to take to solve a goal. This references (usually outrmost layer) components and goals and describe how to use the project components to solve a goal. This will be where agent skills, getting started guides, or code vignettes will be found (or referenced). This where integration tests would be found.

yaml frontmatter:

```yaml
---
status: planned|in-progress|implemented|deprecated|needs-review
goal: <goal-name>
implementation: <project file-path to implementation (optional)>
---
```

## 07-issues

A set of defects or quality control issues as markdown. Defects include things like test coverage, linting or technical debt as well as functional issues. Cost is determined by priority.

```yaml
---
status: open|in-progress|closed
priority: high|medium|low
component: <component-name (optional)>
---
```
