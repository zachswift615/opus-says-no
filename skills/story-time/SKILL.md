---
name: story-time
description: Break a design into a validated task outline with acceptance criteria, dependencies, and gap analysis. The PM work before detailed planning.
model: claude-opus-4-5-20251101
---

# Story Time

Break it down before you plan it out.

## Overview

Take a design document and decompose it into a validated, gap-free task outline. This is the PM decomposition step — breaking an epic into well-defined stories with goals, acceptance criteria, dependencies, and connections.

**Key innovation:** Gap analysis by a fresh Opus agent catches structural problems before any detailed planning begins. Fix agents get full context budget for focused repairs.

**Announce at start:** "I'm using story-time to decompose the design into a validated task outline."

**Save plans to:** `docs/<feature-name>/plan.md`

**Feature directory:** Should already exist from dream-first with `design.md`. If not, create it.

---

## Context Budget Protocol

**The #1 risk for any orchestrator skill is running out of context.** Foreground agents dump their entire output (~50-70k tokens each) into the orchestrator's context. Three foreground agents can consume ~160k of a 200k context window, killing the session. Follow these rules strictly:

### Rule 1: Background ALL Agents
Every agent spawned by the orchestrator MUST use `run_in_background: true`. **No exceptions.** This is the single most important rule in the entire skill.

### Rule 2: Agents Write to File, Return a Summary
Every agent prompt MUST end with this instruction:
> **CRITICAL:** Write all detailed output directly to the plan file. Your final message must be ONLY a 2-3 sentence summary of what you accomplished and any blockers. Do NOT return detailed content in your response — it belongs in the file only.

### Rule 3: Don't Read Source Code in the Orchestrator
The orchestrator reads ONLY:
- The design document (once, to create the plan header)
- The Planning Progress section of the plan file (to track status — use `offset`/`limit` to read just that section)

All source code reading happens inside agents in their own context windows. Pass file paths to agents, never file contents.

### Rule 4: Check Completion Leanly
After a background agent completes:
1. Read ONLY the **last 30 lines** of the agent's output file (use `Read` with `offset`) to get the summary
2. Optionally read just the "Planning Progress" table from the plan file to verify the checkbox updated
3. **NEVER** read the full output file or the full plan file back into the orchestrator

### Context Budget Target
| Item | Tokens | Notes |
|------|--------|-------|
| Design doc read | ~5-15k | One-time, acceptable |
| Per-agent completion check | ~1-2k | Summary + progress table only |
| Orchestrator tracking/decisions | ~5-10k | Status updates, gap decisions |
| **Target total** | **<40k** | For a full story-time session |

---

## The Orchestration Flow

```
Read Design Document
        ↓
Task Outline Agent (background, opus)
        ↓
Gap Analysis Agent (background, opus)
        ↓
   Gaps found? → Spawn FRESH Fix Agent (background, opus)
        ↓         → Re-run Gap Analysis
   No gaps
        ↓
Validated Outline Ready
```

---

## Phase 1: Read Design Document

**Input:** Path to design document (from `/story-time` command or `/blueprint` routing)

**Actions:**
1. Read the design document to extract key information:
   - Problem & Goals
   - Chosen Approach
   - Key Decisions
   - Scope (must-have, nice-to-have, out-of-scope)
   - User Stories (if present)
   - Constraints

2. Create plan file: `docs/<feature-name>/plan.md`

**IMPORTANT:** Read ONLY the design document here. Do NOT read any source code files (models, views, utils, etc.) — agents will read those in their own context. Pass file paths to agents, never contents.

**Plan file header:**
```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Execute this plan task-by-task with verification at each step.

Date: YYYY-MM-DD
Status: In Progress - Task Outline

**Design Document:** docs/<feature-name>/design.md

**Goal:** [One sentence from design]

**Architecture:** [2-3 sentences from design's chosen approach]

**Key Decisions:**
- [Decision 1]
- [Decision 2]

**Tech Stack:** [Technologies from design]

**Scope Summary:**
- Must have: [N items]
- Nice to have: [M items]
- Out of scope: [K items]

---

## Planning Progress

- [x] Design document read
- [ ] Task outline created
- [ ] Gap analysis complete

---
```

---

## Phase 2: Task Outline Creation

**Spawn a subagent** to create the task outline.

### Subagent Invocation

```
I'm spawning a task outline agent to create the high-level task structure.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Create task outline"
- `run_in_background`: true
- `prompt`:

```
Create a task outline for the following implementation plan.

**Design Document:** Read docs/<feature-name>/design.md for full context.

**Task Outline Format:**

