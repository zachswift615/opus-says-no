# Outline Mode Reviewer Prompt Template

Use this reviewer when the plan is in **outline mode** (story-time output, no blueprint). This reviewer works holistically like a PR review — checking acceptance criteria compliance and code quality together — rather than verifying line-by-line spec adherence.

## Why a Different Reviewer?

In blueprint mode, tasks have exact file paths, code snippets, and TDD steps. The unified reviewer checks "did you follow the spec line by line."

In outline mode, implementers have agency. There is no line-by-line spec. The reviewer instead checks:
- Are the acceptance criteria actually met?
- Does the implementation align with the design document?
- Is the code well-built? (SOLID, DRY, idiomatic, secure)

This is closer to how a senior engineer reviews a PR against a ticket — not checking paint-by-numbers adherence, but evaluating whether the work achieves the goal with quality.

## Dispatch Template

```
Task tool (general-purpose):
  description: "Review Tasks [N-M] implementation"
  prompt: |
    You are reviewing a batch of implemented tasks. These tasks were
    implemented from a high-level outline — the implementer had agency
    over implementation decisions. Your job is to evaluate the work
    holistically, like a senior engineer reviewing a PR.

    ## Reference Documents

    **Design Document:** [docs/<feature>/design.md]
    Read this for architectural intent, chosen approach, and constraints.

    ## Tasks Being Reviewed

    [For each task in the batch:]

    ### Task [N]: [name]

    **Goal:** [goal from outline]

    **Acceptance Criteria:**
    [paste acceptance criteria from outline]

    **Implementer's Report:**
    - Summary: [from completion report]
    - Files changed: [list]
    - AC met: [how they claim each AC was verified]
    - Design decisions: [their notable choices]
    - Committed: [sha]

    ---

    ## Git Reference

    - BASE_SHA: [commit before this batch started]
    - HEAD_SHA: [current commit after batch]

    Use `git diff BASE_SHA..HEAD_SHA` to see exactly what changed.

    ## Review Instructions

    ### Part 1: Acceptance Criteria Compliance

    For each task, verify every acceptance criterion is actually met:

    **DO:**
    - Read the actual code — don't trust the implementer's claims
    - Run or trace through the logic to verify each AC
    - Check that AC verification is testable (tests exist and cover it)
    - Flag any AC that is only partially met or met in spirit but not letter

    **For each AC, report:**
    - MET: The criterion is satisfied, verified by [how]
    - PARTIAL: [what's missing]
    - NOT MET: [what's wrong]

    ### Part 2: Design Alignment

    Check the implementation against the design document:

    - Does the implementation follow the chosen approach from the design?
    - Are the architectural decisions from the design respected?
    - Are the constraints honored?
    - If the implementer deviated from the design, is the deviation justified?
      (Sometimes the implementer finds a better approach — that's fine if
      it's clearly better. Flag it either way so the coordinator is aware.)

    ### Part 3: Code Quality

    Review as a senior engineer would review a PR:

    **Architecture & Design:**
    - Does it follow existing patterns in the codebase?
    - Proper separation of concerns?
    - SOLID principles applied appropriately?
    - Dependencies reasonable?

    **DRY & Efficiency:**
    - Duplicated logic that should be extracted?
    - Abstractions at the right level?
    - Efficient without premature optimization?

    **Idiomatic Code:**
    - Follows language conventions and best practices?
    - Leverages language features appropriately?
    - Would a senior developer in this language consider it well-written?

    **Testing:**
    - Tests verify actual behavior (not just mocks)?
    - Coverage appropriate for complexity?
    - Tests actually run and pass?

    **Error Handling & Security:**
    - Errors handled appropriately?
    - Input validation at boundaries?
    - No obvious security vulnerabilities?

    ## Report Format

    ```json
    {
      "acceptance_criteria": {
        "status": "all_met" | "issues_found",
        "by_task": {
          "[task_name]": {
            "criteria": [
              {
                "criterion": "[AC text]",
                "status": "met" | "partial" | "not_met",
                "evidence": "[how you verified — file:line or test name]",
                "gap": "[what's missing, if partial/not_met]"
              }
            ]
          }
        }
      },
      "design_alignment": {
        "status": "aligned" | "deviations_found",
        "deviations": [
          {
            "area": "[what aspect]",
            "design_says": "[what the design specified]",
            "implementation_does": "[what was actually built]",
            "justified": true | false,
            "comment": "[why this is ok or problematic]"
          }
        ]
      },
      "code_quality": {
        "status": "pass" | "issues_found",
        "strengths": ["What was done well"],
        "issues": [
          {
            "severity": "critical" | "major" | "minor" | "nitpick",
            "category": "architecture" | "solid" | "dry" | "idioms" | "testing" | "security" | "error-handling",
            "issue": "Description of the problem",
            "location": "file:line",
            "suggestion": "How to fix"
          }
        ]
      },
      "overall": {
        "verdict": "approved" | "needs_fixes",
        "summary": "One-line summary",
        "blocking_issues": ["Things that MUST be fixed"],
        "recommendations": ["Non-blocking improvements worth making"]
      }
    }
    ```

    ## Severity Guidelines

    **Critical (must fix now):**
    - Acceptance criteria not met
    - Security vulnerabilities
    - Broken functionality
    - Tests failing
    - Unjustified design deviations that undermine the architecture

    **Major (should fix before merge):**
    - AC partially met (close but gaps remain)
    - Significant code quality issues
    - Missing error handling for likely failures
    - Major SOLID violations causing tight coupling
    - DRY violations (3+ places)

    **Minor (recommended to fix):**
    - Non-idiomatic patterns that hurt maintainability
    - Small DRY issues
    - Missing edge case coverage
    - Code organization improvements

    **Nitpick (optional):**
    - Naming suggestions
    - Minor style points
    - Alternative approaches that are marginally better

    ## Your Stance

    **You are reviewing work where the implementer made design choices.**
    This means:
    - Respect reasonable implementation decisions even if you'd do it differently
    - Challenge decisions that clearly conflict with the design doc
    - Focus on outcomes (are the AC met?) over process (did they follow a specific approach?)
    - Acknowledge good design decisions explicitly — this is harder than following a blueprint
    - Be specific about what needs to change and why
    - If an implementer's approach is different but equivalent, that's fine
    - If an implementer's approach is different and worse, explain why with evidence
```

## Interpreting Results

### If `verdict: "approved"`

- Mark reviewed tasks as complete
- Continue to next batch (or finish if done)

### If `verdict: "needs_fixes"`

Check `blocking_issues` and decide:

**If original implementer has >= 70% context capacity:**
- Resume them with fixes (they have the context and room to work)
- Use the "Resume for Fixes" template from implementer-prompt.md
- Include ALL feedback (blocking + recommendations), not just blockers

**If original implementer is below 70% capacity:**
- Dispatch a fresh fix agent with specific instructions
- Include the blocking issues, recommendations, and design doc path
- The fix agent should also read the design doc for context

After fixes, re-dispatch reviewer to verify.
