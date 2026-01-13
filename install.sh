#!/bin/bash
#
# Install custom Claude Code skills to the global skills directory
#
# Usage: ./install.sh [--dry-run]
#
# Supports both:
# - Flat skills: skills/my-skill.md
# - Directory skills: skills/my-skill/SKILL.md (with supporting files)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.claude/skills"
PROMPTS_SOURCE="$SCRIPT_DIR/prompts"
PROMPTS_TARGET="$HOME/.claude/prompts"
COMMANDS_SOURCE="$SCRIPT_DIR/commands"
COMMANDS_TARGET="$HOME/.claude/commands"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "DRY RUN - no files will be copied"
    echo ""
fi

# Ensure target directories exist
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$SKILLS_TARGET"
    mkdir -p "$PROMPTS_TARGET"
    mkdir -p "$COMMANDS_TARGET"
fi

echo "Installing custom skills, prompts, and commands..."
echo "  Skills: $SKILLS_SOURCE → $SKILLS_TARGET"
echo "  Prompts: $PROMPTS_SOURCE → $PROMPTS_TARGET"
echo "  Commands: $COMMANDS_SOURCE → $COMMANDS_TARGET"
echo ""

# Copy flat skill files (skills/*.md)
for skill_file in "$SKILLS_SOURCE"/*.md; do
    if [[ -f "$skill_file" ]]; then
        skill_name=$(basename "$skill_file")

        if [[ -f "$SKILLS_TARGET/$skill_name" ]]; then
            echo "  [UPDATE] $skill_name"
        else
            echo "  [NEW]    $skill_name"
        fi

        if [[ "$DRY_RUN" == false ]]; then
            cp "$skill_file" "$SKILLS_TARGET/$skill_name"
        fi
    fi
done

# Copy directory skills (skills/*/SKILL.md with supporting files)
for skill_dir in "$SKILLS_SOURCE"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")

        # Check if it's a valid skill directory (has SKILL.md)
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            if [[ -d "$SKILLS_TARGET/$skill_name" ]]; then
                echo "  [UPDATE] $skill_name/ (directory skill)"
            else
                echo "  [NEW]    $skill_name/ (directory skill)"
            fi

            if [[ "$DRY_RUN" == false ]]; then
                mkdir -p "$SKILLS_TARGET/$skill_name"
                # Copy all .md files in the skill directory
                for md_file in "$skill_dir"*.md; do
                    if [[ -f "$md_file" ]]; then
                        cp "$md_file" "$SKILLS_TARGET/$skill_name/"
                    fi
                done
            fi
        fi
    fi
done

# Copy each prompt
for prompt_file in "$PROMPTS_SOURCE"/*.md; do
    if [[ -f "$prompt_file" ]]; then
        prompt_name=$(basename "$prompt_file")

        if [[ -f "$PROMPTS_TARGET/$prompt_name" ]]; then
            echo "  [UPDATE] prompts/$prompt_name"
        else
            echo "  [NEW]    prompts/$prompt_name"
        fi

        if [[ "$DRY_RUN" == false ]]; then
            cp "$prompt_file" "$PROMPTS_TARGET/$prompt_name"
        fi
    fi
done

# Copy each command
for command_file in "$COMMANDS_SOURCE"/*.md; do
    if [[ -f "$command_file" ]]; then
        command_name=$(basename "$command_file")

        if [[ -f "$COMMANDS_TARGET/$command_name" ]]; then
            echo "  [UPDATE] commands/$command_name"
        else
            echo "  [NEW]    commands/$command_name"
        fi

        if [[ "$DRY_RUN" == false ]]; then
            cp "$command_file" "$COMMANDS_TARGET/$command_name"
        fi
    fi
done

echo ""
if [[ "$DRY_RUN" == false ]]; then
    echo "Done! Skills, prompts, and commands installed."
    echo ""
    echo "Skills installed to: $SKILLS_TARGET"
    echo "Prompts installed to: $PROMPTS_TARGET"
    echo "Commands installed to: $COMMANDS_TARGET"
    echo ""
    echo "Available skills:"
    # List flat skills
    for skill_file in "$SKILLS_TARGET"/*.md; do
        if [[ -f "$skill_file" ]]; then
            skill_name=$(basename "$skill_file" .md)
            echo "  /$skill_name"
        fi
    done
    # List directory skills
    for skill_dir in "$SKILLS_TARGET"/*/; do
        if [[ -d "$skill_dir" ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
            skill_name=$(basename "$skill_dir")
            echo "  /$skill_name (directory)"
        fi
    done
else
    echo "Dry run complete. Run without --dry-run to install."
fi
