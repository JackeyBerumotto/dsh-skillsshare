---
name: huayoungtk
version: 1.1.0
description: "花漾TK CLI 技能，供 AI Agent 使用 huayoungtk-cli 调用花漾TK 平台 API。适用于需要通过花漾TK平台查询、分析或管理 TikTok 公海达人、达人 CRM、买家、TikTok Shop 店铺、商品、订单、索样申请、带货视频、带货直播、商品评论、云盘、设备、手机、店铺浏览器、RPA 任务或团队信息的场景。必须使用 huayoungtk-cli；不要替换成 huayoung-cli，二者不是同一个 CLI。"
---

# huayoungtk-cli

花漾TK 官方 CLI，使用 `huayoungtk-cli` 供 AI Agent 调用花漾TK平台 API。


## 硬性规则

- 始终使用 `huayoungtk-cli`。不要使用 `huayoung-cli`，它是另一个不同的 CLI。
- 区分只读查询和会修改数据或触发 RPA 的操作。
- 用户要求查询信息时，可以直接执行只读命令。
- 执行会修改数据或触发 RPA 的命令前，必须获得用户明确确认：`creator note add`、`tag`、`status`、`shelve`、`approve`、`reject`、`sync`、`collaboration-order create`、`job cancel`、`disk cp`、`disk rm`。
- 对不可撤销或高风险操作，例如 `sample-request approve`、`sample-request reject`、`job cancel`、`disk rm`，执行前要复述目标 ID 或完整路径和计划动作。
- 批量修改前，先列出候选对象和计划修改内容，再等待用户确认。
- 查询阶段可以使用名称、handle 或关键词；进入写操作前，优先解析出明确 ID，并确认目标对象。
- OpenClaw（`OPENCLAW_CLI=1`）多用户环境下，`--openclaw-user-id` 必须传**当前发话人**的 id——谁在问就传谁。复用上一个用户或默认 id 会造成账号串用。详见“OpenClaw 多用户环境”。

## 环境检查

只有在需要确认环境、首次使用、或命令失败时才检查 CLI：

```bash
huayoungtk-cli --version
huayoungtk-cli auth status         # 当前用户身份、endpoint、授权 Key
huayoungtk-cli auth profile list   # 所有用户身份，标记 current
```

如果找不到 `huayoungtk-cli`，检查 npm 全局 bin 目录是否在 `PATH` 中。
如果认证缺失或失效，向用户索要授权 Key 后运行：

```bash
huayoungtk-cli auth login --token <access-key>                 # 用户身份名取自授权 Key 的授权名称（服务端权威，无需也无法自定义）
```

CLI 支持本地保存多组（团队 × 用户）凭证。用户要切换账号时优先用 `auth profile switch <name|index>`，不要让用户重新 login 覆盖其他用户身份。详见 `references/common.md` 的"认证（多用户身份）"。

### OpenClaw 多用户环境

当 CLI 运行在 OpenClaw（"龙虾"）下（环境变量 `OPENCLAW_CLI=1`），多人共用一台机器时，**会读写用户配置的命令必须**带上 `--openclaw-user-id <id>`（或设环境变量 `HUAYOUNGTK_CLI_OPENCLAW_USER_ID`），让每个用户读写各自的配置文件 `~/.huayoungtk-cli/config-<id>.json`，避免串号。未带 user-id 时（身份相关）命令会报错退出；`skills`、`help`、`logs` 子命令与 `--help` 不受影响（`--help` 会打印一行提示）。

- **`skills`（list/install/uninstall）、`help` 和 `logs` 子命令不读写用户配置、与身份无关，不需要 `--openclaw-user-id`**——你可先 `huayoungtk-cli skills install` 学到本技能（含本段用法），再带 user-id 调用其他命令。
- 每个用户首次使用时先 login 一次：`huayoungtk-cli auth login --openclaw-user-id <id> --token <access-key>`。
- 之后命令只需带 `--openclaw-user-id <id>`：`huayoungtk-cli --openclaw-user-id <id> team info`。
- 也可在子 Agent spawn 配置里设 `HUAYOUNGTK_CLI_OPENCLAW_USER_ID=<id>` 一次，省去每条命令都带 flag。
- user-id 建议用 OpenClaw 的 senderId（飞书 `ou_xxx`、微信 wxid）；含 `:`/`/`/空格等特殊字符会自动过滤为安全文件名。
- 非 OpenClaw 环境下 OpenClaw 参数不存在（`--openclaw-user-id` 不注册、`--help` 不显示），用默认 `config.json`，行为不变。

