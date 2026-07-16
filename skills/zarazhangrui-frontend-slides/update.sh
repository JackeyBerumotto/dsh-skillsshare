#!/bin/bash
set -e
REPO_URL="https://github.com/zarazhangrui/frontend-slides.git"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Updating Frontend Slides..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"
cd "$TEMP_DIR/repo"
SKILL_COUNT=0
while IFS= read -r skill_md; do
    SKILL_DIR=$(dirname "$skill_md")
    SKILL_NAME=$(basename "$SKILL_DIR")
    REL_PATH=$(realpath --relative-to="$TEMP_DIR/repo" "$SKILL_DIR")
    if [ "$REL_PATH" = "." ]; then SKILL_NAME="zarazhangrui-frontend-slides"; fi
    echo "  📦 Updating skill: $SKILL_NAME"
    mkdir -p "$TARGET_DIR/$SKILL_NAME"
    cp -r "$SKILL_DIR"/* "$TARGET_DIR/$SKILL_NAME/" 2>/dev/null || true
    SKILL_COUNT=$((SKILL_COUNT + 1))
done < <(find . -name "SKILL.md" -not -path "*/.git/*" -not -path "*/node_modules/*")
STARS=$(curl -s "https://api.github.com/repos/zarazhangrui/frontend-slides" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stargazers_count',0))" 2>/dev/null || echo "0")
python3 -c "
import json, os
from datetime import datetime
meta_file = os.path.join('$TARGET_DIR', 'metadata.json')
if os.path.exists(meta_file):
    with open(meta_file) as f: meta = json.load(f)
else: meta = {}
meta['stars'] = $STARS
meta['last_updated'] = datetime.now().isoformat()
meta['skill_count'] = $SKILL_COUNT
with open(meta_file, 'w') as f: json.dump(meta, f, indent=2, ensure_ascii=False)
"
rm -rf "$TEMP_DIR"
echo "✅ Done! Updated $SKILL_COUNT skills."
