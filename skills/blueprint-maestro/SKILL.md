---
name: blueprint-maestro
description: Orchestrate multi-agent implementation planning with batched writing and incremental reviews for plans of any size. Use when you have 8+ complex tasks and want highest quality detailed planning.
model: claude-opus-4-5-20251101
---

# Blueprint Maestro

The conductor for complex plans.

## Overview

Coordinate multiple agents to write comprehensive implementation plans in batches. This skill takes a validated task outline (produced by story-time) and orchestrates detailed planning: batched writing, incremental reviews, and final validation.

**Key innovation:** Plans are written in batches of 2-3 tasks by fresh agents, with each batch reviewed before the next begins. Fix agents get full context budget for focused repairs — no resumed agents with exhausted context.

**Announce at start:** "I'm using blueprint-maestro to create detailed implementation plans from the validated task outline."

**Input:** A plan file at `docs/{feature-name}/plan.md` containing a validated task outline (produced by story-time or manually).

**Output:** The same plan file, extended with detailed implementation for every task.

**Feature directory:** Should already exist with `design.md` and a task outline in `plan.md`. Agent summaries are written to `docs/{feature-name}/.maestro/` (created automatically by agents).

**Success at a glance:** All tasks detailed with complete code, all file paths specific, all verification steps clear, all integrations explicit, approved by batch and final reviewers, confidence High or Medium. See [Success Criteria](#success-criteria) for the full checklist.

---

## Resume vs Fresh Start

**Before doing anything else, read the plan file and determine the current state.**

Read ONLY the "## Planning Progress" and "## Detailed Planning Progress" sections of the plan file (use `offset`/`limit` to read just those sections).

### Fresh Start

**Indicators:**
- Plan file has a task outline
- "Gap analysis complete" is checked
- NO "## Detailed Planning Progress" section exists, or it shows no completed batches

**Action:**
1. Read the design document once (for context)
2. Add the detailed planning checkboxes to Planning Progress if not present
3. Start at Phase 1 (Batched Detailed Planning) from batch 1

### Resume

**Indicators:**
- "## Detailed Planning Progress" section exists with some batches marked complete, OR
- "## Planning Handoff" section exists

**Action:**
1. Read "## Planning Handoff" (if present) → find which batch is next
2. Otherwise, determine next batch from Detailed Planning Progress section
3. Continue from that batch in Phase 1 (Batched Detailed Planning)

---

## Context Budget Protocol

**The #1 risk for blueprint-maestro is running out of context.** Foreground agents dump their entire output (~50-70k tokens each) into the orchestrator's context. Three foreground agents can consume ~160k of a 200k context window, killing the session. Follow these rules strictly:

### Rule 1: Background ALL Agents
Every agent spawned by the orchestrator MUST use `run_in_background: true`. **No exceptions.** This is the single most important rule in the entire skill.

### Rule 2: Agents Write to File, Return a Summary
Every agent prompt MUST include these instructions:
> **CRITICAL:** Write all detailed output directly to the plan file. Do NOT return detailed content in your response — it belongs in the file only.
> **SUMMARY FILE:** After writing to the plan file, write a 2-3 sentence summary of what you accomplished (and any blockers) to your designated summary file in `docs/{feature-name}/.maestro/`. Create the `.maestro/` directory if it doesn't exist.

**NEVER instruct agents to write to `/tmp/` or any temporary directory.** All agent working files go in the feature's `.maestro/` directory.

Summary file naming convention:
- Batch writer: `docs/{feature-name}/.maestro/batch-{N}-writer.md`
- Batch reviewer: `docs/{feature-name}/.maestro/batch-{N}-review.md`
- Fix agent: `docs/{feature-name}/.maestro/batch-{N}-fix.md`
- Final reviewer: `docs/{feature-name}/.maestro/final-review.md`
- Handoff: `docs/{feature-name}/.maestro/handoff.md`

### Rule 3: Don't Read Source Code in the Orchestrator
The orchestrator reads ONLY:
- The design document (once, for context)
- The Planning Progress section of the plan file (to track status — use `offset`/`limit` to read just that section)

All source code reading happens inside agents in their own context windows. Pass file paths to agents, never file contents.

### Rule 4: Check Completion Leanly
After a background agent completes:
1. Read the agent's summary file from `docs/{feature-name}/.maestro/` (e.g., `batch-1-writer.md`) to get the summary
2. Optionally read just the "Planning Progress" table from the plan file to verify the checkbox updated
3. **NEVER** read the full plan file back into the orchestrator

### Context Budget Target
| Item | Tokens | Notes |
|------|--------|-------|
| Design doc read | ~5-15k | One-time, acceptable |
| Per-agent completion check | ~1-2k | .maestro/ summary file + progress table only |
| Orchestrator tracking/decisions | ~5-10k | Status updates, batch decisions |
| **Target total** | **<50k** | For a full planning session |

**Cumulative tracking example (12-task plan):**
| After | Cumulative | % of 200k | Action |
|-------|-----------|-----------|--------|
| Design doc read | ~10k | 5% | Continue |
| Batch 1 (write + review + check) | ~14k | 7% | Continue |
| Batch 2 (write + review + fix + re-review + check) | ~20k | 10% | Continue |
| Batch 3 (write + review + check) | ~24k | 12% | Continue |
| ... | ... | ... | Check at 50% → handoff if needed |

---

## Orchestrator Role Rules

**You are the conductor, not the musicians.**

### Rule: NEVER Write Plan Content Directly

The orchestrator MUST NEVER write review content, batch details, task implementations, or any planning content directly to the plan file.

**ALL plan file modifications happen through subagents:**
- Batch details → batch writer agent
- Fixes from reviews → fresh fix agent
- Final feedback → feedback incorporation agent
- Planning handoff → handoff agent

**The orchestrator ONLY:**
- Reads summaries (agent output last 30 lines, Planning Progress section)
- Makes dispatch decisions (which agent next, which batch)
- Tracks progress (which batches are done)
- Communicates with the user

**If a batch review comes back with issues:**
- Dispatch a fresh fix agent
- Do NOT copy the review into the plan
- Do NOT attempt to fix things yourself
- Do NOT write the review summary into the plan

---

## The Orchestration Flow

```
Read Plan File (determine resume vs fresh start)
        ↓
Batch Planning Loop:
  ├─ Batch Writer Agent (fresh agent per batch)
  ├─ Batch Reviewer Agent (fresh agent per batch)
  ├─ Spawn FRESH Fix Agent if fixes needed
  └─ Context Checkpoint → Above 50%? Write handoff, stop.
        ↓
   More tasks? → Next batch
        ↓ All tasks detailed
Final Plan Reviewer (subagent)
        ↓
Incorporate Feedback Agent (fresh subagent if needed)
        ↓
Complete Plan Ready for Execution
```

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

## Phase 1: Batched Detailed Planning

Now write detailed implementation in batches.

### Batch Size Strategy

**Always 2-3 tasks per batch.**

This applies regardless of task complexity. Smaller batches mean:
- Writers have full context budget for quality
- Reviews are focused and thorough
- Fix agents have clear scope
- Context checkpoints happen frequently

**Example:**
- Total: 12 tasks from outline
- Batches: 4-6 batches of 2-3 tasks each

### Batch Loop

For each batch:

#### 1.1: Spawn Batch Writer Agent

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

#### 1.2: Spawn Batch Reviewer Agent

After the writer's background task completes (read `docs/{feature-name}/.maestro/batch-{N}-writer.md` for success):

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

#### 1.3: Decision Point: Fixes Needed?

Read the reviewer's summary from `docs/{feature-name}/.maestro/batch-{N}-review.md` to get the recommendation.

**If Critical or Important issues found:**

Spawn a **FRESH fix agent** (do NOT resume the batch writer):

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Fix batch [N] issues"
- `run_in_background`: true
- `prompt`:

```
You are a fix agent for Batch [N] (Tasks [X-Y]) of an implementation plan.

**Plan file:** docs/{feature-name}/plan.md  (substitute the actual feature directory name)
**Design document:** docs/{feature-name}/design.md

**Your job:**
1. Read the plan file
2. Find the "## Batch [N] Review" section — it lists the issues found
3. Fix ALL critical and important issues in the task details
4. Update the plan file with your fixes

**QUALITY STANDARD — every fix MUST follow this pattern:**
- Exact file paths (absolute or clearly relative from project root)
- Complete code (no TODOs, no placeholders, no "add validation here")
- TDD pattern: Write failing test → Run to verify fail → Implement → Run to verify pass → Commit
- Exact commands with expected output (copy-pasteable)
- Integration checks showing how tasks connect

**CRITICAL:** Write all fixes directly to the plan file. Then write a 2-3 sentence summary of what you fixed to `docs/{feature-name}/.maestro/batch-{N}-fix.md` (create the `.maestro/` directory if needed). Do NOT return detailed content in your response — it belongs in the file only.
```

After the fix agent completes (read `docs/{feature-name}/.maestro/batch-{N}-fix.md` for summary):
- Re-run batch reviewer (fresh agent, backgrounded) to verify fixes
- Repeat fix → review cycle until batch approved
- **Maximum 3 fix iterations per batch.** If still failing after 3, note remaining issues in Detailed Planning Progress and move to next batch.

**If only Minor issues or approved:**
- Proceed to context checkpoint

#### 1.4: Context Checkpoint

**After each batch cycle completes (write → review → fix if needed → approve), check your own context usage.**

**If you estimate your context is above ~50% full:**

1. Spawn a background handoff agent:

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "haiku"
- `description`: "Write planning handoff"
- `run_in_background`: true
- `prompt`:

```
Read docs/{feature-name}/plan.md. Add a "## Planning Handoff" section at the end with:

- Which batches are complete (list batch numbers and task ranges)
- Which batch is next (batch number and task range)
- Total tasks remaining
- Any notes about issues encountered during planning

Write this to the plan file. Then write a 2-sentence summary to docs/{feature-name}/.maestro/handoff.md (create the .maestro/ directory if needed).
```

2. After handoff agent completes (read `docs/{feature-name}/.maestro/handoff.md` for summary), tell the user:

**"Context is getting full. Run `/blueprint-maestro docs/{feature-name}/plan.md` in a fresh session to continue planning from where I left off."**

3. **Stop.** Do not attempt another batch.

**If context is below ~50%:**
- Continue to next batch

#### 1.5: Update Progress

After each batch is approved, verify the Detailed Planning Progress section was updated by the writer/fix agent.

```markdown
## Detailed Planning Progress

**Batch 1 (Tasks 1-3):** ✓ Complete, reviewed, approved
**Batch 2 (Tasks 4-6):** ✓ Complete, reviewed, approved
**Batch 3 (Tasks 7-9):** In progress

## Planning Progress

- [x] Design document read
- [x] Task outline created
- [x] Gap analysis complete
- [~] Detailed planning in progress (67% complete)
...
```

#### 1.6: Next Batch

Repeat 1.1-1.5 for each batch until all tasks are detailed.

---

## Phase 2: Final Plan Review

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

Read the reviewer's summary from `docs/{feature-name}/.maestro/final-review.md` to get:
- Execution confidence level
- Whether critical issues were found
- Whether to proceed or spawn a feedback agent

---

## Phase 3: Incorporate Final Feedback

If final reviewer found Critical or Important issues:

### Spawn FRESH Feedback Fix Agent

```
I'm spawning feedback fix agent to address final review findings.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Incorporate final review feedback"
- `run_in_background`: true
- `prompt`:

```
You are a fix agent for final review feedback on an implementation plan.

**Plan file:** docs/{feature-name}/plan.md

Read the "## Final Review Results" section for all feedback.

**Your job:**
1. Fix Critical issues (must address)
2. Address Important issues (should address)
3. Consider Minor issues
4. Add missing items
5. Clarify ambiguities

**QUALITY STANDARD — every fix MUST follow this pattern:**
- Exact file paths (absolute or clearly relative from project root)
- Complete code (no TODOs, no placeholders, no "add validation here")
- TDD pattern: Write failing test → Run to verify fail → Implement → Run to verify pass → Commit
- Exact commands with expected output (copy-pasteable)
- Integration checks showing how tasks connect

Update the plan file with all changes. Mark sections that were updated.

**CRITICAL:** Write all fixes directly to the plan file. Then write a 2-3 sentence summary of what you changed and whether a re-review is needed to `docs/{feature-name}/.maestro/final-fix.md` (create the `.maestro/` directory if needed). Do NOT return detailed changes in your response.
```

### Decision Point: Re-Review?

Read the fix agent's summary from `docs/{feature-name}/.maestro/final-fix.md`.

**If significant changes made:**
- Re-run final plan reviewer (fresh agent, backgrounded)
- Verify issues resolved

**If minor changes:**
- Proceed to completion

---

## Phase 4: Finalize and Handoff

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
- Batch reviews: [M] iterations
- Final review: [K] iterations

**Gaps Found and Resolved:** [Total across all reviews]

**Plan Quality:** [Excellent/Good/Fair]
```

### Handoff Message

**"Implementation plan complete and ready for execution."**

**Feature directory:** `docs/{feature-name}/`
**Plan:** `docs/{feature-name}/plan.md`

**Quality metrics:**
- Detailed planning: [M] batches, [K] review iterations
- Final review: [Confidence level]

**Total planning time:** [Coordinated across N agents]

**To execute this plan, use:**

```
/go-time {feature-name}
```

**After execution, if bugs remain:**

```
/patch-party {feature-name} {bug descriptions}
```

---

## Key Principles

### 1. Small Batches, High Quality

**Always 2-3 tasks per batch.** Smaller batches mean writers have full context budget, reviews are focused, and fix agents have clear scope.

### 2. Fresh Agents Per Batch

Each batch gets a fresh writer agent:
- No context pollution from previous batches
- Full context budget for quality writing
- Can produce complete, detailed implementations

### 3. Incremental Reviews

Review each batch before next begins:
- Catch issues early
- Maintain quality bar
- Avoid cascading problems

### 4. Fresh Fix Agents for Repairs

When reviewer finds issues:
- Spawn a FRESH fix agent with full context budget
- Fix agent reads plan file, finds the review, fixes issues
- No context pollution from the original writing session
- Writer used 70% on writing — fix agent gets 100% for focused repairs

### 5. Final Holistic Review

After all batches:
- Check end-to-end integration
- Verify cross-batch connections
- Catch any overall issues

### 6. Context Self-Monitoring

After each batch cycle:
- Check context usage
- Write handoff and stop if above 50%
- Fresh session picks up seamlessly via Resume path

---

## Troubleshooting

### Writer Can't Complete Assigned Batch

**Symptom:** Writer reports "can only complete Tasks X-Y, not Z"

**Action:**
- Accept the smaller batch
- Create new batch for remaining tasks
- Future batches stay at 2-3 tasks

### Reviewer Finds Too Many Issues

**Symptom:** 10+ critical issues in one batch

**Action:**
- Spawn fresh fix agent with feedback
- If issues persist after 3 fix iterations, note in progress and move on
- May indicate task complexity needs splitting

### Batches Don't Connect

**Symptom:** Final reviewer finds integration gaps between batches

**Action:**
- Spawn integration fixer agent
- Have it add connection tasks
- Re-review affected sections

### Context Running Low

**Symptom:** You're at 50%+ context during orchestration

**Action:**
- Follow the Context Checkpoint protocol (Phase 1.4)
- Write planning handoff and stop
- User invokes `/blueprint-maestro` again — Resume path picks up automatically
- This should NOT happen before at least 2-3 batches if you followed the Context Budget Protocol

### Resume Not Working

**Symptom:** Blueprint-maestro can't determine where to continue

**Action:**
- Read the full Planning Progress and Detailed Planning Progress sections
- Count completed batches and identify the next task range
- If ambiguous, start from the last incomplete batch

---

## When to Use This Skill

**Use blueprint-maestro when:**
- You have a validated task outline (from story-time or manual creation)
- Plan will have 8+ tasks
- Tasks are complex or varied in complexity
- Want highest quality at any plan size

**Prerequisites:**
- Plan file with validated task outline (gap analysis complete)
- Design document in the same feature directory

**Use blueprint (simple) when:**
- Plan is simple (< 5 tasks)
- All tasks are straightforward
- Single agent can handle it

---

## Success Criteria

A successful plan has:
- [ ] All tasks detailed with complete code
- [ ] All file paths specific
- [ ] All verification steps clear
- [ ] All integrations explicit
- [ ] Approved by batch reviewers
- [ ] Approved by final reviewer
- [ ] Confidence: High or Medium

If all checked, plan is ready for `/go-time`.