## 通用执行规则

- 默认输出是 JSON。需要精简字段时使用 `--jq`，需要逐行处理时使用 `-o ndjson`。
- 正常输出内容写入 stdout；错误信息和升级提示写入 stderr。解析命令结果时只读取 stdout，并将 stderr 单独展示或记录。
- CLI 最多每 24 小时检查一次 npm registry。发现新版本但仍可继续使用时，命令成功后可能在 stderr 输出"发现新版本"提示，stdout 的 JSON 不受影响；主动告知用户当前与最新版本，并建议升级。当前版本过低时，业务命令会返回 `CLI_VERSION_TOO_OLD` 且不会执行；此时必须明确要求用户依次运行下面两条命令，升级后再重试。`--help`、`--version` 和 `skills` 命令仍可使用。

```bash
npm install -g @huayoung/huayoungtk-cli --allow-scripts=@huayoung/huayoungtk-cli
huayoungtk-cli skills install
```
- 有意识地控制分页：`--page`、`--page-size`、`--page-token`。
- 探索数据时先用较小页数，确认方向后再扩大范围。
- 不确定字段含义、输出结构或排序字段时，先用 `--describe`。
- 当前参考文件没有覆盖的语法，用 `--help` 查询。
- 命令异常需要排查时，运行 `huayoungtk-cli logs`；优先取输出中 `logs[0].path` 指向的最新日志文件。向技术人员发送文件前先告知用户该文件包含命令参数和错误信息；不要把整份日志直接粘贴到群聊。
- 命令示例中的变量统一使用小写 kebab-case 尖括号占位符，例如 `<shop-id>`、`<shop-code>`、`<creator-handle>`；不要使用 `$变量名`、驼峰占位符或只有 `id` 的含糊占位符。
- 用户说“今天”“昨天”“最近 7 天”等相对日期时，答复中写清楚实际日期范围；命令支持时优先使用 `--from` / `--to`。
- 返回的所有时间字段默认使用东八区（UTC+8），格式为 `yyyy-MM-dd HH:mm:ss`。除非接口或用户另有明确说明，不要在各字段描述中重复标注时区。
- 面向用户输出时，先给运营结论，再列关键字段。除非用户要求原始数据，不要整段粘贴完整 JSON。

### 后续操作引导

- 每次业务回复都要附带简短、自然的后续操作建议，避免用户看完结果后不知道还能做什么。
- 结合用户目标、当前结果和对话上下文给出建议。确实没有必要继续操作时，明确告诉用户当前事项已处理完成，并说明以后还可以查询什么。
- 建议必须是 CLI 确实支持的能力；不确定时先查对应的 `--help` 或本 Skill 参考文件，不要编造命令、参数或业务能力。
- 不要固定用“下一步”作标题或生硬开头。只有一个合适动作时，可以问“你是否想要我继续查看……？”；有多个动作时，可以说“建议接下来可以……”或“你还可以选择……”。措辞要结合当前结果自然变化。
- 对话界面支持按钮或快捷选项时，优先把动作做成可点击选项；不支持时列成 `A`、`B`、`C`，告诉用户回复字母即可继续。
- 写操作建议必须说明会做什么，并在用户明确选择或确认后执行。点击按钮或回复对应字母可视为对该项的选择，但高风险操作仍需复述目标后再次确认。
- 下一步引导面向用户描述业务结果，例如“查看这个达人的近期视频”，不要展示内部字段名或实现细节。用户主动索要命令时再给完整命令。

## 参考文件

按任务只读取需要的参考文件：

