---
name: fix-feature-bugs
description: Use after plan execution when bugs remain. Bootstraps from feature docs, triages bugs, dispatches fix subagents with full context, and handles escalation to rubber-duck or design review.
---

# Fix Feature Bugs

## Overview

Post-implementation bugs share context. Starting fresh without that context wastes the first hour rediscovering what you already knew.

**Core principle:** Bootstrap fast, triage smart, dispatch with everything the subagent needs.

```
CONTEXT IS EXPENSIVE. TRANSFER IT, DON'T REBUILD IT.
```

## When to Use

**Use fix-feature-bugs when:**
- Implementation plan execution completed but bugs remain
- Starting fresh session to address known bugs
- User provides bug list for a feature with existing docs

**Prefer fresh session with this skill over improvising when:**
- Execution orchestrator's context is > 50% used
- Bugs are non-trivial
- You want consistent escalation behavior

**Don't use when:**
- No feature docs exist (create them first or use ad-hoc debugging)
- Single trivial bug (just fix it directly)
- Bug reveals fundamental design flaw (go to brainstorm-to-design)

## The Process

```
1. Bootstrap
   └─ Read design.md fully (architecture, decisions)
   └─ Read bugs.md fully (what's broken, what's been tried)
   └─ Search plan.md for relevant sections (plans can be 4k+ lines)
       └─ Read full sections only when needed

2. Triage
   └─ Categorize bugs (simple / complex / uncertain)
   └─ Group related bugs together
   └─ Gather relevant code sites for each bug/group
   └─ Detect design gaps → escalate to brainstorm-to-design

3. Dispatch
   └─ Subagent per bug group (related bugs together)
   └─ Each subagent gets: bug description, relevant code, acceptance criteria
   └─ Subagents follow escalation ladder (direct → rubber-duck → systematic)

4. Handle Returns
   └─ Subagent fixed it → update bugs.md, verify fix
   └─ Subagent hit rubber-duck → returns with prompt, awaits consultation
       └─ Main agent decides: external LLM or Opus consultation
       └─ After consultation: resume same subagent OR spawn fresh (judgment call)
   └─ Subagent escalated to systematic-debugging → let it complete

5. Collect
   └─ Update bugs.md (fixed, remaining, new discoveries)
   └─ Verify all fixes (run tests, check behavior)
```

## Phase 1: Bootstrap

### Locate Feature Docs

```
docs/<feature-name>/
├── design.md      # Architecture, decisions, trade-offs
├── plan.md        # Tasks, code locations, integration points
└── bugs.md        # Found, fixed, remaining, discoveries
```

### Read Strategy

**Read fully:**
- `design.md` - You need the full architecture context
- `bugs.md` - You need to know what's broken and what's been tried

**Search then read:**
- `plan.md` - Often 4k+ lines. Search for relevant task sections.
  - Search for keywords from bug descriptions
  - Read full sections for related tasks
  - Don't load the entire plan unless necessary

### If docs don't exist

Ask user:
```
I don't see feature docs at docs/<feature-name>/.

Options:
1. Point me to existing docs elsewhere
2. Provide a brief summary of the feature design
3. I'll work without full context (not recommended for complex bugs)
```

## Phase 2: Triage

### Categorize Each Bug

| Category | Criteria | Approach |
|----------|----------|----------|
| **Simple** | Clear cause, localized fix | Direct fix attempt |
| **Complex** | Multiple files, unclear cause | Gather more context first |
| **Uncertain** | Don't understand the bug yet | Investigate before dispatching |
| **Design Gap** | Requires new concept/architecture | Escalate to brainstorm |

### Group Related Bugs

Bugs are related if they:
- Touch the same files
- Involve the same feature component
- Might share root cause
- Would conflict if fixed in parallel

**Group together → one subagent. Unrelated → separate subagents (can run in sequence).**

### Gather Code Sites

For each bug/group, identify:
- Files likely involved (from error messages, plan.md, design.md)
- Specific functions or components
- Test files that cover this area
- Related code that might be affected

**Include snippets in the dispatch prompt.** Don't make subagents search for context you already found.

### Detect Design Gaps

**Flag as design gap when ANY of:**
- Fix requires adding a concept/flow not in original design
- Same root cause behind 2+ bugs (pattern = missing consideration)
- Can't fix without architectural changes

**If design gap detected:**
```
This bug appears to be a design gap, not an implementation bug.

Evidence:
- [Why this indicates missing design]

Recommend escalating to brainstorm-to-design to address:
- [What needs to be designed]

Proceed with design review, or attempt fix anyway?
```

## Phase 3: Dispatch

