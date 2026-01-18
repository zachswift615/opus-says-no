---
name: handoff
description: Create a comprehensive handoff document when ending a session with unresolved work, especially bugs or layout issues. Use when you can't figure something out and need to continue in a fresh context with complete precision.
---

<objective>
Create a comprehensive handoff document that captures all context from the current session, enabling a fresh Claude instance to pick up exactly where you left off with zero information loss. This is especially valuable for stubborn bugs or layout issues that resist multiple attempts.

The handoff document prioritizes deep documentation of unresolved issues - essentially a pre-written rubber-duck analysis that saves the next session significant discovery time.
</objective>

<when_to_use>
- Session ending with unresolved bugs or issues
- Hitting a wall on a layout or styling problem
- Multiple fix attempts haven't resolved the issue
- Complex investigation that needs fresh eyes
- User explicitly requests a handoff document
</when_to_use>

<quick_start>

<process>
1. **Audit the session**: Review the full conversation to identify all tasks, their status, and key context
2. **Deep-dive unresolved issues**: For each unfinished item, gather comprehensive diagnostic information
3. **Generate rubber-duck analysis**: For bugs, write the explanation that forces clarity
4. **Document learnings**: Capture insights that would take time to rediscover
5. **Write handoff document**: Create with unique filename (see naming convention below)
</process>

</quick_start>

<filename_convention>
Each handoff creates a new file in `docs/handoffs/` to maintain a trail:

**Location:** `docs/handoffs/`
**Format:** `YYYY-MM-DD-{feature-name}-handoff.md`

**Examples:**
- `docs/handoffs/2025-01-17-auth-flow-handoff.md`
- `docs/handoffs/2025-01-17-dashboard-layout-handoff.md`
- `docs/handoffs/2025-01-18-api-caching-handoff.md`

**Rules:**
- Create `docs/handoffs/` directory if it doesn't exist
- Use today's date in ISO format (YYYY-MM-DD)
- Derive feature name from the session's primary goal
- Use lowercase with hyphens, no spaces
- Keep feature name concise (2-4 words)
- Always end with `-handoff.md`
</filename_convention>

<document_structure>

Write to `YYYY-MM-DD-{feature-name}-handoff.md` using this format:

```xml
<session_summary>
<original_goal>
[What the user initially asked for - the primary objective]
</original_goal>

<tasks_handled>
| Task | Status | Notes |
|------|--------|-------|
| [Task 1] | Completed / Partial / Blocked | [Brief note] |
| [Task 2] | Completed / Partial / Blocked | [Brief note] |
</tasks_handled>
</session_summary>

<unresolved_issues>
<!-- For EACH unresolved bug or issue, create a full section -->

<issue id="1">
<bug_report>
**Expected behavior:** [What should happen]
**Actual behavior:** [What actually happens - be specific]
**Reproduction steps:**
1. [Step 1]
2. [Step 2]
3. [Observe: specific symptom]

**Error messages or symptoms:**
```
[Exact error text, console output, or visual description]
```
</bug_report>

<relevant_code>
<!-- Include the actual code, not summaries. Show enough to understand the problem. -->

**Primary location:** `path/to/file.ts:123`
```typescript
[The code where the issue manifests]
```

**Call sites / Related code:**
- `path/to/caller.ts:45` - [Why this is relevant]
- `path/to/related.ts:78` - [Why this is relevant]

```typescript
[Additional relevant code snippets]
```
</relevant_code>

<attempts_made>
<!-- Document EVERYTHING tried - this is the most diagnostic information -->

1. **[First approach]**
   - Rationale: [Why this seemed like it would work]
   - Changes made: [Specific code/config changes]
   - Result: [What happened - exact error or behavior]

2. **[Second approach]**
   - Rationale: [Why this seemed like it would work]
   - Changes made: [Specific code/config changes]
   - Result: [What happened - exact error or behavior]

3. **[Third approach]**
   - Rationale: [Why this seemed like it would work]
   - Changes made: [Specific code/config changes]
   - Result: [What happened - exact error or behavior]
</attempts_made>

<rubber_duck_analysis>
<!-- Force yourself to explain the problem clearly -->

**What we know for certain:**
- [Fact 1 with evidence]
- [Fact 2 with evidence]

**What we suspect but haven't confirmed:**
- [Suspicion 1 - why we suspect this]
- [Suspicion 2 - why we suspect this]

**Patterns in the failed attempts:**
- [What do the failures have in common?]
- [What approach HASN'T been tried?]

**Current hypothesis:**
[Your best guess based on evidence. "I suspect X because Y, but this doesn't explain Z"]

**What would prove/disprove this hypothesis:**
- To prove: [What we'd expect to see if true]
- To disprove: [What would contradict this]
</rubber_duck_analysis>

<next_steps_recommended>
<!-- What you would try if you had more time, and WHY -->

1. **[Next thing to try]**
   - Why: [Evidence/reasoning that suggests this]
   - How to test: [Specific steps]

2. **[Second thing to try]**
   - Why: [Evidence/reasoning that suggests this]
   - How to test: [Specific steps]

3. **[Third thing to try]**
   - Why: [Evidence/reasoning that suggests this]
   - How to test: [Specific steps]
</next_steps_recommended>

</issue>
</unresolved_issues>

<skills_and_workflows_used>
<!-- Which skills or debugging approaches were employed -->

| Skill/Workflow | How it was used | Outcome |
|---------------|-----------------|---------|
| [e.g., systematic-debugging] | [Brief description] | [What we learned] |
| [e.g., root-canal] | [Brief description] | [What we learned] |
</skills_and_workflows_used>

<session_learnings>
<!-- Critical discoveries that would take significant time to rediscover -->

<learning importance="high">
**Discovery:** [What was learned]
**How we discovered it:** [The path that led here]
**Why it matters:** [Impact on the problem or solution]
</learning>

<learning importance="medium">
**Discovery:** [What was learned]
**How we discovered it:** [The path that led here]
**Why it matters:** [Impact on the problem or solution]
</learning>

<!-- Include things like:
- Configuration quirks discovered
- Library behavior that wasn't obvious from docs
- Dead ends that looked promising
- Relationships between components that weren't apparent
- Environment-specific issues
- Timing or race condition observations
-->
</session_learnings>

<environment_context>
<!-- Technical context the next session needs -->

**Branch:** [current git branch]
**Key files modified:** [list of files with uncommitted changes]
**Temporary changes in place:** [any workarounds or debug code left in]
**Dependencies/versions that matter:** [relevant package versions if applicable]
</environment_context>
```

</document_structure>

<critical_rules>
- **Include actual code** - snippets, not summaries
- **Be specific about failures** - exact errors, not "it didn't work"
- **Document everything tried** - failed attempts are the most diagnostic
- **Explain your reasoning** - why you thought each approach would work
- **Don't summarize error messages** - copy them verbatim
- **Capture session learnings** - the next session shouldn't re-discover what you found
</critical_rules>

<success_criteria>
A complete handoff document enables:

- [ ] Someone can understand the original goal and current status in 30 seconds
- [ ] Unresolved bugs have full reproduction steps
- [ ] All relevant code is included (not referenced - included)
- [ ] Every attempted fix is documented with rationale and result
- [ ] Current hypothesis is stated with supporting evidence
- [ ] Next steps are prioritized with reasoning
- [ ] Session learnings capture non-obvious discoveries
</success_criteria>
