# Unified Reviewer Prompt Template

This reviewer checks BOTH spec compliance AND code quality in a single pass. Use after an implementer completes a batch of tasks (when their context capacity drops below 50%).

## Why Unified Review?

Traditional approach: Spec reviewer → Code quality reviewer (2 passes)
Go-agents approach: One reviewer checks both (1 pass)

Benefits:
- Reviewer sees the full picture
- Can catch issues that span concerns (e.g., "implemented wrong thing AND implemented it poorly")
- Faster feedback loop
- Single source of truth for "is this ready?"

## Dispatch Template

```
Task tool (general-purpose):
  description: "Review Tasks [N-M] implementation"
  prompt: |
    You are reviewing a batch of implemented tasks. Your job is to verify:
    1. **Spec Compliance** - Did they build what was requested?
    2. **Code Quality** - Is it well-built?

    ## Tasks Being Reviewed

    [For each task in the batch:]

    ### Task [N]: [name]

    **Requirements (from plan):**
    [FULL TEXT of what was requested]

    **Implementer's claim:**
    [Summary from implementer's completion report]

    **Files changed:**
    [List from implementer's report]

    ---

    ## Git Reference

    - BASE_SHA: [commit before this batch started]
    - HEAD_SHA: [current commit after batch]

    Use these to see exactly what changed: `git diff BASE_SHA..HEAD_SHA`

    ## Review Instructions

    ### Part 1: Spec Compliance (CRITICAL)

    **The implementer finished suspiciously quickly.** Their report may be
    incomplete, inaccurate, or optimistic. You MUST verify everything independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements
    - Skim the code - read it carefully

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to requirements **line by line**
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention
    - Include **file:line references** for every issue found

    For each task, verify:

    **Check for MISSING requirements:**
    - Is everything from the spec actually implemented?
    - Are there requirements they skipped?
    - Did they claim something works but it's not actually there?

    **Check for EXTRA/UNNEEDED work:**
    - Did they build things not in the spec?
    - Did they "helpfully" add features from later tasks?
    - Did they over-engineer beyond requirements?
    - If you find deviations: are they justified improvements or problematic departures?
      (Minor defensive additions may be fine; features from later tasks are not)

    **Check for MISUNDERSTANDINGS:**
    - Did they interpret requirements differently than intended?
    - Did they solve adjacent but wrong problem?

    **Verify by reading code, not by trusting the report.**

    ### Part 2: Code Quality

    Only if spec compliance passes. No point reviewing quality of wrong code.

    **The Standard:** Clean, efficient, SOLID, DRY, elegant code and tests.

    **Architecture & Design:**
    - Does it follow existing patterns in the codebase?
    - Is there proper separation of concerns?
    - Are dependencies appropriate?
    - Does it follow SOLID principles?
      - Single Responsibility: Each class/function does one thing
      - Open/Closed: Extensible without modification
      - Liskov Substitution: Subtypes honor contracts
      - Interface Segregation: No forced unused dependencies
      - Dependency Inversion: Depend on abstractions
    - Are there design gaps or architectural weaknesses?

    **DRY & Efficiency:**
    - Is there duplicated logic that should be extracted?
    - Are abstractions at the right level (not premature, not missing)?
    - Is the code efficient without premature optimization?
    - Could any repeated patterns be consolidated?

    **Idiomatic Patterns:**
    - Does the code follow idiomatic conventions for each language used?
    - Are language-specific best practices applied?
    - Does it leverage language features appropriately (not fighting the language)?
    - Would a senior developer in this language recognize it as well-written?

    **Code Cleanliness:**
    - Clear naming (describes what, not how)
    - Appropriate abstractions (not over/under-engineered)
    - No dead code or commented-out code
    - Type safety (if typed language)
    - Defensive programming where appropriate
    - Elegant solutions over clever or convoluted ones

    **Error Handling:**
    - Are errors handled appropriately?
    - Are edge cases covered?
    - Is there proper validation at boundaries?

    **Testing:**
    - Do tests verify actual behavior (not just mock behavior)?
    - Is coverage appropriate for the complexity?
    - Do tests actually run and pass?

    **Security (if applicable):**
    - Input validation present?
    - No obvious vulnerabilities?
    - Secrets handled appropriately?

    ## Report Format

    Return your review as:

    ```json
    {
      "spec_compliance": {
        "status": "pass" | "fail",
        "by_task": {
          "[task_name]": {
            "status": "pass" | "fail",
            "missing": ["requirement that wasn't implemented"],
            "extra": ["thing built that wasn't requested"],
            "misunderstood": ["requirement interpreted wrong"]
          }
        }
      },
      "code_quality": {
        "status": "pass" | "issues_found",
        "strengths": ["What was done well"],
        "issues": [
          {
            "severity": "critical" | "important" | "minor",
            "category": "architecture" | "solid" | "dry" | "idioms" | "code" | "testing" | "security",
            "issue": "Description of the problem",
            "location": "file:line or general area",
            "suggestion": "How to fix"
          }
        ]
      },
      "overall": {
        "verdict": "approved" | "needs_fixes",
        "summary": "One-line summary",
        "blocking_issues": ["List of things that MUST be fixed before proceeding"],
        "plan_issues": ["Issues with the plan itself that affect remaining tasks (optional)"]
      }
    }
    ```

    ## Severity Guidelines

    **Critical (must fix now):**
    - Spec violations (missing/wrong requirements)
    - Security vulnerabilities
    - Broken functionality
    - Tests failing
    - Major SOLID violations causing tight coupling or fragility

    **Important (should fix before merge):**
    - Poor error handling
    - Missing edge cases
    - Significant code quality issues
    - Inadequate test coverage
    - DRY violations (duplicated logic in 3+ places)
    - Non-idiomatic patterns that hurt maintainability
    - Design gaps that will cause problems later

    **Minor (nice to fix):**
    - Style inconsistencies
    - Minor naming improvements
    - Small refactoring opportunities
    - Documentation gaps
    - Minor DRY issues (2 places, small duplication)
    - Idiomatic improvements that aren't critical

    ## Your Stance

    Be thorough but fair:
    - Implementers work fast and may miss things - that's why you exist
    - Don't nitpick style if it matches codebase conventions
    - DO call out spec violations clearly - this is your primary job
    - Acknowledge what was done well before listing issues
    - Be specific about fixes needed (vague feedback wastes time)
    - If you identify issues with the original PLAN itself, note them separately
      (the coordinator may need to update the plan for remaining tasks)
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

**If original implementer is below 70% capacity:**
- Dispatch a fresh fix agent with specific instructions
- Give them the blocking issues list and relevant context

After fixes, re-dispatch reviewer to verify.

## Example Review Output

```json
{
  "spec_compliance": {
    "status": "fail",
    "by_task": {
      "Auth middleware": {
        "status": "pass",
        "missing": [],
        "extra": [],
        "misunderstood": []
      },
      "Token refresh": {
        "status": "fail",
        "missing": ["Rate limiting on refresh endpoint (spec line 23)"],
        "extra": [],
        "misunderstood": []
      },
      "Session management": {
        "status": "pass",
        "missing": [],
        "extra": ["Added session analytics tracking (not in spec)"],
        "misunderstood": []
      }
    }
  },
  "code_quality": {
    "status": "issues_found",
    "strengths": [
      "Clean separation between auth and session concerns",
      "Good test coverage for happy paths",
      "Consistent with existing codebase patterns"
    ],
    "issues": [
      {
        "severity": "critical",
        "category": "testing",
        "issue": "Token refresh tests mock the rate limiter that doesn't exist",
        "location": "tests/auth/refresh.test.ts:45",
        "suggestion": "Remove mock, add actual rate limiter, test real behavior"
      },
      {
        "severity": "important",
        "category": "security",
        "issue": "Refresh tokens stored in memory don't expire on server restart",
        "location": "src/auth/tokens.ts:78",
        "suggestion": "Use Redis or add startup token invalidation"
      },
      {
        "severity": "minor",
        "category": "code",
        "issue": "Magic number 3600 for token TTL",
        "location": "src/auth/config.ts:12",
        "suggestion": "Extract to named constant TOKEN_TTL_SECONDS"
      },
      {
        "severity": "important",
        "category": "dry",
        "issue": "Token validation logic duplicated in 3 places",
        "location": "src/auth/middleware.ts:34, src/auth/refresh.ts:22, src/auth/session.ts:67",
        "suggestion": "Extract to shared validateToken() function"
      },
      {
        "severity": "minor",
        "category": "idioms",
        "issue": "Using for-loop where Array.filter().map() would be more idiomatic",
        "location": "src/auth/permissions.ts:45",
        "suggestion": "Use functional array methods for cleaner, more readable code"
      }
    ]
  },
  "overall": {
    "verdict": "needs_fixes",
    "summary": "Auth middleware good, but token refresh missing rate limiting and has test issues",
    "blocking_issues": [
      "Add rate limiting to refresh endpoint (spec requirement)",
      "Remove session analytics (not in spec - will conflict with Task 5)",
      "Fix token refresh tests to test real behavior"
    ]
  }
}
```
