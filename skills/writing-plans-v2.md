---
name: writing-plans-v2
description: Two-phase implementation planning with gap analysis. Use when you have requirements and need a comprehensive, gap-free implementation plan.
model: opus
---

# Writing Plans v2 (Two-Phase with Gap Analysis)

## Overview

Create comprehensive implementation plans using a two-phase approach that catches gaps before they get baked into detailed steps. This skill produces plans that are complete, connected, and executable.

**Announce at start:** "I'm using writing-plans-v2 to create a gap-free implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>.md`

## The Two-Phase Approach

```
Phase 1: Task Outline (WHAT, not HOW)
              ↓
Phase 2: Gap Analysis (adversarial review)
              ↓
        Iterate until no gaps found
              ↓
Phase 3: Detailed Implementation Plan
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

---

## Phase 2: Gap Analysis

After completing the task outline, perform an adversarial review. Ask these questions systematically:

### Connection Gaps
- [ ] Does every task output get used by another task or the end user?
- [ ] Does every task input come from a previous task or external source?
- [ ] Are there any "orphan" tasks that nothing depends on?
- [ ] Is there a clear path from first task to final deliverable?

### Integration Gaps
- [ ] Is there a task for wiring components together?
- [ ] Is there a task for updating call sites when signatures change?
- [ ] If Task A changes an interface, does Task B update all consumers?
- [ ] Are there any "import" or "export" statements that need adding?

### Testing Gaps
- [ ] Is there an integration test that exercises the full flow?
- [ ] Does each task have a way to verify it worked?
- [ ] Is there a regression test for existing functionality?

### Error Handling Gaps
- [ ] What happens if Task N fails? Is rollback needed?
- [ ] Are there error cases that need explicit handling?
- [ ] Is there a task for adding error messages/logging?

### Dependency Gaps
- [ ] Are tasks ordered correctly based on dependencies?
- [ ] Are there circular dependencies?
- [ ] Can any tasks be parallelized?

### Documentation Gaps
- [ ] Is there a task for updating README/docs if needed?
- [ ] Are config changes documented?

### Output Format

```markdown
## Gap Analysis

### Gaps Found
1. **[Gap Type]:** [Description of what's missing]
   **Fix:** Add Task N.5 to [do X]

2. **[Gap Type]:** [Description]
   **Fix:** Modify Task M to also [do Y]

### Revised Task Outline
[Updated outline with gaps filled]
```

### Iterate Until Clean
Repeat gap analysis on the revised outline until no new gaps are found. Only then proceed to Phase 3.

---

## Phase 3: Detailed Implementation Plan

Now write the full implementation plan with code, file paths, and commands.

### Plan Document Header

```markdown
# [Feature Name] Implementation Plan

> **For Claude:** Execute this plan task-by-task. Verify each step before proceeding.

**Goal:** [One sentence]

**Architecture:** [2-3 sentences]

**Gap Analysis:** Completed - [N] iterations, [M] gaps found and resolved

**Tech Stack:** [Key technologies]

---
```

### Task Structure

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

---

## Execution Handoff

After saving the plan:

**"Plan complete: `docs/plans/<filename>.md`**

**Gap Analysis Summary:**
- Iterations: [N]
- Gaps found: [List key gaps that were caught]
- Confidence: [High/Medium based on complexity]

**Execution options:**
1. **This session** - Execute with checkpoints between tasks
2. **Fresh session** - Hand off to new session with full context"

---

## Example Gap Analysis

**Task Outline (Before):**
```
Task 1: Add validation function
Task 2: Update tests
Task 3: Add error messages
```

**Gap Analysis:**
```
Gap Found: Task 1 adds a function but nothing calls it.
Fix: Add Task 1.5 to wire validation into the existing flow.

Gap Found: No integration test for the full validation flow.
Fix: Add Task 4 for integration testing.
```

**Task Outline (After):**
```
Task 1: Add validation function
Task 1.5: Wire validation into existing pipeline
Task 2: Update unit tests
Task 3: Add error messages
Task 4: Integration test for full flow
```

---

## Key Principle

> "Every gap caught in Phase 2 is a bug prevented in execution."

The extra 10 minutes spent on gap analysis saves hours of debugging incomplete implementations.
