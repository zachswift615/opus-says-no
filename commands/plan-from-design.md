---
name: plan-from-design
description: Create an implementation plan from a design document using the implementation-planning skill
arguments:
  - name: design_doc_path
    description: Path to the design document file (e.g., docs/designs/2026-01-12-feature-name.md)
    required: true
---

# Create Implementation Plan from Design Document

Create a comprehensive implementation plan from the design document using the **implementation-planning** skill.

**Design document:** @{{design_doc_path}}

## Instructions

1. **Read the design document:** Load the complete design document from the specified file
2. **Invoke implementation-planning:** Use the Skill tool to invoke `implementation-planning`
3. **Pass design context:** Ensure the planning skill has access to:
   - Problem & Goals
   - Chosen Approach
   - Key Decisions
   - Scope definition
   - User Stories (if present)
   - Any constraints or requirements

## What Happens Next

The implementation-planning skill will:
1. Create a task outline based on the design
2. Spawn Opus subagent for gap analysis
3. Iterate until gaps are resolved
4. Write detailed implementation plan
5. Spawn Opus subagent for final review
6. Output the final plan with `/execute-plan` command

The design document provides the "WHAT" and "WHY" - the implementation plan adds the "HOW" with tasks, code, and verification steps.
