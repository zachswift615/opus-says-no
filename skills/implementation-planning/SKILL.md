---
name: implementation-planning
description: Three-phase implementation planning with adversarial gap analysis. Use when you have requirements and need a comprehensive, gap-free implementation plan.
model: opus
---

# Implementation Planning (Gap-Free Plans)

## Overview

Create comprehensive implementation plans using a three-phase approach that catches gaps before they get baked into detailed steps. This skill produces plans that are complete, connected, and executable.

**Announce at start:** "I'm using implementation-planning to create a gap-free implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## The Three-Phase Approach

```
Phase 1: Task Outline (WHAT, not HOW)
              ↓
Phase 2: Adversarial Gap Analysis (Opus subagent)
              ↓
        Iterate until no gaps found
              ↓
Phase 3: Detailed Implementation Plan
              ↓
Phase 4: Final Plan Review (Opus subagent)
              ↓
        Ready for Execution
```

---

## Phase 1: Task Outline

Create a high-level task list focused on GOALS and CONNECTIONS, not implementation details.

### Task Outline Template

```markdown
## Task Outline

### Task 1: [Name]
**Goal:** [What this accomplishes in one sentence]
**Inputs:** [What this task needs to start]
**Outputs:** [What this task produces]
**Acceptance Criteria:**
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
**Depends On:** [Other task numbers, or "None"]
**Consumed By:** [Which tasks use this output, or "End User"]

### Task 2: [Name]
...
```

### Rules for Phase 1
- NO code snippets yet
- NO file paths yet
- Focus on the dependency graph
- Every output must be consumed by something
- Every input must come from somewhere

### Save the Outline

Save to the plan file: `docs/plans/YYYY-MM-DD-<feature-name>.md`

Start with this header:

```markdown
# [Feature Name] Implementation Plan

Date: YYYY-MM-DD
Status: Outline - Pending Gap Analysis

## Goal

[One sentence describing what this plan achieves]

## Architecture Overview

[2-3 sentences about the approach]

---

## Task Outline

[Your task outline here]
```

---

## Phase 2: Adversarial Gap Analysis

Now spawn an Opus subagent to challenge your task outline and find structural gaps.

### Why a Subagent?

- **Fresh perspective:** No attachment to the outline you just created
- **Systematic review:** Follows comprehensive checklist
- **Adversarial stance:** Explicitly tasked to find problems
- **Catches blind spots:** Things you missed while creating the outline

### How to Execute

Use the Task tool to spawn the gap analysis subagent:

```
I'm spawning a gap analysis subagent to review the task outline for structural gaps.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus" (use the most capable model)
- `description`: "Gap analysis review"
- `prompt`: Load from `@gap-analysis-review.md` and include:
  - Path to plan file: `docs/plans/YYYY-MM-DD-<feature-name>.md`

**Example invocation:**

"I'm using the Task tool to spawn an Opus subagent for gap analysis."

[Call Task tool with prompt loaded from gap-analysis-review.md plus the file path]

### What to Expect Back

The subagent will return a review with:
- **Critical gaps:** Missing connections, orphaned tasks, missing inputs/outputs
- **Integration gaps:** Missing wiring tasks
- **Testing gaps:** Missing verification
- **Error handling gaps:** Unhandled failure modes
- **Revised outline:** Updated version with gaps filled

### Incorporate Feedback

For each gap found:

1. **Critical gaps:** MUST address - add missing tasks, fix connections
2. **Important gaps:** Should address - add integration/testing tasks
3. **Minor gaps:** Consider - edge cases and polish

Update your task outline in the plan file.

### Iterate Until Clean

**If subagent found Critical or Important gaps:**
- Update the outline
- **Re-run gap analysis** on the revised outline
- Repeat until no Critical/Important gaps remain

**If only Minor gaps found or no gaps:**
- Proceed to Phase 3

Document the iterations:

```markdown
## Gap Analysis Summary

**Iterations:** [N]
**Critical gaps found:** [List key gaps]
**Important gaps found:** [List key gaps]
**Status:** All critical gaps resolved, ready for detailed planning
```

---

## Phase 3: Detailed Implementation Plan

Now write the full implementation plan with code, file paths, and commands.

### Update Plan Header

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Execute this plan task-by-task. Verify each step before proceeding.

Date: YYYY-MM-DD
Status: Detailed - Pending Final Review

**Goal:** [One sentence]

**Architecture:** [2-3 sentences]

**Gap Analysis:** Completed - [N] iterations, [M] gaps found and resolved

**Tech Stack:** [Key technologies]

---
```

### Task Structure

For each task from your outline, write the detailed implementation:

```markdown
### Task N: [Name]

**Goal:** [From outline]
**Depends On:** Task [X] (needs [specific output])
**Produces:** [Specific artifact consumed by Task Y]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext:line-range`
- Test: `tests/exact/path/test.ext`

**Step 1: [Action]**

```language
[Complete code - no placeholders]
```

**Step 2: Verify**

Run: `exact command`
Expected: [Specific output]

**Step 3: Commit**

```bash
git add [files]
git commit -m "[conventional commit message]"
```

**Integration Check:** [How to verify this connects to dependent tasks]
```

### Rules for Phase 3
- Complete code, no "add validation here" placeholders
- Exact file paths with line numbers for modifications
- Every task ends with an integration check
- Commands include expected output
- All imports/exports explicit

---

## Phase 4: Final Plan Review

Now spawn a second Opus subagent to review the complete implementation plan for executability.

### Why Another Review?

- **Verify completeness:** No placeholders, all code complete
- **Check clarity:** File paths specific, commands clear
- **Validate executability:** Can someone follow this without questions?
- **Catch ambiguities:** Find unclear instructions before execution

### How to Execute

Use the Task tool to spawn the plan review subagent:

```
I'm spawning a plan review subagent to verify the implementation plan is complete and executable.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Implementation plan review"
- `prompt`: Load from `@plan-review.md` and include:
  - Path to plan file: `docs/plans/YYYY-MM-DD-<feature-name>.md`

**Example invocation:**

"I'm using the Task tool to spawn an Opus subagent for final plan review."

[Call Task tool with prompt loaded from plan-review.md plus the file path]

### What to Expect Back

The subagent will return a review with:
- **Critical issues:** Blockers (placeholders, missing file paths, incomplete code)
- **Important issues:** Problems that cause execution difficulties
- **Ambiguities:** Unclear instructions
- **Missing items:** Things that should be in the plan
- **Execution readiness:** Ready/Not Ready assessment

### Address Feedback

For each issue found:

1. **Critical issues:** MUST fix before execution
2. **Important issues:** Should fix to avoid problems
3. **Minor issues:** Polish items, optional
4. **Ambiguities:** Clarify instructions

Update the plan file with fixes.

**If Critical issues found:**
- Fix them
- **Re-run plan review** to verify fixes
- Repeat until no Critical issues remain

**If only Important/Minor issues or no issues:**
- Optionally address important issues
- Proceed to execution handoff

### Update Plan Status

```markdown
## Final Review Results

**Reviewed by:** Claude Opus (Plan Review Agent)
**Review Date:** YYYY-MM-DD

**Critical issues:** [N] (all resolved)
**Important issues:** [N] (addressed/deferred)
**Execution confidence:** [High/Medium]

**Status:** Ready for execution
```

Update plan status: `Status: Detailed - Pending Final Review` → `Status: Approved - Ready for Execution`

---

## Execution Handoff

After both reviews are complete and all critical issues are resolved, hand off to execution.

### Final Message

**"Implementation plan complete and reviewed."**

**Plan:** `docs/plans/<filename>.md`

**Quality metrics:**
- Gap analysis: [N] iterations, [M] gaps resolved
- Plan review: [N] issues addressed
- Execution confidence: [High/Medium/Low]

**To execute this plan in a fresh session, use:**

```
/execute-plan docs/plans/<filename>.md
```

This command will load the plan and invoke superpowers:subagent-driven-development for coordinated execution.

---

## Example Gap Evolution

**Task Outline (Phase 1):**
```
Task 1: Add validation function
Task 2: Update tests
Task 3: Add error messages
```

**After Gap Analysis (Phase 2):**
```
Task 1: Add validation function
Task 1.5: Wire validation into existing pipeline (GAP FILLED)
Task 2: Unit tests for validation
Task 2.5: Integration test for validation flow (GAP FILLED)
Task 3: Add error messages
Task 4: Verify end-to-end flow (GAP FILLED)
```

**After Plan Review (Phase 4):**
- Task 1.5 originally said "wire it up" → Now includes exact code and imports
- Task 2.5 originally had "test it" → Now includes exact command and expected output
- All file paths now absolute from project root

---

## Key Principle

> "Every gap caught in Phase 2 is a bug prevented in execution. Every ambiguity caught in Phase 4 is a question avoided during execution."

The extra 20 minutes spent on reviews saves hours of debugging incomplete or unclear implementations.

---

## When NOT to Use This Skill

Skip the multi-phase process for:
- Single-file changes
- Trivial bug fixes
- Well-understood patterns you've done many times
- Very small tasks (<30 minutes)

For these, write the plan directly without gap analysis.
