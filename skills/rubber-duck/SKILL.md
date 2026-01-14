---
name: rubber-duck
description: Use when stuck after 2 failed fix attempts, when uncertain about a bug, or when explicitly requested. Write a detailed explanation prompt - often solving the problem in the process.
---

# Rubber-Duck Debugging

## Overview

Explaining a problem to someone else forces you to organize your thinking. Half the time, you solve it mid-sentence. The other half, you have a clear prompt ready for consultation.

**Core principle:** Writing the explanation IS the debugging. The prompt is a side effect.

```
IF YOU CAN'T EXPLAIN IT CLEARLY, YOU DON'T UNDERSTAND IT YET
```

## When to Invoke

**Automatic triggers:**
- After 2 failed fix attempts
- When you catch yourself thinking "I'm not sure why this isn't working"
- When each fix reveals a new problem in a different place

**Explicit triggers:**
- User requests rubber-duck
- Main orchestrator requests rubber-duck from subagent

**Don't skip when:**
- "One more try" feels tempting (that's exactly when to rubber-duck)
- The bug seems simple (simple bugs that resist 2 fixes aren't simple)
- You're in a hurry (rubber-ducking is faster than fix attempt #3, #4, #5)

## The Process

### Phase 1: Write the Prompt

Address it to "a senior engineer unfamiliar with this codebase."

**Required sections:**

```markdown
## The Bug

**Expected behavior:** [What should happen]
**Actual behavior:** [What actually happens]
**Reproduction steps:** [How to trigger it]

## What I've Tried

1. [First fix attempt]
   - Rationale: [Why I thought this would work]
   - Result: [What happened instead]

2. [Second fix attempt]
   - Rationale: [Why I thought this would work]
   - Result: [What happened instead]

## Relevant Code

[Minimal but complete code snippets - enough to understand the problem]

## My Current Hypothesis

[Your best guess, even if uncertain. "I suspect X because Y, but I'm not sure because Z"]

## Specific Questions

1. [What would help you understand this better?]
2. [What am I missing?]
```

**Writing discipline:**
- Be precise - vague descriptions mean you don't understand yet
- Include actual code, not paraphrases
- Show real error messages, not summaries
- Don't skip what you already tried (it's the most useful part)

### Phase 2: Pause and Reflect

Stop after writing. Read what you wrote.

**Ask yourself:**
- Did writing this reveal the answer?
- Is there a pattern in what I tried that I didn't notice before?
- Does my "current hypothesis" actually make sense now that I wrote it down?

**If self-resolved:** Apply the fix. You're done.

**If still stuck:** Continue to Phase 3.

### Phase 3: Offer Consultation Options

Present to the user:

```
I've written a detailed prompt explaining this bug but haven't solved it yet.

Options:
1. Share with external LLM (ChatGPT, etc.) for fresh perspective
2. Spawn Opus consultation agent to analyze
3. Let me re-read and try once more before consulting

Which would you prefer?
```

### Phase 4: Handle Consultation

**If user chooses external LLM:**
- Output the complete prompt for them to copy
- Wait for them to report findings
- Apply insights to the fix

**If user chooses Opus consultation:**
- Spawn consultation agent with `@opus-consultation-prompt.md`
- Include the full rubber-duck prompt as context
- Agent returns analysis and suggestions

**If consultation doesn't resolve:**
- Escalate to `root-canal`
- The rubber-duck prompt becomes input to Phase 1 (you've already gathered evidence)

## The Escalation Ladder

```
Direct Fix Attempt
     │
     ▼ (2 fails OR uncertainty OR request)
Rubber-Duck (this skill)
     │
     ├─► Self-resolved? → Done
     │
     ▼ (still stuck)
Consultation (external LLM or Opus agent)
     │
     ├─► Resolved? → Done
     │
     ▼ (still stuck)
Root-Canal (full 4-phase forensic investigation)
```

## Red Flags - You're Not Really Rubber-Ducking

| Behavior | Reality |
|----------|---------|
| Prompt is vague ("it doesn't work") | You're avoiding the hard thinking. Be specific. |
| Skipping "what I tried" section | That's the most diagnostic part. Include it. |
| Not including actual code | Descriptions aren't enough. Show the code. |
| Rushing to get to consultation | The writing IS the debugging. Slow down. |
| "I'll just try one more thing first" | You already tried 2 things. Rubber-duck. |
| Summarizing error messages | Exact text matters. Copy-paste it. |

## Why This Works

**Forcing function:** Writing for someone else forces you to:
- State assumptions explicitly (revealing bad ones)
- Organize the timeline (revealing patterns)
- Question your hypothesis (revealing gaps)
- Notice what you skipped (revealing shortcuts)

**Fresh perspective:** Even if you don't solve it yourself:
- The prompt is ready for consultation
- No time lost explaining context
- Consultant can focus on analysis, not archaeology

**Evidence gathering:** The prompt becomes input to systematic-debugging if needed:
- What was tried is documented
- Hypotheses are recorded
- Code is already gathered

## Integration

**Used by:**
- `patch-party` - subagents invoke when stuck
- Any debugging session after 2 failed attempts

**Escalates to:**
- `root-canal` - when consultation doesn't resolve

**Related:**
- `opus-consultation-prompt.md` - prompt template for Opus consultation agent
