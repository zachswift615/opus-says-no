---
name: gh-review
description: Review a GitHub PR against a Jira ticket, design doc, or specification. Checks for spec compliance, efficiency, elegance, idiomatic code, DRY, SOLID principles, and security. Outputs detailed review to markdown file.
---

# GitHub PR Review

## Overview

Review a GitHub Pull Request against provided requirements (Jira ticket, design doc, or specification). Uses the `gh` CLI to fetch PR details and produces a comprehensive review organized by severity.

**Core principle:** Verify implementation matches spec → Check code quality → Identify issues by severity → Write detailed review.

**Announce at start:** "I'm using the gh-review skill to review this PR against the provided specification."

## Invocation

```
/gh-review <pr-url>
```

The user will paste the Jira ticket, design doc, or specification details after invocation.

## The Process

### Step 1: Gather Inputs

**Required:**
- PR URL (from command argument)
- Specification/requirements (user will paste)

**Ask if not provided:**
```
Please paste the Jira ticket, design doc, or specification that this PR should implement.
```

### Step 2: Fetch PR Details

Use `gh` CLI to gather comprehensive PR information:

```bash
# Get PR metadata
gh pr view <pr-number> --repo <owner/repo> --json title,body,author,baseRefName,headRefName,additions,deletions,changedFiles

# Get list of changed files
gh pr diff <pr-number> --repo <owner/repo> --name-only

# Get full diff
gh pr diff <pr-number> --repo <owner/repo>

# Get PR comments/conversation (for context)
gh pr view <pr-number> --repo <owner/repo> --json comments,reviews
```

**Parse the PR URL to extract owner/repo and PR number:**
- `https://github.com/owner/repo/pull/123` → owner/repo, 123
- `owner/repo#123` → owner/repo, 123

### Step 3: Analyze Changed Files

For each changed file, read and understand:
- What the file does in the broader codebase
- What changes were made
- How changes relate to the specification

**Group files by type:**
- Source code (review for all criteria)
- Tests (review for coverage and correctness)
- Config/infrastructure (review for security and correctness)
- Documentation (review for accuracy)

### Step 4: Review Against Criteria

#### 4.1 Specification Compliance

**Check:**
- Does the implementation fulfill ALL requirements in the spec?
- Are there any requirements that were missed?
- Are there any changes that go beyond the spec (scope creep)?
- Does the behavior match what the spec describes?

**Document:**
- Each requirement and whether it's satisfied
- Any gaps between spec and implementation
- Any additions not in the spec

#### 4.2 Code Efficiency

**Check:**
- Algorithm complexity (time and space)
- Unnecessary iterations or redundant operations
- Database query efficiency (N+1 problems, missing indexes)
- Memory usage patterns
- Caching opportunities missed
- Premature optimization (over-engineering simple cases)

#### 4.3 Code Elegance

**Check:**
- Readability and clarity
- Appropriate naming (variables, functions, classes)
- Function/method length (too long = hard to understand)
- Nesting depth (deeply nested = hard to follow)
- Control flow clarity
- Appropriate use of language features

#### 4.4 Idiomatic Code

**Check for language-specific idioms:**

**JavaScript/TypeScript:**
- Proper use of async/await vs promises
- Destructuring where appropriate
- Optional chaining and nullish coalescing
- Type safety (TypeScript)

**Python:**
- List comprehensions vs loops
- Context managers (with statements)
- Pythonic naming (snake_case)
- Type hints

**Go:**
- Error handling patterns
- Interface usage
- Goroutine/channel patterns
- Naming conventions (mixedCaps)

**Rust:**
- Ownership and borrowing
- Result/Option handling
- Iterator usage
- Lifetime annotations

**Java:**
- Stream API usage
- Optional handling
- Builder patterns where appropriate

*Adapt checks to the languages present in the PR.*

#### 4.5 DRY (Don't Repeat Yourself)

**Check:**
- Duplicated code blocks
- Similar logic that could be abstracted
- Copy-pasted code with minor variations
- Repeated magic numbers/strings (should be constants)
- Similar error handling that could be centralized

#### 4.6 SOLID Principles

**S - Single Responsibility:**
- Does each class/module have one reason to change?
- Are functions doing too many things?

**O - Open/Closed:**
- Is the code open for extension, closed for modification?
- Would adding features require modifying existing code?

**L - Liskov Substitution:**
- Can subtypes be substituted for their base types?
- Do overridden methods honor the contract?

**I - Interface Segregation:**
- Are interfaces focused and minimal?
- Are clients forced to depend on methods they don't use?

**D - Dependency Inversion:**
- Do high-level modules depend on abstractions?
- Are dependencies injected rather than created internally?

#### 4.7 Security

**Check for OWASP Top 10 and common vulnerabilities:**

