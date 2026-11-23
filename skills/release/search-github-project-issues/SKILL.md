---
name: search-github-project-issues
description: >
  Search and inspect issues, PRs, code, and remote files in any GitHub
  repository without cloning. Use when debugging an issue with a dependency,
  tool, or any GitHub-hosted project — searching for existing issues and PRs
  should be the first diagnostic step. Covers structured output, pagination,
  search syntax, repo targeting, and remote file reading. Do not use for
  creating issues, forking repos, or managing your own project's issues.
allowed-tools: Read, Bash, Glob
compatibility: >
  Requires gh CLI v2.0+. Some features require v2.30+.
metadata:
  source_url: https://cli.github.com/manual/
---

# Search GitHub Project Issues — Agent Skill

Full documentation: https://cli.github.com/manual/

---

## When to Use

Use this skill whenever you need to find information about a GitHub-hosted
project **that is not the current working repository**. Typical triggers:

- Debugging a crash, error, or unexpected behavior in a dependency or tool
  and needing to check if others have reported the same issue
- Investigating whether a behavior is a known issue, a fixed issue, or a
  feature request
- Checking if a PR fix for the issue exists (open, merged, or in-flight)
- Searching across multiple repos for discussions about a topic
- Inspecting remote files without cloning

**Rule: searching the repo's open and closed issues is the first diagnostic
step.** Do not start by guessing at causes or reimplementing logic — check
what others have reported first.

## Quick Start — Fact-Finding Workflow

```bash
# 1. Ensure gh is authenticated
gh auth status

# 2. Target the repo (gh infers from git remotes; override with --repo)
# To discover owner/repo from a local checkout: gh repo view --json nameWithOwner
REPO="owner/repo"

# 3. Search issues FIRST — before trying anything else
# Always search --state all: closed issues may have been closed
# without a fix (unconfirmed, out of scope, duplicate)
gh search issues "error message or symptom" --state all --repo "$REPO"

# 4. Check if a PR fixing it exists
gh search prs "root cause or fix" --state all --repo "$REPO"

# 5. If a matching issue exists, view it with structured fields
gh issue view <number> --json title,body,state,comments,labels,assignees

# 6. Inspect relevant source files without cloning
gh repo read-file <path> --repo "$REPO"
```

## Structured Search Queries

