---
name: blueprint-maestro
description: Orchestrate multi-agent implementation planning with batched writing and incremental reviews for plans of any size
model: claude-opus-4-5-20251101
---

# Blueprint Maestro

The conductor for complex plans.

## Overview

Coordinate multiple agents to create comprehensive implementation plans without hitting context limits. This skill orchestrates task outline creation, gap analysis, batched detailed planning, incremental reviews, and final validation.

**Key innovation:** Plans are written in batches by fresh agents, with each batch reviewed before the next begins. This allows plans of any size while maintaining quality and completeness.

**Announce at start:** "I'm using blueprint-maestro to create a scalable, gap-free implementation plan."

**Save plans to:** `docs/<feature-name>/plan.md`

**Feature directory:** Should already exist from dream-first with `design.md`. If not, create it.

---

## Context Budget Protocol

**The #1 risk for blueprint-maestro is running out of context.** Foreground agents dump their entire output (~50-70k tokens each) into the orchestrator's context. Three foreground agents can consume ~160k of a 200k context window, killing the session. Follow these rules strictly:

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
| Orchestrator tracking/decisions | ~5-10k | Status updates, batch decisions |
| **Target total** | **<50k** | For a full planning session |

---

## The Orchestration Flow

```
Read Design Document
        ↓
Task Outline Agent (subagent)
        ↓
Gap Analysis Agent (subagent)
        ↓
   Gaps found? → Resume Outline Agent
        ↓ No gaps
Batch Planning Loop:
  ├─ Batch Writer Agent (fresh agent per batch)
  ├─ Batch Reviewer Agent (fresh agent per batch)
  └─ Resume Writer if fixes needed
        ↓
   More tasks? → Next batch
        ↓ All tasks detailed
Final Plan Reviewer (subagent)
        ↓
Incorporate Feedback Agent (subagent if needed)
        ↓
Complete Plan Ready for Execution
```

---

## Phase 1: Read Design Document

**Input:** Path to design document (from `/plan-from-design` command)

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
- [ ] Detailed planning in progress
- [ ] Final review complete

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
1. Resume the task outline agent with a brief prompt referencing the gap analysis in the plan file:
   ```
   The gap analysis found [N] critical and [M] important gaps. Read the "## Gap Analysis Results" section of docs/<feature-name>/plan.md for the full details. Fix the gaps and update the Task Outline section. Then update Gap Analysis Results to show what you fixed.

   CRITICAL: Write all changes directly to the plan file. Return ONLY a 2-3 sentence summary of what you fixed.
   ```
2. Use `run_in_background: true` for the resumed agent
3. Re-run gap analysis (also backgrounded) until no Critical/Important gaps

**If only Minor gaps or no gaps:**
- Proceed to Phase 4

### Verify Gap Analysis Complete

Read only the Planning Progress section of the plan file to confirm the gap analysis checkbox is marked complete.

---

## Plan Quality Standard

Write comprehensive implementation plans assuming the engineer has zero context for the codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about the toolset or problem domain. Assume they don't know good test design very well.

### Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

### Required Task Structure

Every detailed task in the plan MUST follow this structure:

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
```

### Remember
- Exact file paths always
- Complete code in plan (not "add validation")
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

---

## Phase 4: Batched Detailed Planning

Now write detailed implementation in batches to avoid context limits.

### Batch Size Strategy

**Determine batch size based on task complexity:**
- Count total tasks from outline
- Estimate complexity (simple/medium/complex)
- Calculate batches:
  - Simple tasks: 4-5 per batch
  - Medium tasks: 3-4 per batch
  - Complex tasks: 1-2 per batch
  - Mixed: 2-3 per batch (conservative)

**Example:**
- Total: 18 tasks
- Complexity: Mixed (some simple config, some complex algorithms)
- Batches: 6 batches of 3 tasks each

### Batch Loop

For each batch:

#### 4.1: Spawn Batch Writer Agent

```
I'm spawning batch writer agent for Tasks [X-Y].
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus" (use most capable)
- `description`: "Write detailed plan for batch [N]"
- `run_in_background`: true
- `prompt`: Load from `@batch-plan-writer.md` and include:
  - Design document path (agent reads it itself)
  - Plan file path (agent reads outline + previous batches itself)
  - Assigned tasks: "Tasks [X-Y]"

