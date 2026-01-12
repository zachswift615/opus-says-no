# Custom Claude Code Skills

A collection of custom skills for Claude Code that improve the planning and implementation workflow.

## Skills Included

### `brainstorming-to-plan`
Explore requirements and design before implementation. Use when starting any feature work to clarify goals, explore options, and make decisions.

**Flow:**
1. Understand the goal (problem, success criteria, constraints)
2. Explore solution space (2-3 options with pros/cons)
3. Make decisions (explicit choices with rationale)
4. Define scope (must have / nice to have / out of scope)
5. Hand off to `writing-plans-v2`

**Use:** `/brainstorming-to-plan`

### `writing-plans-v2`
Two-phase implementation planning with gap analysis. Creates comprehensive, gap-free implementation plans.

**The Two-Phase Approach:**
1. **Phase 1: Task Outline** - Goals, inputs, outputs, dependencies (no code yet)
2. **Phase 2: Gap Analysis** - Adversarial review to find missing pieces:
   - Connection gaps (orphan tasks?)
   - Integration gaps (wiring missing?)
   - Testing gaps (integration test?)
   - Iterate until no gaps found
3. **Phase 3: Detailed Plan** - Only now write code snippets and file paths

**Use:** `/writing-plans-v2`

## Installation

```bash
# Clone or navigate to this repo
cd ~/projects/claude-custom-skills

# Preview what will be installed
./install.sh --dry-run

# Install skills to ~/.claude/skills
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
/brainstorming-to-plan     # Explore and decide
        ↓
/writing-plans-v2          # Plan with gap analysis
        ↓
Execute the plan           # Implementation
```

For well-defined tasks where you know the approach:

```
/writing-plans-v2          # Plan with gap analysis
        ↓
Execute the plan           # Implementation
```

## File Structure

```
claude-custom-skills/
├── README.md
├── install.sh          # Install skills to ~/.claude/skills
├── uninstall.sh        # Remove installed skills
└── skills/
    ├── brainstorming-to-plan.md
    └── writing-plans-v2.md
```

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

The default planning approach often produces plans with gaps - missing integration points, tasks that don't connect, or incomplete wiring. These skills address that by:

1. **Separating exploration from planning** - Brainstorm first, plan second
2. **Adding gap analysis** - Adversarial review catches missing pieces
3. **Iterating before detailing** - Fix the outline before writing code
4. **Using Opus for review** - Better reasoning for catching subtle gaps
