# Issue Authoring — Reference

Guidelines for writing clear, actionable GitHub issues and PR descriptions.
Based on maintainers' expectations, not AI templates.

---

## The Problem with AI-Authored Issues

AI models tend to produce issues that are:

- **Verbally generous, information-sparse** — lots of framing and context-setting, few actionable details
- **Subjective** — "the app feels slow" instead of "page load takes 12s on first visit"
- **Redundant** — restating the same observation in multiple sections
- **Overly formal** — "We would like to request the following feature…" when "Add X" suffices
- **Missing the actual error** — describing what happened but omitting the exact error message or stack trace

**Rule: maintainers scan 20+ issues per day. Your issue should be readable in 30 seconds.**

---

## Title

### Do
- Be specific about **what** failed and **where**: `Crash when calling tokenize() on empty input`
- Mention the component or function if relevant: `gh pr list --search fails on repos with 1000+ PRs`
- Keep it under 80 characters

### Don't
- Be vague: `Something is broken` / `Not working` / `Bug in parser`
- Sound like a feature request when it's a bug: `I need a better error message` → `Error message omits line number on SyntaxError`

---

## Description

### Do
- One or two sentences. What went wrong, under what condition.
- State the impact briefly: "This blocks CI for all Python 3.12 users."

### Don't
- Write a preamble: "Hello maintainers, I hope this email finds you well. I am writing to report an issue that I encountered while using your excellent project. After spending some time debugging, I believe that..."
- Reintroduce the project: "Your project does X, Y, and Z. I was using it to..."
- Repeat the title in full sentences.

---

## Steps to Reproduce

### Do
- Numbered list. Each step is one action.
- Include enough detail that someone can follow them without context.
- Stop when the bug occurs — no need to describe what they did after.

```markdown
1. Run `python -c "import vllm; vllm.model_executor.parallel_utils.parallel_llm.init_parallel_attention_mask()"`
2. Pass an empty list as the input_ids argument.
3. Observe a crash with the traceback below.
```

### Don't
- Write paragraphs: "First you open the app, then you navigate to the settings page, and then you might want to click on the save button — if it's there."
- Use vague actions: "Do something with the API" / "Try it out"
- Include steps after the bug occurs.

### Minimum viable repro
If possible, include a minimal reproduction:

- A single command that triggers the bug
- A Gist or repo with the minimal code
- A short inline code block (under 20 lines)

---

## Expected vs Actual

### Do
- Keep it to one line each.

```markdown
**Expected:** `tokenize()` returns an empty list for empty input.
**Actual:** `tokenize()` raises `IndexError: list index out of range`.
```

### Don't
- Write paragraphs explaining what should happen. The expected behavior should be obvious from the function's purpose. If it's not, that's a documentation issue.

---

## Environment

Only include what is relevant to the bug:

```markdown
- OS: Ubuntu 22.04
- Python: 3.12.1
- vllm: 0.3.0
- GPU: A100 80GB
```

### Don't
- List every installed package. If it's a dependency conflict, narrow it down first.

---

## Evidence

### Attach when available
- Exact error message (copied, not paraphrased)
- Stack trace (the full one, not just the last line)
- Short log excerpt (relevant lines only, under 10 lines)
- Screenshots for UI bugs
- Screen recordings for timing-dependent bugs

### Format
```markdown
```
RuntimeError: CUDA error: invalid device context
Traceback (most recent call last):
  File "main.py", line 42, in <module>
    model = LLM(model="meta-llama/Llama-2-7b")
  File ".../vllm/__init__.py", line 21, in __init__
    self.engine = VLLMEngine(...)
RuntimeError: CUDA error: invalid device context
```
```

### Don't
- Paste entire log files (use a Gist for >50 lines)
- Screenshot terminal output that can be copied as text
- Attach files without describing what they show

---

## PR Descriptions

The same principles apply to PRs. Maintainers need to know:

1. **What** this PR does (one sentence)
2. **Why** (what issue it fixes or what need it addresses)
3. **How** (briefly, if the approach is non-obvious)

```markdown
## Summary
Fix crash when `tokenize()` receives an empty input by checking for empty lists before indexing.

## Changes
- Add empty-list guard in `tokenize()` at `tokenizer.py:42`
- Add regression test

## Related
Fixes #1234
```

### Don't
- Write: "This PR addresses the issue reported in #1234 by implementing a comprehensive solution that handles various edge cases and improves the overall robustness of the codebase."
- Use filler: "Please review", "Let me know if you have any questions", "Happy to make changes"

---

## Checklist for Every Issue/PR

Before submitting, verify:

- [ ] **Title** — specifies what, not just that something is wrong
- [ ] **Description** — one or two sentences, no preamble
- [ ] **Steps** — numbered, minimal, someone else can follow them
- [ ] **Expected vs Actual** — one line each, clear contrast
- [ ] **Evidence** — exact error message, full trace, minimal repro if possible
- [ ] **Environment** — only relevant details
- [ ] **Single issue** — one bug, one feature, one PR

---

---

---

## Sources

- [OpenSC: How to write a good bug report](https://github.com/OpenSC/OpenSC/wiki/How-to-write-a-good-bug-report)
- [GitHub Community: Best Practices for GitHub Issues](https://github.com/orgs/community/discussions/147722)
- [Bird Eats Bug: Bug Report Templates](https://birdeatsbug.com/blog/how-to-create-bug-report-template)
