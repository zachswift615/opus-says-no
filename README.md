# Opus Says No

```
THE PROCESS IS THE SHORTCUT.
```

A collection of custom skills for Claude Code that enforce discipline in planning, implementation, and bug-fixing.

```
PLANS WITH GAPS ARE BUGS YOU HAVEN'T FOUND YET.
```

## The Philosophy

Every shortcut in planning becomes a bug in implementation. Every skipped review becomes a regression. Every "just try this" becomes three hours of debugging.

**Opus says no to:**
- Plans with placeholders ("add validation here")
- Skipping adversarial review ("it looks fine to me")
- Context-limit compromises ("I'll summarize the rest")
- Fixing bugs without understanding them ("let me try one more thing")
- Starting fresh sessions without context ("what does this feature do again?")

**Opus says yes to:**
- Gap analysis before detailed planning
- Fresh Opus subagents challenging every design
- Batched planning that scales to any size
- Structured escalation when bugs resist fixing
- Feature docs that transfer context between sessions

---

## Skills Included

### `dream-first`

Don't start coding until you know what you're building.

**Core principle:** Exploration before commitment. Decisions before details.

1. Understand the goal (problem, success criteria, constraints)
2. Explore 2-3 approaches with trade-offs
3. Make explicit decisions with rationale
4. Define scope ruthlessly (must have / nice to have / out of scope)
5. Write Gherkin scenarios (for user-facing features)
6. Write design document
7. **Adversarial review** - Fresh Opus challenges everything
8. Iterate until approved
9. Hand off to planning

**Output:** `docs/<feature-name>/design.md`

### `story-time`

Break it down before you plan it out.

**Core principle:** Validated decomposition before detailed planning.

1. Read design document
2. **Task Outline** - Goals, connections, acceptance criteria
3. **Gap Analysis** - Opus finds structural gaps
4. Iterate until gap-free with fresh fix agents
5. Hand off validated outline

**Use for:** Any feature that needs structured decomposition before detailed planning

**Output:** `docs/<feature-name>/plan.md` (task outline)

### `blueprint-maestro` (Recommended)

The conductor for complex plans.

**Core principle:** Fresh agents per batch. Fresh fix agents for repairs. No compromises.

1. **Resume/Fresh check** - Detect plan state automatically
2. **Batched Planning** - 2-3 tasks per fresh agent
3. **Incremental Reviews** - Each batch approved before next
4. **Fresh Fix Agents** - Full context budget for focused repairs
5. **Final Review** - End-to-end validation

**Use for:** 8+ tasks, complex features, anything that matters

**Requires:** Validated task outline (from story-time)

**Output:** `docs/<feature-name>/plan.md`

### `blueprint`

Draw the plan before you build.

Same rigor, single agent. Use when you have < 5-7 straightforward tasks.

### `go-time`

Time to make it real.

**Core principle:** Resume > re-dispatch. Context is expensive.

- **Creates a git worktree** for isolated feature development
- Agents answer questions via resume (true agent-to-agent communication)
- Agents continue with next task while context allows
- Batch review after agent exhaustion, not per-task
- Unified reviewer checks spec AND quality in one pass
- Skips the manual verification task (deferred to trust-but-verify)
- Hands off to trust-but-verify, never directly to land-it

### `trust-but-verify`

The code works. Now prove it.

**Core principle:** Human verification before landing. Trust the code, verify the behavior.

1. Read the plan's manual verification task
2. Walk user through each test case one at a time
3. Collect pass/fail/blocked for each
4. All pass → hand off to `/land-it`
5. Bugs found → write bugs.md → `/patch-party` (same session or handoff)

**Output:** Verification results, `docs/<feature-name>/bugs.md` (if bugs found)

### `patch-party`

Implementation rarely ends clean. Time to clean up.

**Core principle:** Context is expensive. Transfer it, don't rebuild it.

```
IMPLEMENTATION COMPLETE ≠ FEATURE COMPLETE
```

1. **Bootstrap** - Read design.md and bugs.md fully, search plan.md
2. **Triage** - Categorize, group related bugs, gather code sites
3. **Dispatch** - Subagent per bug group with full context
4. **Handle Returns** - Fixed, rubber-duck, or design gap
5. **Collect** - Update bugs.md, verify all fixes

