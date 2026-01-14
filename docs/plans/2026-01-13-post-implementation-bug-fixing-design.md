# Post-Implementation Bug Fixing: Design Document

## Overview

This design addresses the gap between execution completion and feature completion. When bugs remain after implementing a plan, there's currently no structured process - sessions either improvise or start fresh without context.

**The Problem:**
- Execution orchestrator's context is often exhausted when bugs remain
- Fresh sessions must rediscover feature context from scratch
- Without structure, agents jump straight to editing files
- Simple bugs get over-engineered debugging; stuck bugs get under-investigated

**The Solution:**
- Structured `fix-feature-bugs` workflow with context bootstrapping
- `rubber-duck` skill as a lightweight escalation before systematic-debugging
- Docs convention for discoverable feature artifacts
- Clear escalation ladder: direct fix → rubber-duck → consultation → systematic-debugging

---

## The Escalation Ladder

When bugs remain after implementation, fixing blindly creates new bugs. Each failed attempt burns context and trust.

**Core principle:** Escalate methodically. Simple bugs get simple fixes. Stuck bugs get structured thinking.

```
ESCALATE ON EVIDENCE, NOT FRUSTRATION
```

### Level 1: Direct Fix (via subagent)

- Main agent triages the bug, gathers relevant code sites
- Dispatches subagent with context + acceptance criteria
- Subagent attempts fix, reports back
- Exit: Fixed → done. Design gap detected → brainstorm-to-design

### Level 2: Rubber-Duck

**Triggered by:** 2 failed fixes OR uncertainty expressed OR explicit request

- Write detailed prompt explaining issue to "another LLM"
- Include: bug description, what was tried, relevant code, expected vs actual
- Pause - often the act of explaining reveals the answer
- If self-resolved → done
- If not → ask: "Share with external LLM?" or spawn Opus consultation agent
- Exit: Solution found → apply → done

### Level 3: Systematic Debugging

**Triggered if:** rubber-duck + consultation didn't resolve

- Full 4-phase investigation
- Root cause, pattern analysis, hypothesis testing, verified fix

---

## The fix-feature-bugs Workflow

Post-implementation bugs share context. Starting fresh without that context wastes the first hour rediscovering what you already knew.

**Core principle:** Bootstrap fast, triage smart, dispatch with everything the subagent needs.

```
CONTEXT IS EXPENSIVE. TRANSFER IT, DON'T REBUILD IT.
```

### The Flow

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
       └─ After consultation: resume same subagent OR spawn fresh (main agent judgment)
   └─ Subagent escalated to systematic-debugging → let it complete full investigation

5. Collect
   └─ Update bugs.md (fixed, remaining, new discoveries)
   └─ Verify all fixes (run tests, check behavior)
```

### Design Gap Detection

Flag as design gap (→ brainstorm-to-design) when ANY of:
- Fix requires adding a concept/flow not in original design
- Same root cause behind 2+ bugs (pattern = missing design consideration)
- Can't fix without architectural changes

---

## The Rubber-Duck Skill

Explaining a problem to someone else forces you to organize your thinking. Half the time, you solve it mid-sentence.

**Core principle:** Writing the explanation IS the debugging. The prompt is a side effect.

```
IF YOU CAN'T EXPLAIN IT CLEARLY, YOU DON'T UNDERSTAND IT YET
```

### When to Invoke

- After 2 failed fix attempts
- When agent expresses uncertainty ("I'm not sure why...")
- Explicit request from user or main agent

### The Process

```
1. Write the Prompt
   └─ Address it to "a senior engineer unfamiliar with this codebase"
   └─ Include:
       • What the bug is (expected vs actual behavior)
       • What was tried and why it didn't work
       • Relevant code snippets (minimal but complete)
       • Your current hypothesis (even if uncertain)
   └─ Force yourself to be precise - vague = you don't understand yet

2. Pause and Reflect
   └─ Did writing this reveal the answer?
   └─ Often yes → apply fix → done
   └─ If no → continue

3. Offer Consultation Options
   └─ "Share this with an external LLM for fresh perspective?"
   └─ Yes → user pastes to ChatGPT/etc, reports findings
   └─ No → spawn Opus consultation agent with the prompt

4. After Consultation
   └─ Solution found → apply fix → done
   └─ Still stuck → escalate to systematic-debugging
```

### Red Flags - You're Not Really Rubber-Ducking

- Prompt is vague ("it doesn't work")
- Skipping what was already tried
- Not including actual code
- Rushing through to get to consultation

---

## The Docs Structure Convention

Fresh sessions shouldn't play archaeology. Feature context should be findable in one place with predictable names.

**Core principle:** Discoverability beats documentation. A doc nobody can find is a doc that doesn't exist.

```
ONE DIRECTORY PER FEATURE. PREDICTABLE NAMES. ALWAYS.
```

### The Structure

```
docs/
└── <feature-name>/
    ├── design.md      # From brainstorming-to-plan
    │                  # Architecture, decisions, trade-offs
    │
    ├── plan.md        # From implementation-planning
    │                  # Tasks, code locations, integration points
    │
    ├── bugs.md        # Living document
    │                  # Found, fixed, remaining, discoveries
    │
    └── ...            # Other artifacts as needed
                       # (test results, review notes, etc.)
