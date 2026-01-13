---
name: execute-plan
description: Execute an implementation plan using go-agents for resumable subagent coordination
arguments:
  - name: plan_path
    description: Path to the implementation plan file (e.g., docs/plans/2026-01-12-feature-name.md)
    required: true
---

# Execute Implementation Plan

Execute the implementation plan using the **go-agents** skill for resumable subagent coordination.

**Plan file:** @{{plan_path}}

## Instructions

1. **Read the plan:** Load the complete implementation plan from the specified file
2. **Invoke go-agents:** Use the Skill tool to invoke `go-agents`
3. **Follow the go-agents workflow:**
   - Extract all tasks from the plan with full text
   - Create TodoWrite with all tasks
   - Dispatch implementer subagents
   - Resume agents for questions and additional tasks
   - Batch review when agents exhaust context
   - Complete with finishing-a-development-branch

## What go-agents Does

**Resumable agents:** Instead of spawning fresh agents for each task, go-agents reuses agents while they have context capacity. Agents can be resumed to:
- Answer their questions (true agent-to-agent communication)
- Assign additional tasks (efficient context reuse)
- Request fixes from reviewers

**Batched reviews:** Reviews happen after an agent completes all tasks it can handle (not after every single task). One unified reviewer checks both spec compliance and code quality.

**Context tracking:** Implementers report their remaining context capacity. When capacity drops below 50%, review is triggered and a fresh agent takes over.

## Key Differences from Traditional Approach

| Traditional | go-agents |
|-------------|-----------|
| Fresh agent per task | Reuse while context allows |
| Review after every task | Batch review after agent exhaustion |
| Separate spec + code reviews | Unified review (one pass) |
| Questions = new agent | Questions = resume same agent |

## Requirements

This skill requires the `go-agents` skill to be installed via the custom skills installer.