**Output:** `docs/<feature-name>/bugs.md`

### `rubber-duck`

When you can't figure out why something isn't working, explain it to someone else. Half the time, you'll solve it mid-sentence.

**Core principle:** Writing the explanation IS the debugging. The prompt is a side effect.

```
IF YOU CAN'T EXPLAIN IT CLEARLY, YOU DON'T UNDERSTAND IT YET
```

**Triggers:**
- 2 failed fix attempts
- "I'm not sure why this isn't working"
- Explicit request

**Process:**
1. Write detailed prompt explaining the bug
2. Pause - did writing reveal the answer?
3. If still stuck: consult external LLM or Opus agent
4. If still stuck: escalate to root-canal

### `root-canal`

When rubber-duck + consultation didn't work. Time to go surgical.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

**The Four Phases:**
1. **Root Cause Investigation** - Read errors, reproduce, check changes, gather evidence
2. **Pattern Analysis** - Find working examples, compare differences
3. **Hypothesis Testing** - Form single theory, test minimally, verify
4. **Implementation** - Create failing test, single fix, verify

**Escalation:** If 3+ fixes fail → question the architecture → dream-first

**Supporting techniques:** root-cause-tracing, defense-in-depth, condition-based-waiting

### `land-it`

Implementation done. Time to land the branch.

**Core principle:** Verify tests → Present options → Execute choice → Clean up.

```
LAND IT CLEAN OR DON'T LAND IT AT ALL
```

**The Process:**
1. **Verify tests** - Must pass before any option is available
2. **Determine base branch** - Where are we merging back to?
3. **Present 4 options** - Merge locally, Create PR, Keep as-is, Discard
4. **Execute choice** - Handle the chosen workflow
5. **Cleanup** - Remove worktree if applicable

**Options:**
- Merge back locally (merge + delete branch + cleanup worktree)
- Push and create PR (push + gh pr create + keep worktree)
- Keep as-is (do nothing, preserve everything)
- Discard (requires typed confirmation, force delete)

---

## The Escalation Ladder

```
ESCALATE ON EVIDENCE, NOT FRUSTRATION
```

When bugs resist fixing, escalate methodically:

```
Direct Fix (subagent attempts)
     │
     ▼ (2 fails OR uncertainty)
Rubber-Duck (write explanation prompt)
     │
     ├─► Self-resolved → done
     │
     ▼ (still stuck)
Consultation (external LLM or Opus agent)
     │
     ├─► Resolved → done
     │
     ▼ (still stuck)
Root-Canal (full 4-phase forensic investigation)
     │
     ├─► Root cause found → done
     │
     ▼ (reveals architectural issue)
Dream-First (it's not a bug, it's a design gap)
```

---

## What Opus Says No To

| Shortcut | Why It Fails | What To Do Instead |
|----------|--------------|-------------------|
| "Skip the design review" | Gaps bake into the plan | Adversarial review catches them |
| "I'll add tests later" | You won't. And if you do, they'll be weak. | TDD or write tests with the plan |
| "Just try this fix" | Fix #3, #4, #5 are coming | Rubber-duck after 2 failures |
| "The plan looks complete" | To you. Fresh eyes see differently. | Gap analysis with Opus subagent |
| "I'll remember the context" | You won't. Next session starts cold. | Write to docs/<feature>/ |
| "One more fix attempt" | You've been saying that for an hour | Escalate. Rubber-duck or systematic. |
| "It's a simple bug" | Simple bugs that resist 2 fixes aren't simple | Follow the escalation ladder |
| "I don't need the full process" | That's what everyone thinks before wasting 3 hours | The process IS the shortcut |

---

## Quick Start

For any new feature:

```
/dream-first                      # What are we building?
/blueprint <feature>              # How are we building it?
/go-time <feature>                # Build it (in a worktree).
/trust-but-verify <plan-path>     # Prove it works.
/land-it                          # Ship it.
```

If bugs are found during verification:
```
/patch-party <feature>            # Fix what's broken.
/land-it                          # Then ship it.
```