**What writer does:**
- Reads design doc and plan file in its own context
- Assesses capacity
- Writes complete implementation directly to the plan file following the Required Task Structure: exact file paths, complete code (no placeholders), TDD steps, exact commands
- Updates the Detailed Planning Progress section
- Returns ONLY a 2-3 sentence summary

#### 4.2: Spawn Batch Reviewer Agent

After the writer's background task completes (check summary for success):

```
I'm spawning batch reviewer agent for Tasks [X-Y].
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Review batch [N] implementation"
- `run_in_background`: true
- `prompt`: Load from `@batch-plan-reviewer.md` and include:
  - Design document path (agent reads it itself)
  - Plan file path (agent reads the batch it's reviewing itself)
  - Batch to review: "Tasks [X-Y]"

**What reviewer does:**
- Reads plan file in its own context
- Reviews only assigned batch
- Writes review to plan file
- Returns ONLY the recommendation summary

#### 4.3: Decision Point: Fixes Needed?

Read the **last 30 lines** of the reviewer's output file to get the recommendation.

**If Critical or Important issues found:**
1. Resume batch writer agent with a brief prompt:
   ```
   The reviewer found issues with your batch. Read the "## Batch [N] Review" section in the plan file for details. Fix the critical and important issues, update the plan file. Return ONLY a summary of what you fixed.
   ```
2. Use `run_in_background: true` for the resumed agent
3. Re-run batch reviewer (backgrounded) until batch approved

**If only Minor issues or approved:**
- Proceed to next batch

#### 4.4: Update Progress

After each batch is approved:

```markdown
## Detailed Planning Progress

**Batch 1 (Tasks 1-6):** ✓ Complete, reviewed, approved
**Batch 2 (Tasks 7-12):** ✓ Complete, reviewed, approved
**Batch 3 (Tasks 13-18):** In progress

## Planning Progress

- [x] Design document read
- [x] Task outline created
- [x] Gap analysis complete
- [~] Detailed planning in progress (67% complete)
...
```

#### 4.5: Next Batch

Repeat 4.1-4.4 for each batch until all tasks are detailed.

---

## Phase 5: Final Plan Review

After all batches are complete, review the entire plan end-to-end.

### Spawn Final Reviewer

```
I'm spawning final plan reviewer to verify the complete implementation plan.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Final plan review"
- `run_in_background`: true
- `prompt`: Load from `@plan-review.md` and include:
  - Path to complete plan file

**What final reviewer does:**
- Reads the entire plan file in its own context
- Reviews plan holistically, checks end-to-end flow
- Writes full review to the plan file (per its Output Protocol)
- Returns ONLY a brief summary to the orchestrator

### Check Completion

Read the **last 30 lines** of the agent's output file to get:
- Execution confidence level
- Whether critical issues were found
- Whether to proceed or spawn a feedback agent

---

## Phase 6: Incorporate Final Feedback

If final reviewer found issues:

### Spawn Feedback Incorporation Agent

```
I'm spawning feedback incorporation agent to address final review findings.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "sonnet" (haiku if changes are trivial)
- `description`: "Incorporate final review feedback"
- `run_in_background`: true
- `prompt`:

```
Incorporate the final review feedback into the implementation plan.

**Plan file:** docs/<feature-name>/plan.md

The review is already written in the plan file under "## Final Review Results". Read it there.

**Actions needed:**
1. Fix Critical issues (must address)
2. Address Important issues (should address)
3. Consider Minor issues
4. Add missing items
5. Clarify ambiguities

Update the plan file with all changes. Mark sections that were updated.

**CRITICAL:** Your final message must be ONLY a 2-3 sentence summary of what you changed and whether a re-review is needed. Do NOT return detailed changes in your response.
```

### Decision Point: Re-Review?

Read the **last 30 lines** of the agent's output file to get the summary.

**If significant changes made:**
- Re-run final plan reviewer (backgrounded)
- Verify issues resolved

**If minor changes:**
- Proceed to completion

---

## Phase 7: Finalize and Handoff

### Update Plan Status

```markdown
## Final Review Results

