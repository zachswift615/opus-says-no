---
name: trust-but-verify
description: Walk the user through manual test cases after implementation to confirm the feature works as intended. Routes to land-it (all pass) or patch-party (bugs found).
---

# Trust but Verify

The code works. Now prove it.

## Overview

After go-time finishes executing the implementation plan, trust-but-verify walks the user through the manual test cases from the plan's verification task. The user confirms each test case passes, fails, or is blocked. Based on results, routes to land-it (clean) or patch-party (bugs).

**Announce at start:** "I'm using trust-but-verify to walk through manual verification of the feature."

**Input:** Path to plan file (from go-time handoff or `/trust-but-verify` command)

**You are in a worktree** created by go-time. All work happens here.

## The Flow

```
Bootstrap (read plan, find manual-verification task)
        |
Present Test Cases (numbered checklist)
        |
Walk Through Each (one at a time)
        |
Results Summary
        |
   All pass? --> /land-it
        |
   Failures? --> Write bugs.md
        |
   Context available? --> /patch-party (same session)
        |
   Context low? --> Write handoff --> next session /patch-party
```

---

## Phase 1: Bootstrap

1. Read the plan file path (from go-time handoff, command argument, or ask user)
2. Search the plan file for `**Type:** manual-verification` to find the verification task
3. Extract all test cases from that task
4. Read `docs/<feature-name>/design.md` for additional context about the feature's intent

**If no manual-verification task found:**
```
The plan doesn't include a manual verification task.
I'll review the design doc's acceptance criteria instead.
```
Fall back to extracting acceptance criteria from design.md and presenting those as test cases.

---

## Phase 2: Present Test Cases

List all test cases as a numbered checklist:

```
## Manual Verification Test Cases

I'll walk you through each test case one at a time.

1. [Scenario name] - [Brief description]
2. [Scenario name] - [Brief description]
3. [Scenario name] - [Brief description]
...

Let's start with test case 1.
```

---

## Phase 3: Walk Through Each Test Case

Present one test case at a time with full details:

```
### Test Case 1: [Scenario Name]

**Setup:** [What to prepare]

**Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected:** [What should happen]

---

Does this work as expected?
```

Use AskUserQuestion with three options:

| Response | Action |
|----------|--------|
| **Pass** | Mark green, move to next |
| **Fail** | Capture bug details (what happened vs expected), mark red, move to next |
| **Blocked** | Note which failing test blocks this one, mark yellow, move to next |

**When a test fails**, ask the user:
```
What happened instead of the expected result?
```

Record their description as the bug report.

**When a test is blocked**, note the dependency:
```
Which failing test case blocks this one?
```

---

## Phase 4: Results Summary

After all test cases are walked through, present the results:

```
## Verification Results

- [PASS] Test 1: [Description]
- [PASS] Test 2: [Description]
- [FAIL] Test 3: [Description]
- [PASS] Test 4: [Description]
- [BLOCKED] Test 5: [Description] (blocked by test 3)

**Passed:** 3/5 | **Failed:** 1/5 | **Blocked:** 1/5
```

---

## Phase 5: Route Based on Results

### All Pass

```
All manual test cases passed. Feature verified.

To integrate this work, use:
/land-it
```

Hand off to `/land-it`. Land-it handles merge/PR options and worktree cleanup.

### Failures Found

#### Step 1: Write bugs.md

Write `docs/<feature-name>/bugs.md` in patch-party format:

```markdown
# Bugs - <feature-name>

## Source
Discovered during manual verification (trust-but-verify)

## Remaining
- [ ] [Test case name]: [What happened vs what was expected]
  - Reproduction: [Steps from the test case]
  - Severity: [critical/major/minor based on user impact]
  - Related test cases: [any blocked tests that depend on this fix]

- [ ] [Next bug...]
```

Commit the bugs file:

```bash
git add docs/<feature-name>/bugs.md
git commit -m "docs: add bugs from manual verification"
```

#### Step 2: Assess Context

**If context allows (~40%+ remaining):**

```
Manual verification found [N] bugs. I've written them to docs/<feature-name>/bugs.md.

Starting patch-party to fix these bugs.
```

Invoke `/patch-party <feature-name>` in the same session. Patch-party will fix each bug with user confirmation, then hand off to `/land-it`.

**If context is low (<40% remaining):**

Write a handoff file and tell the user to start a fresh session:

```markdown
# Handoff - <feature-name>

## Status
Implementation complete. Manual verification revealed bugs.

## Resume Instructions
Invoke `/patch-party <feature-name>` to fix the following bugs.

## Context
- **Worktree branch:** [branch name]
- **Worktree path:** [worktree path from git worktree list]
- **Plan file:** docs/<feature-name>/plan.md
- **Bugs file:** docs/<feature-name>/bugs.md
- **Design doc:** docs/<feature-name>/design.md
- **Failed tests:** [count]
- **Blocked tests:** [count] (will need re-verification after fixes)
```

Save to `docs/<feature-name>/handoff.md` and commit:

```bash
git add docs/<feature-name>/handoff.md
git commit -m "docs: add handoff for patch-party session"
```

Tell the user:

```
Manual verification found [N] bugs. Context is low for a fix session.

I've written:
- docs/<feature-name>/bugs.md (bug details)
- docs/<feature-name>/handoff.md (session handoff)

Start a fresh session in the worktree and run:
/patch-party <feature-name>
```

---

## Integration

**Input:**
- Plan file with `**Type:** manual-verification` task (from go-time)

**Routes to:**
- `/land-it` - When all test cases pass (handles merge/PR + worktree cleanup)
- `/patch-party` - When bugs found (same session if context allows)
- Handoff file - When bugs found and context is low (next session runs patch-party)

**Invoked by:**
- `go-time` - After implementation completes
- User directly via `/trust-but-verify`