If you skip steps, Opus will punish you later.

---

## Installation

```bash
cd ~/projects/claude-custom-skills

# Preview
./install.sh --dry-run

# Install
./install.sh
```

## Uninstallation

```bash
./uninstall.sh --dry-run
./uninstall.sh
```

---

## The Workflow

```mermaid
flowchart TD
    Start([New Feature]) --> DreamFirst[/dream-first/]
    DreamFirst --> Explore[Explore & Decide]
    Explore --> DesignReview{{Design Review<br/>Opus Says No?}}
    DesignReview -->|Iterate| Explore
    DesignReview -->|Approved| DesignDoc[(design.md)]

    DesignDoc --> BlueprintCmd[/blueprint/]
    BlueprintCmd --> Assess{Complexity?}

    Assess -->|Simple| BlueprintSkill[blueprint skill]
    BlueprintSkill --> PlanDoc[(plan.md)]

    Assess -->|Complex| StoryTime[story-time]
    StoryTime --> Outline[Task Outline]
    Outline --> GapReview{{Gap Analysis<br/>Opus Says No?}}
    GapReview -->|Iterate| GapFix[Fresh Fix Agent]
    GapFix --> GapReview
    GapReview -->|Clean| Maestro[blueprint-maestro]

    Maestro --> BatchLoop[Batch Loop]
    BatchLoop --> Writer[Fresh Writer<br/>2-3 Tasks]
    Writer --> BatchReview{{Batch Review<br/>Opus Says No?}}
    BatchReview -->|Iterate| BatchFix[Fresh Fix Agent]
    BatchFix --> BatchReview
    BatchReview -->|Next| ContextCheck{Context<br/>OK?}
    ContextCheck -->|Yes| BatchLoop
    ContextCheck -->|No| Handoff[Handoff + Resume]
    Handoff --> Maestro
    BatchReview -->|Done| FinalReview{{Final Review}}
    FinalReview --> PlanDoc

    PlanDoc --> GoTimeCmd[/go-time/]
    GoTimeCmd --> Worktree[Create Worktree]
    Worktree --> GoTime[go-time skill]
    GoTime --> Impl[Implementers]
    Impl --> UnifiedReview{{Unified Review}}
    UnifiedReview -->|Iterate| Impl
    UnifiedReview -->|Complete| TBV[/trust-but-verify/]

    TBV --> WalkTests[Walk Through<br/>Manual Test Cases]
    WalkTests -->|All Pass| LandIt[/land-it/]
    LandIt --> Done([Complete!])
    WalkTests -->|Bugs Found| PatchParty[/patch-party/]

    PatchParty --> Triage[Triage]
    Triage --> FixAgent[Fix Subagents]
    FixAgent -->|2 Fails| RubberDuck[/rubber-duck/]
    RubberDuck --> FixAgent
    FixAgent -->|Design Gap| DreamFirst
    FixAgent -->|Fixed| BugsDoc[(bugs.md)]
    BugsDoc -->|More| Triage
    BugsDoc -->|Done| LandIt

    classDef reviewNode fill:#ff6b6b,stroke:#c92a2a,color:#fff
    classDef cmdNode fill:#ffd43b,stroke:#f59f00,color:#000
    classDef docNode fill:#51cf66,stroke:#2f9e44,color:#fff

    class DesignReview,GapReview,BatchReview,FinalReview,UnifiedReview reviewNode
    class DreamFirst,BlueprintCmd,BlueprintSkill,StoryTime,Maestro,GoTimeCmd,GoTime,PatchParty,RubberDuck,TBV,LandIt cmdNode
    class DesignDoc,PlanDoc,BugsDoc docNode
```

**Legend:** 🟡 Skills | 🔴 Reviews (Opus Says No?) | 🟢 Documents

---

## Text Workflow

