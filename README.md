# Custom Claude Code Skills

A collection of custom skills for Claude Code that improve the planning and implementation workflow.

## Skills Included

### `brainstorming-to-plan`
Explore requirements and design before implementation. Use when starting any feature work to clarify goals, explore options, and make decisions. Includes adversarial design review to catch gaps before planning.

**Flow:**
1. Understand the goal (problem, success criteria, constraints)
2. Explore solution space (2-3 options with pros/cons)
3. Make decisions (explicit choices with rationale)
4. Define scope (must have / nice to have / out of scope)
5. Write Gherkin user stories (for user-facing features)
6. Write initial design document
7. **Adversarial design review** (Opus subagent challenges the design)
8. Incorporate feedback & iterate
9. Hand off to `implementation-planning`

**Use:** `/brainstorming-to-plan`

### `implementation-planning`
Three-phase implementation planning with adversarial gap analysis. Creates comprehensive, gap-free, executable implementation plans.

**The Three-Phase Approach:**
1. **Phase 1: Task Outline** - Goals, inputs, outputs, dependencies (no code yet)
2. **Phase 2: Adversarial Gap Analysis** - Opus subagent finds structural gaps:
   - Connection gaps (orphan tasks, missing inputs/outputs)
   - Integration gaps (wiring missing?)
   - Testing gaps (integration test?)
   - Error handling gaps
   - Iterate until no gaps found
3. **Phase 3: Detailed Plan** - Write complete code, exact file paths, verification steps
4. **Phase 4: Final Plan Review** - Opus subagent verifies executability:
   - No placeholders in code
   - File paths are specific
   - Commands are clear
   - Verification steps are testable

**Use:** `/implementation-planning`

Then execute with: `/execute-plan <path-to-plan>`

## Installation

```bash
# Clone or navigate to this repo
cd ~/projects/claude-custom-skills

# Preview what will be installed
./install.sh --dry-run

# Install skills, prompts, and commands
./install.sh
```

## Uninstallation

```bash
# Preview what will be removed
./uninstall.sh --dry-run

# Remove skills
./uninstall.sh
```

## Workflow

For new features or complex tasks:

```
/brainstorming-to-plan              # Explore and decide (includes design review)
        ↓
/plan-from-design <design-doc>      # Create implementation plan from design
        ↓
/execute-plan <plan-file>           # Coordinated execution with subagents
```

For well-defined tasks where you know the approach:

```
/implementation-planning            # Plan with gap analysis
        ↓
/execute-plan <plan-file>           # Coordinated execution with subagents
```

## Commands Included

### `/plan-from-design <path>`
Create an implementation plan from a design document using the `implementation-planning` skill.

**Usage:** `/plan-from-design docs/designs/2026-01-12-feature-name.md`

This command loads your design document and invokes `implementation-planning`, which will:
- Create a task outline based on your design
- Run gap analysis with Opus subagent
- Write the detailed implementation plan
- Run final plan review with Opus subagent
- Output the `/execute-plan` command to run it

### `/execute-plan <path>`
Execute an implementation plan using coordinated subagent orchestration.

**Usage:** `/execute-plan docs/plans/2026-01-12-feature-name.md`

This command loads the plan and invokes the execution orchestration skill, which:
- Breaks the plan into independent tasks
- Spawns subagents for parallel execution where possible
- Coordinates dependencies between tasks
- Reviews work at logical checkpoints
- Ensures integration points are properly connected

## File Structure

```
claude-custom-skills/
├── README.md
├── install.sh                       # Install skills, prompts, and commands
├── uninstall.sh                     # Remove installed files
├── skills/
│   ├── brainstorming-to-plan/
│   │   ├── SKILL.md                 # Main skill
│   │   └── design-review.md         # Design review prompt
│   └── implementation-planning/
│       ├── SKILL.md                 # Main skill
│       ├── gap-analysis-review.md   # Gap analysis prompt
│       └── plan-review.md           # Final review prompt
├── prompts/                         # Shared prompts (also in skill dirs)
│   ├── design-review.md
│   ├── gap-analysis-review.md
│   └── plan-review.md
└── commands/
    ├── plan-from-design.md          # Create plan from design doc
    └── execute-plan.md              # Execute plan with subagents
```

The install script copies:
- Skills → `~/.claude/skills/`
- Prompts → `~/.claude/prompts/`
- Commands → `~/.claude/commands/`

## Adding New Skills

1. Create a new `.md` file in the `skills/` directory
2. Follow the skill format with YAML frontmatter:
   ```yaml
   ---
   name: my-skill
   description: What this skill does
   model: opus  # or sonnet, haiku
   ---
   ```
3. Run `./install.sh` to deploy

## Why These Skills?

The default planning approach often produces plans with gaps - missing integration points, tasks that don't connect, incomplete wiring, or unclear instructions. These skills address that through multiple layers of adversarial review:

1. **Separating exploration from planning** - Brainstorm first, plan second
2. **Using Gherkin scenarios** - Concrete user stories reveal edge cases and gaps
3. **Design review (brainstorming)** - Fresh Opus subagent challenges designs before planning
4. **Gap analysis (planning)** - Fresh Opus subagent finds structural gaps in task outlines
5. **Plan review (planning)** - Fresh Opus subagent verifies executability of detailed plans
6. **Iterating at each stage** - Fix issues before moving to next phase
7. **Using Opus for all reviews** - Better reasoning for catching subtle gaps
8. **Subagent-driven execution** - Coordinated task execution with dependency management
