---
name: manage-github-issues
description: >
  Manage issues, pull requests, and discussions in your own GitHub project.
  Use when triaging, creating, editing, or closing issues; reviewing and
  merging PRs; or managing discussions. Covers issue lifecycle management,
  sub-issues and relationships, PR review workflow, discussion commands, and
  the gh api fallback. Do not use for searching external repos or for
  forking/contributing to upstream projects.
allowed-tools: Read, Edit, Write, Bash, Glob
compatibility: >
  Requires gh CLI v2.0+. Issue types, sub-issues, and blocked-by/blocking
  relationships require v2.30+. On GHES: issue types need 3.17+,
  blocked-by/blocking need 3.19+.
metadata:
  source_url: https://cli.github.com/manual/
---

# Manage Current Project Github Issues — Agent Skill

Full documentation: https://cli.github.com/manual/

---

## When to Use

Use this skill when you are **in a GitHub repository (or targeting one you
manage)** and need to work with its issues, PRs, or discussions. Typical
triggers:

- Triage: reviewing new issues, labeling, assigning, prioritizing
- Managing issue lifecycle: creating, editing, linking, closing issues
- Working with sub-issues and blocking relationships
- Reviewing, merging, or closing PRs
- Managing GitHub Discussions (listing, creating, editing, commenting)
- Checking PR status, review-thread comments, or commit history

**This skill is for managing your own project's GitHub workflow.** For
searching issues in a dependency or external repo, use the
`search-github-project-issues` skill instead.

## Quick Start — Triage Workflow

```bash
# 1. List open issues (adjust -L for your needs)
gh issue list --state open -L 50

# 2. Filter by label or state
gh issue list --label "bug" --state open
gh issue list --assignee "" --state open   # unassigned issues

# 3. Create a new issue — use the appropriate reference
## Technical bug (deferred fix, root cause, architectural defect)
## Read references/technical-bug-reports.md first

gh issue create \
  --title "[module] — What breaks and where" \
  --body-file -  # write to file first using the technical-bug-reports guide

## Feature proposal (new feature, architectural change, design decision)
## Read references/feature-proposals.md first

gh issue create \
  --title "RFC: [Component] — Brief description" \
  --body-file -  # write to file first using the feature-proposals guide

# 4. View an issue with full details
gh issue view 42 --json title,body,state,comments,labels,assignees

# 5. Edit an issue
gh issue edit 42 --add-label "priority:high" --assignee username
```

## Issue Management

### Listing and filtering issues

```bash
# List open issues, sorted by created date (most recent first)
gh issue list --state open --sort created --order desc

# Filter by label
gh issue list --label "bug" --label "priority:high"

# Filter by assignee
gh issue list --assignee username --state open
gh issue list --assignee "" --state open   # unassigned

# Filter by type
gh issue list --type bug --state open

# Search within a repo (flag value, quoted string)
gh issue list --search "crash" --state open
```

### Creating issues

```bash
# Create with body from stdin or flag
gh issue create --title "Bug: server crashes on startup" --body "..."

# Body from a file (avoids -T flag collision)
gh issue create --title "..." --body-file CHANGELOG.md

# Create as a sub-issue
gh issue create --title "..." --body "..." --parent 42

# Create with relationships
gh issue create --title "..." --blocked-by 42,43 --blocking 44
```

### Editing issues

```bash
# Single issue
gh issue edit 42 --add-label "bug" --remove-label "triage" --assignee user1

# Multiple issues in the same repo
gh issue edit 42 43 --add-label "bug"

# Remove relationships
gh issue edit 42 --remove-type --remove-parent --remove-blocked-by

# Edit sub-issue relationship (one issue at a time)
gh issue edit 42 --add-sub-issue 43
```

## Issue Types, Sub-issues, and Relationships

Newer `gh issue` subcommands model issue types, sub-issue hierarchy, and
blocked-by/blocking relationships.

### Available fields (via --json)

