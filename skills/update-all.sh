#!/bin/bash
# Master update script for all skill repos
# Run this to update all skills from their latest versions.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOTAL=0
UPDATED=0
FAILED=0

echo "🔄 Master Update: All Skill Repos"
echo "=================================="
echo ""

for dir in "$SCRIPT_DIR"/*/; do
    [ ! -f "$dir/update.sh" ] && continue
    name=$(basename "$dir")
    TOTAL=$((TOTAL + 1))
    
    echo "[$TOTAL] Updating: $name"
    if bash "$dir/update.sh" 2>&1 | tail -1; then
        UPDATED=$((UPDATED + 1))
    else
        echo "  ❌ FAILED"
        FAILED=$((FAILED + 1))
    fi
    echo ""
done

echo "=================================="
echo "✅ Complete: $UPDATED updated, $FAILED failed (of $TOTAL total)"
