---
name: contribute-github-project-fix
description: >
  Fork a GitHub repository, clone it, fix a bug or implement a feature, and
  propose a pull request back to upstream. Use when debugging an issue in a
  dependency or tool and you've determined a fix is needed. Covers the full
  fork → clone → branch → fix → push → PR lifecycle, including upstream sync,
  draft PRs, linking issues, and reading code via gh api. Do not use for
  managing your own project's issues or for read-only fact-finding.
allowed-tools: Read, Edit, Write, Bash, Glob
compatibility: >
  Requires gh CLI v2.0+ and a GitHub account with write access (forks are
  always to your own account). Git must be installed and configured.
metadata:
  source_url: https://cli.github.com/manual/gh_repo_fork
---

# Contribute to GitHub Project Fix — Agent Skill

Full documentation: https://cli.github.com/manual/

---

## When to Use

Use this skill when you've diagnosed a bug or missing feature in a
third-party repository and need to **propose changes back to upstream**.
Typical triggers:

- You've searched issues (`search-github-project-issues`), confirmed no
  existing fix, and now need to implement one
- You've found a bug in a dependency and want to create a PR for it
- You need to fork a repo, make changes, and propose them upstream

**Rule: always search existing issues/PRs before starting code work.** If a
PR already exists for the fix, reference or comment on it instead of
creating a duplicate.

## References

When creating issues or PRs for upstream projects, consult the
`references/issue-authoring.md` guide. It covers the common failure modes
of AI-authored issues (verbosity, missing error messages, vague titles)
and provides concrete do/don't patterns. **Read it before creating any
issue or PR body.**

## Quick Start — Fork to PR Workflow

```bash
REPO="owner/repo"

# 1. Fork, clone, and set up upstream remote (one command)
gh repo fork "$REPO" --clone --remote

# 2. Create a branch for your fix
# `gh repo fork --clone` creates the repo directory in the current working directory
cd "$(basename "$REPO")"
git checkout -b fix/<short-description>

# 3. Make your changes, commit
git add .
git commit -m "fix: describe the change"

# 4. Push your fork branch
git push -u origin fix/<short-description>

# 5. Create a PR targeting the upstream repo
gh pr create \
  --base main \
  --title "fix: <descriptive title>" \
  --body "Fixes #<issue-number>

  <description of the change and why it's needed>"

# 6. (Optional) Mark as draft if not ready for review
gh pr create --draft --base main --title "WIP: <title>" --body "..."
```

## Fork Workflow

### Creating and cloning a fork

```bash
# Fork + clone + configure upstream in one step
gh repo fork owner/repo --clone --remote

# Fork to an organization
gh repo fork owner/repo --org "my-org"

# Fork only (no clone)
gh repo fork owner/repo

# Fork + clone only (no upstream remote)
gh repo fork owner/repo --clone
```

### Syncing your fork with upstream

After forking, set up an upstream remote to keep your fork in sync:

```bash
# (Usually done automatically with --remote above)
git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPO.git

# Sync your fork periodically
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Or if your fork has branches beyond main
git fetch upstream
git checkout fix/something
git merge upstream/main
git push origin fix/something
```

### Git remote structure after fork

```bash
$ git remote -v
origin  https://github.com/YOU/repo.git (fetch)
origin  https://github.com/YOU/repo.git (push)
upstream https://github.com/ORIGINAL_OWNER/repo.git (fetch)
upstream https://github.com/ORIGINAL_OWNER/repo.git (push)
```

- `origin` = your fork (your remote, where you push)
- `upstream` = original repo (where PRs are targeted)

## Creating Useful Pull Requests

### Write issues and PRs using the issue-authoring reference

**Read `references/issue-authoring.md` before creating any issue or PR.**
It covers the most common AI pitfalls: verbose preambles, missing the
actual error, subjective language, and redundancy. Maintainants scan
20+ issues per day — every issue must be readable in 30 seconds.

### PR structure (after reading the reference)

A good PR makes it easy for maintainers to review and merge:

```bash
gh pr create \
  --base main \
  --head fix/branch-name \
  --title "fix: resolve crash when X happens" \
  --body "Fixes #123

## Summary
<1-2 sentences describing the fix>

## Changes
- <bullet 1>
- <bullet 2>

## Testing
- <what you tested and how>

## Related
- Closes #123
- Related to PR #456 (optional)
"
```

### PR flags

| Flag | Purpose |
|---|---|
| `--base <branch>` | Target branch in upstream repo (default: `main`) |
| `--head <branch>` | Your fork's branch to merge from |
| `--title <title>` | PR title |
| `--body <text>` | PR body |
| `--body-file <file>` | PR body from file (avoids `-T` collision) |
| `--draft` | Create as draft (no review yet) |
| `--label "bug,fix"` | Add labels to the PR |
| `--assignee user` | Assign reviewers |
| `--reviewer user` | Request review from users |

### Draft PRs

Useful for:
- Getting early feedback on approach before finishing implementation
- Linking to an issue early ("work in progress")
- Triggering CI without asking for review

```bash
gh pr create --draft --base main --title "WIP: fix crash on X" --body "..."
# Later, ready for review:
gh pr ready <number>
```

### Linking issues

GitHub auto-closes issues when PRs reference them:

```bash
# In the PR body:
Fixes #123       → auto-closes #123 when merged
Closes #123      → same as Fixes
Relates to #123  → reference only, no auto-close
```

## Reading Code Without Cloning

When you need to understand the upstream code before making changes,
use `gh repo read-file` and `read-dir` (see `search-github-project-issues`
skill). This is often faster than cloning the entire repo.

```bash
# Find the relevant file
gh repo read-dir --repo owner/repo --json name,path

# Read a specific file
gh repo read-file src/error_handler.py --repo owner/repo

# Read at a specific tag/branch
gh repo read-file src/error_handler.py --repo owner/repo --ref v2.0.0
```

## References

When creating or editing issues and PRs, read the appropriate reference:

### Reading `references/issue-authoring.md`

**Read this reference when:**
- You are **creating an issue** in a third-party repository
- You are **writing a PR description** for a fix you're proposing
- You need guidance on title format, description length, steps-to-reproduce, or evidence

This reference covers writing for upstream maintainers: concise titles, one-paragraph descriptions, numbered repro steps, expected vs actual, environment details, and PR structure (what/why/how).

**Mandatory read** when the user asks you to create an issue or write a PR description. The reference's anti-verbosity rules (no preambles, no filler, no "I think") are critical for issues going to upstream maintainers.

### Reading `manage-current-project-issues` references

These are **not needed** for this skill. They cover internal project management, not external contributions.

---

## Common Gotchas

| Mistake | Consequence | Fix |
|---|---|---|
| Pushing to `origin/main` directly | Push rejected — your fork's main is out of sync | Fetch upstream, merge/rebase, then push |
| Wrong `--base` branch | PR targets the wrong branch | Always verify with `gh repo view --repo upstream` |
| `-T` flag on `gh pr create` | Collides with body-template flag | Use `--body-file` explicitly |
| Creating duplicate PRs | Wastes maintainer time | Always search existing PRs first |
| Fork without upstream remote | Can't sync with upstream updates | Use `--remote` flag or add manually |
| Forgetting to mention the issue | Maintainer doesn't know context | Always link with `Fixes #<number>` in the body |

## Further Reading

- [gh repo fork manual](https://cli.github.com/manual/gh_repo_fork)
- [GitHub: Fork a repo](https://docs.github.com/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo)
- [GitHub: Syncing a fork](https://docs.github.com/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)
- [GitHub: About pull requests](https://docs.github.com/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests)
