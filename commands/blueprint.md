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

1. **Check for existing plan:** Check if `docs/{{feature}}/plan.md` already exists
2. **Read the design:** Load `docs/{{feature}}/design.md`
3. **Determine path:**

### If plan.md exists with a validated outline (gap analysis complete):
- Skip to `blueprint-maestro` for detailed planning
- Use `blueprint-maestro` skill with `docs/{{feature}}/plan.md`

### If plan.md exists with detailed batches (resume scenario):
- Go directly to `blueprint-maestro` which will auto-detect resume state
- Use `blueprint-maestro` skill with `docs/{{feature}}/plan.md`

### If no plan.md or plan.md has no outline:
- **Assess complexity** from the design document
- **8+ tasks or complex?** → Use `story-time` first, then `blueprint-maestro`
- **< 5 simple tasks?** → Use `blueprint` skill directly

## What Happens

**Complex features (recommended path):**
1. `story-time` → Task outline + Gap analysis → `docs/{{feature}}/plan.md` (outline)
2. `blueprint-maestro` → Batched planning + Reviews → `docs/{{feature}}/plan.md` (detailed)

**Simple features:**
1. `blueprint` skill → Outline + Gap analysis + Single-pass planning → Done

**Default to the story-time + maestro path when in doubt.**

## Next Step

```
/go-time {{feature}}
```
