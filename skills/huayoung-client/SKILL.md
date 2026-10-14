---
name: huayoung-client
description: "花漾客户端 CLI（huayoung-cli）技能：控制同一台电脑上已打开并登录的花漾桌面客户端，管理团队、分身、IP、加速通道和分身浏览器。使用于用户提到花漾客户端 CLI、花漾 CLI、huayoung-cli、桌面客户端、团队、分身、IP、指纹浏览器或浏览器控制时。它不是花漾 TK CLI（huayoungtk-cli），两者不得混用。"
metadata:
  version: 1.0.16
---

# 花漾客户端 CLI

通过 `huayoung-cli` 控制本机已打开并登录的花漾桌面客户端。

## 产品边界

| 项目 | 花漾客户端 CLI（本技能） | 花漾 TK CLI（另一个产品） |
|------|---------------------------|-----------------------------|
| 命令 | `huayoung-cli` | `huayoungtk-cli` |
| npm 包 | `@huayoung/huayoung-cli` | `@huayoung/huayoungtk-cli` |
| Skill | `huayoung-client` | `huayoungtk` |
| 连接对象 | 本机花漾桌面客户端 | 花漾 TK 平台 API |
| 典型功能 | 团队、分身、IP、浏览器 | 达人、商品、订单、索样、视频、直播 |

必须遵守：

1. 用户提到“花漾客户端 CLI”“花漾 CLI”或 `huayoung-cli` 时，只使用本技能和 `huayoung-cli`。
2. 不得将 `huayoung-cli` 替换或映射为 `huayoungtk-cli`。
3. 安装本产品时，只安装 `@huayoung/huayoung-cli`。
4. 无法判断用户指的是哪个产品时，先询问，不得猜测后执行安装或写操作。

## 核心模型

```
团队（Team）
├── 分身（Avatar）— 独立的浏览器指纹与配置环境
│   ├── IP 隔离 — 已有 IP、系统代理/VPN 或本机直连
│   ├── 加速通道 — 分身打开后的网络出口路径
│   ├── 备注与敏感信息 — 可独立获取或设置
│   ├── Cookie — 按域查看数量、查看详情、按域或 key 删除
│   └── 浏览器 — 优先通过 CLI browser 子命令控制
└── IP 资源（IP）— 可绑定到分身的代理资源
```

典型依赖链：`status` → `team info` → `avatar list` → `avatar open` → 浏览器操作。

## 资料路由

只读取当前任务所需的参考文件；不要默认加载全部资料。

- 安装、客户端发现、输出字段、状态、技能安装或配置：读取 [references/client-basics.md](references/client-basics.md)。
- 团队选择、分身搜索、分身创建/删除、分身备注、分身敏感信息、分身标签、分身 Cookie、分身 IP 隔离方式查询、浏览器打开/关闭：读取 [references/team-avatar.md](references/team-avatar.md)。
- 加速通道、网页网络故障、IP 隔离、空闲 IP 查询、IP 导入/绑定/删除、IP 标签：读取 [references/network-ip.md](references/network-ip.md)。
- 页面导航、快照、点击、填写、截图、等待、网络请求或控制台诊断：读取 [references/browser-automation.md](references/browser-automation.md)。

执行具体命令前，完整读取对应参考文件中的相关章节。跨领域任务可以读取多个文件。

## 通用执行规则

1. 先执行 `huayoung-cli status` 确认客户端在线；离线时提醒用户打开并登录花漾客户端。
2. 先用只读命令确认团队、分身、IP 或页面状态，再进行写操作。
3. 不确定参数时执行对应命令的 `--help`，不要凭记忆猜测。
4. 需要解析输出字段时先执行同一命令的 `--describe`；CLI 升级后以当前输出为准。
5. 多数业务命令输出 JSON，但不保证统一包装；stdout 是数据，stderr 是进度或提示。
6. 常规页面自动化优先使用 `browser` 子命令；只有 CLI 未覆盖的底层场景才使用 `avatar open` 返回的 CDP `wsEndpoint`。
7. 手动打开的分身默认没有 `wsEndpoint`。需要 CDP 时，先告知关闭分身会中断现有标签页和未保存状态并取得明确确认，再执行 `avatar close`，然后通过 `avatar open` 重新打开；不要把空 `wsEndpoint` 当作临时网络故障反复查询。
8. 操作后进行最小必要验证，例如重新查询资源、检查 `effects`、等待目标状态、读取新快照或截图。
9. 不记录、不回显用户密码、代理凭证、SSH 密钥和页面敏感内容。
10. 浏览器动作使用 POST 且不做传输层自动重试；连接超时后先检查页面状态，不要盲目重复点击、填写或提交。

## 授权与安全

以下操作必须在执行前获得用户明确确认：

- `team switch`
- `avatar create`、`avatar delete`
- `avatar sensitive-info set`
- `avatar cookies delete`
- `ip create`、`ip delete`
- 切换到 VIP 或其他收费加速通道
- `browser upload-file`、`browser evaluate`
- 为获取 `wsEndpoint` 而关闭并重开正在运行的分身
- 网页中的发布、付款、删除、授权等不可逆或外部影响操作

普通导航、列表查询、页面快照、截图，以及填写用户已明确指定的内容，不需要额外确认。

收费通道必须先读取 `references/network-ip.md` 中的扣费规则，明确告知可能产生花瓣扣费，并在用户同意后执行。

## 标准工作流

```bash
huayoung-cli status
huayoung-cli team info
huayoung-cli avatar list --team-id $TEAM_ID
huayoung-cli avatar get --team-id $TEAM_ID --avatar-id $AVATAR_ID
huayoung-cli avatar open --team-id $TEAM_ID --avatar-id $AVATAR_ID
```

打开分身后：

1. 使用 `browser pages` 确认目标标签页。
2. 使用 `browser navigate` 导航；已知角色、名称、标签或稳定属性时优先使用 `browser locate`，需要理解完整页面结构时使用 `browser snapshot`。
3. 从 locate 候选或最新快照读取 uid 后执行元素交互；候选不唯一时先结合页面结构缩小条件。
4. 导航、刷新、文档切换或元素重建后重新获取快照，不重试旧 uid。
5. 网页慢、打不开或频繁网络错误时，先读取网络资料并执行 `avatar channel ping`。
6. 调试页面时，先用 `browser network list` 或 `browser console list` 定位，再读取具体记录。

## 配置原则

使用 CLI 前，确保花漾客户端已打开并登录。配置细节见 `references/client-basics.md`。
