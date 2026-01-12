#!/bin/bash
#
# Install custom Claude Code skills to the global skills directory
#
# Usage: ./install.sh [--dry-run]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.claude/skills"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "DRY RUN - no files will be copied"
    echo ""
fi

# Ensure target directory exists
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$SKILLS_TARGET"
fi

echo "Installing custom skills..."
echo "  Source: $SKILLS_SOURCE"
echo "  Target: $SKILLS_TARGET"
echo ""

# Copy each skill
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

echo ""
if [[ "$DRY_RUN" == false ]]; then
    echo "Done! Skills installed to $SKILLS_TARGET"
    echo ""
    echo "Available skills:"
    for skill_file in "$SKILLS_TARGET"/*.md; do
        if [[ -f "$skill_file" ]]; then
            skill_name=$(basename "$skill_file" .md)
            echo "  /$skill_name"
        fi
    done
else
    echo "Dry run complete. Run without --dry-run to install."
fi
