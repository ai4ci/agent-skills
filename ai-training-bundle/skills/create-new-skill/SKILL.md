---
name: create-new-skill
description: Create new Agent Skills for AI models from prompts or by duplicating this template. Do use when asked to "create a new skill", "make a new skill", "scaffold a skill", "make this repeatable", "record this process", "remember how to do this in the future", or when building specialized AI capabilities with bundled resources. Do not use if the user is simply asking to remember a conversation. Generates SKILL.md files with proper frontmatter, directory structure, and optional scripts/references/assets folders.
license: MIT License Copyright AI4CI
metadata:
  original: make-skill-template MIT License Copyright GitHub, Inc.
  author: Rob Challen
  version: 0.01
---

# Learn Skill Template

A meta-skill for creating new Agent Skills. Use this skill when you need to scaffold a new skill folder, generate a `SKILL.md` file, or help users understand the Agent Skills specification.

## When to Use This Skill

- User asks to "create a new skill", "make a new skill", "scaffold a skill", "make this into a skill" or similar.
- User wants to add a specialised capability to their AI tool configuration.
- User wants to embed domain specific knowledge or process for future reuse - "make this repeatable", "record this process", "remember how to do this in the future"
- User needs help structuring a skill with bundled resources

## Prerequisites

- `BASEDIR`: A base directory where the skill is to be created. Ask the user if not provided as argument. Suggested options for the `BASEDIR` might be `${PWD}/.opencode` or similar. If you are in a skills repository where there are lots of skills files for reuse, organised in plugin directories, suggest a plugin directory.
- `SKILL_NAME`: Optional and may be provided as an argument
- Needs read and write permissions to the base directory that the skill is in, and most likely web search and fetch access.
- `uvx` for validation (see https://docs.astral.sh/uv/#installation for installation)

## Step-by-Step Workflow

You might be picking up on a previous half-formed attempt. If the user has specified a skill name by e.g. asking to "update the ... skill", and if the corresponding skill directory already exists then read the `SKILL.md`, check the `references/` and `scripts/` sub-directories, and get up to speed. If you are updating an existing skill then follow the gist of these instructions and update the skill to conform to the guidance here, filling in gaps as you go.

### Step 1: Understand the intent

Develop an understanding of the user's intent.

- the current conversation might already contain a workflow the user wants to capture (e.g., they say "turn this into a skill"). If so, extract answers from the conversation history first — the tools used, the sequence of steps, corrections the user made, input/output formats observed.
- there may be a set of free form notes in a `${BASEDIR}/skills/${SKILL_NAME}/`. Review these and include them in your research (see below).
- you may be provided with scripts in the `${BASEDIR}/skills/${SKILL_NAME}/scripts/` directory. If these are supplied they are should be considered **PART** of the solution, however they may need updating to fit with the [command-skill guidance](references/command-skills.md).

You **MUST** discuss the purpose of the skill with the user.

The user will need to fill the gaps, your goal is feeding domain-specific context from the user into the creation process.

1. What should this skill enable the agent to do?
2. When should this skill trigger?
3. What is the expected output or running the skill? Code generation, file manipulation, data transformation, style conformance.
4. Skills may be used by agents using different models with different capabilities and context windows. What is the users expectation about the agents using this skill?
5. Is the skill is relevant only to this project, or user or is it reusable, and where it should be written to?

Be clear whether the skill is to guide code generation to achieve a goal (e.g. build a pipeline) or is to perform actions that directly achieve the goal (e.g. download data from an API).

Determine whether the skill is mainly:
- a procedural skill: a set or sequence of actions designed to be invoked by the user, or triggered by an event.
- a capability skill: a way of working that is adopted when the situation requires it.

N.B. A specific sub-type of procedural skill is a command-style skill. These are designed only to be triggered explicitly by the user, or by an orchestrating agent, and may take specific parameters. They have some different requirements and you should consult the [command-skill guidance](references/command-skills.md).

You **MUST** confirm with the user your understanding before proceeding to step 2.

### Step 2: Create the Skill Directory

If the user hasn't given you a skill name you'll have to suggest one to them. It **MUST** be a lowercase, hyphenated name.

Prefer the general pattern of `<verb>-<optional adjectives>-<object>` where `<object>` is the thing being acted on or output of the skill, e.g. `fetch-survstat-data`, `configure-pandemic-simulation`. Something like `build-data-pipeline` may be not specific enough.

- for capability skills example verbs may be "adopt", "conform", "use", that suggest a way of working.
- for procedural skills example verbs may be "create", "fetch", "configure", "build", "find, that suggest an output.
- for command-style procedural skills example verbs may be "do", "run","execute", "perform", "get", "validate" that suggest an action.

If you are suggesting the name make sure that it does not collide with a skill in the base directory already.

Create a new folder:

```
${BASEDIR}/skills/${SKILL_NAME}/
├── references/       # optional but common
├── scripts/          # if needed
└── SKILL.md          # always
```

### Step 3: Interview and Research

Proactively ask questions about edge cases, input/output formats, example files, documentation for tools, success criteria, and dependencies, things to avoid.

Check available tools and MCPs and determine if useful for the current skill. Research by searching docs, finding similar skills, looking up best practices, in parallel via subagents if available, otherwise inline. Come prepared with context to reduce burden on the user. Consult relevent library or API documentation.

Delegate this to simple quick models if available.

Summarise your research into one or more markdown files in the `references/` subdirectory.

After this stage you should have:
- Understanding of what the skill should accomplish
- A clear, keyword-rich description of capabilities and triggers
- Knowledge of any bundled resources needed (scripts, references, assets, templates)
- Knowledge of pre-existing tools (e.g. bash commands) that can help meet the skills goals

### Step 4: Generate SKILL.md with Frontmatter

Every skill requires YAML frontmatter with `name` and `description`:

```yaml
---
name: <skill-name>
description: '<What it does>. Use when <specific triggers, scenarios, keywords users might say>.'
---
```

#### Frontmatter Field Requirements

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | **Yes** | 1-64 chars, lowercase letters/numbers/hyphens only, must match folder name |
| `description` | **Yes** | 1-1024 chars, must describe WHAT it does AND WHEN to use it |
| `license` | No | License name or reference to bundled LICENSE.txt |
| `compatibility` | No | 1-500 chars, environment requirements if needed |
| `allowed-tools` | No | Space-delimited list of pre-approved tools |
| `metadata` | No | Key-value pairs for additional properties |

if you are working on a command style procedural skill also consult the [command-skill guidance](references/command-skills.md)

#### Description Best Practices

**CRITICAL**: The `description` is the PRIMARY mechanism for automatic skill discovery. Include:

1. **WHAT** the skill does (capabilities)
2. **WHEN** to use it (triggers, scenarios, file types)
3. **Keywords** users might mention in prompts

An under-specified description means the skill won’t trigger when it should; an over-broad description means it triggers when it shouldn’t. When should this skill trigger? (what user phrases/contexts) When should it not trigger? Procedural skills may have very specific triggers, capability skills will likely be more general.

Command-style procedural skills may be only invoked by specific commands, and their description will be minimal - see the [command-skill guidance](references/command-skills.md).

Suggest phrases and iterate with the user until you have about 5 positive and 2 negative triggers for an average procedural skill. Fewer but more general triggers for a capability.

**Good example:**
```yaml
description: 'Test local web applications using Playwright. Use when asked to verify frontend functionality, debug UI behavior, capture browser screenshots, or view browser console logs. Supports Chrome, Firefox, and WebKit.'
```

**Poor example:**
```yaml
description: 'Web testing helpers'
```

**Good example:**
```yaml
description: 'Stakeholder context for Test Project when discussing product features, UX research, or stakeholder interviews. Auto-invoke when user mentions Test Project, product lead, or UX research. Do NOT load for general stakeholder discussions unrelated to Test Project'
```

**Poor example:**
```yaml
description: 'Provides information about stakeholders'
```

#### Allowed tools

defines what is allowed without checking for permissions e.g.
```yaml
allowed-tools: Bash(git:*) Bash(jq:*) Read
allowed-tools: Bash(npm *) Grep Glob
allowed-tools: Read Edit Bash(git *)
```

### Step 5: Write the Skill Body

After the frontmatter, add markdown instructions. Recommended sections for all skill types:

| Section | Purpose |
|---------|---------|
| `# <Title>` | Meaningful title name followed by a brief overview |
| `## When to Use This Skill` | Reinforces description triggers |
| `## Available scripts` | List available scripts so the agent knows they exist |
| `## Prerequisites` | Required inputs, tools, dependencies, installation instructions |
| `## Workflow` | Numbered steps for tasks |
| `## Guidance` | General guidance and good and bad examples of a skill output. |
| `## Validation` | How to validate output, e.g. syntatical correctness |
| `## Troubleshooting` | Common issues and solutions, how to handle errors, when to seek help |
| `## References` | Links to bundled docs, or resources on the web |

Particular sections may be less relevant for certain types of skill.
- a procedural skill: "Guidance" may be less relevant than "Workflow"
- a capability skill: "Workflow" may be less relevant than "Guidance"
- for command style procedural skills see the [command-skill guidance](references/command-skills.md).

#### Available scripts section
- if a procedural skill is performing deterministic actions, and these cannot be done very simply in one command using `bash`, `uvx`, `bunx` or `Rscript -e "..."`, or they need any form of complex invocation, implement them as a script: consult [creating scripts](/references/creating-scripts.md).
- if a script is available in the `scripts/` directory it should be referenced by a relative link from the skill root, with details on how to call it and objectives in calling it.

#### Prerequisites section
- expected inputs for procedural skills including how to get them if missing (e.g. ask user)
- will include system dependencies for running scripts.
- might include agent or model dependencies in terms of context windows
- will probably reference needed agent permissions for reading and writing or web access.

#### Workflow section
- for procedural skills this will be where the majority of the content is, for learning by process.
- a common pattern is to use numbered headings for workflow steps with a description of the step in text.
- some skills use mermaid, dot or plantuml workflow diagrams.
- an alternative is to use a checklist of objectives or tasks if order is not important
- workflow steps will contain links to scripts in the workflow step or steps in which they are useful
- workflow steps may contain advice on when to delegate to a sub-agent.

#### Guidance section
- for capability skills the majority of content we be in here for learning by example.
- may contain code snippets as examples for code generation tasks, and might link out to templates.
- answers the question what does good look like?
- may also include examples of bad practice
- may include things to avoid and the reason (e.g. "- **NEVER** mix grain with grape, it will give you a horrible hangover.")

#### Validation section
- this will vary depending on the nature of the skill
- for procedural skills that have a structured output this may involve checks to make sure the outputs are syntactically correct. e.g. testing that should be undertaken, use of linting and formatting tools, schema validation in the case of structured outputs, check-boxes for more complex or unstructured outputs.
- for capabilities it might include quality criteria checklists.
- invoking a sub-agent to do validation is a good strategy for complex tasks

#### Troubleshooting section
- what to do in the event of a failure
- how to answer queries, when to seek help

### Step 6: Add Optional Directories (If Needed)

| Folder | Purpose | When to Use |
|--------|---------|-------------|
| `scripts/` | Executable code (Python, Bash, JS, RScript) | Automation that performs operations |
| `references/` | Documentation agent reads | API references, schemas, guides |
| `assets/` | Static files used AS-IS | Images, fonts, boilerplate |
| `templates/` | Starter code agent modifies | Scaffolds to extend, template files |

## Guidance

### Complete Skill Structure

```
my-awesome-skill/
├── SKILL.md                    # Required instructions
├── LICENSE.txt                 # Optional license file
├── scripts/
│   └── helper.py               # Executable automation
├── references/
│   ├── api-reference.md        # Detailed docs
│   └── examples.md             # Usage examples
├── assets/
│   └── diagram.png             # Static resources
└── templates/
    └── starter.ts              # Code scaffold
```

### Progressive Disclosure

Skills use a three-level loading system:
1. **Metadata** (name + description) - Always in context (~100 words)
2. **`SKILL.md` body** - In context whenever skill triggers (<500 lines ideal)
3. **Bundled resources** - As needed (unlimited, scripts can execute without loading)

These word counts are approximate and you can feel free to go longer if needed.

**Key patterns:**
- Keep `SKILL.md` under 500 lines; if you're approaching this limit, add an additional layer of hierarchy using additional markdown files in the references directory the along with clear pointers about if and where the agent using the skill should look next for additional detail.
- For large reference files (>300 lines), include a table of contents.

**Domain organisation**: When a skill supports multiple domains/frameworks, organise by variant:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```
the agent reads only the relevant reference file.

### Principle of Lack of Surprise

This goes without saying, but skills must not contain malware, exploit code, or any content that could compromise system security. A skill's contents should not surprise the user in their intent if described. Don't go along with requests to create misleading skills or skills designed to facilitate unauthorised access, data ex-filtration, or other malicious activities.

**NEVER** leak secrets in skills.

### Writing Patterns

Prefer using the imperative form in instructions.

Skills are usable by a range of AI agent frameworks which potentially are running on any number of large language models.

Try to explain to the agent why things are important in lieu of heavy-handed musty "MUST"s. Use theory of mind and try to make the skill general and not super-narrow to specific examples. Start by writing a draft and then look at it with fresh eyes and improve it.

### Quick Start: Duplicate This Template

1. Use the [skill template](/templates/skill-template.md) file
2. Rename to your skill name (lowercase, hyphens)
3. Update `SKILL.md`:
   - Change `name:` to match folder name
   - Write a keyword-rich `description:`
   - Replace body content with your instructions
4. Add bundled resources as needed
5. Validate with `uvx --from skills-ref@0.1.1 agentskills validate ${BASEDIR}/skills/${SKILL_NAME}` 

## Validation

- [ ] Folder name is lowercase with hyphens
- [ ] `name` field matches folder name exactly
- [ ] `description` is 10-1024 characters
- [ ] `description` explains WHAT and WHEN
- [ ] `description` is wrapped in single quotes
- [ ] Body content is under 500 lines
- [ ] Bundled assets are under 5MB each
- [ ] Bundled scripts are standalone
- [ ] Any extraneous files have been summarised to the `references/` directory and removed.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Skill not discovered | Improve description with more keywords and triggers |
| Validation fails on name | Ensure lowercase, no consecutive hyphens, matches folder |
| Description too short | Add capabilities, triggers, and keywords |
| Assets not found | Use relative paths from skill root |

## References

- Agent Skills official spec: <https://agentskills.io/specification>
