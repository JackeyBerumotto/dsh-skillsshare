# 团队与分身

本文档收录团队选择、分身创建与删除、浏览器启停等资源生命周期命令。涉及网络出口、通道或 IP 时改读 `network-ip.md`。

## 目录

- [团队](#团队team)
- [分身](#分身avatar)

## 团队（Team）

### 查看当前团队

```bash
huayoung-cli team info
```

显示客户端当前选中团队的详细信息，包括团队名称、类型、状态、用户角色等。


### 列出已加入团队

```bash
huayoung-cli team list
```

列出当前登录用户加入的所有团队。支持 `--page` 和 `--page-size` 分页（默认 page=1, pageSize=20）。返回分页结构 `{current, pageSize, total, list}`，字段同 `team info`。

### 切换当前团队

```bash
huayoung-cli team switch --team-id $TEAM_ID
```

切换后其他依赖团队的命令将使用新团队。当 `team info` 报错"未选中团队"时，需要先执行此命令。

---

## 分身（Avatar）

### 列出分身

```bash
huayoung-cli avatar list --team-id $TEAM_ID

# 按分身名称或绑定 IP 模糊查询
huayoung-cli avatar list --team-id $TEAM_ID --query "demo"

# 按单个标签名称精确过滤
huayoung-cli avatar list --team-id $TEAM_ID --tag "主力店铺"

# 按 IP 隔离方式筛选
huayoung-cli avatar list --team-id $TEAM_ID --ip-type direct
huayoung-cli avatar list --team-id $TEAM_ID --ip-type system
huayoung-cli avatar list --team-id $TEAM_ID --ip-type ip
huayoung-cli avatar list --team-id $TEAM_ID --ip-type no-ip
```

支持 `--page` 和 `--page-size` 分页（默认 page=1, pageSize=20），使用 `--query` 可按分身名称或绑定 IP 模糊查询，使用 `--tag` 可按单个标签名称精确过滤。`--ip-type` 支持 `direct`（本机 IP 直连）、`system`（系统代理/VPN）、`ip`（已绑定 IP，包括 IP 资源、IP 池和临时 IP）和 `no-ip`（未设置 IP 隔离）。按 IP 隔离方式筛选时，CLI 会自动检查所有分页。返回分页结构 `{current, pageSize, total, list}`，`list` 中每个分身包含完整信息，常用字段包括：

| 字段 | 说明 |
|------|------|
| `id` | 分身 ID |
| `name` | 分身名称 |
| `teamId` | 团队 ID |
| `platform` | 平台与站点信息 |
| `tags` | 分身标签 |
| `channels` | 通道及绑定的 IP 信息 |
| `fingerprintVo` | 浏览器指纹信息 |
| `lanProxy` | 本机网络代理设置 |

`avatar list` 不返回浏览器运行状态和 `wsEndpoint`。需要打开浏览器或获取 CDP 地址时使用 `avatar open`。

### 获取分身详情

```bash
huayoung-cli avatar get --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 只查看标签和通道/IP
huayoung-cli avatar get --team-id $TEAM_ID --avatar-id $AVATAR_ID --jq '{id, name, tags, channels}'
```

该命令返回指定分身的完整详情。

### 查看可用平台

```bash
huayoung-cli avatar platforms
```

列出创建分身时可选择的所有平台和站点，用于确定 `--platform-id`。


### 创建分身

```bash
# 创建单个分身
huayoung-cli avatar create --team-id $TEAM_ID --name "test" --platform-id 1

# 批量创建（name 作为前缀，生成 test-1、test-2...）
huayoung-cli avatar create --team-id $TEAM_ID --name "batch" --platform-id 1 --count 5

# 带备注
huayoung-cli avatar create --team-id $TEAM_ID --name "shop-01" --platform-id 1 --description "主力店铺"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--name` | string | 是 | 分身名称（`--count` > 1 时作为前缀） |
| `--platform-id` | int | 是 | 平台 ID（用 `avatar platforms` 查看） |
| `--count` | int | 否 | 创建数量，默认 1 |
| `--description` | string | 否 | 备注 |

### 管理分身备注

```bash
# 获取备注
huayoung-cli avatar description get --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 设置备注
huayoung-cli avatar description set --team-id $TEAM_ID --avatar-id $AVATAR_ID --value "主力店铺"

# 清空备注
huayoung-cli avatar description set --team-id $TEAM_ID --avatar-id $AVATAR_ID --value ""
```

`get` 返回 `avatarId` 和 `description`。设置后再次执行 `get` 验证结果。

### 管理分身敏感信息

```bash
# 获取敏感信息
huayoung-cli avatar sensitive-info get --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 设置敏感信息
huayoung-cli avatar sensitive-info set --team-id $TEAM_ID --avatar-id $AVATAR_ID --value "仅本人可见的内容"

# 清空敏感信息
huayoung-cli avatar sensitive-info set --team-id $TEAM_ID --avatar-id $AVATAR_ID --value ""
```

`get` 返回 `avatarId` 和 `sensitiveInfo`；内容可能包含账号、密钥等敏感数据，不得写入日志或发送给无关人员。`set` 不回显内容，但参数可能保留在 shell 历史中。覆盖或清空前先执行 `get`，并取得用户明确确认；设置后再次执行 `get` 验证结果，验证时不要复述敏感内容。


### 删除分身

```bash
huayoung-cli avatar delete --team-id $TEAM_ID --avatar-id $AVATAR_ID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--avatar-id` | int | 是 | 分身 ID |

### 管理分身标签

```bash
# 查看分身当前标签
huayoung-cli avatar tag list --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 按名称添加标签
huayoung-cli avatar tag add --team-id $TEAM_ID --avatar-id $AVATAR_ID --tag "主力店铺"

# 按名称移除标签
huayoung-cli avatar tag remove --team-id $TEAM_ID --avatar-id $AVATAR_ID --tag "主力店铺"
```

`remove` 只解除标签与该分身的关联，不删除团队的标签定义。添加或移除后，重新执行 `avatar tag list` 验证结果。

### 管理分身 Cookie

```bash
# 按域名列出 Cookie 数量；不返回 Cookie 值
huayoung-cli avatar cookies domains --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 查看一个域名下的全部 Cookie 详情（包含敏感的 Cookie 值）
huayoung-cli avatar cookies list --team-id $TEAM_ID --avatar-id $AVATAR_ID --domain .example.com

# 删除一个域名下的全部 Cookie
huayoung-cli avatar cookies delete --team-id $TEAM_ID --avatar-id $AVATAR_ID --domain .example.com

# 删除多个域名
huayoung-cli avatar cookies delete --team-id $TEAM_ID --avatar-id $AVATAR_ID --domain .example.com --domain login.example.com

# 只删除一个域名下指定的 Cookie key，其余 Cookie 保留
huayoung-cli avatar cookies delete --team-id $TEAM_ID --avatar-id $AVATAR_ID --domain .example.com --name unwanted_key_1 --name unwanted_key_2
```

不带 `--name` 的 `delete` 会删除指定域名下的全部 Cookie。带 `--name` 时只能指定一个域名，CLI 会保留该域名下名称不匹配的 Cookie。Cookie 操作可能使网站退出登录；删除前先执行 `domains` 或 `list` 确认目标，删除后再次查询验证结果。`list` 返回的 `value` 是敏感登录凭证，不得写入日志或发送给无关人员。

### 打开分身浏览器

```bash
# 打开浏览器
huayoung-cli avatar open --team-id $TEAM_ID --avatar-id $AVATAR_ID

# 打开并导航到指定 URL
huayoung-cli avatar open --team-id $TEAM_ID --avatar-id $AVATAR_ID --url "https://example.com"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--team-id` | int | 是 | 团队 ID |
| `--url` | string | 否 | 打开后要导航的 URL |

如果分身的浏览器已经打开，会将其带到前台。

手动从客户端界面打开的分身，其 `wsEndpoint` 默认为空；对已经运行的该分身再次执行 `avatar open` 只会将窗口带到前台，不能为现有进程补开 CDP 端点。若任务明确需要非空 `wsEndpoint`：

1. 告知用户关闭分身会中断现有标签页、登录流程和未保存页面状态，并取得明确确认。
2. 执行 `huayoung-cli avatar close --avatar-id $AVATAR_ID`。
3. 执行 `huayoung-cli avatar open --team-id $TEAM_ID --avatar-id $AVATAR_ID`，使用新响应中的 `wsEndpoint`。
4. 若仍为空，停止重试并报告异常；不要继续反复关闭和打开。


### 关闭分身浏览器

```bash
huayoung-cli avatar close --avatar-id $AVATAR_ID
```

关闭分身会终止其浏览器进程。不要仅为尝试修复空 `wsEndpoint` 而在未确认的情况下关闭用户手动打开的分身。