### Create Context Packet

For each bug/group, prepare:

```markdown
## Bug Description
[What's broken - expected vs actual]

## Relevant Code
[File snippets - enough to understand, not entire files]

## From the Design
[Relevant architecture context from design.md]

## Acceptance Criteria
- [ ] [Specific condition that means "fixed"]
- [ ] Tests pass
- [ ] No regressions introduced

## Escalation Rules
- After 2 failed fix attempts → use rubber-duck skill
- If uncertain at any point → use rubber-duck skill
- If this reveals a design gap → report back, don't force a fix
```

### Dispatch Subagent

Use Task tool with `@bug-fixer-prompt.md`:

```
Task tool (general-purpose):
  description: "Fix: [bug summary]"
  prompt: |
    [Load from ./bug-fixer-prompt.md]

    [Context packet from above]
```

### Dispatch Rules

- **One subagent per bug group** (related bugs together)
- **Sequential, not parallel** (fixes may conflict)
- **Full context in prompt** (don't make them search)

## Phase 4: Handle Returns

### Subagent Fixed It

```
1. Verify fix (run tests, check behavior)
2. Update bugs.md:
   - Move from "Remaining" to "Fixed"
   - Document root cause and fix
   - Note commit hash
3. Continue to next bug group
```

### Subagent Hit Rubber-Duck

Subagent returns with:
```json
{
  "status": "needs_consultation",
  "rubber_duck_prompt": "[Full prompt they wrote]",
  "attempts_so_far": 2
}
```

**Your decision:**
1. **External LLM** - Output prompt for user to paste elsewhere
2. **Opus consultation** - Spawn consultation agent
3. **User insight** - User might know the answer

After consultation:
- **Resume subagent** if they have context capacity
- **Spawn fresh** if subagent exhausted or consultation changed approach significantly

### Subagent Reports Design Gap

```
1. Acknowledge the finding
2. Document in bugs.md under "Discovered During Fixes"
3. Ask user: Address now (→ brainstorm) or defer?
4. Continue with remaining bugs if deferring
```

### Subagent Escalates to Systematic Debugging

Let them complete the full 4-phase investigation. This might take a while but will find the root cause.

## Phase 5: Collect

### Update bugs.md

```markdown
# Bugs: <feature-name>

## Fixed
- [x] [Bug description] (commit: abc123)
  - Root cause: [What was wrong]
  - Fix: [What was changed]

## Remaining
- [ ] [Bug description]
  - Attempts: [What was tried]
  - Status: investigating / blocked / needs-design-review

## Discovered During Fixes
- [ ] [New issue found while fixing]
```

### Verify All Fixes

```
1. Run full test suite
2. Manually verify each fixed bug
3. Check for regressions
4. Update bugs.md status
```

### Report Summary

```
Fix session complete.

Fixed: N bugs
Remaining: M bugs
Discovered: K new issues
Design gaps identified: L (deferred/addressed)

Updated: docs/<feature>/bugs.md

Next steps:
- [If remaining bugs: continue fixing]
- [If design gaps: brainstorm-to-design]
- [If all clear: finishing-a-development-branch]
```

## The Escalation Ladder

```
Direct Fix (subagent attempts)
     │
     ▼ (2 fails OR uncertainty)
Rubber-Duck (write explanation prompt)
     │
     ├─► Self-resolved → apply fix → done
     │
     ▼ (still stuck)
Consultation (external LLM or Opus agent)
     │
     ├─► Resolved → apply fix → done
     │
     ▼ (still stuck)
Systematic Debugging (full 4-phase)
     │
     ├─► Root cause found → fix → done
     │
     ▼ (reveals architectural issue)
Brainstorm-to-Design (design gap)
```

## Red Flags

| Behavior | Reality |
|----------|---------|
| Skipping bootstrap | You'll waste time rediscovering context |
| Dispatching without code snippets | Subagent wastes time searching |
| Parallel fix subagents | Fixes will conflict |
| Ignoring "uncertain" category | Those bugs need investigation first |
| Forcing fix on design gap | You're creating tech debt |
| Not updating bugs.md | Next session loses your progress |

## Integration

**Input:**
- Feature docs at `docs/<feature>/`
- Bug descriptions (from user or execution review)

**Works with:**
- `rubber-duck` - Subagents invoke when stuck
- `superpowers:systematic-debugging` - Final escalation
- `brainstorm-to-design` - When design gaps found

**Output:**
- Updated `docs/<feature>/bugs.md`
- Fixed bugs (or clear next steps)

**Invoked via:**
- `/fix-feature-bugs <feature-dir> <bug descriptions>`