| Field | Description |
|---|---|
| `issueType` | Type name (e.g., "bug", "enhancement") |
| `parent` | Parent issue (for sub-issues) |
| `subIssues` | Sub-issues list (object with `nodes` + `totalCount`) |
| `subIssuesSummary` | Summary of sub-issue completion |
| `blockedBy` | Issues this one is blocked by |
| `blocking` | Issues blocked by this one |

### Important details

- `subIssues`, `blockedBy`, and `blocking` are objects shaped:
  ```json
  {"nodes": [...], "totalCount": N}
  ```
  `nodes` is capped (`subIssues` at 100, `blockedBy`/`blocking` at 50).
  Compare node count against `totalCount` to detect truncation.
- Relationship and parent refs accept issue numbers or URLs. URLs may
  point to another repo on the same host; different hosts are rejected.
- `--add-sub-issue` cannot be used when editing more than one issue.
- GHES: issue types/sub-issues need v3.17+; blocked-by/blocking need v3.19+.

## Pull Request Management

### Listing PRs

```bash
# Open PRs
gh pr list --state open

# Filter by state, label, reviewer
gh pr list --state merged --label "release"
gh pr list --reviewer self --state open   # PRs awaiting my review
gh pr list --author dependabot --state open

# Search within the repo
gh pr list --search "fix" --state open
```

### Viewing PRs

```bash
# Full PR with comments, commits, and files
gh pr view 42 --json title,body,state,comments,commits,files,labels,reviews,assignees,reviewDecision

# Review thread comments (different from issue-level comments)
gh api repos/{owner}/{repo}/pulls/{n}/comments
```

### Reviewing and merging PRs

```bash
# View the diff without checking out
gh pr diff 42

# Checkout locally for deeper inspection
gh pr checkout 42

# Approve a PR
gh pr review --approve 42 --body "LGTM"

# Comment on a PR review
gh pr review --comment 42 --body "Suggestion: ..."

# Request changes
gh pr review --request-changes 42 --body "Needs work: ..."

# Merge a PR
gh pr merge 42 --delete-branch --squash
gh pr merge 42 --delete-branch --merge
gh pr merge 42 --delete-branch --rebase
```

## Discussions (`gh discussion`)

Use when the user explicitly references GitHub Discussions — not for
issues or PRs. Preview command set, subject to change.

### Listing discussions

```bash
gh discussion list --state open --category "General"
gh discussion list --state all --category "Q&A" --answered
gh discussion list --search "setup" --sort created --limit 20
```

- `--state` defaults to open; `--sort` defaults to updated; `--order` defaults to desc.
- `--answered` is tri-state: `--answered` for answered, `--answered=false`
  for unanswered (Q&A categories).

### Viewing discussions

```bash
# View discussion with comments
gh discussion view 10 --comments

# Comments ordered newest first by default
gh discussion view 10 --comments --order oldest --limit 50

# View a specific comment
gh discussion view <comment-id> --comments

# JSON output for structured parsing
gh discussion view 10 --json title,body,author,category,commentsCount
```

### Creating discussions

```bash
gh discussion create \
  --title "Discussion title" \
  --body "Discussion content" \
  --category "General"
```

Title, body (`--body` or `--body-file`), and category are required
non-interactively.

### Editing discussions

```bash
gh discussion edit 10 --title "New title" --body "New content"
gh discussion edit 10 --add-label "pinned"
gh discussion edit 10 --remove-label "needs-response"
```

### Commenting

```bash
# Add a top-level comment to a discussion
gh discussion comment 10 --body "My comment"

# Reply to a comment
gh discussion comment <comment-id> --body "Reply"

# Edit or delete a comment/reply
gh discussion comment <comment-id> --edit --body "Updated text"
gh discussion comment <comment-id> --delete --yes
```

`--json`/`--jq`/`--template` are available on `list` and `view` only;
`create` and `edit` print the discussion URL. `comment` prints the comment
(or reply) URL.

## Authentication

```bash
# Check auth status
gh auth status

# Structured auth info
gh auth status --json userName,host,authToken

# Login (if needed)
gh auth login
```

