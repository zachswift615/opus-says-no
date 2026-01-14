---
name: execute-plan
description: Execute an implementation plan using go-time for resumable subagent coordination
arguments:
  - name: plan_path
    description: Path to the implementation plan file (e.g., docs/user-auth/plan.md)
    required: true
---

# Execute Implementation Plan

Execute the implementation plan using the **go-time** skill for resumable subagent coordination.

**Plan file:** @{{plan_path}}

## Instructions

1. **Read the plan:** Load the complete implementation plan from the specified file
2. **Invoke go-time:** Use the Skill tool to invoke `go-time`
3. **Follow the go-time workflow:**
   - Extract all tasks from the plan with full text
   - Create TodoWrite with all tasks
   - Dispatch implementer subagents
   - Resume agents for questions and additional tasks
   - Batch review when agents exhaust context
   - Complete with finishing-a-development-branch

## What go-time Does

**Resumable agents:** Instead of spawning fresh agents for each task, go-time reuses agents while they have context capacity. Agents can be resumed to:
- Answer their questions (true agent-to-agent communication)
- Assign additional tasks (efficient context reuse)
- Request fixes from reviewers

**Batched reviews:** Reviews happen after an agent completes all tasks it can handle (not after every single task). One unified reviewer checks both spec compliance and code quality.

**Context tracking:** Implementers report their remaining context capacity. When capacity drops below 50%, review is triggered and a fresh agent takes over.

## Key Differences from Traditional Approach

| Traditional | go-time |
|-------------|---------|
| Fresh agent per task | Reuse while context allows |
| Review after every task | Batch review after agent exhaustion |
| Separate spec + code reviews | Unified review (one pass) |
| Questions = new agent | Questions = resume same agent |

## Requirements

This skill requires the `go-time` skill to be installed via the custom skills installer.