- `references/common.md`：安装、认证、调用日志、JSON 处理、分页、日期处理、失败处理和安全策略。
- `references/settings.md`：团队/CLI 配置项查询，例如达人分配模式、合作单审核机制等。
- `references/shop-product-order.md`：店铺、商品、订单、买家命令。
- `references/disk.md`：个人/团队云盘浏览和文件路径引用。
- `references/product-category.md`：各国家/市场的商品类目树查询。
- `references/target-plan.md`：创建店铺定向邀约计划，以及查询计划详情、达人和产品。
- `references/target-plan-template.md`：查看店铺已有的邀约计划模板，并在创建邀约任务时使用模板。
- `references/collaboration-order.md`：合作单（BD与达人合作记录）列表、详情、创建。
- `references/creator.md`：达人发现、详情、带货能力、视频、直播、合作商品、邀约计划、合作店铺、分析归档、标签和合作状态。
- `references/global-creator.md`：公海达人库搜索、完整资料和字段发现。
- `references/creator-pack.md`：动态达人包（保存的筛选条件集合）列表、详情、命中达人查询。
- `references/video-live.md`：独立的带货视频和带货直播命令。
- `references/product-rating.md`：商品评论抓取、列表、统计、每日统计、追评查询、筛选条件和评论巡检流程。
- `references/sample-request.md`：索样申请列表、详情、关联视频/直播、搁置、同意、拒绝和审核流程。
- `references/mobile.md`：手机查询、页面源码、截图和 TikTok 达人首页导航。
- `references/browser.md`：在用户选择的客户端设备上打开店铺浏览器中的 TikTok 达人首页、截取当前激活页面，以及浏览器命令的能力边界和失败提示。
- `references/device-job-team.md`：执行设备发现、RPA/OpenAPI 任务详情、RPA 任务列表/取消和团队信息。

## 常见工作流

### 团队配置查询

1. 读取 `references/settings.md`。
2. 根据用户问题选择对应的 key，运行 `settings get --key <key>`。
3. 返回结果时解释该配置的业务含义，并基于配置给出后续建议（例如达人分配模式为 `OTM_SPU` 时，按 SPU 维度判断商品归属）。

### 达人分析

1. 读取 `references/creator.md`。
2. 用 `creator list` 筛选达人，默认排除团队达人库中已删除的记录。列表已包含 GMV、ROI、订单等带货数据；只看团队手动关注的达人时再加 `--favorite`。
3. 用 `creator get` 查看完整信息。评估带货能力时必须区分数据口径：`creator capability` 是公海最近30天，`creator capability4me` 是给当前团队带货最近30天，`creator capability-total` 是给当前团队带货全部时间；需要粉丝画像时用 `creator follower-profile`。
4. 需要评估转化表现时，继续查看达人带货视频和直播；需要查看达人合作商品时用 `creator products`，查看达人生效中的邀约计划时用 `creator target-plans`，查看达人历史索样记录时用 `creator sample-requests`。
5. 需要建联达人时用 `creator contact` 获取联系方式（WhatsApp/Email/Phone/iMessage 等）及对应好友关系状态。
6. 用户按国家询问合作中或已出单达人时，用 `creator list --region <国家代码> --status Collaborating|HasOrder`；询问该国家 GMV 最高达人时，用 `creator top --region <国家代码>`，指定自然月时加 `--month YYYY-MM`。
7. 基于证据输出简洁建议和下一步动作。
8. 需要归档分析结论时，用 `creator note add` 保存（内容用 Markdown，单条不超过 3000 字，记录达人画像/带货表现/合作建议等）；同一达人可多次保存，全部保留，用 `creator note list` 回看历史。
9. 修改标签或合作状态前，先征得用户确认。
10. `creator sync --execute-mode` 默认为 `rpa`。`openapi` 更实时；使用前先以 `shop get` 确认 `openApi.authorized=true`。
11. `creator send-message --execute-mode` 默认为 `rpa`。`openapi` 更实时；使用前确认 `openApi.authorized=true`。OpenAPI 支持普通文本、图片和商品消息，不支持 `--card-title` 组合卡片。
12. `creator messages` 查询达人近期站内消息，要求店铺 `openApi.authorized=true`。如果 `messages` 为空，先询问用户是否同步；只有用户确认后才能加 `--sync` 重试。

### 定向邀约计划

