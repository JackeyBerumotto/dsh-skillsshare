#!/bin/bash
# Auto-generated update script for Scientific Agent Skills
# Repository: https://github.com/K-Dense-AI/scientific-agent-skills
# Run this script to update skills from the latest version.

set -e

REPO_URL="https://github.com/K-Dense-AI/scientific-agent-skills.git"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Updating Scientific Agent Skills..."

# Clone to temp
git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"

# Find and copy skills
cd "$TEMP_DIR/repo"
SKILL_COUNT=0
while IFS= read -r skill_md; do
    SKILL_DIR=$(dirname "$skill_md")
    SKILL_NAME=$(basename "$SKILL_DIR")

    # If at root level, use repo name
    REL_PATH=$(realpath --relative-to="$TEMP_DIR/repo" "$SKILL_DIR")
    if [ "$REL_PATH" = "." ]; then
        SKILL_NAME="K-Dense-AI-scientific-agent-skills"
    fi

    echo "  📦 Updating skill: $SKILL_NAME"
    mkdir -p "$TARGET_DIR/$SKILL_NAME"
    cp -r "$SKILL_DIR"/* "$TARGET_DIR/$SKILL_NAME/" 2>/dev/null || true
    SKILL_COUNT=$((SKILL_COUNT + 1))
done < <(find . -name "SKILL.md" -not -path "*/.git/*" -not -path "*/node_modules/*")

# Update metadata
STARS=$(curl -s "https://api.github.com/repos/K-Dense-AI/scientific-agent-skills" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stargazers_count',0))" 2>/dev/null || echo "0")
python3 -c "
import json, os
from datetime import datetime
meta_file = os.path.join('$TARGET_DIR', 'metadata.json')
if os.path.exists(meta_file):
    with open(meta_file) as f:
        meta = json.load(f)
else:
    meta = {}
meta['stars'] = $STARS
meta['last_updated'] = datetime.now().isoformat()
meta['skill_count'] = $SKILL_COUNT
with open(meta_file, 'w') as f:
    json.dump(meta, f, indent=2, ensure_ascii=False)
"

# Cleanup
rm -rf "$TEMP_DIR"

echo "✅ Done! Updated $SKILL_COUNT skills."