**Reviewed by:** Claude Opus (Final Plan Reviewer)
**Review Date:** YYYY-MM-DD

**Execution Confidence:** [High (90%+) / Medium (70-90%) / Low]

**Critical issues:** 0 (all resolved)
**Important issues:** [N] (addressed/acceptable)

**Status:** Approved - Ready for Execution

## Planning Progress

- [x] Design document read
- [x] Task outline created
- [x] Gap analysis complete
- [x] Detailed planning complete
- [x] Final review complete

---

## Execution Summary

**Total Tasks:** [N]
**Batches:** [M]
**Review Iterations:**
- Gap analysis: [N] iterations
- Batch reviews: [M] iterations
- Final review: [K] iterations

**Gaps Found and Resolved:** [Total across all reviews]

**Plan Quality:** [Excellent/Good/Fair]
```

### Handoff Message

**"Implementation plan complete and ready for execution."**

**Feature directory:** `docs/<feature-name>/`
**Plan:** `docs/<feature-name>/plan.md`

**Quality metrics:**
- Task outline: Gap-free after [N] iterations
- Detailed planning: [M] batches, [K] review iterations
- Final review: [Confidence level]

**Total planning time:** [Coordinated across N agents]

**To execute this plan, use:**

```
/execute-plan docs/<feature-name>/plan.md
```

This will invoke go-time for coordinated task execution with resumable subagents.

**After execution, if bugs remain:**

```
/patch-party <feature-name> <bug descriptions>
```

---

## Key Principles

### 1. Batch Size Matters

**Too large:** Writer hits context limits, leaves placeholders
**Too small:** Overhead of agent coordination
**Just right:** 5-8 tasks for mixed complexity

### 2. Fresh Agents Per Batch

Each batch gets a fresh writer agent:
- No context pollution
- Can handle full task complexity
- Can incorporate review feedback via resume

### 3. Incremental Reviews

Review each batch before next begins:
- Catch issues early
- Maintain quality bar
- Avoid cascading problems

### 4. Resume for Fixes

When reviewer finds issues:
- Resume the same writer agent
- It has context of what it wrote
- Efficient fixing without re-reading

### 5. Final Holistic Review

After all batches:
- Check end-to-end integration
- Verify cross-batch connections
- Catch any overall issues

---

## Troubleshooting

### Writer Can't Complete Assigned Batch

**Symptom:** Writer reports "can only complete Tasks X-Y, not Z"

**Action:**
- Accept the smaller batch
- Create new batch for remaining tasks
- Adjust batch size down for future batches

### Reviewer Finds Too Many Issues

**Symptom:** 10+ critical issues in one batch

**Action:**
- Resume writer with feedback
- If issues persist after 2 iterations, spawn fresh writer for problematic tasks
- May indicate batch complexity too high

### Batches Don't Connect

**Symptom:** Final reviewer finds integration gaps between batches

**Action:**
- Spawn integration fixer agent
- Have it add connection tasks
- Re-review affected sections

### Context Running Low

**Symptom:** You're at 80%+ context during orchestration

**This shouldn't happen if you followed the Context Budget Protocol.** If it does:
- You likely read a full agent output file or the full plan file — stop doing that
- Read ONLY the last 30 lines of output files and ONLY the Planning Progress section of the plan file
- All detailed work must happen inside background agents, not in the orchestrator

---

## When to Use This Skill

**Use blueprint-maestro when:**
- Plan will have 8+ tasks
- Tasks are complex or varied in complexity
- Design is comprehensive
- Want highest quality with any plan size

**Use blueprint when:**
- Plan is simple (< 5 tasks)
- All tasks are straightforward
- Single agent can handle it

---

## Success Criteria

A successful plan has:
- [ ] Gap-free task outline
- [ ] All tasks detailed with complete code
- [ ] All file paths specific
- [ ] All verification steps clear
- [ ] All integrations explicit
- [ ] Approved by batch reviewers
- [ ] Approved by final reviewer
- [ ] Confidence: High or Medium

If all checked, plan is ready for `/execute-plan`.