`gh search issues|prs|code|repos|commits` uses GitHub's search index and
accepts the full [GitHub search syntax](https://docs.github.com/search-github/github-searching-understanding-search-syntax-and-understanding-using-query-helpers).

### Bare tokens vs quoted strings

Pass each qualifier as its own **bare token**, not as one quoted string:

```bash
# ✅ Bare tokens — each qualifier is separate
gh search issues repo:owner/repo is:open label:bug

# ✅ Quoted multi-word free text
gh search issues "segmentation fault on startup" --repo owner/repo

# ❌ Quoted qualifiers — parsed as a single keyword → Invalid search query
gh search issues "repo:owner/repo is:open label:bug"
```

Most qualifiers also have dedicated flags — prefer them for readability:

```bash
gh search issues --repo owner/repo --author dependabot --state open
gh search issues --label "bug" --sort created --order desc
```

### Search qualifiers cheat sheet

| Qualifier | Example | Meaning |
|---|---|---|
| `repo:owner/name` | `repo:vlfeat/opencv` | Scoped to one repo |
| `is:open` / `is:closed` | `is:open` | Issue/PR state |
| `author:user` | `author:monalisa` | Created by user |
| `app:dependabot` | `app:dependabot` | Created by GitHub App (bot) |
| `label:bug` | `label:"help wanted"` | Issues with label |
| `in:title` | `title:crash` | Search in title only |
| `mentions:user` | `mentions:username` | Mentions user |
| `no:assignee` | `no:assignee` | No assignee |
| `created:>` / `created:<` | `created:>2024-01-01` | Date range |
| `is:pr` / `is:issue` | `is:pr merged:>2024-06-01` | Type + state filter |

### Search gotchas

- **Bots author as GitHub Apps** — `author:dependabot` matches nothing.
  Use `app:dependabot` (expands to `author:app/<slug>`) or
  `author:"dependabot[bot]"`.
- **Limit results** — list commands cap at 30 by default. Pass `-L 50` or
  higher to get more results.
- **Aggregate totals** — `gh issue list` / `gh pr list` do not expose
  `totalCount` via `--json`. For a true count, use `gh api graphql`.
- **Search vs list scoping** — `gh search issues` searches across GitHub;
  `gh issue list --search "..."` is scoped to one repo and takes the query
  as one quoted string (it's a flag value, not bare tokens).

## Core Patterns

### Interactivity policy

`gh` does the right thing in non-TTY contexts: it skips the pager, strips
ANSI color, and errors out fast with a helpful message instead of prompting
(e.g. `must provide --title and --body when not running interactively`).
You do **not** need to set `GH_PAGER` or pass `--no-pager` (no such flag
exists).

Set `GH_FORCE_TTY=1` only if you want TTY-style output (colors, tables, the
pager, interactivity) inside an agent harness; leave it unset otherwise.

### Structured output

Human output from `gh` is column-formatted. For structured data:

- Add `--json field1,field2,...` for structured output.
- Run a command with `--json` and **no field list** to print the full set of
  available fields, then pick what you need.
- Use `--jq '<expr>'` for filtering without piping through a separate `jq`.
- Use `--template '<go-template>'` (alongside `--json`) for shaped text
  output. Note that `--template` / `-T` collides with a body-template flag
  on a few commands (e.g. `gh pr create -T`, `gh issue create -T`); always
  check `--help` before assuming which one you're hitting.

### Pagination

List commands cap results.

- `gh issue list`, `gh pr list`, `gh search ...`: pass `-L N` (`--limit N`).
- For raw API calls use `gh api --paginate <path>`. Combine with `--jq` and
  (optionally) `--slurp` to assemble one array.

### Repo targeting

`gh` infers the repo from the cwd's git remotes. Pass `--repo OWNER/REPO`
(`-R`) to override.

### Fall back to `gh api`

When `--json` doesn't expose what you need:

- Review-thread comments on a PR:
  `gh api repos/{owner}/{repo}/pulls/{n}/comments`
  (the `--comments` flag on `gh pr view` shows issue-level comments only).
- Arbitrary GraphQL: `gh api graphql -f query='...' -F var=value`.
- REST shortcuts: `gh api repos/{owner}/{repo}/...` — note the
  `{owner}/{repo}` placeholder is filled in when run from a repo with
  detected remotes; pass them literally if you want determinism.

## Viewing Issues and PRs

### Issue view with structured fields

```bash
# View an issue with comments and metadata
gh issue view 42 --repo owner/repo --json title,body,state,comments,labels,assignees,milestone

# Search and view matching issues
gh search issues "error message" --repo owner/repo --json number,title,url,commentsCount,state | \
  jq '.[].number' | head -5
```

### PR view with structured fields

```bash
# View a PR with diff stats, reviews, and commit info
gh pr view 42 --repo owner/repo --json title,body,state,comments,commits,files,labels,reviews

# List PRs with key fields
gh search prs "fix X" --repo owner/repo --json number,title,state,url,mergedAt
```

### Issue types, sub-issues, and relationships

```bash
# View metadata
gh issue view 42 --repo owner/repo --json issueType,parent,subIssues,subIssuesSummary,blockedBy,blocking

# Note: subIssues, blockedBy, blocking are shaped
#   {"nodes": [...], "totalCount": N}
# nodes is capped (subIssues: 100, blockedBy/blocking: 50).
# Compare node count against totalCount to detect truncation.
```

## Reading Remote Files and Directories

Preview commands (`gh repo read-file` / `read-dir`). They read a repo's
contents over the API without cloning, honoring `--repo OWNER/REPO` and
`--ref <branch|tag|commit>` (defaults to the default branch).

### read-file

```bash
# Print a file's contents
gh repo read-file <path> --repo owner/repo

# Read at a specific commit or branch
gh repo read-file <path> --repo owner/repo --ref v2.0.0

# Write to disk instead of stdout
gh repo read-file <path> --repo owner/repo --output <local-path>
```

- `--output <path>` (`-o`) writes to disk (a trailing slash writes under
  a directory using the remote file name; `--clobber` allows overwrite).
- `--output` and `--json` are mutually exclusive.
- Files with terminal escape sequences are refused in TTY mode; pass
  `--allow-escape-sequences` to read anyway.
- Binary files are piped as-is; in TTY mode they are refused.

### read-dir

```bash
# List the repo root
gh repo read-dir --repo owner/repo

# List a subdirectory
gh repo read-file <subdir> --repo owner/repo

# JSON output for structured parsing
gh repo read-dir --repo owner/repo --json name,path,type,gitType,mode,gitSHA,size
```

- Non-TTY output is tab-separated: type, name, octal mode, byte size.
- A path pointing at a file errors — use `read-file` instead.

## Common Gotchas

| Mistake | Consequence | Fix |
|---|---|---|
| Passing quoted search qualifiers | Parsed as single keyword → `Invalid search query` | Pass each qualifier as its own bare token |
| `author:dependabot` | Matches nothing (bots are GitHub Apps) | Use `app:dependabot` or `author:"dependabot[bot]"` |
| Assuming `-L 30` means "all results" | Last 130+ issues silently hidden | Pass `-L 50` or higher |
| Scraping text output for issue metadata | Unreliable, fragile formatting | Use `--json issueType,parent,subIssues,blockedBy,blocking` |

## References

### Reading `references/upstream-identification.md`

**Read this reference when:**
- The user is debugging a dependency or tool and you need to find the GitHub repo
- The package is a wrapper and the real code lives in a different repo
- The bug may be in a transitive dependency, not the direct dependency
- You need to trace which repo a package's source code is in (pip/npm/maven/etc.)

This reference covers:
- How to find the GitHub source URL for packages in each ecosystem (PyPI, npm, Maven, RubyGems, Cargo)
- How to trace transitive dependency chains
- Search patterns optimized for upstream repos (by version, by symptom, by function name)
- What to do when no match is found

**Mandatory read** when the user says something like "I think there's a bug in X" where X is a pip/npm/maven package or dependency, not a repo the user is currently working in. The reference's ecosystem-specific commands for finding the source URL are critical — assuming `pip install` and `npm install` packages live on GitHub is a common mistake.

---

## Further Reading

- [gh CLI manual](https://cli.github.com/manual/)
- [GitHub search syntax](https://docs.github.com/search-github/github-searching-understanding-search-syntax-and-understanding-using-query-helpers)
- [GitHub GraphQL API](https://docs.github.com/graphql)
- [GitHub REST API](https://docs.github.com/rest)