1. 读取 `references/target-plan.md`；用户提到邀约计划模板时同时读取 `references/target-plan-template.md`。
2. 用户要求批量发送定向邀约时使用 `target-plan create`。先确认达人来源：来自 `creator list/get` 或团队达人包时用 `--source team`；来自 `global-creator search/get` 时用 `--source global`。公海 `candidates[].id` 是公海 ES 记录 ID，只能配合 `--source global --id` 使用；OpenAPI 公海邀约由 CLI 解析并向后台传 `handles`，不得把该 ID 当作团队达人 ID 或 `creatorIds`。
3. 用户要求向已有的指定邀约计划“追加达人”“补充达人”或“把达人加入计划”时，同样使用 `target-plan create`，并传 `--plan-policy reuse --reuse-policy assign --reuse-plan-id <planId>`。`planId` 必须取自 `target-plan list` 输出的 TikTok 官方 `planId`，不是记录 `id`；不得使用 `--copy-from-id`，后者会复制配置并创建新计划。
4. 按来源和 `region` 分组，每组单独执行一次；店铺必须属于同一站点。
5. 用户希望使用已有模板时，先用 `target-plan-template list` 获取模板 ID，再给 `target-plan create` 传 `--template-id`；希望基于已有邀约计划创建新计划时，先用 `target-plan list` 获取记录 `id`，再传 `--copy-from-id`。两者均由 CLI 加载配置，不要手工转抄，也不要凭名称猜 ID。
6. 不使用模板或已有计划时，新建计划前取得商品及逐商品佣金、邀约话术 `--content`、该站点必填联系方式，并确认是否忽略当前店铺或团队店铺已邀约、已出单、已分配的达人，以及是否发送邀约卡片。部分通过客户端浏览器或插件同步的计划没有保存联系方式，CLI 会要求显式补充；模板或已有计划缺少其他必填信息时也需向用户确认。不要擅自开启非默认过滤项。
7. `target-plan create --execute-mode` 默认为 `rpa`。`openapi` 更实时；使用前先以 `shop get` 确认 `openApi.authorized=true`。OpenAPI 创建或复用计划时都必须取得 Email。
8. 查询已有计划时，`target-plan list` 看店铺计划，`target-plan get` 看详情，`target-plan creators` 看计划达人，`target-plan products` 看计划商品及定向佣金。用户确认某些达人不符合要求时，用 `target-plan clear-creators` 发起清理；该操作不可恢复，执行前必须复述计划和达人并取得明确确认。

### 公海达人发现

1. 读取 `references/global-creator.md`。
2. 用户要从全平台达人中发现新达人时使用 `global-creator search`，不要用只查询团队达人库的 `creator list`；国家代码 `--region` 必须明确指定。
3. 用户希望为某个商品快速找到合适的新达人时，优先执行“优秀达人画像 → 精选公海达人 → 定向邀约”流程：用 `product creators --ranking gmv --page-size 1` 找该商品 GMV 最高达人，并用 `product creators --first-order-from <日期> --first-order-to <日期>` 找目标时间范围内的首单达人；结合 `creator get`、`creator follower-profile` 和 `creator capability` 分析其国家、类目、粉丝量、粉丝画像、带货和内容表现；提取共同特征后调用 `global-creator candidates --shop-id <店铺> --region <国家> ...`，不得用普通 `global-creator search` 代替任务候选过滤。
4. `global-creator candidates` 只返回已通过定向邀约业务过滤的精选公海达人，不会发送邀约。先向用户说明画像条件和候选结果；用户要求发起邀约时，再把输出 `candidates[].id` 交给 `target-plan create --source global --id ...`。不要把画像收窄为对单个优秀达人的逐字段精确复制，应保留合理范围，避免找不到候选人。使用 `nextCursor` 翻页时，必须原样保留店铺、画像条件、业务过滤和排序，只增加或替换 `--cursor`。
5. 需要单个达人的完整公海资料时，使用 `global-creator get`。默认结果已包含全部公海资料卡片，不要为了拿全量数据逐卡重复调用。
6. 不确定字段所属资料卡片、能否筛选或排序时，使用 `global-creator fields`；实际筛选参数仍以 `global-creator search --help` 或 `global-creator candidates --help` 为准。
7. GMV 参数按所选国家本地货币传入；百分比参数直接传百分数，例如 8 表示 8%。
8. 用户要把公海达人加入团队达人库时使用 `creator import`；先确认 `global-creator` 输出的公海 ES ID、`--region` 和可选标签，再执行导入。一次最多 200 人，跨国家分开执行；不要把公海 ID 当作团队达人数据库 ID。

