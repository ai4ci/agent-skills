# Feature Proposals — Reference

For documenting features, ideas, or design changes in your project that are
too complex for a TODO comment. Based on RFC (Request for Comments) patterns
from open-source projects like Concourse and Zephyr.

---

## When to Use This Guide

Use when proposing something **new** or **substantive** in your own project:

- A feature that changes user-facing behavior or introduces a new concept
- An architectural change with significant implications
- A design decision that needs team input before implementation
- An idea worth documenting even if it's not being worked on now
- A technical approach for a problem too complex for a code comment

An RFC-style proposal is **not necessary** for:
- Bug fixes with a clear, narrow scope
- Small features that are self-evident (e.g., "add a button that says X")
- Cosmetic changes or typo fixes

## Title Format

```
RFC: [Feature/Component] — Brief description
```

Examples:
- `RFC: Add retry queue for rate-limited API calls`
- `RFC: Migrate auth from session cookies to JWT`
- `RFC: Plugin system for custom response transformers`

---

## Structure

Every feature proposal should include these sections:

### 1. Summary (1–2 sentences)

What is the feature or change? Why is it needed?

```markdown
Add a retry queue that buffers rate-limited requests and replays them
at a controlled rate. This prevents data loss and eliminates the need
for callers to handle 429 responses manually.
```

### 2. Motivation (Why)

What problem does this solve? What is the impact of **not** doing this?

```markdown
Currently, callers must implement their own retry logic for 429
responses. This is error-prone (see #123) and creates inconsistent
behavior across different parts of the codebase. A centralized retry
queue would:
- Eliminate per-call retry logic
- Provide a single place to configure rate limits and backoff
- Prevent data loss from swallowed errors
```

### 3. Proposed Solution (What)

Describe the approach. Be specific but not over-engineered. Include:
- Key design decisions
- Interfaces/APIs (if applicable)
- How it integrates with existing code

```markdown
Add a `RetryQueue` class that wraps the HTTP client:

```python
class RetryQueue:
    def __init__(self, max_retries=3, backoff_factor=2):
        ...
    
    def enqueue(self, request):
        """Add request to retry queue."""
        ...
    
    def drain(self):
        """Process queued requests with backoff."""
        ...
```

The queue operates as a background thread. Callers interact with it
through `enqueue()` / `enqueue_all()` — no changes to existing caller
code needed.
```

### 4. Alternatives Considered

What other approaches were considered, and why were they rejected?

```markdown
**Alternative 1: Decorator-based retry on individual functions**
- Rejected: would require changes in 12+ call sites, inconsistent config

**Alternative 2: Retry in the HTTP client library itself**
- Rejected: adds dependency on third-party retry library; our client
  is intentionally lightweight

**Alternative 3: Do nothing — let callers handle it**
- Rejected: leads to duplicated, buggy code (see #123)
```

### 5. Open Questions

What is not yet decided? Be honest — unresolved questions are what make
an RFC useful.

```markdown
- Should retries be configurable per-request or global?
- Do we need a dead-letter queue for permanently failing requests?
- How do we handle queue persistence across process restarts?
```

### 6. Implementation Plan (Optional)

If the proposal is mature, include a rough implementation plan:

```markdown
## Implementation Plan

1. Add `RetryQueue` class (`lib/retry.py`) — 1 day
2. Add basic tests for enqueue/drain logic — 0.5 day
3. Integrate with `HTTPClient` wrapper — 1 day
4. Add integration tests — 0.5 day
5. Update docs — 0.5 day

**Total estimated effort:** 4 days
```

### 7. Related

Links to tracking issues, design docs, or related proposals.

```markdown
- Tracks: #456 (feature request)
- Blocks: #457 (API design for retry configuration)
- Related: #123 (swallowed 429 errors)
```

---

## Status Labels

Use labels to track the lifecycle of a proposal:

| Label | Meaning |
|---|---|
| `proposal` | Open for discussion, no consensus yet |
| `proposal/accepted` | Concept approved, ready for implementation |
| `proposal/merged` | Implementation complete |
| `proposal/postponed` | Deferred — may be revisited |
| `proposal/deferred` | Deferred with no plans to revisit |
| `proposal/abandoned` | Not moving forward |

---

## Writing Guidelines

### Do
- Write the summary first. If you can't summarize it in 2 sentences, it's not clear enough.
- Be specific about what you're proposing — include code snippets, diagrams, or pseudocode.
- List alternatives honestly. A rejected alternative with good reasoning is valuable context.
- Leave open questions — they're what make an RFC actionable for reviewers.
- Link to existing issues and code.

### Don't
- Write a novel. If a section is more than a paragraph, ask whether it belongs in the main body or a linked doc.
- Include implementation details that will change. The proposal is the plan, not the code.
- Assume everyone agrees. If you're biased toward an approach, say so and explain why.
- Use "I think" or "I feel." State observations and reasoning.
- Propose something without stating the motivation. The "why" matters more than the "how."

---

## Before-and-After Examples

### Bad — no structure, no alternatives
```markdown
We should add a retry mechanism for API calls. It would be nice if
the client automatically retried failed requests. I think we could
use a queue or maybe a decorator. Let me know what you think!
```

### Good — structured, specific, includes alternatives
```markdown
## Summary
Add a background `RetryQueue` that buffers rate-limited requests and
replays them with exponential backoff.

## Motivation
Callers must currently handle 429 responses manually (see #123).
This is error-prone and inconsistent.

## Proposed Solution
Background `RetryQueue` class wrapping the HTTP client. Callers call
`enqueue()` — the queue handles retries transparently.

## Alternatives Considered
- Decorator on individual functions (rejected: 12+ call sites)
- Retry in HTTP client library (rejected: adds dependency)

## Open Questions
- Per-request vs global retry config?
- Dead-letter queue for permanent failures?

## Implementation
4 days estimated. See task breakdown in comments.
```

---

## Sources

- [Concourse RFC process](https://github.com/concourse/rfcs)
- [Zephyr: Proposals and RFCs](https://docs.zephyrproject.org/latest/contribute/proposals_and_rfcs.html)
