---
name: create-r-analysis-skill
description: 'Creates a new agent capability skill by learning from R analysis examples and R package documentation. Use when asked to "create a skill from my R code", "build a capability for this R workflow", "encode my R analysis approach", "turn these R examples into a reusable skill", "capture how I use these R packages", or "build a skill from my R project". Given a project directory and R package names, extracts package documentation, studies example R/Rmd files, and synthesises a new SKILL.md with reference files that teach agents to write similar analyses. Requires capable models (Claude Sonnet / GPT-4 class). Do NOT use for general R coding assistance, or for creating skills unrelated to R analysis.'
license: MIT License Copyright AI4CI
metadata:
  author: Rob Challen
  version: 0.01
---

# Create R Analysis Skill

A meta-skill that generates new capability skills for R analysis workflows. It studies your
existing R code examples and R package documentation to synthesise a tailored `SKILL.md` that teaches agents to write similar analyses using the same packages.

## When to Use This Skill

Use this skill when the user wants to capture their R analysis approach as a reusable agent skill:

- "Create a skill from my R code / R project"
- "Build a capability for this workflow", "encode how I use these packages"
- "Turn these examples into a skill", "make this analysis repeatable for an agent"
- Working with custom or domain-specific R packages that agents won't know about by default
- User has `.R` or `.Rmd` example files representing a pattern worth encoding

Do NOT use this skill for:
- General R coding help unrelated to creating a new agent skill
- Creating skills for non-R projects
- Simply explaining what an R package does

## Available Scripts

- [`scripts/list_documentation.R`](scripts/list_documentation.R): Lists the vignettes, and manual pages available for a given package.
- [`scripts/extract_documentation.R`](scripts/extract_documentation.R): Extracts full documentation for a locally installed R package (DESCRIPTION, vignettes, function reference) as plain text. Used in Step 3 of the workflow.
- [`scripts/pick_documentation.R`](scripts/pick_documentation.R): Extracts a single vignette or manual page by name for a locally installed R package as plain text. Used in Step 3 of the workflow.

  ```bash
  Rscript scripts/extract_documentation.R --package <package_name> [--output <file>]
  ```

Run from the base directory of this skill as provided in your skill context.
## Prerequisites

**Inputs** — gather from user if not provided:

| Input | Description |
|-------|-------------|
| `PROJECT_DIR` | Path to the project directory containing example R/Rmd files |
| `PACKAGES` | List of R package names to document (the key packages used in the project) |
| `SKILL_NAME` | Name for the new skill (lowercase, hyphenated, e.g. `analyse-survival-data`) |
| `SKILL_BASEDIR` | Where to write the new skill (e.g. `$PROJECT_DIR/.github/skills`) |

**System requirements**:
- R must be installed (`Rscript` in PATH)
- The listed R packages must be installed locally
- Read access to the project directory
- Write access to `SKILL_BASEDIR`

**Model requirement**: This skill involves reading substantial documentation and synthesising
structured guidance. Use a capable model (Claude Sonnet / GPT-4 class or above). Smaller models may miss important patterns or produce shallow output.

## Workflow

### Step 1: Gather and validate inputs

Ask the user for any missing inputs from the table above. Confirm the full set before proceeding — it saves iteration time later.

Ask the user what aspect of the analysis they want to focus on. It may be that the analysis covers several complementing capabilities and the user will want to make several skills from one set of inputs, so wants you to focus on specific parts of the code.

You **MUST** get the user to confirm that your intentions are correct before moving to step 2
### Step 2: Create the output skill directory

Create the directory structure for the new skill:

```
${SKILL_BASEDIR}/skills/${SKILL_NAME}/
├── references/       # populated in Step 6
└── SKILL.md          # created in Step 7
```


### Step 3: Scan the project for analysis examples

Use glob/grep to find analysis files in `PROJECT_DIR`:
- Look for `*.R`, `*.Rmd`, `*.qmd` files
- Focus on analysis scripts; skip package source (`R/` directories) and test files (`tests/`)
- Read the most representative examples — prioritise files that use multiple key packages
- Focus on parts that align with the user's area of interest for this skill
### Step 4: Extract R package documentation

- Either: for each package in `PACKAGES`, run the extraction script to capture its full documentation: [`scripts/list_documentation.R`](scripts/list_documentation.R): This may produce a large output so most output it to a temporary file and analyse from there, with a focus on vignettes.
 
```bash
Rscript <skill_base_dir>/scripts/extract_documentation.R \
  --package <package_name> \
  --output /tmp/<package_name>_docs.txt
```