```

### bugs.md Format

```markdown
# Bugs: <feature-name>

## Fixed
- [x] Description of bug (commit: abc123)
  - Root cause: what was wrong
  - Fix: what was changed

## Remaining
- [ ] Description of bug
  - Attempts: what was tried
  - Status: investigating / blocked / needs-design-review

## Discovered During Fixes
- [ ] New issue found while fixing other bugs
```

### Naming Convention

- `<feature-name>` = kebab-case, matches branch name when possible
- Examples: `user-auth`, `metrics-export`, `dark-mode-toggle`

---

## Integration with Existing Workflow

The bug-fixing phase isn't separate from the workflow - it's the natural continuation. Same rigor, same structure, different scope.

**Core principle:** Execution rarely ends clean. Plan for the cleanup phase as part of the process.

```
IMPLEMENTATION COMPLETE ≠ FEATURE COMPLETE
```

### The Extended Workflow

```
1. brainstorm-to-design
   └─ Explore → Design → Review
   └─ Output: docs/<feature>/design.md

2. implementation-planning
   └─ Outline → Gap analysis → Detailed plan → Review
   └─ Output: docs/<feature>/plan.md

3. go-agents (execution)
   └─ Dispatch → Implement → Unified review
   └─ Output: Code changes, likely some bugs remain

4. fix-feature-bugs (NEW)          ← You are here
   └─ Bootstrap → Triage → Dispatch → Collect
   └─ Output: docs/<feature>/bugs.md, fixes applied
   └─ May loop back to step 1 if design gap detected

5. finishing-a-development-branch
   └─ Verify → Choose path → Merge/PR/Keep/Discard
   └─ Output: Feature shipped or parked
```

### Context Handoff Points

| From | To | What Transfers |
|------|-----|----------------|
| brainstorm | planning | design.md |
| planning | execution | plan.md |
| execution | fix-bugs | design.md + plan.md + bug list |
| fix-bugs | brainstorm | design gap description (if escalating) |
| fix-bugs | finishing | bugs.md (all fixed) |

### After Execution Completes

```
Recommended: Fresh session with fix-feature-bugs
└─ Structured process > improvisation
└─ Full context budget for bug fixing
└─ Consistent escalation ladder

Acceptable: Same session improvises
└─ Works when orchestrator has capacity AND bugs are simple
└─ But structure works better more often
└─ Consider: "Would I benefit from a clean start?"
```

### Invoking fix-feature-bugs

```
/fix-feature-bugs <feature-dir> <bug descriptions>

Example:
/fix-feature-bugs user-auth "Login fails silently when token expired;
  Password reset email not sent for SSO users"
```

---

## Summary & What to Build

### The Design in One View

```
┌─────────────────────────────────────────────────────────────────┐
│                    EXTENDED WORKFLOW                            │
├─────────────────────────────────────────────────────────────────┤
│  brainstorm → planning → execution → fix-feature-bugs → finish  │
│                                            │                    │
│                              ┌─────────────┴──────────┐         │
│                              │                        │         │
│                              ▼                        ▼         │
│                      design gap?              all fixed?        │
│                      → brainstorm             → finish          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    ESCALATION LADDER                            │
├─────────────────────────────────────────────────────────────────┤
│  Direct Fix (subagent)                                          │
│       │                                                         │
│       ▼ (2 fails OR uncertainty OR request)                     │
│  Rubber-Duck (write prompt, often self-resolves)                │
│       │                                                         │
│       ▼ (still stuck)                                           │
│  Consultation (external LLM or Opus agent)                      │
│       │                                                         │
│       ▼ (still stuck)                                           │
│  Systematic Debugging (full 4-phase)                            │
└─────────────────────────────────────────────────────────────────┘
```

### What to Build

| Artifact | Type | Purpose |
|----------|------|---------|
| `fix-feature-bugs` | Skill + Command | Main orchestration for post-implementation bug fixing |
| `rubber-duck` | Skill | Structured prompt-writing for stuck bugs |
| Docs convention | Update to existing skills | Have brainstorm/planning write to `docs/<feature>/` |

### Quick Reference - Escalation Triggers

| Trigger | Action |
|---------|--------|
| Bug found post-implementation | fix-feature-bugs |
| 2 failed fix attempts | rubber-duck |
| Agent says "I'm not sure why..." | rubber-duck |
| User/agent requests it | rubber-duck |
| Rubber-duck + consultation failed | systematic-debugging |
| Fix requires new concept/architecture | brainstorm-to-design |
| Same root cause behind 2+ bugs | brainstorm-to-design |
