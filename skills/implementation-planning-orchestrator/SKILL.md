---
name: implementation-planning-orchestrator
description: Orchestrate multi-agent implementation planning with batched writing and incremental reviews for plans of any size
model: claude-opus-4-5-20251101
---

# Implementation Planning Orchestrator

## Overview

Coordinate multiple agents to create comprehensive implementation plans without hitting context limits. This skill orchestrates task outline creation, gap analysis, batched detailed planning, incremental reviews, and final validation.

**Key innovation:** Plans are written in batches by fresh agents, with each batch reviewed before the next begins. This allows plans of any size while maintaining quality and completeness.

**Announce at start:** "I'm using implementation-planning-orchestrator to create a scalable, gap-free implementation plan."

**Save plans to:** `docs/<feature-name>/plan.md`

**Feature directory:** Should already exist from brainstorming-to-plan with `design.md`. If not, create it.

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
1. Read the complete design document
2. Extract key information:
   - Problem & Goals
   - Chosen Approach
   - Key Decisions
   - Scope (must-have, nice-to-have, out-of-scope)
   - User Stories (if present)
   - Constraints

3. Create plan file: `docs/<feature-name>/plan.md`

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
- `prompt`:

```
Create a task outline for the following implementation plan.

**Design Document:** @docs/<feature-name>/design.md

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
```

### Update Plan Status

After outline is created, update plan file status:
```markdown
## Planning Progress

- [x] Design document read
- [x] Task outline created
- [ ] Gap analysis complete
...
```

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
- `prompt`: Load from `@gap-analysis-review.md` and include:
  - Path to plan file: `docs/<feature-name>/plan.md`

### Review Results

The gap agent will return:
- Critical gaps (must fix)
- Important gaps (should fix)
- Minor gaps (optional)
- Revised task outline (if gaps found)

### Decision Point: Gaps Found?

**If Critical or Important gaps found:**
1. Resume the task outline agent with gap feedback
2. Have it update the outline
3. Re-run gap analysis
4. Repeat until no Critical/Important gaps

**Resume outline agent:**
```
I'm resuming the task outline agent to address gap analysis feedback.
```

Use the Task tool with `resume` parameter and provide:
- Gap analysis results
- Which gaps to address
- Request updated outline

**If only Minor gaps or no gaps:**
- Proceed to Phase 4
- Document gap analysis results in plan

### Update Plan File

```markdown
## Gap Analysis Summary

**Iterations:** [N]
**Critical gaps found and resolved:**
1. [Gap description] → [How fixed]

**Important gaps found and resolved:**
1. [Gap description] → [How fixed]

**Status:** Gap-free outline ready for detailed planning

## Planning Progress

- [x] Design document read
- [x] Task outline created
- [x] Gap analysis complete
- [ ] Detailed planning in progress
...
```

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
- `prompt`: Load from `@batch-plan-writer.md` and include:
  - Design document path
  - Plan file path (with task outline)
  - Assigned tasks: "Tasks [X-Y]"
  - Previous batches info (if not first batch)

**What writer does:**
- Assesses capacity
- Writes complete implementation for assigned tasks
- Reports completion and capacity remaining

#### 4.2: Spawn Batch Reviewer Agent

```
I'm spawning batch reviewer agent for Tasks [X-Y].
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Review batch [N] implementation"
- `prompt`: Load from `@batch-plan-reviewer.md` and include:
  - Design document path
  - Plan file path
  - Batch to review: "Tasks [X-Y]"
  - Previous batches info

**What reviewer does:**
- Reviews only assigned batch
- Checks completeness, clarity, executability
- Identifies Critical/Important/Minor issues
- Recommends re-review if needed

#### 4.3: Decision Point: Fixes Needed?

**If Critical or Important issues found:**
1. Resume batch writer agent with review feedback
2. Have it fix the issues
3. Re-run batch reviewer
4. Repeat until batch approved

**Resume writer:**
```
I'm resuming batch writer agent to address review feedback.
```

Use Task tool with `resume` parameter and provide:
- Review results
- Issues to fix
- Request updated implementation

**If only Minor issues or approved:**
- Note issues for writer to consider
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
- `prompt`: Load from `@plan-review.md` and include:
  - Path to complete plan file

**What final reviewer does:**
- Reviews entire plan holistically
- Checks end-to-end flow
- Verifies all integrations
- Confirms no gaps between batches
- Validates final deliverable

### Review Results

Final reviewer will return:
- Overall executability assessment
- Any cross-batch integration issues
- Missing end-to-end verification
- Final recommendations

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
- `prompt`:

```
Incorporate the final review feedback into the implementation plan.

**Plan file:** docs/<feature-name>/plan.md
**Review results:** [Include review findings]

**Actions needed:**
1. Fix Critical issues (must address)
2. Address Important issues (should address)
3. Consider Minor issues
4. Add missing items
5. Clarify ambiguities

Update the plan file with all changes. Mark sections that were updated.
```

### Decision Point: Re-Review?

**If significant changes made:**
- Re-run final plan reviewer
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

This will invoke go-agents for coordinated task execution with resumable subagents.

**After execution, if bugs remain:**

```
/fix-feature-bugs <feature-name> <bug descriptions>
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

**Action:**
- Summarize completed batches
- Track only: batch status, issues found, current batch
- Delegate all detail work to subagents

---

## When to Use This Skill

**Use implementation-planning-orchestrator when:**
- Plan will have 8+ tasks
- Tasks are complex or varied in complexity
- Design is comprehensive
- Want highest quality with any plan size

**Use original implementation-planning when:**
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