For each task, specify:
- **Goal:** What this accomplishes (one sentence)
- **Inputs:** What this task needs to start
- **Outputs:** What this task produces
- **Acceptance Criteria:** Measurable success criteria
- **Depends On:** Which task numbers (or "None")
- **Consumed By:** Which tasks use this output (or "End User")

**Rules:**
- NO code yet - just goals and connections
- NO file paths yet - just what needs to be done
- Focus on the dependency graph
- Every output must be consumed by something
- Every input must come from somewhere

**Write the task outline to:** docs/<feature-name>/plan.md
Add the outline under a "## Task Outline" section.
Also update the "## Planning Progress" checklist to mark "Task outline created" as complete.

**CRITICAL:** Write all detailed output directly to the plan file. Your final message must be ONLY a 2-3 sentence summary: how many tasks you created, the key structure, and any concerns. Do NOT return the full outline in your response — it belongs in the file only.
```

### Check Completion

After the background agent completes:
1. Read the **last 30 lines** of the agent's output file to get the summary
2. Verify the outline was written by reading just the Planning Progress section of `docs/<feature-name>/plan.md`
3. Do **NOT** read the full plan file or full agent output

---

## Phase 3: Gap Analysis

**Spawn gap analysis agent** to review the task outline.

### Subagent Invocation

```
I'm spawning a gap analysis agent to find structural gaps in the task outline.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Gap analysis review"
- `run_in_background`: true
- `prompt`: Load from `@gap-analysis-review.md` and include:
  - Path to plan file: `docs/<feature-name>/plan.md`

### Check Completion & Decision Point

After the background agent completes:
1. Read the **last 30 lines** of the agent's output file to get the gap summary
2. The summary tells you: critical count, important count, and whether the outline needs revision

**If Critical or Important gaps found (from the summary):**

Spawn a **FRESH fix agent** (do NOT resume the outline agent):

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Fix outline gaps"
- `run_in_background`: true
- `prompt`:

```
You are a fix agent for a task outline that has structural gaps.

**Plan file:** docs/<feature-name>/plan.md
**Design document:** docs/<feature-name>/design.md

**Your job:**
1. Read the plan file
2. Find the "## Gap Analysis Results" section — it lists the gaps found
3. Fix ALL critical and important gaps by updating the "## Task Outline" section
4. Update the Gap Analysis Results section to show what you fixed

**Rules for task outline entries:**
- Each task must have: Goal, Inputs, Outputs, Acceptance Criteria, Depends On, Consumed By
- Every output must be consumed by something
- Every input must come from somewhere
- Focus on structure and connections, not implementation details
- NO code, NO file paths — just goals and connections

**CRITICAL:** Write all changes directly to the plan file. Your final message must be ONLY a 2-3 sentence summary of what you fixed. Do NOT return detailed content in your response — it belongs in the file only.
```

After the fix agent completes:
- Re-run gap analysis (fresh agent, backgrounded) to verify fixes
- Repeat fix → gap analysis cycle until no Critical/Important gaps remain
- Maximum 3 fix iterations. If still failing after 3, note remaining gaps in the plan file and proceed.

**If only Minor gaps or no gaps:**
- Proceed to Phase 4

### Verify Gap Analysis Complete

Read only the Planning Progress section of the plan file to confirm the gap analysis checkbox is marked complete.

---

## Phase 4: Finalize and Handoff

### Update Plan Status

Update the plan file status line from "In Progress - Task Outline" to "Outline Complete - Ready for Detailed Planning".

### Handoff Message

**"Task outline complete and validated. Ready for detailed planning."**

**Feature directory:** `docs/<feature-name>/`
**Plan (outline):** `docs/<feature-name>/plan.md`

**Quality metrics:**
- Tasks: [N] tasks in outline
- Gap analysis: [N] iterations, [M] gaps resolved
- Status: Gap-free, ready for detailed planning

**To create the detailed implementation plan, use:**

```
/blueprint-maestro docs/<feature-name>/plan.md
```

Or use `/blueprint <feature-name>` which will detect the outline and route automatically.

---

## When to Use This Skill

**Use story-time when:**
- You have a design document and need structured decomposition
- Feature has multiple tasks with dependencies
- You want validated acceptance criteria before detailed planning
- You're breaking an epic into stories

**Skip story-time when:**
- Feature is simple (< 5 tasks, obvious structure)
- You're using the `blueprint` skill for simple plans (it does its own outline)

---

## Success Criteria

A successful story-time produces:
- [ ] Task outline with clear goals, inputs, outputs for every task
- [ ] Acceptance criteria are measurable for every task
- [ ] Dependency graph is complete (no orphans, no missing inputs)
- [ ] Gap analysis passed with no critical/important issues
- [ ] Plan file saved to `docs/<feature-name>/plan.md`
- [ ] Ready for `/blueprint-maestro` to add detailed implementation