## References

> **These references are the authoritative guide for issue quality.**
> The Quick Start examples below show the CLI workflow only — do not use
> them as templates for issue bodies. Consult the appropriate reference
> below when writing issue or PR content.

When creating or editing issues in this project, read the appropriate reference:

### Reading `references/technical-bug-reports.md`

**Read this reference when:**
- You are creating a **technical bug report** in the current project
- The bug is complex enough to not fit in a TODO comment
- The fix will be deferred (root cause known but risky, or requires refactoring)
- You discovered an architectural problem, performance issue, or technical debt
- The bug is intermittent or environment-specific

This reference covers the internal bug report format: module-prefixed titles, root cause analysis with file/line references, deferred fix sections (status, reason, effort estimate), scope documentation, and internal evidence (logs, metrics, profiles).

**Mandatory read** when the user asks you to file a bug report in the current project that involves technical detail or deferred work. Do not fall back to `issue-authoring.md` for these — the deferred section, root cause, and scope sections are unique to this reference.

### Reading `references/feature-proposals.md`

**Read this reference when:**
- You are proposing a **new feature** in the current project
- The feature or design change is too complex for a TODO comment
- You need to document a technical approach before implementation
- You're creating an RFC-style proposal that needs alternatives, open questions, and motivation

This reference covers the RFC structure: summary, motivation, proposed solution, alternatives considered, open questions, implementation plan, and status labels.

**Mandatory read** when the user asks you to propose a feature, document a design change, or create an RFC-style issue. An RFC proposal is appropriate for changes with significant architectural implications, not for simple bug fixes or cosmetic changes.

### Reading `references/duplicate-issues.md`

**Read this reference when:**
- You are **triaging a batch of new issues** and need to check for duplicates
- You are **closing a duplicate issue** and need the correct procedure
- You need to distinguish between a true duplicate and a similar-but-different issue

This reference covers: search heuristics for finding duplicates, the correct marking procedure (`Duplicate of #N` comment + close), treating duplicates as customer interactions (not noise), and when similar issues should be kept separate.

**Mandatory read** when the user asks you to triage, merge, or manage duplicate issues. Never close a duplicate with just "Duplicate of #123" — always include a thank-you note pointing the reporter to the primary issue.

### When to use which reference

| Task | Reference |
|---|---|
| Simple bug report in current project | Use inline guidance in this skill |
| Complex/deferred bug in current project | `references/technical-bug-reports.md` |
| Architecture or performance issue | `references/technical-bug-reports.md` |
| Feature proposal / RFC | `references/feature-proposals.md` |
| Design decision needing input | `references/feature-proposals.md` |
| Triage: merging duplicates | `references/duplicate-issues.md` |
| Triaging a batch of new issues | `references/duplicate-issues.md` |

---

## Common Gotchas

| Mistake | Consequence | Fix |
|---|---|---|
| `gh search issues "repo:X is:open"` | Parsed as single keyword → error | Use bare tokens: `gh search issues repo:X is:open` |
| `--author dependabot` | Matches nothing (bots are GitHub Apps) | Use `--app dependabot` |
| `--add-sub-issue` on multi-issue edit | Error: cannot use with more than one issue | Edit sub-issues one at a time |
| `-T` flag on `gh pr create` / `gh issue create` | Collides with `--body-file` | Use `--body-file` explicitly |
| `gh pr view --comments` vs review-thread comments | Shows issue-level comments only | Use `gh api repos/{owner}/{repo}/pulls/{n}/comments` for review threads |
| `gh issue list --search` vs `gh search issues` | Different query syntax (quoted string vs bare tokens) | Use `gh search issues` for full syntax; `gh issue list --search` for one-repo scoping |

## Further Reading

- [gh CLI manual](https://cli.github.com/manual/)
- [GitHub: Managing issues](https://docs.github.com/issues/tracking-your-work-with-issues/about-issues)
- [GitHub: About pull requests](https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
- [GitHub Discussions](https://docs.github.com/discussions)