```
/dream-first                   # Explore. Decide. Review.
        ↓                      # → docs/<feature>/design.md (committed to main)
/story-time <feature>          # Outline. Gap analysis. Validate.
        ↓                      # → docs/<feature>/plan.md (committed to main)
/blueprint-maestro <plan>      # Batched planning. Reviews. Fix agents.
        ↓                      # → docs/<feature>/plan.md (committed to main)
/go-time <feature>             # Create worktree. Implement. Resume. Review.
        ↓                      # (in worktree)
/trust-but-verify <plan>       # Walk through manual test cases.
        ├── all pass ──→ /land-it    # Merge/PR + cleanup worktree
        └── bugs ──→ /patch-party    # Fix. Then /land-it.
```

Or use `/blueprint <feature>` which routes through story-time + maestro automatically.

---

## Feature Docs Convention

All feature artifacts live together. Fresh sessions bootstrap from here.

```
docs/
└── <feature-name>/
    ├── design.md      # Architecture, decisions, trade-offs
    ├── plan.md        # Tasks, code, integration points
    ├── bugs.md        # Found, fixed, remaining
    └── ...            # Whatever else accumulates
```

**Naming:** kebab-case, match branch name when possible

---

## Commands

### `/story-time <feature>`

```
/story-time user-auth
```

Decomposes `docs/<feature>/design.md` into a validated task outline with gap analysis.

### `/blueprint <feature>`

```
/blueprint user-auth
```

Creates implementation plan from `docs/<feature>/design.md`. Routes to story-time + blueprint-maestro for complex features, or blueprint for simple ones.

### `/go-time <feature>`

```
/go-time user-auth
```

Creates a worktree and executes plan from `docs/<feature>/plan.md` with resumable subagents and batched reviews. Hands off to trust-but-verify when complete.

### `/trust-but-verify [plan-path]`

```
/trust-but-verify docs/user-auth/plan.md
```

Walks through manual test cases from the plan. Routes to `/land-it` (all pass) or `/patch-party` (bugs found).

### `/patch-party <feature> "<bugs>"`

```
/patch-party user-auth "Login fails silently; Password reset not sent"
```

Bootstraps from feature docs, triages, dispatches fix subagents, handles escalation.

---

## File Structure

```
claude-custom-skills/
├── skills/
│   ├── dream-first/           # Explore → Design → Review
│   ├── story-time/            # Task outline → Gap analysis → Validate
│   ├── blueprint/             # Simple plans (< 5-7 tasks)
│   ├── blueprint-maestro/     # Complex plans (from validated outline)
│   ├── go-time/               # Worktree creation + resumable execution
│   ├── trust-but-verify/      # Manual verification before landing
│   ├── patch-party/           # Post-implementation bugs
│   ├── rubber-duck/           # Stuck bug escalation
│   ├── root-canal/            # Full forensic debugging
│   └── land-it/               # Branch completion workflow
├── prompts/                   # Shared review prompts
├── commands/                  # Entry points
├── install.sh
└── uninstall.sh
```

---

## Why This Exists

The default approach produces plans with gaps. Agents hit context limits and leave placeholders. Reviews get skipped "just this once." Bugs get fixed with "let me try one more thing" until you've burned three hours.

**This is what Opus says no to.**

### The Multi-Layered Review System

1. **Design review** - Fresh Opus challenges designs before planning
2. **Gap analysis** - Fresh Opus finds structural gaps in outlines
3. **Batch reviews** - Each batch reviewed before next begins
4. **Final review** - Fresh Opus verifies end-to-end executability
5. **Unified code review** - Spec compliance + quality in one pass
6. **Manual verification** - Human walks through test cases before landing

### The Scalable Planning Architecture

- Decomposition (story-time) separated from detailed planning (blueprint-maestro)
- Plans written in 2-3 task batches by fresh agents
- No context limits because each batch starts fresh
- Issues caught per batch, not at the end
- Fresh fix agents for repairs — full context budget, no exhausted writers
- Context self-monitoring with automatic handoff and resume

### The Structured Bug Fixing

- Context bootstraps from docs/<feature>/
- Escalation ladder prevents thrashing
- Design gaps escalate to dreaming
- Rubber-duck catches what persistence misses

---

## Acknowledgments

Most of these skills are heavily modified versions of skills and prompts from the [superpowers](https://github.com/obra/superpowers) project by Jesse Vincent, customized for this workflow.

---

```
THE PROCESS IS THE SHORTCUT.
```
