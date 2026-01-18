---
description: Create a comprehensive handoff document for continuing work in a fresh context
argument-hint: []
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

<objective>
Create a comprehensive handoff document that captures all session context, enabling a fresh Claude instance to continue exactly where you left off.

This is especially valuable for stubborn bugs or layout issues that resist multiple fix attempts.
</objective>

<process>
1. Use the Skill tool to invoke the `handoff` skill
2. Follow the skill's document structure precisely
3. Write to `YYYY-MM-DD-{feature-name}-handoff.md` (unique file each time)
</process>

<critical_emphasis>
For unresolved bugs, go DEEP:
- Include actual code snippets, not references
- Document every fix attempt with rationale and exact result
- Write a rubber-duck analysis that forces clarity
- Capture what you'd try next and why
- Note session learnings that would take time to rediscover
</critical_emphasis>

<success_criteria>
- Full session context captured
- Unresolved issues have complete diagnostic information
- Next session can start immediately without re-discovery
</success_criteria>
