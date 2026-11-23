# Technical Bug Reports — Reference

For raising technical issues in your own project: deferred fixes, complex bugs,
architectural issues, and engineering problems that don't fit in a TODO comment.

---

## When to Use This Guide

Use when filing a technical issue about a defect or problem **in your own
project**. This is different from the general `issue-authoring.md` — these
issues are more technical, more detailed, and often deferred.

Typical triggers:

- You found a bug that is complex to fix and will be deferred
- A root cause is identified but the fix is risky or would require refactoring
- There's a performance issue with no obvious solution
- You discovered an architectural problem or technical debt
- The bug is intermittent or environment-specific
- A fix exists but is low priority (blocked by a release, affects a deprecated feature)

## Title Format

```
[Feature/Module] — What breaks and where
```

Examples:
- `[tokenizer] — IndexError on empty input in `parse_response()``
- `[cache] — Memory leak in LRU eviction under high write throughput`
- `[auth] — Token refresh fails silently when OAuth provider returns 503`

### Don't
- Vague: `Performance problem` / `Bug in auth` / `Something is slow`
- Overly broad: `System is unstable`

---

## Description — One Paragraph, Not an Essay

Start with a single paragraph that answers:
- What is the problem?
- Where does it manifest?
- What is the impact?

```markdown
When `parse_response()` receives an HTTP 429 (rate limit), it silently
returns `None` instead of raising an error. This causes the calling function
to proceed with stale data, leading to inconsistent UI state. Affects all
users during traffic spikes.
```

### Don't
- Start with backstory or context about your project
- Repeat the title
- Write "I think the issue might be..." — state observations, not hypotheses

---

## Steps to Reproduce

Even for internal issues, numbered steps are essential. But for complex bugs,
include more context.

```markdown
1. Configure the client to hit `/api/data` with rate limit of 50 req/s.
2. Send 100 requests in rapid succession.
3. Observe the 429 responses are swallowed by `parse_response()`.
4. Observe the UI shows stale data from the previous successful request.
```

If the bug is intermittent, state the reproduction rate:
> Reproduced 8 out of 15 attempts. More likely under network congestion.

### If you cannot reproduce reliably

Log it anyway. Be transparent:
```markdown
Observed once on staging during deployment of v3.2.1. The application
crashed on startup with the following error. Could not reproduce locally.
```

---

## Root Cause Analysis (When Known)

If the root cause has been identified, include a "Root Cause" section.
Be specific — cite the file, line, and the mechanism.

```markdown
## Root Cause

`parse_response()` at `client/response.py:42` catches all exceptions
silently:

```python
def parse_response(resp):
    try:
        return json.loads(resp.text)
    except Exception:
        return None  # <-- swallows HTTP 429
```

This was introduced in commit `a1b2c3d` to handle malformed JSON but
now also swallows HTTP-level errors.
```

### Don't
- Write "Investigate root cause" as the description itself — that's a task, not a report.
- Skip to "Fix needed" without documenting what was observed.

---

## Deferred Fix Section

When a bug is known but the fix will be deferred, include a "Deferred Fix"
section. This is critical for maintaining context over months.

```markdown
## Deferred Fix

**Status:** Deferred until post-v4.0 refactor
**Reason:** Fix requires restructuring the error handling in `parse_response()`
which is shared across 12 callers. A naive fix would break those callers.
The team agreed to address this as part of the v4.0 error handling redesign.
**Estimated effort:** 2–3 days (includes updating all callers)
**Workaround:** None at this time
```

### Fields to include when deferring:

| Field | When to use |
|---|---|
| **Status** | Why it's deferred (e.g., "Deferred until post-X refactor") |
| **Reason** | The technical blocker or tradeoff |
| **Estimated effort** | How much work the fix would be |
| **Workaround** | Any known mitigation |
| **Related** | Links to tracking issues or the larger refactor |

### Don't
- Just label it "low priority" and walk away — the reason for deferral matters
- Write "TODO: fix this later" with no context. You will forget why it was deferred.

---

## Complexity and Scope

For bugs that are complex enough to not fit in a TODO comment, describe the
scope of the problem. This helps someone coming back to it later.

```markdown
## Scope

- Affects: all API integrations that may receive rate-limited responses
- Not affected: direct API calls (no rate limiting), internal services
- First observed: v3.1.0 release
- Regression: yes — worked correctly through v3.0.x
```

---

## Technical Evidence

Internal bugs need the same evidence discipline as external ones, but
can include internal artifacts:

- Internal logs with timestamps
- Metrics graphs (e.g., "error rate spikes to 15% during traffic peaks")
- Performance profiles (flame graphs, memory dumps)
- Database state before/after
- API request/response pairs

### Format

```markdown
## Logs

```
2024-03-15T14:23:01Z client/response.py:42 WARNING — Failed to parse response, returning None
2024-03-15T14:23:01Z client/response.py:42 DEBUG — Response status: 429, body: {"error": "rate limited"}
```

## Metrics

Error rate for `/api/data` spikes to 15% during the 14:20–14:25 window.
See [Grafana dashboard](link).
```

---

## Checklist

Before filing a technical issue, verify:

- [ ] **Title** — specifies feature/module, what, and where
- [ ] **Description** — one paragraph: what, where, impact
- [ ] **Steps** — numbered, sufficient for reproduction
- [ ] **Root cause** — included if known, with file/line references
- [ ] **Deferred section** — status, reason, effort estimate (if applicable)
- [ ] **Scope** — what's affected, what's not, when it was introduced
- [ ] **Evidence** — logs, metrics, profiles (not just "it's broken")

---

---

---

## Sources

- [TestGrid: Advanced Guide to Bug Reports](https://testgrid.io/blog/guide-to-write-an-effective-bug-report/) — severity vs priority, environment specificity, evidence
