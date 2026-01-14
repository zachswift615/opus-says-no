---
name: blueprint
description: Create an implementation plan from a feature's design document
arguments:
  - name: feature
    description: Feature name (e.g., user-auth). Reads from docs/<feature>/design.md
    required: true
---

# Blueprint

Create a comprehensive implementation plan for **{{feature}}**.

**Design document:** `docs/{{feature}}/design.md`
**Output:** `docs/{{feature}}/plan.md`

## Instructions

1. **Read the design:** Load `docs/{{feature}}/design.md`
2. **Assess complexity:** Check scope and estimated task count
3. **Choose skill:**
   - **8+ tasks or complex?** → Use `blueprint-maestro`
   - **< 5 simple tasks?** → Use `blueprint` skill
4. **Create the plan** with gap analysis and reviews

## What Happens

**With blueprint-maestro (recommended for complex):**
1. Task outline → Gap analysis → Batched planning → Reviews → Done

**With blueprint skill (simple plans):**
1. Task outline → Gap analysis → Single-pass planning → Review → Done

**Default to maestro when in doubt.**

## Next Step

```
/go-time {{feature}}
```
