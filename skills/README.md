# Skills

GitHub 开源 Agent Skills 集合，按仓库归档。每个子目录对应一个 GitHub 仓库，包含该仓库中所有 `SKILL.md` 技能文件。

## 目录结构

```
skills/
├── README.md                    # 本文件
├── update-all.sh                # 一键更新所有仓库
├── {owner}-{repo}/              # 每个仓库一个目录
│   ├── metadata.json            # 仓库元信息（名称、stars、license 等）
│   ├── update.sh                # 该仓库的独立更新脚本
│   ├── {skill-name}/            # 每个技能一个子目录
│   │   ├── SKILL.md             # 技能定义文件
│   │   └── ...                  # 其他资源文件
│   └── ...
└── ...
```

## 快速操作

### 更新所有仓库

```bash
cd skills
./update-all.sh
```

### 更新单个仓库

```bash
cd skills/{owner}-{repo}
./update.sh
```

### 查看仓库信息

```bash
cat skills/{owner}-{repo}/metadata.json
```

## 如何新增一个 Skill 来源仓库

### 步骤

#### 1. 确认仓库包含 SKILL.md

到 GitHub 仓库中确认存在 `SKILL.md` 文件。纯 awesome list（只有链接没有 SKILL.md）不适合收录。

#### 2. 克隆仓库到临时目录

```bash
git clone --depth 1 https://github.com/{owner}/{repo}.git /tmp/{owner}-{repo}
```

#### 3. 查找 SKILL.md 文件

```bash
find /tmp/{owner}-{repo} -name "SKILL.md"
```

#### 4. 创建目标目录并复制

目录命名规则：`{owner}-{repo}`（GitHub owner 和 repo 名用 `-` 连接）

```bash
TARGET="skills/{owner}-{repo}"
mkdir -p "$TARGET"
```

复制 SKILL.md 及其同级资源文件（跳过 `.git`、`node_modules` 等）：

```bash
# 对每个找到的 SKILL.md 目录执行：
SKILL_DIR=$(dirname path/to/SKILL.md)
SKILL_NAME=$(basename "$SKILL_DIR")
mkdir -p "$TARGET/$SKILL_NAME"
cp -r "$SKILL_DIR"/* "$TARGET/$SKILL_NAME/"
```

> **注意嵌套结构**：如果仓库结构是 `plugin-name/skills/skill-name/SKILL.md`，
> 技能目录名应命名为 `plugin-name-skill-name`，避免所有技能都叫 `skills`。

#### 5. 创建 metadata.json

```json
{
  "name": "{owner}-{repo}",
  "display_name": "仓库显示名称",
  "description": "仓库描述",
  "github_url": "https://github.com/{owner}/{repo}",
  "stars": 12345,
  "license": "MIT",
  "author": "{owner}",
  "skill_count": 10,
  "last_updated": "2025-01-01T00:00:00"
}
```

#### 6. 创建 update.sh

```bash
#!/bin/bash
set -e
REPO_URL="https://github.com/{owner}/{repo}.git"
TEMP_DIR=$(mktemp -d)
TARGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔄 Updating {display_name}..."
git clone --depth 1 "$REPO_URL" "$TEMP_DIR/repo"
cd "$TEMP_DIR/repo"
SKILL_COUNT=0
while IFS= read -r skill_md; do
    SKILL_DIR=$(dirname "$skill_md")
    SKILL_NAME=$(basename "$SKILL_DIR")
    # 处理嵌套结构: plugin-name/skills/skill-name
    PARENT=$(dirname "$SKILL_DIR")
    PARENT_NAME=$(basename "$PARENT")
    if [ "$PARENT_NAME" = "skills" ]; then
        GRANDPARENT=$(dirname "$PARENT")
        SKILL_NAME="$(basename "$GRANDPARENT")-$SKILL_NAME"
    fi
    REL_PATH=$(realpath --relative-to="$TEMP_DIR/repo" "$SKILL_DIR")
    if [ "$REL_PATH" = "." ]; then SKILL_NAME="{owner}-{repo}"; fi
    echo "  📦 Updating skill: $SKILL_NAME"
    mkdir -p "$TARGET_DIR/$SKILL_NAME"
    cp -r "$SKILL_DIR"/* "$TARGET_DIR/$SKILL_NAME/" 2>/dev/null || true
    SKILL_COUNT=$((SKILL_COUNT + 1))
done < <(find . -name "SKILL.md" -not -path "*/.git/*" -not -path "*/node_modules/*")

# 更新 metadata.json 中的 stars 和 skill_count
STARS=$(curl -s "https://api.github.com/repos/{owner}/{repo}" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stargazers_count',0))" 2>/dev/null || echo "0")
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
```

设置可执行权限：

```bash
chmod +x "$TARGET/update.sh"
```

#### 7. 测试更新脚本

```bash
cd skills/{owner}-{repo}
./update.sh
```

## metadata.json 字段说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | ✅ | 目录名，格式 `{owner}-{repo}` |
| `display_name` | string | ✅ | 人类可读的仓库名称，必须是中文 |
| `description` | string | ✅ | 仓库简介，必须是中文 |
| `github_url` | string | ✅ | GitHub 仓库地址 |
| `stars` | number | ✅ | GitHub Stars 数量 |
| `license` | string | ✅ | 开源许可证（如 MIT、Apache-2.0） |
| `author` | string | ✅ | GitHub 用户名 |
| `skill_count` | number | ✅ | 包含的 SKILL.md 数量 |
| `last_updated` | string | ✅ | ISO 8601 时间戳 |

## 注意事项

- **只收录有 SKILL.md 的仓库**：纯 awesome list（只有链接）不收录
- **update.sh 使用相对路径**：基于脚本自身位置推导 `TARGET_DIR`，不硬编码绝对路径
- **嵌套结构处理**：`plugin/skills/name/SKILL.md` → 目录名用 `plugin-name`
- **跳过已有目录**：update.sh 不会覆盖已存在的技能目录
- **元数据自动更新**：每次 update 会刷新 stars 数量和 last_updated 时间
