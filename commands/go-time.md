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

1. **Create worktree** for isolated feature development
2. **Read the plan:** Load `docs/{{feature}}/plan.md`
3. **Invoke go-time skill**
4. **Follow the workflow:**
   - Extract all tasks from the plan
   - Create TodoWrite with all tasks
   - Dispatch implementer subagents
   - Resume agents for questions and additional tasks
   - Batch review when agents exhaust context
   - Skip the manual-verification task (deferred to trust-but-verify)
   - Hand off to trust-but-verify when implementation is complete

## What go-time Does

**Worktree isolation:** Creates a git worktree so all implementation happens on an isolated branch. Design docs committed to main are available automatically.

**Resumable agents:** Reuse agents while they have context. Resume to:
- Answer questions (agent-to-agent communication)
- Assign additional tasks (efficient context reuse)
- Request fixes from reviewers

**Batched reviews:** Review after agent exhaustion, not per-task. One unified reviewer checks spec + code quality.

**Context tracking:** When capacity < 50%, review triggers and fresh agent takes over.

## Next Step

```
/trust-but-verify docs/{{feature}}/plan.md
```
