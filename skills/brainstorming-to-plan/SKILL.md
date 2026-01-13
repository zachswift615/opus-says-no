---
name: brainstorming-to-plan
description: Explore requirements and design before implementation. Use when starting any feature work to clarify goals, explore approaches, and flow into implementation-planning.
model: opus
---

# Brainstorming to Plan

## Overview

Explore and clarify requirements before committing to an implementation. This skill guides you through understanding the problem, exploring options, and making decisions - then flows directly into implementation-planning for gap-free implementation planning.

**Announce at start:** "I'm using brainstorming-to-plan to explore this before we commit to an approach."

## The Flow

```
Brainstorming (this skill)
        ↓
    Decisions documented
        ↓
    implementation-planning
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

## Phase 5: Write Gherkin User Stories

**For user-facing features only.** Skip this phase for internal refactoring, developer tooling, or infrastructure work.

### Purpose

Writing concrete Gherkin scenarios forces you to think through actual user interactions and often reveals edge cases, ambiguities, or gaps in the design.

### When to Include User Stories

**Include if:**
- Feature has direct user interaction
- Behavior needs to be testable from user perspective
- Multiple user workflows exist
- Feature has conditional logic or edge cases

**Skip if:**
- Internal refactoring
- Developer tooling
- Infrastructure/deployment work
- Pure API design (unless it's a user-facing API)

### Gherkin Template

```gherkin
Feature: [Feature Name]

Scenario: [Main happy path]
  Given [initial context or precondition]
  When [user action]
  Then [expected outcome]
  And [additional outcome if needed]

Scenario: [Edge case or error condition]
  Given [different context]
  When [action that triggers edge case]
  Then [how system should handle it]

Scenario: [Another important workflow]
  Given [context]
  When [action]
  Then [outcome]
```

### Writing Good Scenarios

**Good scenarios:**
- Are specific and concrete ("Given a user with 2 active sessions" not "Given a logged-in user")
- Cover the happy path AND edge cases
- Describe user-observable behavior (not implementation)
- Reveal assumptions ("Given the cache is empty" makes caching explicit)

**Bad scenarios:**
- Too abstract ("Given a valid state")
- Only happy path (no error cases)
- Implementation-focused ("Given Redis is running")
- Redundant (5 scenarios that test the same thing)

### Output

Create a file `docs/designs/YYYY-MM-DD-<feature-name>-stories.gherkin` with all scenarios.

**If writing scenarios reveals gaps:**
- Missing scope items
- Unclear decisions
- Edge cases not considered

**Add these to the design document's "Open Questions" section** - you'll address them in Phase 8 after the design review.

---

## Phase 6: Write Initial Design Document

Now save the design document with everything you've explored so far.

### Save Location

`docs/designs/YYYY-MM-DD-<feature-name>.md`

### Document Template

```markdown
# [Feature Name] Design Document

Date: YYYY-MM-DD
Status: Under Review

## Problem & Goals
[From Phase 1]

