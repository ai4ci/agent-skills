---
name: practice-emergent-design
description: Use whenever asked to create a program, analyse a program, familiarise yourself with a codebase, add a feature, develop testing for a project, prototype code, explore how code works,
license: MIT License Copyright AI4CI
metadata:
  author: Rob Challen
  version: 0.01
---
# Practice emergent design

Emergent design is a methodological framework for AI assisted software development that supports green field and legacy code. It is primarily designed to help you work with solo human developers who are used to working outside of traditional development methodologies, such as in research settings. You are helping turn their projects into maintainable and reusable code in a form that can be rapidly assimilated by new agents, can be safely extended or refactored, and which can be used in other agentic AI enabled projects.

---
## When to use this skill

* The user specifies or you have a memory that this project is to use "emergent design".
* "Migrate this project to emergent design", implies this is a legacy project.
* "Setup this project for emergent design", maybe a legacy or green-field project.
* "Work on a new feature" when the project is using emergent design principles, suggests a mature project. 
* "Check my changes" when in an emergent design project suggests, either a legacy or mature project

---
## Fundamental principles

These instructions are based around 3 different scenarios. The first task is to decide which is most relevant:

* **Mature:** You are working on a project that already conforms to emergent design principles and is passing all code and design quality checks.
* **Green Field:** You are working on a new software project with no pre-existing design or code.
* **Legacy:** You are working on a existing software project that has not been using an emergent design, or is being adapted to emergent design, but does not pass all code and design quality checks.

A mature emergent design project has the following characteristics:

* A fully maintained design documentation folder with features, test-scripts, prototypes reflecting the scope of the project.
* A production codebase that is automatically tested with very high code coverage, with the results stored in `.agents/em`.
* Production code passes a full code quality check including formatting, linting, code duplication checks, with the results stored in `.agents/em`.
* Exposes a language independent consistent mechanism to test the production code (the `em` script).
* Contains tools to help navigate the code.
* Contains skills that help AI agents use the code.

**Practical tip:** Inspect the `.agents/em` folder contents to see the results of tests and code and design quality checks to decide if this is a mature emergent design project, or a legacy project that is being migrated. 

In all cases your goal is for the project to be completely documented, design and prototype driven production code, with full automated tests, and high quality defect free, minimally duplicated code, automatically monitored with metrics, with supporting AI skills.

Based on the type of project follow the relevant guide:
* [working with legacy code](./references/legacy-code.md)
* [set up green field project](references/green-field)
* [extending a mature project](./references/mature-project.md)

Discuss with the user if it is not clear which guide to follow.


## Mapping out legacy code

---
## Prototyping


---
## Code quality


---
## Ways of working

**State assumptions explicitly before coding.** If a requirement is ambiguous, ask rather than guess. Surfacing the ambiguity is cheaper than rebuilding from the wrong interpretation.
### Testing Mandate

**NO NEW AI GENERATED CODE WITHOUT A FAILING TEST FIRST.** - Except prototypes and test support services

The RED-GREEN-REFACTOR cycle:
1. **RED** - Write minimal failing test
2. **GREEN** - Implement simplest passing code
3. **REFACTOR** - Improve while keeping tests green
### Git

* You are working alongside a person who is operating at a different timescale to you.
* Unstaged changes reflect the developer's work in progress, or refactoring of your generated code.
* Work in a branch or a worktree if conducting a large change to the code base. Help the developer with the resulting merge.
* Commit often. Mandatory to have a commit point before and after a major change.
* If things go wrong revert your branch and start again.
### Change Discipline

**Touch only what you must. Clean up only your own mess.**

When editing code:

- Match existing style, even if you disagree with it. Style debates belong in a separate PR.
- Do not refactor unrelated code that happens to be nearby. Scope creep hides real changes inside noise.
- Remove only the imports, helpers, or dead code that *your* change rendered unnecessary.
- Before finishing, ask: would a senior engineer find this overcomplicated? If yes, simplify before shipping.
- If it is not covered by a test and you change it then you have probably broken something.



---



The developer:
* Has domain expertise that you do not.
* Understands the rationale for this project better than you.
* Knows about historical design choices and why they were made.
* Probably has a mental map of a legacy codebase.
* Is under more time pressure than you, and more likely to cut corners.

Your advantages:
* Have more knowledge of modern design principles and alternative frameworks.
* Are better at unexciting repetitive tasks.
* Have better discipline to follow methodologies.
* Are better at pattern recognition and code summarization, quick analysis of undocumented systems.

Your disadvantages
* May not understand the full context of the codebase yet.
* Have a tendency to focus on specifics and potential to quickly generate technical debt.

Collaboration model
* Will be most successful working on isolated bugs or cleanly scoped tasks.
- You will require multiple attempts to achieve multi-file legacy fixes and will benefit from human-in-the-loop iteration.
- Your success rates will be higher when the task includes upfront test coverage, CI integration, and you have clear understanding of the task.


---



---


---
### Creating AI-Friendly Reference Points
- Create reference examples of how to properly implement features
- Document edge cases and business logic in natural language
- Dealing with Technical Debt - Identify and document code smells and technical debt
- Create a priority list for refactoring opportunities

---


### 1) Start with the bugs, not the features

Use AI for:

- Cleaning up long-standing bugs
- Refactoring repetitive code snippets
- Isolating common exceptions in logs

Avoid using AI to “bolt on” major new functionality to fragile legacy systems. Instead, think of it as your cleanup crew.


### 2) 

### 3) 



### 4 Create Guardrails with Human Review

Establish a workflow where:

- AI proposes the first draft
- Senior devs refine and approve
- Outputs are tested in CI

This speeds things up without compromising code safety or business logic.

### 5 Document Everything the AI Touches

Legacy systems tend to lack docs. Use AI not only to fix bugs — but to write:

- Inline comments
- Commit messages
- Change logs
- Markdown documentation

Over time, this turns a fragile legacy codebase into a more understandable and maintainable system.

## Final Thought: Use AI Where Legacy Systems Hurt the Most

Don’t ask AI to revolutionize your legacy app overnight. Instead, use it to surgically reduce pain points — bugs, small improvements, and documentation gaps. That’s where SWE-Lancer showed the most consistent wins.

Document the "why" behind technical debt (sometimes it exists for good reasons)

Have the AI maintain a living document of codebase quirks and special cases

Document "gotchas" and unexpected behaviours

Create a glossary of domain-specific terms and concepts

The key is patience in the documentation phase rather than rushing to make changes.

Common Pitfalls
- Rushing to implementation: Spend at least twice as long understanding as implementing
- Trying to fix everything at once: Incremental progress is more sustainable
- Not maintaining documentation: Keep updating as you learn
