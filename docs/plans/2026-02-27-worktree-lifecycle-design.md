# Worktree Lifecycle Integration + Trust-but-Verify

## Problem

The skill workflow (dream-first → story-time → blueprint → go-time → land-it) doesn't use git worktrees by default. Implementation happens on whatever branch the user is on, risking contamination of the main branch and making it harder to discard failed experiments. Additionally, there's no structured step where the user manually verifies the feature works before merging.

## Solution

Thread git worktrees through the execution phase and add a new trust-but-verify skill that walks users through manual test cases before landing.

## Design Decisions

- **Worktree created at go-time, not earlier.** Design and planning happen on main. Docs are committed before handoff so they're available when the worktree branches.
- **Manual verification is a plan requirement.** Blueprint and blueprint-maestro must produce a final "Manual Verification" task with step-by-step test cases. This becomes the source for trust-but-verify.
- **Trust-but-verify is mandatory between go-time and land-it.** No more going directly from execution to merge.
- **Verify-fix loop handled simply.** Trust-but-verify identifies bugs, patch-party fixes them with user confirmation per fix, then straight to land-it. No round-tripping back through trust-but-verify.

## Workflow

```
dream-first (main) → commit design.md
    ↓
story-time (main) → commit plan.md outline
    ↓
blueprint/blueprint-maestro (main) → commit detailed plan.md (with final Manual Verification task)
    ↓
go-time → create worktree → execute all tasks except manual verification → trust-but-verify
    ↓
trust-but-verify (worktree) → walk user through manual test cases
    ├── all pass → /land-it (merge/PR + cleanup worktree)
    ├── bugs + context available → write bugs.md → /patch-party → /land-it
    └── bugs + context low → write bugs.md + handoff → next session /patch-party → /land-it
```

## Changes Per Skill

### dream-first
- Add explicit step to commit `docs/<feature-name>/design.md` before handoff

### story-time
- Add explicit step to commit `docs/<feature-name>/plan.md` before handoff

### blueprint
- Add requirement: last task in plan must be `**Type:** manual-verification` with step-by-step test cases
- Add explicit step to commit plan before handoff

### blueprint-maestro
- Same manual verification requirement for the final batch
- Add explicit step to commit plan before handoff

### go-time
- Create worktree via `EnterWorktree` at start before dispatching implementers
- Skip the manual-verification task during execution (defer to trust-but-verify)
- Updated handoff: always → trust-but-verify (same session if ~30%+ context, handoff if not)
- No longer hands off directly to land-it or patch-party

### patch-party
- No structural changes. Handoff remains: fixes done → /land-it, design gap → /dream-first, bugs remain → handoff

### land-it
- No changes. Already handles worktree detection and cleanup.

## New Skill: trust-but-verify

### Purpose
Walk the user through manual test cases from the plan's verification task. Track pass/fail/blocked. Route to land-it (clean) or patch-party (bugs).

### Bootstrap
1. Read plan file path (from go-time handoff or session context)
2. Find the `**Type:** manual-verification` task
3. Extract test cases
4. Read design doc for additional intent context

### Phase 1: Present Test Cases
List all test cases as a numbered checklist with scenario name, setup, steps, expected outcome.

### Phase 2: Walk Through Each Test Case
One at a time. User responds:
- **Pass** — mark green, next
- **Fail** — capture bug details (actual vs expected), mark red, next
- **Blocked** — can't test due to dependency on failing test, mark yellow, next

### Phase 3: Results Summary
```
## Verification Results
- [PASS] Test 1: Description
- [FAIL] Test 3: Description
- [BLOCKED] Test 5: Description

Passed: X/N | Failed: Y/N | Blocked: Z/N
```

### Phase 4: Route Based on Results

**All pass:** "Verification complete." → `/land-it`

**Failures found + context available (~40%+ remaining):**
- Write `docs/<feature-name>/bugs.md` in patch-party format
- Invoke `/patch-party` in same session

**Failures found + context low:**
- Write `docs/<feature-name>/bugs.md`
- Write `docs/<feature-name>/handoff.md` with explicit instruction to invoke `/patch-party`
- Tell user to start fresh session with the handoff

### bugs.md Format
```markdown
# Bugs - <feature-name>

## Source
Discovered during manual verification (trust-but-verify)

## Remaining
- [ ] [Test case name]: [Actual vs expected]
  - Reproduction: [Steps]
  - Severity: [critical/major/minor]
  - Related test cases: [blocked tests that depend on this]
```

### Handoff Format
```markdown
# Handoff - <feature-name>

## Status
Implementation complete. Manual verification revealed bugs.

## Resume Instructions
Invoke `/patch-party` to fix the following bugs.

## Context
- **Worktree branch:** <branch-name>
- **Plan file:** docs/<feature-name>/plan.md
- **Bugs file:** docs/<feature-name>/bugs.md
- **Design doc:** docs/<feature-name>/design.md
- **Failed tests:** <count>
- **Blocked tests:** <count>
```
