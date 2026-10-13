# Duplicate Issue Management — Reference

Guidance for detecting, merging, and managing duplicate GitHub issues during
triage.

---

## Detecting Duplicates

### Manual detection patterns

When triaging a new issue, search for duplicates **before** reading the full
description. A duplicate is an issue where:

- The **same root cause** is reported, even if described differently
- The **same symptom** occurs under the same conditions
- The same feature request was already filed (even if worded differently)

### Search heuristics

```bash
# Search by error message (most reliable signal)
gh search issues "exact error message text" --repo owner/repo --state all

# Search by the feature/behavior being discussed
gh search issues "button X not working" --repo owner/repo --state all

# Search by the component + symptom
gh search issues "tokenizer" "crash" --repo owner/repo --state all
```

**Key principle:** search for the **root cause**, not the reporter's
description. A reporter may say "my app crashes" when the actual issue is
"a NullPointerException in X when Y".

### Using GitHub's built-in duplicate detection

GitHub now provides AI-assisted duplicate detection in issue creation (public
preview, June 2026). When creating an issue, GitHub suggests up to 3
potential matches as the description is populated. This feature is available
for repositories using GitHub's web interface but not yet exposed via the gh
CLI.

### Tools for automated detection

- **ghidd** (GitHub Issue Duplicate Detector) — a GitHub Action that
  automatically spots and tags duplicate issues
- **Dosu** — automates issue triage including deduplication
- These are repository-level tools, not something an agent should install

---

## Marking a Duplicate

### The correct procedure

When you determine an issue is a duplicate:

1. **Pick the primary issue** — the oldest, best-documented, or most complete
   version. If equally matched, pick the one with more reactions.
2. **Add a comment referencing the primary issue** — the format GitHub uses
   is: `Duplicate of #N` (where N is the primary issue number). This creates
   a timeline event.
3. **Close the duplicate** — close the secondary issue with the duplicate
   comment already attached.

```bash
# Example: issue #456 is a duplicate of #123
gh issue comment 456 --body "Duplicate of #123"
gh issue close 456
```

### What NOT to do

- **Don't close with a bare "Closed as duplicate"** — this is a poor user
  experience. The reporter gets no context.
- **Don't merge two issues into one without documenting** — GitHub doesn't
  have a native "merge issues" feature. The workaround is to pick a primary
  issue and close the other as duplicate.
- **Don't merge content manually** — don't copy comments or logs from the
  duplicate into the primary issue unless they add genuinely new information.

---

## Handling the Reporter

Treat every duplicate close as a customer interaction. When closing a
duplicate:

1. **Thank the reporter** — they took time to report something.
2. **Point them to the primary issue** — tell them where to subscribe for
   updates.
3. **Encourage them to react** — upvoting the primary issue helps priority.

```bash
# Good duplicate close comment:
gh issue comment <duplicate-number> \
  --body "Thanks for reporting this! We're tracking this on #123 —
  feel free to subscribe there for updates and react to the issue to
  help us prioritize."
gh issue close <duplicate-number>
```

### Why this matters

Closing duplicates cold (just "duplicate of #123") trains users to stop
reporting bugs. Adding a brief note preserves community goodwill and keeps
the reporter engaged.

---

## When Issues Are Similar but Not Duplicates

Sometimes issues overlap but aren't the same bug:

| Situation | Action |
|---|---|
| Same symptom, different root cause | Keep both. Add a note linking them. |
| Same feature request, different scope | Keep both. Note the scope difference. |
| One is a subset of the other | Keep the more detailed one. Close the other as duplicate. |
| One already has a fix, one doesn't | Keep both until the fix is released. |
| Reporter's issue adds new evidence | Keep both. Add new evidence to the primary issue. |

---

## Managing Duplicate Backlogs

For repositories with many duplicates:

- **Use labels consistently** — consider `state: duplicate` to distinguish
  state labels from type labels (e.g., `type: bug`).
- **Search filtered by duplicate** — `gh issue list --label "state:duplicate" --state all` to review old duplicates that may need cleanup.
- **Clean up after releases** — when a fix ships, check that all linked
  duplicates are closed and the reporter was notified.

---

## Sources

- [GitHub Docs: Marking issues as duplicate](https://docs.github.com/en/issues/tracking-your-work-with-issues/administering-issues/marking-issues-or-pull-requests-as-a-duplicate) — "Duplicate of #N" comment format
- [GitHub Blog: Duplicate Detection (June 2026)](https://github.blog/changelog/2026-06-18-duplicate-detection-and-issue-fields-mcp-support-for-github-issues/) — AI-assisted duplicate suggestions during issue creation
- [Adam Cogan: Handle Duplicates Without Annoying Users](https://adamcogan.com/2025/12/05/handle-duplicate-github-issues/) — treat duplicates as customer interactions, not noise
- [Rewind: Best Practices for GitHub Issues](https://rewind.com/blog/best-practices-for-using-github-issues/) — search before submitting, use labels, don't forget to close