- **Injection:** SQL injection, command injection, XSS
- **Broken Authentication:** Weak session handling, credential exposure
- **Sensitive Data Exposure:** Logging secrets, unencrypted data
- **XML External Entities:** XXE vulnerabilities
- **Broken Access Control:** Missing authorization checks
- **Security Misconfiguration:** Debug mode, default credentials
- **Cross-Site Scripting (XSS):** Unsanitized user input in output
- **Insecure Deserialization:** Untrusted data deserialization
- **Using Components with Known Vulnerabilities:** Outdated dependencies
- **Insufficient Logging:** Missing audit trails for sensitive operations

**Additional checks:**
- Secrets/credentials in code
- Hardcoded sensitive values
- Missing input validation
- Race conditions
- Path traversal vulnerabilities

### Step 5: Categorize Findings

Organize all findings into severity categories:

#### Critical
Issues that **must be fixed** before merge:
- Security vulnerabilities
- Data loss risks
- Specification requirements not met
- Breaking changes to public APIs
- Production-breaking bugs

#### Major
Issues that **should be fixed** before merge:
- Significant performance problems
- SOLID principle violations that will cause maintenance issues
- Missing error handling for likely failure cases
- Incomplete implementation of spec requirements

#### Minor
Issues that are **recommended to fix**:
- DRY violations (duplicated code)
- Non-idiomatic code patterns
- Suboptimal but working implementations
- Missing edge case handling for unlikely scenarios
- Code organization improvements

#### Nitpicks
**Optional improvements** (nice-to-have):
- Naming suggestions
- Minor style inconsistencies
- Documentation improvements
- Alternative approaches that are marginally better

### Step 6: Write Review Document

Create a markdown file with the review:

**File naming:** `pr-<number>-review.md` in the current directory.

**Structure:**

```markdown
# PR Review: <PR Title>

**PR:** <pr-url>
**Author:** <author>
**Branch:** <head> → <base>
**Files Changed:** <count> (+<additions>, -<deletions>)
**Reviewed:** <date>

## Specification Summary

<Brief summary of what the spec/ticket requires>

## Specification Compliance

| Requirement | Status | Notes |
|-------------|--------|-------|
| <requirement 1> | ✅ Met / ⚠️ Partial / ❌ Missing | <notes> |
| ... | ... | ... |

## Critical Issues

<If none: "No critical issues found.">

### <Issue Title>

**File:** `path/to/file.ext` (lines X-Y)
**Category:** Security / Spec Compliance / Data Integrity / etc.

**Problem:**
<Detailed explanation of what's wrong and why it matters>

**Current Code:**
```<language>
<problematic code snippet>
```

**Suggested Fix:**
```<language>
<corrected code snippet>
```

**Why This Matters:**
<Explanation of the risk/impact>

---

## Major Issues

<Same format as Critical>

---

## Minor Issues

<Same format, can be more concise>

---

## Nitpicks

<Brief list format is acceptable>

- **file.ext:123** - Consider renaming `x` to `userCount` for clarity
- **file.ext:456** - Could use optional chaining here: `obj?.prop`

---

## Summary

**Recommendation:** ✅ Approve / ⚠️ Approve with Comments / 🔄 Request Changes / ❌ Reject

<Brief summary of overall assessment>

### Strengths
- <What the PR does well>

### Areas for Improvement
- <Key areas to focus on>
```

### Step 7: Present Review

After writing the review file:

```
Review complete. Written to: pr-<number>-review.md

Summary:
- Critical: <count>
- Major: <count>
- Minor: <count>
- Nitpicks: <count>

Recommendation: <recommendation>

Would you like me to:
1. Walk through any specific issues in detail?
2. Suggest how to address the critical/major issues?
3. Check anything else about this PR?
```

## Important Notes

**DO NOT comment on the PR directly.** All feedback goes to the markdown file only.

**Be constructive.** Every issue should include:
- What's wrong
- Why it matters
- How to fix it

**Be specific.** Reference exact file paths and line numbers.

**Be fair.** Acknowledge what the PR does well, not just problems.

**Respect context.** Consider project conventions and constraints.

## Red Flags

**Never:**
- Post comments directly on the PR
- Approve/reject the PR via gh CLI
- Make assumptions about spec requirements not provided
- Nitpick style issues covered by linters/formatters

**Always:**
- Get the full specification before reviewing
- Check ALL changed files, not just a sample
- Provide actionable suggestions for issues found
- Categorize by severity (not everything is critical)
- Write the review to a file

## Example Usage

```
User: /gh-review https://github.com/acme/webapp/pull/456

Agent: I'm using the gh-review skill to review this PR against the provided specification.

Please paste the Jira ticket, design doc, or specification that this PR should implement.

User: JIRA-123: Add user export feature
- Users can export their data as JSON or CSV
- Export must include: profile, posts, comments
- Rate limit: 1 export per hour per user
- Must log export requests for audit

Agent: [Fetches PR, analyzes code, writes review]

Review complete. Written to: pr-456-review.md
...
```

## Integration

**Standalone skill** - not part of the main development workflow.

**Pairs with:**
- Any PR review workflow
- Code quality gates
