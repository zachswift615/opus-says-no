---
name: patch-party
description: Fix bugs remaining after plan execution. Bootstraps from feature docs, triages bugs, and dispatches fix subagents.
arguments:
  - name: feature
    description: Feature name (e.g., user-auth). Reads from docs/<feature>/
    required: true
  - name: bugs
    description: Description of bugs to fix (can be multiline, semicolon-separated, or natural language)
    required: true
---

# Patch Party

Fix bugs for **{{feature}}**.

**Feature docs:** `docs/{{feature}}/`
**Bugs to fix:** {{bugs}}

## Instructions

1. **Invoke the skill:** Use the Skill tool to invoke `patch-party`
2. **Follow the workflow:**

### Phase 1: Bootstrap
- Read `docs/{{feature}}/design.md` fully
- Read `docs/{{feature}}/bugs.md` fully (if exists)
- Search `docs/{{feature}}/plan.md` for relevant sections

### Phase 2: Triage
- Categorize bugs (simple / complex / uncertain / design-gap)
- Group related bugs together
- Gather relevant code sites

### Phase 3: Dispatch
- Subagent per bug group with full context
- Sequential, not parallel

### Phase 4: Handle Returns
- Fixed → verify and update bugs.md
- Rubber-duck → handle consultation
- Design gap → escalate to dream-first

### Phase 5: Collect
- Update `docs/{{feature}}/bugs.md`
- Verify all fixes (run tests)
- Report summary

## The Escalation Ladder

```
Direct Fix → Rubber-Duck → Consultation → Systematic Debugging → Dream-First
```

Subagents follow this automatically.
