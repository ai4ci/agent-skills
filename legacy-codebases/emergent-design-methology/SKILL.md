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
## Fundamental principles

* The primary goal is to improve code maintainability and quality, and to make it possible for other agents and humans to understand the project.
* Automated tests are essential to success.
* Code quality metrics must be put in place.
* A secondary goal is to help address issues.
* A distant tertiary goal is to add new features.

Your priorities
* Map out the code, update design and end user documentation, including test scripts
* Retrofit automated testing, quality checks and continuous integration
* Retrospectively prototype legacy features to help discover issues, and create test data.
* Develop test support services to make implementing testing easy.

You are striving for
* 20% of code is developer focused comments describing intent and control flow with clear provenance (e.g. `// AI: at this point XYZ is ...`)
* Diagnostic trace logging enthusiastically embraced in new and legacy code.
* Code quality is improving by measuring and acting on code coverage, linting, etc.
* Design documentation that mirrors production code and is updated after every change.
* User documentation that mirrors current features and is updated after every change.
* Version information available through the code (e.g. a `--version` option).

Working style
* When implementing features or fixing issues with production code you must follow the [[editing-production-code]] guidance
* 

New features
- Validate requirements for new features with the developer before implementing
* Keep it simple - simpler code is easier to maintain. 
* YAGNI - fewer options = more useable code and simpler control flow.
* Prospectively prototype new features
* No new production code without automated tests

---

---
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






---



---

### Advanced Debugging with Logging

When debugging:
* Don't implement fixes without **clear evidence** for cause.
* Replicate issue and code up a failing test case.
* Add logging for this issue / function for the input and outputs
* Run function, review the logs and fix the issue.

By using logging, you can see exactly what's happening inside the function, which variables have unexpected values, and where things are breaking.
### Revert Reimplement loop

- After you have fixed a complex issue, ask yourself what the issue was and how it was fixed
- Ask: "If we had this issue again, what would we need to prompt to fix it?"
- Document this approach in the issue.
- Go back to a previous restore point or commit (right as the bug occurred)
- Say: "Looking at the code, please follow this approach and fix the problem..."

This uses future knowledge to prevent spaghetti code that results from just prompting through an issue without understanding it.

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

### 3) Use AI for Exploratory Tasks

- Summarize confusing methods
- Map out outdated class hierarchies
- Draft migration plans

### refactoring:
- moving code to where it most logically belongs
- removing duplicate code
- making names self-documenting
- splitting monolithic methods into smaller pieces
- re-arranging inheritance hierarchies

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
