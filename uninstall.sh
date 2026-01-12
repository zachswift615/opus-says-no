#!/bin/bash
#
# Uninstall custom Claude Code skills from the global skills directory
#
# Usage: ./uninstall.sh [--dry-run]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SOURCE="$SCRIPT_DIR/skills"
SKILLS_TARGET="$HOME/.claude/skills"

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "DRY RUN - no files will be removed"
    echo ""
fi

echo "Uninstalling custom skills..."
echo "  Target: $SKILLS_TARGET"
echo ""

# Remove each skill that exists in our source
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

echo ""
if [[ "$DRY_RUN" == false ]]; then
    echo "Done! Custom skills removed."
else
    echo "Dry run complete. Run without --dry-run to uninstall."
fi
