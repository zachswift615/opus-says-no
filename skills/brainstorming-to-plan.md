---
name: brainstorming-to-plan
description: Explore requirements and design before implementation. Use when starting any feature work to clarify goals, explore approaches, and flow into writing-plans-v2.
model: opus
---

# Brainstorming to Plan

## Overview

Explore and clarify requirements before committing to an implementation. This skill guides you through understanding the problem, exploring options, and making decisions - then flows directly into writing-plans-v2 for gap-free implementation planning.

**Announce at start:** "I'm using brainstorming-to-plan to explore this before we commit to an approach."

## The Flow

```
Brainstorming (this skill)
        ↓
    Decisions documented
        ↓
    writing-plans-v2
        ↓
    Gap-free implementation plan
```

---

## Phase 1: Understand the Goal

Before exploring solutions, make sure we understand the problem.

### Questions to Answer
1. **What problem are we solving?** (Not "what feature" - what pain point)
2. **Who experiences this problem?** (User, developer, system)
3. **What does success look like?** (Measurable outcome)
4. **What are the constraints?** (Time, tech, compatibility)
5. **What's out of scope?** (Explicitly)

### Output Format

```markdown
## Problem Understanding

**Problem:** [One sentence describing the pain point]

**Who:** [Who experiences this]

**Success Criteria:**
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]

**Constraints:**
- [Constraint 1]
- [Constraint 2]

**Out of Scope:**
- [Thing we're NOT doing]
```

---

## Phase 2: Explore the Solution Space

Generate multiple approaches before picking one.

### Generate Options
- List at least 2-3 different approaches
- Include the "obvious" solution AND alternatives
- Consider the "do nothing" option - is it viable?

### For Each Option, Evaluate

```markdown
### Option A: [Name]

**Approach:** [2-3 sentences]

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Disadvantage 1]
- [Disadvantage 2]

**Effort:** [Low/Medium/High]

**Risk:** [Low/Medium/High] - [What could go wrong]

**Dependencies:** [What this requires]
```

### Compare Options

Create a decision matrix:

```markdown
| Criterion | Weight | Option A | Option B | Option C |
|-----------|--------|----------|----------|----------|
| Simplicity | High | 3 | 2 | 1 |
| Robustness | High | 2 | 3 | 3 |
| Time to implement | Medium | 3 | 2 | 1 |
| Maintainability | Medium | 2 | 3 | 2 |
```

---

## Phase 3: Make Decisions

Document decisions explicitly so they're preserved for the implementation phase.

### Decision Template

```markdown
## Decisions

### Decision 1: [Topic]
**Choice:** [What we decided]
**Rationale:** [Why this over alternatives]
**Trade-offs Accepted:** [What we're giving up]
**Revisit If:** [Conditions that would change this decision]

### Decision 2: [Topic]
...
```

### Key Decisions to Make
- [ ] Overall approach (which option?)
- [ ] Technology/library choices
- [ ] Architecture pattern
- [ ] Error handling strategy
- [ ] Testing strategy
- [ ] Migration/compatibility approach (if applicable)

---

## Phase 4: Define the Scope

Before handing off to planning, define exactly what we're building.

```markdown
## Scope Definition

### In Scope (Must Have)
1. [Feature/behavior 1]
2. [Feature/behavior 2]

### In Scope (Nice to Have)
1. [Feature that can be cut if needed]

### Explicitly Out of Scope
1. [Thing we're NOT doing this round]

### Open Questions
1. [Question that still needs answering]
   **Blocker?** [Yes/No]
   **How to resolve:** [Ask user / research / defer]
```

---

## Phase 5: Handoff to Planning

Once brainstorming is complete, hand off to writing-plans-v2.

### Handoff Document

Save to `docs/designs/YYYY-MM-DD-<feature-name>.md`:

```markdown
# [Feature Name] Design Document

## Problem & Goals
[From Phase 1]

## Chosen Approach
[From Phase 2 - the winning option]

## Key Decisions
[From Phase 3]

## Scope
[From Phase 4]

## Ready for Planning
This design is ready for implementation planning.

**Next Step:** Use writing-plans-v2 to create the implementation plan.
```

### Transition

After saving the design document:

**"Brainstorming complete. Design saved to `docs/designs/<filename>.md`**

**Summary:**
- Problem: [One line]
- Approach: [One line]
- Key decisions: [Count]
- Scope: [N must-haves, M nice-to-haves]

**Ready to create implementation plan with writing-plans-v2?**"

If yes, invoke writing-plans-v2 with the design document as context.

---

## When to Use This Skill

**Use brainstorming-to-plan when:**
- Starting a new feature
- Facing a non-trivial technical decision
- Multiple valid approaches exist
- Requirements are fuzzy
- Stakeholder alignment is needed

**Skip to writing-plans-v2 when:**
- Requirements are crystal clear
- Approach is obvious/predetermined
- It's a bug fix with clear solution
- You're implementing a well-defined spec

---

## Anti-Patterns to Avoid

1. **Premature commitment:** Don't pick the first idea
2. **Analysis paralysis:** Time-box exploration (30 min max)
3. **Skipping trade-offs:** Every decision has costs
4. **Vague scope:** "Improve X" is not a scope
5. **Hidden assumptions:** Make them explicit

---

## Example Session

**User:** "I want to add caching to the API"

**Brainstorming Output:**
```markdown
## Problem Understanding
**Problem:** API responses are slow for repeated queries
**Success:** Response time < 100ms for cached queries

## Options Explored
- Option A: In-memory LRU cache (simple, loses on restart)
- Option B: Redis cache (robust, adds dependency)
- Option C: HTTP cache headers (client-side, limited control)

## Decision
**Choice:** Option A (in-memory LRU)
**Rationale:** Simplest solution that meets requirements
**Trade-off:** Accept cache loss on restart (acceptable for this use case)

## Scope
- Must: Cache GET responses by URL
- Must: TTL-based expiration
- Nice: Cache statistics endpoint
- Out of scope: Distributed caching, cache warming
```

Then → writing-plans-v2 for implementation.