- Or: if you know what functions are relevant from the packages load them directly with [`scripts/list_documentation.R`](scripts/list_documentation.R) and [`scripts/pick_documentation.R`](scripts/pick_documentation.R)

```bash
Rscript <skill_base_dir>/scripts/list_documentation.R \
  --package <package_name>
  
Rscript <skill_base_dir>/scripts/pick_documentation.R \
  --package <package_name>
  --vignette <vignett_name>
```

Your skill base directory is provided in your context — use it to locate the script.
### Step 5: Analyse patterns and goals

Read the example files alongside the extracted package docs. Identify:

1. **Analysis goals** — What is the analysis trying to achieve? (e.g. survival analysis, spatial
   modelling, time series forecasting)
2. **Package roles** — What does each package contribute? What are its key functions and idioms?
3. **Common patterns** — What code patterns appear repeatedly across the examples?
4. **Data flow** — How is data typically structured, loaded, transformed, and output?
5. **Domain conventions** — Are there domain-specific naming, units, or data structures?

This synthesis is the core of the skill — take time here to understand intent, not just
mechanics.

### Step 6: Write reference files

For each package (or logical grouping), create a concise reference file:

```
${SKILL_BASEDIR}/skills/${SKILL_NAME}/references/<package_name>.md
```

Each reference file should contain:
- Purpose of the package in this analysis workflow
- Key functions with signatures and brief descriptions
- Typical usage patterns with short code snippets drawn from the real examples
- Common pitfalls or gotchas observed in the examples

Keep each file under 300 lines. For large packages, focus only on the subset of functions
actually used in the examples — breadth is less useful than depth on what matters.

### Step 7: Write the SKILL.md

Create `${SKILL_BASEDIR}/skills/${SKILL_NAME}/SKILL.md` as a **capability skill** — it describes
a way of working rather than a fixed procedure. The output skill should include:

**Frontmatter**:
- `name` — matches the folder name exactly
- `description` — rich, keyword-dense: WHAT the analysis does, WHEN to trigger, key phrases a  user might say. See the `create-new-skill` skill for description guidance.

**Body sections** to include:

| Section              | Content                                                                      |
| -------------------- | ---------------------------------------------------------------------------- |
| `## When to Use`     | Reinforce triggers; include "Do NOT use for" negatives                       |
| `## Prerequisites`   | Data inputs, required packages, environment setup                            |
| `## Guidance`        | Representative code patterns from the real examples ("what good looks like") |
| `## References`      | Links to bundled reference files with guidance on when to read each          |
| `## Troubleshooting` | Common R-specific issues: missing packages, data format mismatches           |

The **Guidance** section is where most value is delivered — include concrete, annotated code
snippets drawn directly from the examples. Explain *why* patterns are used, not just *what* they
do.

### Step 8: Validate the output skill

Run the validator on the newly created skill:

```bash
uvx --from skills-ref@0.1.1 agentskills validate ${SKILL_BASEDIR}/skills/${SKILL_NAME}
```

Fix any validation errors before presenting the result to the user.

## Validation

Before declaring the skill complete, verify:

- [ ] All specified R packages were successfully summarised in references
- [ ] At least one example R/Rmd file was found and read
- [ ] Output `SKILL.md` passes `agentskills validate`
- [ ] Reference files are under 300 lines each and contain real code snippets from the examples
- [ ] The `description` field explains WHAT the analysis does and WHEN to trigger (10-1024 chars, wrapped in single quotes)
- [ ] Guidance section contains annotated, real code examples — not invented or generic snippets

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Package not found by extract script | Package must be installed locally — ask user to run `install.packages("<pkg>")` in R first |
| No R/Rmd examples found | Confirm `PROJECT_DIR` with user; check subdirectories with `find "$PROJECT_DIR" -name "*.Rmd"` |
| Raw package docs too large to process | Read vignettes first; then load only function entries for functions that appear in the examples |
| `agentskills validate` fails on `name` | Ensure folder name and `name` field match exactly (lowercase, hyphens only) |
| `agentskills validate` fails on `description` | Must be 10-1024 chars and wrapped in single quotes |
| Output skill is generic / not grounded | Return to Step 5 — read more examples more carefully before writing; quote real code |

## References

- [`scripts/extract_documentation.R`](scripts/extract_documentation.R) — R package documentation
  extractor (run this in Step 3)
- [`scripts/list_documentation.R`](scripts/list_documentation.R) and [scripts/pick_documentation.R]
- [`eval/scripts/test_extract_documentation.sh`](eval/scripts/test_extract_documentation.sh) —
  Test script for the extractor; run after changes to the extractor script
- `create-new-skill` skill — Canonical guidance on `SKILL.md` structure, description best
  practices, and skill types
