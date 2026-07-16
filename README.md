# NTD 内置资源仓库

本仓库存储 NTD（Nothing-Todo）系统的内置资源，包括专家、技能和模板。

## 目录结构

```
ntd-resource/
├── experts/          # 专家定义（WorkBuddy 格式）
├── skills/           # 内置技能
└── templates/        # Todo 模板
```

## experts 目录

存放专家和专家团队定义，采用 WorkBuddy 兼容格式。

### plugin.json 格式

单个专家：

```json
{
  "name": "senior-developer",
  "displayName": { "en": "Senior Developer", "zh": "资深开发工程师" },
  "description": "经验丰富的全栈开发专家",
  "profession": "软件开发",
  "avatar": "avatars/avatar.png",
  "agent_name": "senior-developer",
  "type": "agent",
  "skills": ["code-review", "refactoring"]
}
```

专家团队：

```json
{
  "name": "software-company",
  "type": "team",
  "displayName": { "zh": "软件公司" },
  "teamInfo": {
    "leader": "cto",
    "members": ["frontend-dev", "backend-dev"]
  }
}
```

## 同步机制

NTD 应用启动时自动从本仓库克隆/拉取最新资源到本地 `~/.ntd/bundled/` 目录。