### 达人包查询

1. 读取 `references/creator-pack.md`。
2. 动态达人包是保存的筛选条件集合，不是固定名单，结果随数据实时变化。`creator-pack list` 看可见的包，`--scope`/`--type` 缩小范围。
3. `creator-pack get --id <id>` 看筛选条件（`conditions`），`estimateCount` 是上次估算值、可能非实时（CLI 不触发重算）。
4. 查看达人包命中的达人用 `creator-pack creators --id <id>`：索样记录达人包一行对应一笔索样记录，同一达人可能出现多行；常规达人包返回达人列表，不含"为我"带货维度。查看团队共享的手动关注达人用 `creator-pack creators --favorite`。
5. 常规达人包和手动关注不支持 `--shop-id`/`--shop-code`；需要单个达人完整字段时从 `creators` 拿 `handle`/`creatorId` 再用 `creator get` 单查。

### 索样审批

1. 读取 `references/sample-request.md` 并阅读其中的索样审批流程。
2. 按 `references/sample-request.md` 中的配置判断树处理前置动作：`CREATOR_ASSIGNMENT=OTM_PRODUCT` 或 `OTM_SPU` 时才需要创建合作单；`CREATOR_ASSIGNMENT=OTO` 时先完成达人认领；未开启前置认领时直接进入审批。
3. 需要创建合作单时，读取 `references/collaboration-order.md`，并在执行 `collaboration-order create` 前征得用户明确确认。

### 商品评论巡检

1. 读取 `references/product-rating.md`。
2. 用户要求抓取最新评论时，先确认店铺和抓取范围，再执行 `product-rating sync`。`extension` 店铺执行时 `--device-id` 可省略，用户明确指定插件实例时可传；`huayang` 店铺先让用户选择客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略，用户明确指定插件实例时可传对应的 Extension `deviceId`。只查询已有评论时不要触发 RPA。
3. 根据用户关注点查询近期低星评论，或带图、带视频、带文字评论。
4. 对 `hasFollowReview: true` 的评论，用 `product-rating follow-review --review-id <id>` 拉取追评正文（差评原因常在追评里）。
5. 汇总受影响店铺、商品、订单、买家信号、评论内容和时间。
6. 给出后续处理建议；除非用户明确确认，不要修改任何数据。

### 商品类目查询

1. 读取 `references/product-category.md`。
2. `--country` 和 `--shop-type` 都是必填。不知道店铺类型时先跑 `shop get --shop-id <id>` 看 `type` 字段。
3. 用 `product-category list --country <code> --shop-type <Local|Global>` 拿到全量类目树；只关心一级类目加 `--level 1`，按名称找类目加 `-q <keyword>`，反查某类目下的子类目加 `--parent-id <id>`。
4. 类目 ID 和 `product list/get`、`sample-request list-to-review`、`creator capability` 中的类目字段共用同一套 ID 体系，可直接交叉引用。

### 店铺运营

1. 读取 `references/shop-product-order.md`。
2. 先用 `shop list` 或 `shop get` 解析店铺。
3. 店铺的 TikTok OpenAPI 授权状态在 `openApi`，字段含义见 `references/shop-product-order.md`。
4. `shop sync --execute-mode` 默认为 `rpa`。`openapi` 更实时，但只能单独同步 `product` 或 `sample-request`；使用前确认 `openApi.authorized=true`。
5. 用户需要商品的规格名称、规格描述、价格、库存、SKU 编码等详细 SKU 信息时，必须使用 `product get`；`product list` 只有商品汇总信息，不能替代 SKU 明细查询。
6. 查询商品、订单或买家数据时，尽量使用明确的 shop ID。
7. 查看店铺定向邀约计划时读取 `references/target-plan.md`：`target-plan list` 看店铺生效/即将过期的计划、`target-plan get` 看单个计划详情，`target-plan creators` 看计划里的达人列表（按 `--creator-type invited/accepted/promoted` 漏斗过滤）、`target-plan products` 看计划里的产品列表（含每个产品单独设定的定向佣金）；确认达人不符合要求后，用 `target-plan clear-creators` 发起不可恢复的清理任务。
8. 查询与店铺合作中、已出单、指定时间出首单或 GMV 最高的达人时，用 `shop creators`；查询推广某商品、为商品出单、指定时间首次卖出商品或该商品 GMV 最高的达人时，用 `product creators`，优先传店铺参数和 `--product-id`，让 CLI 先确认商品存在。
9. 修改备注或触发同步前，先征得用户确认。

