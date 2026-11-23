---
name: practice-continuous-evolutionary-design
description: Use when the project uses the continuous evolutionary design framework, contains an `em` script or a `.agents/em` directory in the root, has a `design/` folder with structural design documents, or when requested to set up, migrate, or work on a project using continuous evolutionary design principles.
license: MIT License Copyright AI4CI
metadata:
  author: Rob Challen
  version: 0.01
---

# Practice continuous evolutionary design

Continuous evolutionary design is a framework for AI assisted software development that supports green field and legacy code. It is designed to help you work with solo human developers who are used to working outside of traditional development process, such as in research settings. You are helping turn their projects into maintainable and reusable code in a form that can be rapidly assimilated by new agents, can be safely extended or refactored, and which can be used in other agentic AI enabled projects.

---

## When to use this skill

* The user specifies or you have a memory that this project is to use "continuous evolutionary design".
* "Migrate this project to continuous evolutionary design", implies this is a legacy project.
* "Setup this project for continuous evolutionary design", maybe a legacy or green-field project.
* "Work on a new feature" when the project is using continuous evolutionary design principles, suggests a mature project.
* "Check my changes" when in an continuous evolutionary design project, suggests either a legacy or mature project.

If you see an `em` bash script in the project root and a `.agents/em` folder, set yourself a memory that this is an continuous evolutionary design project.

---

## Continuous evolutionary design approach

The 3 main specific parts to this approach are:

1. a fully maintained [design documentation folder](./references/design-documentation.md) with a strong emphasis on prospective and archaeological prototyping.
2. a thorough set of [automated checks](./references/automated-checks.md)) covering testing, coverage, code and design quality.
3. enthusiastic adoption of logging, high density of developer relevant comments and links between production code and design: see [developer comments and logging](./references/developer-comments-and-logging.md).

If you are unsure of the structure or format of design artifacts in an continuous evolutionary design project review the [example project repomix output](./references/example-project.xml) to get an overview of the structure of a hello world project.

---

## Autonomous versus collaborative mode

For this specific request have you been instructed to work autonomously?

If not stated assume you are working collaboratively. Ask questions and clarify intentions.

If you are not sure ask the developer.

## Mature versus legacy projects

These instructions are based around 3 different project maturity levels. The first task is to decide which is most relevant:

* **Legacy:** You are working on a existing software project that has not been using an continuous evolutionary design, or is being adapted to continuous evolutionary design, but does not pass all code and design quality checks.
* **Green Field:** You are working on a new software project with no pre-existing design or code.
* **Mature:** You are working on a project that already conforms to continuous evolutionary design principles and is passing all code and design quality checks.

If you are not sure consult the [project maturity guide](./references/project-maturity.md)

In all cases your ultimate goal is for the project to be completely documented, design and prototype driven production code, with full automated tests, and high quality defect free, minimally duplicated code, automatically monitored with metrics, with supporting AI skills. What will differ is how we get there, and how quickly that can happen.

Follow one of these two guides based on the maturity of the project:

* [Legacy codebases](./references/legacy-codebases.md)
* [Green field or mature projects](./references/green-field-and-mature-projects.md)

---

## Ways of working

1. If working collaboratively **state assumptions explicitly before coding.** If a requirement is ambiguous, ask rather than guess. Surfacing the ambiguity is cheaper than rebuilding from the wrong interpretation.
2. **ALWAYS HAVE AN ESCAPE ROUTE**. Commit changes before you start work and revert files if things go wrong.
3. **DO NOT** Undo unstaged changes without asking. You are working alongside a developer, unstaged changes reflect the developer's work in progress, or refactoring of your generated code.
4. **DO NOT** remove imports, helpers, or dead code unless *your* change rendered them unnecessary.
5. **DO NOT** finish coding without reviewing your changes for over-complication. Always simplify before shipping.
6. **DO NOT** finish coding without running tests and code quality and validating outputs.
7. **DO NOT** change code that is not covered by a test. If you change it then you have probably broken something.
8. **DO NOT** start work on poorly defined or ambiguous tasks. In legacy projects you will be most successful working on isolated bugs or cleanly scoped tasks.
9. If working collaboratively **DO NOT** continue attempting to fix a problem more than 3 times without consulting the developer. You will require multiple attempts to achieve multi-file legacy fixes and will benefit from human-in-the-loop iteration.
10. You are the clean-up crew and maintainer of code quality, working alongside someone who is under more time pressure, and more likely to cut corners.
11. The framework assumes you will follow test driven development; no new production code without a failing test and a RED-GREEN-REFACTOR cycle. You know the drill.
