---
name: patch-party
description: Fix bugs remaining after plan execution. Bootstraps from feature docs, triages bugs, and dispatches fix subagents.
arguments:
  - name: feature_dir
    description: Feature directory name (e.g., user-auth). Docs expected at docs/<feature_dir>/
    required: true
  - name: bugs
    description: Description of bugs to fix (can be multiline, semicolon-separated, or natural language)
    required: true
---

# Patch Party

Fix the bugs described below for the **{{feature_dir}}** feature using the **patch-party** skill.

**Feature docs:** `docs/{{feature_dir}}/`
**Bugs to fix:** {{bugs}}

## Instructions

1. **Invoke the skill:** Use the Skill tool to invoke `patch-party`
2. **Follow the patch-party workflow:**

### Phase 1: Bootstrap
- Read `docs/{{feature_dir}}/design.md` fully
- Read `docs/{{feature_dir}}/bugs.md` fully (if exists)
- Search `docs/{{feature_dir}}/plan.md` for relevant sections

### Phase 2: Triage
- Categorize the bugs (simple / complex / uncertain / design-gap)
- Group related bugs together
- Gather relevant code sites for each bug/group

### Phase 3: Dispatch
- Create context packets for each bug group
- Dispatch subagents with full context using `@bug-fixer-prompt.md`
- One subagent per bug group, sequential not parallel

### Phase 4: Handle Returns
- Fixed → verify and update bugs.md
- Rubber-duck → handle consultation (external LLM or Opus)
- Design gap → discuss escalation to dream-first

### Phase 5: Collect
- Update `docs/{{feature_dir}}/bugs.md` with results
- Verify all fixes (run tests)
- Report summary

## The Escalation Ladder

```
Direct Fix → Rubber-Duck → Consultation → Systematic Debugging → Design Review
```

Subagents follow this ladder automatically. If they hit rubber-duck, they return with a prompt for consultation.

## Requirements

Requires the `patch-party` and `rubber-duck` skills to be installed.
