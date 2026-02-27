---
name: trust-but-verify
description: Walk through manual test cases to verify a feature works as intended
arguments:
  - name: plan-path
    description: Path to plan file (e.g., docs/user-auth/plan.md)
    required: false
---

# Trust but Verify

Walk through manual verification of the feature.

**Plan file:** `{{plan-path}}`

## Instructions

1. **Invoke trust-but-verify skill**
2. **Follow the workflow:**
   - Find the manual-verification task in the plan
   - Present test cases to the user
   - Walk through each test case one at a time
   - Collect pass/fail/blocked results
   - Route to /land-it (all pass) or /patch-party (bugs found)

## Context

This should be run in a worktree created by go-time after implementation is complete. If no plan-path is provided, look for the most recent plan file in the docs/ directory.
