---
name: gh-review
description: Review a GitHub PR against a Jira ticket, design doc, or specification
arguments:
  - name: pr-url
    description: GitHub PR URL (e.g., https://github.com/owner/repo/pull/123)
    required: true
---

# GitHub PR Review

Review **{{pr-url}}** against provided requirements.

## Instructions

1. **Use the gh-review skill** to review this PR
2. **Ask user for specification** - Jira ticket, design doc, or requirements
3. **Fetch PR details** using `gh` CLI
4. **Review against all criteria:**
   - Specification compliance
   - Efficiency
   - Elegance
   - Idiomatic code
   - DRY
   - SOLID principles
   - Security (OWASP Top 10)
5. **Write review** to `pr-<number>-review.md`
6. **Organize feedback** by: Critical → Major → Minor → Nitpicks

## Output

Review written to markdown file. **Do not comment on the PR directly.**

Each issue includes:
- File and line reference
- Explanation of the problem
- Code suggestion for the fix
- **Ready-to-paste PR comment** (see format below)

## PR Comment Format

For each review item, include a `### PR Comment` section with a friendly, concise comment the user can paste directly on the PR. Format:

```markdown
### PR Comment
**Line:** `src/example.ts:42`

> Consider using optional chaining here to handle the null case more cleanly:
>
> ```ts
> const name = user?.profile?.name ?? 'Anonymous';
> ```
>
> This avoids the nested conditionals and makes the intent clearer.
```

Guidelines for PR comments:
- **Friendly tone** - suggest, don't demand ("Consider...", "You might want to...", "One option would be...")
- **Include code examples** - show the suggested fix, not just describe it
- **Keep it concise** - 2-4 sentences max plus code block
- **Specify the line** - include exact file:line for easy navigation