**Problem:** [One sentence]
**Who:** [Who experiences this]
**Success Criteria:**
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Constraints:** [List constraints]
**Out of Scope:** [List what we're NOT doing]

## Options Explored
[From Phase 2 - summary of options considered]

### Option A: [Name]
**Pros:** [List]
**Cons:** [List]
**Effort:** [Low/Medium/High]

### Option B: [Name]
...

## Chosen Approach
[From Phase 2 - the winning option with full details]

**Why this approach:** [Rationale]

## Key Decisions
[From Phase 3]

### Decision 1: [Topic]
**Choice:** [What we decided]
**Rationale:** [Why this over alternatives]
**Trade-offs Accepted:** [What we're giving up]
**Revisit If:** [Conditions that would change this]

## Scope
[From Phase 4]

### In Scope (Must Have)
1. [Feature 1]
2. [Feature 2]

### In Scope (Nice to Have)
1. [Optional feature]

### Explicitly Out of Scope
1. [What we're NOT doing]

## User Stories
[From Phase 5 - link to .gherkin file or include inline if short]

See: `docs/designs/YYYY-MM-DD-<feature-name>-stories.gherkin`

OR inline:

```gherkin
Feature: [Feature Name]

Scenario: [Scenario 1]
  Given [context]
  When [action]
  Then [outcome]
```

## Open Questions
[Any remaining uncertainties]

1. [Question]
   **Blocker?** [Yes/No]
   **How to resolve:** [Ask user / research / defer]

## Next Step

Ready for adversarial design review.
```

---

## Phase 7: Adversarial Design Review

Now spawn a fresh Opus subagent to challenge the design and find gaps.

### Why a Subagent?

- **Fresh eyes:** No attachment to decisions made during brainstorming
- **Adversarial stance:** Explicitly tasked to find problems
- **Full context:** Gets the complete design doc to review
- **No brainstorming fatigue:** You've been exploring for a while; subagent starts fresh

### How to Execute

Use the Task tool to spawn the review subagent:

```
I'm spawning an adversarial design review subagent to challenge this design.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus" (use the most capable model)
- `description`: "Adversarial design review"
- `prompt`: Load from `@design-review.md` and include:
  - Path to design doc: `docs/designs/YYYY-MM-DD-<feature-name>.md`
  - Path to user stories (if exists): `docs/designs/YYYY-MM-DD-<feature-name>-stories.gherkin`

**Example invocation:**

"I'm using the Task tool to spawn an Opus subagent for adversarial design review."

[Call Task tool with prompt loaded from design-review.md plus the file paths]

### What to Expect Back

The subagent will return a review document with:
- **Critical gaps:** Must address before proceeding
- **Design concerns:** Serious issues with the approach
- **Missing considerations:** Things you didn't think about
- **Edge cases:** Scenarios not covered
- **Alternative suggestions:** Different approaches to consider
- **Questions:** Things that need clarification

---

## Phase 8: Incorporate Feedback & Iterate

Review the subagent's findings and update the design.

### Categorize Feedback

**Critical (must address):**
- Missing scope items that break the feature
- Incorrect assumptions
- Unhandled error conditions
- Security/data loss risks

**Important (should address):**
- Edge cases that are likely to occur
- Missing decisions that will bite us during implementation
- Scalability concerns

**Nice-to-have (consider):**
- Polish improvements
- Future enhancements
- Minor edge cases

### Update the Design Document

For each piece of feedback:

1. **If it reveals a gap in decisions:** Add to "Key Decisions" section
2. **If it's a missing scope item:** Add to "In Scope" or document why it's out of scope
3. **If it's a new edge case:** Add user story (if user-facing) or document in design
4. **If it questions the approach:** Re-evaluate in "Chosen Approach" section
5. **If it's truly out of scope:** Add to "Explicitly Out of Scope" with rationale

### When to Iterate vs Proceed

**Iterate (loop back to earlier phases) if:**
- Subagent found critical gaps in understanding (Phase 1)
- Need to explore a new option (Phase 2)
- Major decision was missed (Phase 3)
- Scope significantly changed (Phase 4)
- New user stories needed (Phase 5)

**Update and proceed if:**
- Feedback is clarifications/additions to existing decisions
- Edge cases can be added to scope
- Minor tweaks to the approach
- Questions can be answered without major rework

**Re-review if:**
- You made major changes based on feedback
- You significantly revised the approach
- New scope is substantially different

Otherwise, proceed to handoff.

### Document the Review

Add a section to the design document:

```markdown
## Design Review Results

**Reviewed by:** Claude Opus 4.5 (Subagent)
**Review Date:** YYYY-MM-DD

**Key Feedback Addressed:**
1. [Issue found] → [How addressed]
2. [Issue found] → [How addressed]

**Deferred Items:**
1. [Item] - Reason: [Why deferred]

**Status:** Ready for implementation planning
```

Update document status: `Status: Under Review` → `Status: Approved for Planning`

---

## Phase 9: Handoff to Planning

Once design is validated and updated, hand off to implementation-planning.

### Final Handoff Message

**"Design complete and reviewed. Ready for implementation planning."**

**Summary:**
- Problem: [One line]
- Approach: [One line]
- Key decisions: [Count]
- Scope: [N must-haves, M nice-to-haves]
- User stories: [N scenarios] (if applicable)
- Review feedback: [N items addressed]

**Design document:** `docs/designs/<filename>.md`
**User stories:** `docs/designs/<filename>-stories.gherkin` (if applicable)

**To create the implementation plan, use:**

```
/plan-from-design docs/designs/<filename>.md
```

This command will invoke implementation-planning with your design document as context.

---

## When to Use This Skill

**Use brainstorming-to-plan when:**
- Starting a new feature
- Facing a non-trivial technical decision
- Multiple valid approaches exist
- Requirements are fuzzy
- Stakeholder alignment is needed
- Feature is complex enough to benefit from design review

**Skip to implementation-planning when:**
- Requirements are crystal clear
- Approach is obvious/predetermined
- It's a bug fix with clear solution
- You're implementing a well-defined spec
- Design was already done in a previous session

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

Then → implementation-planning for implementation.
