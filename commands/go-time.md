---
name: go-time
description: Execute a feature's implementation plan with resumable subagent coordination
arguments:
  - name: feature
    description: Feature name (e.g., user-auth). Reads from docs/<feature>/plan.md
    required: true
---

# Go Time

Execute the implementation plan for **{{feature}}**.

**Plan file:** `docs/{{feature}}/plan.md`

## Instructions

1. **Read the plan:** Load `docs/{{feature}}/plan.md`
2. **Invoke go-time skill**
3. **Follow the workflow:**
   - Extract all tasks from the plan
   - Create TodoWrite with all tasks
   - Dispatch implementer subagents
   - Resume agents for questions and additional tasks
   - Batch review when agents exhaust context
   - Complete with finishing-a-development-branch

## What go-time Does

**Resumable agents:** Reuse agents while they have context. Resume to:
- Answer questions (agent-to-agent communication)
- Assign additional tasks (efficient context reuse)
- Request fixes from reviewers

**Batched reviews:** Review after agent exhaustion, not per-task. One unified reviewer checks spec + code quality.

**Context tracking:** When capacity < 50%, review triggers and fresh agent takes over.

## Next Step (if bugs remain)

```
/patch-party {{feature}} "<bug descriptions>"
```
