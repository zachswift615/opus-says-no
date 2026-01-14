---
name: plan-from-design
description: Create an implementation plan from a design document using the implementation-planning skill
arguments:
  - name: design_doc_path
    description: Path to the design document file (e.g., docs/user-auth/design.md)
    required: true
---

# Create Implementation Plan from Design Document

Create a comprehensive implementation plan from the design document using the **implementation-planning** skill.

**Design document:** @{{design_doc_path}}

## Instructions

1. **Read the design document:** Load the complete design document from the specified file
2. **Assess complexity:** Check the design scope and estimated task count
3. **Choose planning skill:**
   - **8+ tasks or complex?** → Use `implementation-planning-orchestrator` (recommended)
   - **< 5 simple tasks?** → Use `implementation-planning`
4. **Pass design context:** Ensure the planning skill has access to:
   - Problem & Goals
   - Chosen Approach
   - Key Decisions
   - Scope definition
   - User Stories (if present)
   - Any constraints or requirements

## What Happens Next

**With implementation-planning-orchestrator (recommended):**
1. Create task outline
2. Gap analysis with Opus subagent
3. Batched detailed planning (fresh agents per batch)
4. Incremental batch reviews
5. Final holistic plan review
6. Output `/execute-plan` command

**With implementation-planning (simple plans only):**
1. Create task outline
2. Gap analysis with Opus subagent
3. Write complete detailed plan in one pass
4. Final plan review
5. Output `/execute-plan` command

The design document provides the "WHAT" and "WHY" - the implementation plan adds the "HOW" with tasks, code, and verification steps.

**Default to orchestrator when in doubt** - it handles any plan size gracefully.
