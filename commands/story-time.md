---
name: story-time
description: Decompose a design into a validated task outline with gap analysis
arguments:
  - name: feature
    description: Feature name (e.g., user-auth). Reads from docs/<feature>/design.md
    required: true
---

# Story Time

Break down **{{feature}}** into a validated task outline.

**Design document:** `docs/{{feature}}/design.md`
**Output:** `docs/{{feature}}/plan.md`

## Instructions

1. **Read the design:** Load `docs/{{feature}}/design.md`
2. **Invoke story-time skill**
3. **Follow the workflow:**
   - Read design document, create plan file header
   - Spawn task outline agent (background, opus)
   - Spawn gap analysis agent (background, opus)
   - Fix gaps with fresh fix agents until clean
   - Save validated outline

## What Happens

Story-time produces a gap-free task outline with:
- Goals, inputs, outputs for every task
- Acceptance criteria
- Dependency graph (no orphans)
- Validated by adversarial gap analysis

## Next Step

```
/blueprint-maestro docs/{{feature}}/plan.md
```

Or use `/blueprint {{feature}}` which will detect the outline and route automatically.
