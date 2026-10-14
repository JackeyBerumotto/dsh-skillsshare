# 网络与 IP

本文档收录分身加速通道、IP 隔离和 IP 资源管理。切换收费通道前必须获得用户明确确认。

## 目录

- [加速通道管理](#加速通道管理avatar-channel)
- [IP 隔离设置](#ip-隔离设置)
- [IP 资源](#ip-资源ip)

### 加速通道管理（avatar channel）

> ⚠️ **扣费警告**：`switch` 切换到 VIP/收费通道（groupName 含 "VIP"、"收费" 字样，或来自付费接入点）时，
> 会按实际流量扣除花瓣。**调用 `switch` 前必须**：
> 1. 先 `avatar channel list` 查看通道列表，识别哪些是收费通道
> 2. 切换前向用户明确说明："该通道为收费通道，会产生花瓣扣费，是否继续？"
> 3. 用户同意后再执行 `switch`

加速通道是分身的网络出口路径（直连、用户自有、中转、跳板、Clash 等）。
所有 channel 子命令都要求分身**已经通过 `avatar open` 打开**——未打开时会报错并提示先打开分身。

#### 何时需要测速 / 切换通道

分身浏览器的网络异常往往源于当前加速通道质量差，遇到以下情况应主动建议用户测速并视情况切换：

- 页面打开明显慢（白屏 / 加载超过 10 秒、资源长期 pending）
- 页面打不开（`ERR_CONNECTION_TIMED_OUT`、`ERR_PROXY_CONNECTION_FAILED`、`ERR_TUNNEL_CONNECTION_FAILED`、`ERR_NAME_NOT_RESOLVED` 等）
- 频繁断流、连接重置、SSL 握手失败
- 视频 / 大文件加载卡顿或失败
- `browser navigate` 反复超时

推荐排障流程：

1. 先 `avatar channel ping --avatar-id $AVATAR_ID` 测每个可切换接入点的延迟（5~15 秒）。
2. 看当前接入点（`isCurrent=true`）的延迟：
   - 直连（`tunnelType=direct`）通常较慢是正常的；但如果当前用的是中转 / 专线通道（`tunnelType=transit` 等）且延迟 >2000ms，或出现 `Unavailable`、`probeError`，说明通道异常。
3. 向用户说明情况：「当前通道延迟 XX ms / 不可用，建议切换」，并给出两个选项：
   - `--auto`：客户端自动选延迟最低的可用通道
   - 指定 `--group-id`：从 `list` 输出里挑一个延迟最低的接入点的 groupId
4. 切换前**必须按上面的扣费警告确认**：哪怕延迟再差，只要目标通道是 VIP / 收费通道，都要先告知用户并征得同意。

#### 列出可用加速通道

```bash
huayoung-cli avatar channel list --avatar-id $AVATAR_ID
```

返回字段（对齐 UI 心智模型，只暴露用户能理解和操作的字段）：
- `channelId`：当前主通道 ID（用于 ping/switch）
- `primary`：是否为主通道
- `targetIp`：当前出口 IP（`remoteIp` / `ipName` / `country` / `city`）
- `currentEndpointVo`：当前正在使用的接入点（结构同 endpoints 元素）
- `endpoints`：可切换的接入点列表（与 UI 一致）
  - `groupId` / `groupName`：通道分组 ID 和名称（switch 用 `--group-id` 指定；直连为 0/null）
  - `tunnelType`：通道类型（direct、localFrontend、transit、jump、clash、platform）
  - `nodeName` / `nodeId`：节点信息
  - `isCurrent`：是否为当前接入点
- `notes`：人类可读的网络备注
- `speedLimit`：限速（kbps，0 表示不限速）

#### 测试每个接入点的延迟

```bash
huayoung-cli avatar channel ping --avatar-id $AVATAR_ID
```

触发客户端对每个**可切换接入点**（即 list.endpoints）发起链路探测（客户端 → 接入点 → 代理 IP）。
测试通常需要 5~15 秒。返回的 items 与 list.endpoints 一一对应，包含：
- `groupId` / `groupName` / `nodeName` / `tunnelType` / `isCurrent`：接入点身份（同 list.endpoints）
- `status`：Available / Unavailable / Pending
- `testingTime`：延迟（毫秒），失败时为 -1
- `remoteIp`：出口 IP（仅直连类型）
- `probeError`：错误信息（仅 Unavailable 时）

#### 切换加速通道

```bash
# 自动切换（客户端选择延迟最优的可用通道）
huayoung-cli avatar channel switch --avatar-id $AVATAR_ID --auto

# 指定通道切换（groupId 必填；nodeId/proxyId/tunnelType 可选）
huayoung-cli avatar channel switch --avatar-id $AVATAR_ID --group-id $GROUP_ID
huayoung-cli avatar channel switch --avatar-id $AVATAR_ID --group-id $GROUP_ID --node-id $NODE_ID --tunnel-type transit
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID（分身必须已打开） |
| `--auto` | bool | 否 | 自动选择最优通道（与 `--group-id` 互斥） |
| `--group-id` | int | 否 | 目标通道分组 ID（非 `--auto` 模式下必填） |
| `--node-id` | int | 否 | 目标节点 ID（用于多节点分组中指定具体节点） |
| `--proxy-id` | int | 否 | 目标 Clash 代理 ID（仅 clash 类型） |
| `--tunnel-type` | string | 否 | 目标通道类型 |

切换成功后浏览器会自动重载页面以应用新通道。频繁切换会被客户端拒绝（错误信息："切换加速通道过于频繁"）。

### IP 隔离设置

每个分身必须设置 IP 隔离后才能打开浏览器。CLI 提供以下 IP 隔离方式：

| 方式 | 命令 | 说明 |
|------|------|------|
| 绑定已有 IP 资源 | `avatar bind-ip` | 将已导入的代理 IP 绑定到分身 |
| 使用系统代理/VPN | `avatar set-proxy --type system` | 分身使用操作系统配置的代理或 VPN |
| 使用本机直连 | `avatar set-proxy --type direct` | 分身直接用本机真实 IP 出网，不走任何代理 |

#### 按 IP 隔离方式查询分身

```bash
# 使用本机 IP 直连
huayoung-cli avatar list --team-id $TEAM_ID --ip-type direct

# 使用系统代理/VPN
huayoung-cli avatar list --team-id $TEAM_ID --ip-type system

# 使用已绑定 IP（包括 IP 资源、IP 池和临时 IP）
huayoung-cli avatar list --team-id $TEAM_ID --ip-type ip

# 未设置 IP 隔离
huayoung-cli avatar list --team-id $TEAM_ID --ip-type no-ip
```

查询时会检查团队的全部分身，结果支持 `--page` 和 `--page-size` 分页。

#### 绑定 / 解绑 IP 资源

```bash
# 绑定 IP（用 ip list --unbound 查看可绑定的空闲 IP）
huayoung-cli avatar bind-ip --team-id $TEAM_ID --avatar-id $AVATAR_ID --ip-id $IP_ID

# 解绑 IP
huayoung-cli avatar unbind-ip --team-id $TEAM_ID --avatar-id $AVATAR_ID --ip-id $IP_ID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--avatar-id` | int | 是 | 分身 ID |
| `--ip-id` | int | 是 | IP 资源 ID |

#### 设置系统代理或本机直连

```bash
# 使用系统代理/VPN（分身通过操作系统代理出网）
huayoung-cli avatar set-proxy --team-id $TEAM_ID --avatar-id $AVATAR_ID --type system

# 使用本机直连（分身直接用本机真实 IP 出网）
huayoung-cli avatar set-proxy --team-id $TEAM_ID --avatar-id $AVATAR_ID --type direct
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--avatar-id` | int | 是 | 分身 ID |
| `--type` | string | 是 | `system`（系统代理/VPN）或 `direct`（本机直连） |

---

## IP 资源（IP）

### 列出 IP 资源

需要查找“空闲 IP”“可绑定 IP”或“没有绑定分身的 IP”时，执行：

```bash
huayoung-cli ip list --team-id $TEAM_ID --unbound
```

该命令返回当前未绑定任何分身的 IP，可直接用于 `avatar bind-ip`。它判断的是当前绑定状态；曾经绑定过但现在已经解绑的 IP 也会返回。

```bash
# 列出所有 IP
huayoung-cli ip list --team-id $TEAM_ID

# 按 IP 名称或地址模糊查询
huayoung-cli ip list --team-id $TEAM_ID --query "1.2.3"
huayoung-cli ip list --team-id $TEAM_ID --query "日本住宅"

# 查找当前可绑定给分身的空闲 IP
huayoung-cli ip list --team-id $TEAM_ID --unbound

# 按单个标签名称精确过滤
huayoung-cli ip list --team-id $TEAM_ID --tag "日本住宅"

# 分页
huayoung-cli ip list --team-id $TEAM_ID --page 2 --page-size 10
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--page` | int | 否 | 页码，默认 1 |
| `--page-size` | int | 否 | 每页数量，默认 20 |
| `--query` | string | 否 | 按 IP 名称或地址模糊查询 |
| `--unbound` | bool | 否 | 仅显示当前未绑定任何分身的空闲 IP |
| `--tag` | string | 否 | 按单个标签名称精确过滤 |


### 获取 IP 详情

```bash
huayoung-cli ip get --team-id $TEAM_ID --ip-id $IP_ID
```

返回结果中的 `shops` 是该 IP 当前绑定的所有分身。

```bash
# 只查看该 IP 绑定的分身 ID 和名称
huayoung-cli ip get \
  --team-id $TEAM_ID \
  --ip-id $IP_ID \
  --jq '.shops | map({id, name})'
```

只有 IP 地址、不知道资源 ID 时，先按地址查询，再将返回的 `id` 传给 `ip get`：

```bash
huayoung-cli ip list --team-id $TEAM_ID --query "1.2.3.4" --jq '.list[] | {id, ip}'
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--ip-id` | int | 是 | IP 资源 ID |

### 查看 IP 绑定的分身

```bash
huayoung-cli ip avatars --team-id $TEAM_ID --ip-id $IP_ID

# 只输出分身 ID 和名称
huayoung-cli ip avatars --team-id $TEAM_ID --ip-id $IP_ID --jq '.[] | {id, name}'
```

该命令直接返回分身数组；没有绑定分身时返回空数组 `[]`。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--ip-id` | int | 是 | IP 资源 ID |

### 管理 IP 标签

```bash
# 查看 IP 当前标签
huayoung-cli ip tag list --team-id $TEAM_ID --ip-id $IP_ID

# 按名称添加标签
huayoung-cli ip tag add --team-id $TEAM_ID --ip-id $IP_ID --tag "日本住宅"

# 按名称移除标签
huayoung-cli ip tag remove --team-id $TEAM_ID --ip-id $IP_ID --tag "日本住宅"
```

`remove` 只从该 IP 移除标签，不影响其他资源使用同名标签。添加或移除后，重新执行 `ip tag list` 验证结果。


### 导入代理 IP

```bash
# 基本导入
huayoung-cli ip create --team-id $TEAM_ID --proxy-type socks5 --host 1.2.3.4 --port 1080

# 带认证
huayoung-cli ip create --team-id $TEAM_ID --proxy-type socks5 --host 1.2.3.4 --port 1080 --username user --password pass

# SSH 代理
huayoung-cli ip create --team-id $TEAM_ID --proxy-type ssh --host 1.2.3.4 --port 22 --ssh-key "ssh-rsa ..."

# 带名称和描述
huayoung-cli ip create --team-id $TEAM_ID --proxy-type http --host 1.2.3.4 --port 8080 --name "my-proxy" --description "测试用"

# 动态 IP（带刷新 URL）
huayoung-cli ip create --team-id $TEAM_ID --proxy-type socks5 --host 1.2.3.4 --port 1080 --dynamic --refresh-url "http://api.proxy.com/refresh"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--proxy-type` | string | 是 | 代理协议（socks5、http、ssh、ipgo、vps） |
| `--host` | string | 是 | 代理主机地址 |
| `--port` | int | 是 | 代理端口 |
| `--username` | string | 否 | 代理用户名 |
| `--password` | string | 否 | 代理密码 |
| `--ssh-key` | string | 否 | SSH 密钥（proxy-type 为 ssh 时使用） |
| `--name` | string | 否 | IP 名称 |
| `--description` | string | 否 | IP 描述 |
| `--dynamic` | bool | 否 | 是否动态 IP |
| `--ipv6` | bool | 否 | 是否 IPv6 |
| `--exclusive` | bool | 否 | 是否独享 IP |
| `--provider` | string | 否 | IP 来源标识 |
| `--refresh-url` | string | 否 | 动态 IP 刷新 URL |


### 删除 IP 资源

```bash
huayoung-cli ip delete --team-id $TEAM_ID --ip-id $IP_ID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--team-id` | int | 是 | 团队 ID |
| `--ip-id` | int | 是 | IP 资源 ID |

---
