---
name: dream-first
description: Explore requirements and design before implementation. Use when starting any feature work to clarify goals, explore approaches, and dream it up before you build it.
model: claude-opus-4-5-20251101
---

# Dream First

Don't start coding until you know what you're building.

## Overview

Help turn ideas into fully formed designs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design in small sections (200-300 words), checking after each section whether it looks right so far.

## The Process

**Understanding the idea:**
- Check out the current project state first (files, docs, recent commits)
- Ask questions one at a time to refine the idea
- Prefer multiple choice questions when possible, but open-ended is fine too
- Only one question per message - if a topic needs more exploration, break it into multiple questions
- Focus on understanding: purpose, constraints, success criteria

**Exploring approaches:**
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**
- Once you believe you understand what you're building, present the design
- Break it into sections of 200-300 words
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

## Key Principles

- **One question at a time** - Don't overwhelm with multiple questions
- **Multiple choice preferred** - Easier to answer than open-ended when possible
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
- **Be flexible** - Go back and clarify when something doesn't make sense

---

## Optional: Gherkin User Stories

**For user-facing features only.** After presenting the design and before writing the design doc, consider writing Gherkin scenarios if the feature involves user interaction.

### When to Include

**Include if:**
- Feature has direct user interaction
- Multiple user workflows exist
- Feature has conditional logic or edge cases

**Skip if:**
- Internal refactoring
- Developer tooling
- Infrastructure work

### Gherkin Template

```gherkin
Feature: [Feature Name]

Scenario: [Main happy path]
  Given [initial context]
  When [user action]
  Then [expected outcome]

Scenario: [Edge case]
  Given [different context]
  When [action that triggers edge case]
  Then [how system should handle it]
```

### Writing Good Scenarios

- Be specific and concrete ("Given a user with 2 active sessions")
- Cover happy path AND edge cases
- Describe user-observable behavior (not implementation)
- Reveal assumptions ("Given the cache is empty")

If writing scenarios reveals gaps, discuss them with the user before finalizing the design.

---

## After the Design is Validated

### 1. Write the Design Document

Save the validated design to `docs/<feature-name>/design.md`

**Feature directory naming:**
- Use kebab-case: `user-auth`, `metrics-export`, `dark-mode-toggle`
- Match branch name when possible
- Keep it short but descriptive

**Design document should include:**
- **Problem & Goals** - What we're solving and why
- **Chosen Approach** - The option we selected with rationale
- **Key Decisions** - Important choices made with trade-offs
- **Architecture** - Components, data flow, integration points
- **Scope** - Must have, nice to have, explicitly out of scope
- **User Stories** - Gherkin scenarios if created
- **Open Questions** - Anything still uncertain

Commit the design document to git.

---

### 2. Adversarial Design Review

Now spawn a fresh Opus subagent to challenge the design and find gaps.

#### Why Review?

- **Fresh perspective** - No attachment to decisions you just made
- **Systematic** - Follows comprehensive checklist
- **Catches blind spots** - Things you missed during brainstorming

#### How to Execute

Use the Task tool to spawn the review subagent:

```
I'm spawning an adversarial design review subagent to challenge this design.
```

**Task tool parameters:**
- `subagent_type`: "general-purpose"
- `model`: "opus"
- `description`: "Adversarial design review"
- `prompt`: Load from `@design-review.md` and include:
  - Path to design doc: `docs/<feature-name>/design.md`
  - Path to user stories (if exists): `docs/<feature-name>/stories.gherkin`

**Example invocation:**

"I'm using the Task tool to spawn an Opus subagent for adversarial design review."

[Call Task tool with prompt loaded from design-review.md plus the file paths]

#### What to Expect Back

The subagent will return a review with:
- **Critical gaps** - Must address before proceeding
- **Design concerns** - Serious issues with the approach
- **Missing considerations** - Things you didn't think about
- **Edge cases** - Scenarios not covered
- **Alternative suggestions** - Different approaches to consider
- **Questions** - Things that need clarification

---

### 3. Incorporate Feedback

Review the subagent's findings with the user and update the design.

**Categorize feedback:**
- **Critical** (must fix) - Missing scope items, incorrect assumptions, security risks
- **Important** (should fix) - Edge cases, missing decisions, scalability concerns
- **Nice-to-have** (consider) - Polish, future enhancements

**For each piece of feedback:**
1. **If it reveals a gap in decisions** - Add to "Key Decisions" section
2. **If it's a missing scope item** - Add to "In Scope" or document why it's out
3. **If it's a new edge case** - Add user story or document in design
4. **If it questions the approach** - Re-evaluate and discuss with user
5. **If it's truly out of scope** - Add to "Explicitly Out of Scope" with rationale

**Update the design document** with:
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

### 4. Handoff to Implementation Planning

Once design is validated and reviewed, hand off to implementation planning.

**Final message:**

**"Design complete and reviewed. Ready for implementation planning."**

**Summary:**
- Problem: [One line]
- Approach: [One line]
- Key decisions: [Count]
- Scope: [N must-haves, M nice-to-haves]
- User stories: [N scenarios] (if applicable)
- Review feedback: [N items addressed]

**Feature directory:** `docs/<feature-name>/`
**Design document:** `docs/<feature-name>/design.md`
**User stories:** `docs/<feature-name>/stories.gherkin` (if applicable)

**To create the implementation plan, use:**

```
/blueprint-maestro docs/<feature-name>/design.md
```

---

## When to Use This Skill

**Use dream-first when:**
- Starting a new feature
- Facing a non-trivial technical decision
- Multiple valid approaches exist
- Requirements are fuzzy
- Need to align on design before coding

**Skip to planning when:**
- Design is already done
- Requirements are crystal clear
- It's a bug fix with obvious solution

---

## Anti-Patterns to Avoid

1. **Asking too many questions at once** - One question per message
2. **Skipping alternatives** - Always explore 2-3 approaches
3. **Big reveal** - Don't present entire design at once, break into sections
4. **Assuming understanding** - Validate each section before moving on
5. **Skipping YAGNI** - Ruthlessly remove unnecessary complexity
6. **No review** - Always use adversarial design review for non-trivial features