### 订单私信携带图片

1. 读取 `references/shop-product-order.md` 和 `references/disk.md`。
2. 使用 `disk list --path team_disk://` 或 `disk list --path user_disk://` 查询云盘，并让用户明确选择图片。
3. `--image` 只接受以 `team_disk://` 或 `user_disk://` 开头的云盘文件，不接受本地路径或普通 URL。
4. 用户指定本地图片时，先确认完整的本地源路径和云盘目标 URI，再执行 `disk cp <local-path> <disk-uri>` 上传；上传成功后将目标 URI 传给 `--image`。具体参数参考 `disk --help` 和 `references/disk.md`。
5. 发送前确认订单、文本、最终使用的云盘图片 URI 以及是否携带商品。`extension` 店铺执行时 `--device-id` 可省略，用户明确指定插件实例时可传；`huayang` 店铺先确认客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略，用户明确指定插件实例时可传对应的 Extension `deviceId`。
6. 根据返回的 `jobId` 查询任务状态。

### 执行店铺/RPA任务

1. 读取 `references/device-job-team.md`。
2. 对所有店铺 RPA 命令，先根据店铺的 `browserType` 决定执行方式：`extension` 店铺不指定具体实例时省略 `--device-id`，由 CLI 自动选择该店铺关联、最近活跃的在线插件实例；只有用户明确要求指定某个插件实例时，才用 `device list --shop-id <shop-id> --online` 查询并只展示 `Extension` 类型，让用户选择后传对应的 `--device-id`。`huayang` 店铺必须查询设备，只展示 `App`、`TeamRpaExecutor` 类型，让用户选择，并传用户选定的 `--device-id`。`both` 店铺必须先询问用户“使用客户端浏览器执行还是插件执行”：选择客户端浏览器时按 `huayang` 处理，必须传用户选定的 `--device-id`；选择插件时不必再询问具体实例，省略 `--device-id` 由 CLI 自动选择，只有用户明确要求指定插件实例时才查询 Extension 设备并传对应的 `--device-id`。只使用设备列表中与当前执行方式匹配、且由用户选定的设备 ID。
3. 任务创建后，用 `job get` 查询最终状态；`--execution-mode` 仅支持 `rpa|openapi`，默认 `rpa`，应传入创建命令返回的 `executionMode`。OpenAPI 任务先用 `job get --job-id <jobId> --execution-mode openapi` 轮询；活跃任务查不到时加 `--alive=false` 查询归档结果。`Succeed`、`Failed`、`Cancelled` 为最终状态。RPA 历史任务也加 `--alive=false`。
4. 取消任务前，先征得用户确认。

### 手机查询

1. 读取 `references/mobile.md`。
2. 按其中的权限、在线状态、文件覆盖和平台差异规则执行手机命令。

### 店铺浏览器远程控制

1. 读取 `references/browser.md`。
2. 所有 `browser` 命令都必须传用户明确选择的在线 `App` 或 `TeamRpaExecutor` 设备 ID；`Extension` 设备不适用于这些命令，店铺 RPA 的插件设备规则也不适用。
3. 用户未明确指定设备时，先运行 `device list --shop-id <shop-id> --online`，只展示 `App` 和 `TeamRpaExecutor` 设备，让用户选择后再执行。
4. 打开达人首页使用 `browser open-creator`；截图使用 `browser screenshot`，只截当前激活页面，且不会自动启动浏览器。
5. `browser` 命令失败时，提示目标花漾客户端版本较低可能是原因之一，并建议升级后重试。
