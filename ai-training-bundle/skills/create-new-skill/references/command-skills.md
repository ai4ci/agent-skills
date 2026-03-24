# Command-style skills

These are implemented in different ways in different AI platforms.

Only use them if all the following are true of a skill:
- Short and task focussed skill
- Triggered explicitly by the user or by an orchestrating agent
- Purpose of the skill is to perform a specific set of actions determinstically
- Completely self contained and do not need to call out to scripts or use other resources
- Can be executed with minimal user input

If any of these are not certain, follow the main guidance for procedural skills.

In general command-style skills should remove as much uncertainty as possible from a process. They will be more like a program. They may be specifically useful for smaller context simpler models. In some platforms they cannot access scripts or resources.

## Directory layout

For claude code the layout is the same as skills
```
<base-directory>/skills/<skill-name>/
└── SKILL.md          # always
```

In opencode it is different
```
<base-directory>/commands/
└── <skill-name>.md          # always
```

The most future proof looks to be to create a symbolic link in the commands directory:
```
<base-directory>/
├── commands/
│   └── <skill-name>.md -> ../skills/<skill-name>/SKILL.md
└── skills/
    └── <skill-name>            # Static resources
        └── SKILL.md            # Static resources
```

## Front matter

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase letters/numbers/hyphens only, must match folder name |
| `description` | Yes | 1-1024 chars, must describe WHAT it does AND WHEN to use it |
| `license` | No | License name or reference to bundled LICENSE.txt |
| `model` | No | Model to use when this command is activated. |
| `agent` | No | Which subagent type to use. |
| `context` | No | Claude specific: Set to "fork" to run in a forked subagent context. |
| `disable-model-invocation` | No | Claude specific: Set to true to prevent Claude from automatically loading this skill. Use for
| `subtask` | No | OpenCode specific: boolean option to suggest opencode uses a different agent |
| `return` | No | OpenCode with Subtask2 specific: tell the main agent what to do after a command completes |
| `parallel` | No | OpenCode with Subtask2 specific: Run multiple subtasks concurrently |

## Main body

Command skills get passed arguments as `$ARGUMENTS`, which may be referred to by index `$1`, `$2`, ... but this is only true if they are invoked by a slash command.

A simpler structure to the SKILL.md file is needed we suggest:

| Section | Purpose |
|---------|---------|
| `# <Title>` | Meaningful title name followed by a brief overview |
| `## Inputs` | Required inputs and how they map to `$ARGUMENTS`, dependencies (e.g. bunx, uvx, bash functions) |
| `## Steps` | Numbered steps for tasks with specific one line bash, uvx, bunx commands to execute |
| `## Tests` | How to validate output, e.g. syntatical correctness |
| `## Output` | Instructions on what to report back to the user or calling agent |
| `## Error handling` | What to do when it goes wrong |


### Steps

Instructions in SKILL.md work better when they explain _why_ a guideline exists, not just _what_ to do. (reasoning-based, versus imperative. For commands however a more imperative style may be appropriate. Bare "MUST/NEVER/ALWAYS" language is useful for hard safety constraints, and mandatory checkpoints, but for workflow guidance, reasoning produces more adaptive behaviour.