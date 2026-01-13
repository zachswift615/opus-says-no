#!/bin/bash
#
# Uninstall custom Claude Code skills from the global skills directory
#
# Usage: ./uninstall.sh [--dry-run]
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
    echo "DRY RUN - no files will be removed"
    echo ""
fi

echo "Uninstalling custom skills, prompts, and commands..."
echo "  Skills: $SKILLS_TARGET"
echo "  Prompts: $PROMPTS_TARGET"
echo "  Commands: $COMMANDS_TARGET"
echo ""

# Remove flat skill files
for skill_file in "$SKILLS_SOURCE"/*.md; do
    if [[ -f "$skill_file" ]]; then
        skill_name=$(basename "$skill_file")
        target_file="$SKILLS_TARGET/$skill_name"

        if [[ -f "$target_file" ]]; then
            echo "  [REMOVE] $skill_name"
            if [[ "$DRY_RUN" == false ]]; then
                rm "$target_file"
            fi
        else
            echo "  [SKIP]   $skill_name (not installed)"
        fi
    fi
done

# Remove directory skills
for skill_dir in "$SKILLS_SOURCE"/*/; do
    if [[ -d "$skill_dir" ]]; then
        skill_name=$(basename "$skill_dir")

        # Check if it's a valid skill directory (has SKILL.md in source)
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            target_dir="$SKILLS_TARGET/$skill_name"

            if [[ -d "$target_dir" ]]; then
                echo "  [REMOVE] $skill_name/ (directory skill)"
                if [[ "$DRY_RUN" == false ]]; then
                    rm -rf "$target_dir"
                fi
            else
                echo "  [SKIP]   $skill_name/ (not installed)"
            fi
        fi
    fi
done

# Remove each prompt that exists in our source
for prompt_file in "$PROMPTS_SOURCE"/*.md; do
    if [[ -f "$prompt_file" ]]; then
        prompt_name=$(basename "$prompt_file")
        target_file="$PROMPTS_TARGET/$prompt_name"

        if [[ -f "$target_file" ]]; then
            echo "  [REMOVE] prompts/$prompt_name"
            if [[ "$DRY_RUN" == false ]]; then
                rm "$target_file"
            fi
        else
            echo "  [SKIP]   prompts/$prompt_name (not installed)"
        fi
    fi
done

# Remove each command that exists in our source
for command_file in "$COMMANDS_SOURCE"/*.md; do
    if [[ -f "$command_file" ]]; then
        command_name=$(basename "$command_file")
        target_file="$COMMANDS_TARGET/$command_name"

        if [[ -f "$target_file" ]]; then
            echo "  [REMOVE] commands/$command_name"
            if [[ "$DRY_RUN" == false ]]; then
                rm "$target_file"
            fi
        else
            echo "  [SKIP]   commands/$command_name (not installed)"
        fi
    fi
done

echo ""
if [[ "$DRY_RUN" == false ]]; then
    echo "Done! Custom skills, prompts, and commands removed."
else
    echo "Dry run complete. Run without --dry-run to uninstall."
fi
