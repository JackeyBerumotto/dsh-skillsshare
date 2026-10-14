# 邀约计划参考

邀约计划（target plan，TikTok Shop 官方称“定向邀约计划”）是店铺向达人发出的带货邀约：店铺把一批商品和一批达人圈进一份计划，达人在计划期内（`startTime` → `endTime`）添加商品、发布内容，就形成“邀约 → 接受 → 推广”的转化漏斗。使用 `create` 创建计划，使用 `list`、`get`、`creators` 和 `products` 查询计划及其达人、商品。

## 创建定向邀约计划

使用 `target-plan create` 向团队达人库或公海达人库中的达人发起定向邀约。`--execute-mode` 支持 `rpa|openapi`，默认 `rpa`。OpenAPI 更实时，但要求店铺 `openApi.authorized=true`，CLI 会在提交前校验。输出中的 `executionMode` 表示实际执行方式。

用户要求向已有的指定邀约计划“追加达人”“补充达人”或“把达人加入计划”时，仍使用 `target-plan create`，但必须选择填充模式：`--plan-policy reuse --reuse-policy assign --reuse-plan-id <planId>`。这里的 `planId` 是 `target-plan list` 输出的 TikTok 官方 `planId`，不是系统记录 `id`。不要使用 `--copy-from-id`：它只会复制已有计划的配置并创建一个新计划。

用户希望复用花漾界面中保存的邀约计划模板时，先按 `target-plan-template.md` 查询模板，再给本命令传 `--template-id`。本次命令明确传入的参数优先于模板配置；达人、店铺、国家和设备不会从模板读取。

用户希望基于已有邀约计划创建新计划时，先用 `target-plan list` 找到该计划的记录 `id`，再给本命令传 `--copy-from-id`。CLI 会复用该计划的商品及佣金、已保存的联系方式和话术；本次明确传入的 `--product`、`--content` 或联系方式会覆盖对应内容。待复制计划必须属于本次指定的店铺，且 `--copy-from-id` 不能与 `--template-id` 同时使用。部分通过客户端浏览器或插件同步的计划没有保存联系方式，CLI 会要求显式补充；其他信息缺失时也需向用户确认。

### Agent 必须先确认的信息

- 达人来源：来自 `creator list/get` 或团队达人包时传 `--source team`；来自 `global-creator search/get` 时传 `--source global`。不能根据 ID 数值猜来源。公海 `candidates[].id` 是公海 ES 记录 ID，只用于 `--source global --id` 定位达人；OpenAPI 公海邀约由 CLI 解析后向后台传 `handles`，不得作为团队达人 `creatorIds` 使用。
- 达人国家：必须传 `--region`。不同来源或不同国家的达人要拆成多条命令；店铺必须与达人属于同一站点。
- 达人标识：`--handle`、`--id`、`--cid` 可以逗号分隔、重复传入或混用，CLI 会解析并去重。
- 新建计划需要商品及逐商品佣金、邀约话术 `--content`、站点要求的联系方式。
- 使用 OpenAPI 前先执行 `shop get`；只有 `openApi.authorized=true` 才能传 `--execute-mode openapi`。
- 执行前询问用户是否忽略当前店铺或团队店铺已邀约、已出单、已分配的达人，以及是否发送邀约卡片；不要擅自开启非默认过滤项。

```bash
# 团队达人库：在一个 --handle 中使用逗号分隔
huayoungtk-cli target-plan create --source team --region US --handle alice,bob --shop-id <shop-id> --product <product-id>:12 --contact-email <email> --content "Hello {creator.name}"

# 团队达人库：重复传入 --handle，效果相同
huayoungtk-cli target-plan create --source team --region US --handle alice --handle bob --shop-id <shop-id> --product <product-id>:12 --contact-email <email> --content "Hello {creator.name}"

# 公海达人库
huayoungtk-cli target-plan create --source global --region TH --id <global-creator-id-1>,<global-creator-id-2> --shop-code <shop-code> --product <product-id>:15:5 --contact-line <line-number> --content "Hello {creator.name}"

# 使用更实时的 TikTok OpenAPI
huayoungtk-cli target-plan create --execute-mode openapi --source team --region US --handle alice,bob --shop-id <shop-id> --product <product-id>:12 --contact-email <email> --content "Hello {creator.name}"

# 使用店铺已有模板；仍需指定本次的达人来源、国家、达人和店铺
huayoungtk-cli target-plan create --template-id <template-id> --source team --region US --handle alice,bob --shop-id <shop-id>

# 基于已有邀约计划创建新计划；id 来自 target-plan list
huayoungtk-cli target-plan create --copy-from-id <id> --source team --region US --handle alice,bob --shop-id <shop-id>

# 向指定的已有邀约计划追加达人；planId 来自 target-plan list
huayoungtk-cli target-plan create --plan-policy reuse --reuse-policy assign --reuse-plan-id <planId> --source team --region US --handle alice,bob --shop-id <shop-id>

huayoungtk-cli target-plan create --describe
```

### 主要参数

| 参数 | 含义 |
|---|---|
| `--shop-id` / `--shop-code` | 发起邀约的店铺，二选一 |
| `--execute-mode rpa\|openapi` | 执行方式，默认 `rpa`；`openapi` 更实时，并要求店铺已授权 |
| `--device-id` | RPA 使用客户端浏览器时必填；插件店铺可省略；OpenAPI 会忽略它 |
| `--template-id` | 店铺已有的邀约计划模板 ID，来自 `target-plan-template list` |
| `--copy-from-id` | 已有邀约计划的记录 ID，来自 `target-plan list`；复用商品、佣金、已保存的联系方式和话术，与 `--template-id` 互斥 |
| `--send-invite-card` / `--invite-card-message` | RPA 分支发送邀约卡片，并可在卡片前发送一条站内消息 |
| `--source team/global` | 达人来自团队达人库或公海达人库，必填 |
| `--region` | 达人国家代码，必填；一次只能处理一个国家 |
| `--id` / `--handle` / `--cid` | 达人标识；多个值可用逗号分隔，也可重复传入同一参数，两种写法效果相同 |
| `--product <id>:<commission>` | 商品 ID 和定向佣金；可重复，佣金范围 1–80 |
| `--product <id>:<commission>:<ads-commission>` | 同时设置广告佣金 |
| `--plan-name` | 计划名称，默认 `plan {MMdd HH:mm}` |
| `--valid-days` | 计划有效天数，默认 365 |
| `--content` | 邀约附加话术；新建计划必填，最多 500 字符 |
| `--free-sample` | 提供免费样品 |
| `--auto-sample-approval` | 自动批准样品申请，必须同时启用 `--free-sample` |
| `--send-invite-card` | 在消息中发送邀约卡片 |
| `--each-plan-max` | 单个计划最多达人数，默认 50 |
| `--invite-interval` | 每次邀约间隔秒数，默认 3 |
| `--invite-mode` | 重复邀约规则：`all`、`ignore-30-shop`、`ignore-60-shop`、`ignore-30`、`ignore-60`、`ignore-all` |
| `--preferred-content` | 内容偏好：`all`、`video` 或 `live` |
| `--speech-id` | 团队邀约话术 ID，可重复 |
| `--bind-system-tag[=false]` | 是否在任务完成后绑定系统标签，默认开启 |
| `--manual-tag` | 任务完成后绑定手动标签 |

站点联系方式要求：US/FR/DE/IT/UK 必填 Email，VN 必填 Zalo，PH 必填 Facebook，TH 必填 Line，SG/MY/ID 必填 WhatsApp。使用 OpenAPI 创建或复用计划时都必须提供 Email。

联系方式参数：

| 联系方式 | 参数 |
|---|---|
| Email | `--contact-email` |
| 电话 | `--contact-phone`、`--contact-phone-area-code` |
| Facebook | `--contact-facebook` |
| Viber | `--contact-viber`、`--contact-viber-area-code` |
| Zalo | `--contact-zalo`、`--contact-zalo-area-code` |
| WhatsApp | `--contact-whatsapp`、`--contact-whatsapp-area-code` |
| Telegram | `--contact-telegram`、`--contact-telegram-area-code` |
| Line | `--contact-line`、`--contact-line-area-code` |

区号参数使用 `<国家代码>#<电话区号>`，例如 `MY#60`、`TH#66`，不要传成 `+60`。

过滤参数：

| 参数 | 含义与默认值 |
|---|---|
| `--filter-invited-by-shop` | 忽略当前店铺已邀约达人，默认关闭 |
| `--filter-invited-team-shop-id` | 忽略指定团队店铺已邀约达人，可重复 |
| `--filter-has-order-by-shop` | 忽略当前店铺已出单达人，默认关闭 |
| `--filter-has-order-team-shop-id` | 忽略指定团队店铺已出单达人，可重复 |
| `--filter-has-allocated` | 忽略已分配给团队成员的达人，默认关闭 |
| `--conflict-policy remove-anyway` | 仅迁移入口使用：从已有冲突计划移除达人；普通邀约不传该参数 |

### 新建与复用计划

- `--plan-policy create`：创建新计划，是默认值。需要 `--product`、`--content`、计划信息和站点要求的联系方式。
- `--plan-policy reuse`：填充已有未满额计划，不需要再次提供商品、计划名称、有效期和邀约话术。
- 复用时使用 `--reuse-policy old-first` 从最旧计划开始，使用 `new-first` 从最新计划开始；使用 `assign` 时必须通过可重复的 `--reuse-plan-id` 指定计划。
- “向指定计划追加/补充达人”对应 `reuse + assign + reuse-plan-id`；`--reuse-plan-id` 接受 TikTok 官方 `planId`。`--copy-from-id` 接受系统记录 `id`，其含义是复制配置并新建计划，两者不可混用。
- `--ignore-on-tops`：复用时跳过已置顶的计划。

创建新计划时，`--default-commission` 设置默认标准佣金，默认 12%；`--enable-default-ads-commission` 启用默认广告佣金，`--default-ads-commission` 设置其比例，默认 5%。商品自身通过 `--product` 指定的佣金优先。

任务创建成功只表示已进入任务池。根据输出的 `executionMode` 和每个 `jobIds` 查询最终结果。OpenAPI 任务先用 `job get --job-id <jobId> --execution-mode openapi` 轮询；活跃任务查不到时加 `--alive=false` 查询归档结果。`Succeed`、`Failed`、`Cancelled` 为最终状态。

## 计划类型（--invitation-type）

`target-plan list` 按到期时间分两档：

| 值 | 含义 | 时间条件 |
|---|---|---|
| `active` | 进行中（默认） | `endTime ≥ 现在 + 7 天`，长期生效 |
| `expiring` | 即将过期 | `现在 ≤ endTime ≤ 现在 + 7 天`，7 天内会过期 |

已过期的计划不在 list 范围内。

## 达人阶段（--creator-type）

`target-plan creators` 按达人在计划里的转化阶段分三档：

| 值 | 含义 | 业务条件 |
|---|---|---|
| `invited` | 已邀约（默认） | 被拉进计划但还没加商品 |
| `accepted` | 已接受 | 已添加商品到橱窗（showcase） |
| `promoted` | 已推广 | 已发布视频或直播带货 |

注意：已接受的达人未必是已推广，已推广的达人未必是已接受。

## 邀约计划列表

`--shop-id` 与 `--shop-code` 二选一，必填。

```bash
huayoungtk-cli target-plan list --shop-id <shop-id>
huayoungtk-cli target-plan list --shop-id <shop-id> --on-top
huayoungtk-cli target-plan list --shop-id <shop-id> --invitation-type expiring
huayoungtk-cli target-plan list --shop-code <shop-code> -q "dress"
huayoungtk-cli target-plan list --shop-id <shop-id> --sort endTime:asc
huayoungtk-cli target-plan list --shop-id <shop-id> --page 2 --page-size 30
huayoungtk-cli target-plan list --describe
```

**过滤参数**：

- `--shop-id` / `--shop-code`：店铺标识，二选一。
- `--invitation-type`：`active`（默认）/ `expiring`，见上表。
- `--on-top`：只查询已置顶的邀约计划；可与计划类型、搜索、排序和分页参数组合使用。
- `-q, --query`：模糊搜索计划名称、达人 ID、商品 ID。

**排序字段**（`--sort field[:asc|desc]`，默认 `startTime:desc`）：

| 字段 | 含义 |
|---|---|
| `startTime` | 创建时间 |
| `endTime` | 过期时间 |
| `updateTime` | 计划修改时间 |
| `lastSyncTime` | 计划同步时间 |
| `creatorCnt` | 邀约达人数 |
| `productCnt` | 商品数 |
| `creatorAddCnt` | 已接受达人数 |
| `creatorPostedCnt` | 已推广达人数 |

**分页**：`--page`（默认 1）、`--page-size`（默认 15）。

`targetPlans` 中每条计划包含以下订单产出字段：

| 字段 | 含义 |
|---|---|
| `gmv` | 该定向邀约计划产出的有效订单累计 GMV |
| `orderCount` | 该定向邀约计划产出的有效订单数 |
| `unit` | GMV 的货币单位 |

这些数据按当前计划归集，不包含开放计划或其他定向邀约计划的数据。

## 邀约计划详情

二选一标识符：

```bash
huayoungtk-cli target-plan get --id <id>
huayoungtk-cli target-plan get --plan-id <planId>
huayoungtk-cli target-plan get --describe
```

- `--id`：邀约计划记录 ID（数字，例 `123`），来自 `target-plan list` 输出的 `id` 字段，建议优先使用。
- `--plan-id`：TikTok 官方计划 ID（字符串，例 `7382918...`），来自 UI 展示。

两者都不传或都传会报错。两种标识符返回的字段完全一致。

详情中的订单产出字段：

| 字段 | 含义 |
|---|---|
| `gmv` | 该定向邀约计划产出的有效订单累计 GMV |
| `orderCount` | 该定向邀约计划产出的有效订单数 |
| `unit` | GMV 的货币单位 |

这些数据按当前计划归集，不包含开放计划或其他定向邀约计划的数据。

## 邀约计划达人列表

`--id` 或 `--plan-id` 必填其一（互斥），标识符语义同 `target-plan get`。

```bash
huayoungtk-cli target-plan creators --id <id>
huayoungtk-cli target-plan creators --plan-id <planId>
huayoungtk-cli target-plan creators --id <id> --creator-type accepted
huayoungtk-cli target-plan creators --id <id> --creator-type promoted --sort totalGmv:desc
huayoungtk-cli target-plan creators --id <id> -q "creator_handle"
huayoungtk-cli target-plan creators --id <id> --describe
```

**过滤参数**：

- `--id`：邀约计划记录 ID（来自 `target-plan list` 的 `id` 字段，建议优先使用）。
- `--plan-id`：TikTok 官方计划 ID（字符串）。两种标识符结果一致。
- `--creator-type`：`invited`（默认）/ `accepted` / `promoted`，见上表。
- `-q, --query`：模糊搜索达人 ID、昵称、备注。

**排序字段**（`--sort field[:asc|desc]`，默认 `followerCnt:desc`）：

| 字段 | 含义 |
|---|---|
| `followerCnt` | 粉丝数 |
| `gmv` | 最近 30 天 GMV |
| `orderCount` | 带货订单数 |
| `totalProducts` | 带货商品数 |
| `totalGmv` | 达人带货 GMV |
| `totalCommission` | 佣金总额 |
| `roi` | ROI |
| `itemsSold` | 商品售出量 |
| `liveCount` | 产出直播数 |
| `videoCount` | 产出视频数 |
| `level` | 达人等级 |
| `creatorFulfillmentScore` | 达人履约评分 |

> `creators` 不分页，一次返回全部匹配达人。计划达人量级通常在百级以内，可直接全量拉取后用 `--jq` 在客户端筛选。

## 从计划中清理指定达人

当用户确认某些达人不符合要求时，使用 `target-plan clear-creators` 创建异步清理任务。执行前向用户复述计划和待清理达人。

```bash
huayoungtk-cli target-plan clear-creators --id <id> --handle alice,bob
huayoungtk-cli target-plan clear-creators --plan-id <planId> --creator-id <creatorDatabaseId>
huayoungtk-cli target-plan clear-creators --id <id> --handle alice --device-id <device-id>
huayoungtk-cli target-plan clear-creators --describe
```

- `--id` / `--plan-id`：二选一，语义与 `target-plan get` 一致。
- `--handle`：达人 handle，可逗号分隔或重复指定。
- `--creator-id`：达人数据库 ID，等同 `creator get/list` 的 `id`，也可取自 `target-plan creators` 的 `creatorDatabaseId`；不是 TikTok `creatorId`。可逗号分隔或重复指定。
- `--device-id`：设备选择规则与其他店铺 RPA 命令一致；插件店铺可自动选择在线插件实例。
- 返回的 `jobId` 只表示任务已创建，继续使用 `job get --job-id <jobId>` 查询执行结果。

CLI 会先校验每个达人当前属于该计划，再使用达人数据库 ID 发起清理任务；不得使用来自其他计划的达人，也不得用 `invitationCreatorId` 或 TikTok `creatorId` 代替 `creatorDatabaseId`。

## 删除邀约计划

`target-plan delete` 会删除整个定向邀约计划，无论计划中是否已有达人接受邀约或发布作品。

如果只是想从计划中移除部分达人，使用 `target-plan clear-creators`，不要删除整个计划。

删除前必须先查询计划：

```bash
huayoungtk-cli target-plan get --id <id>
```

向用户说明计划名称、是否置顶、邀约人数、已接受人数和已推广人数，以及删除计划可能影响达人佣金。取得用户对该计划的明确确认后执行：

```bash
huayoungtk-cli target-plan delete --id <id>
huayoungtk-cli target-plan delete --plan-id <planId>
huayoungtk-cli target-plan delete --id <id> --device-id <device-id>
huayoungtk-cli target-plan delete --describe
```

- `--id` / `--plan-id`：二选一，语义与 `target-plan get` 一致。
- `--device-id`：设备选择规则与其他店铺 RPA 命令一致；插件店铺可自动选择在线插件实例。
- 返回的 `jobId` 只表示删除任务已创建，继续使用 `job get --job-id <jobId>` 查询执行结果。
- 如果用户只想从计划中移除部分达人，不要删除计划，应使用 `target-plan clear-creators`。

## 邀约计划产品列表

`--id` 或 `--plan-id` 必填其一（互斥），标识符语义同 `target-plan get`。

```bash
huayoungtk-cli target-plan products --id <id>
huayoungtk-cli target-plan products --plan-id <planId>
huayoungtk-cli target-plan products --id <id> -q "dress"
huayoungtk-cli target-plan products --id <id> --describe
```

**过滤参数**：

- `--id`：邀约计划记录 ID（建议优先使用）。
- `--plan-id`：TikTok 官方计划 ID（字符串）。两种标识符结果一致。
- `-q, --query`：模糊搜索产品 ID、产品名称。

> `products` 不分页、不支持排序，一次返回全部产品。

**字段语义**：

| 字段组 | 含义 |
|---|---|
| `targetCommission` / `targetAdsCommission` | 定向佣金 / 定向广告佣金（%） |
| `cosRatio` / `adsCosRatio` | 产品维度的标准佣金率 / 广告佣金率（%） |
| `hasOrderCreatorCount` / `invitingCreatorCount` | 该产品已出单 / 正在邀约的达人数 |
| `inside` | 该产品是否仍在该计划中（false 表示已移出） |

## 字段速查

### target-plan list / get 共用字段

| 字段 | 含义 |
|---|---|
| `id` | 邀约计划记录 ID（`get/creators --id` 使用） |
| `planId` | TikTok 官方计划 ID（字符串，UI 展示） |
| `name` | 计划名称 |
| `shopId` / `shopName` | 所属店铺 ID / 名称 |
| `startTime` / `endTime` | 计划生效区间（UTC+8） |
| `updateTime` | 计划修改时间 |
| `lastSyncTime` | 计划同步时间（最近的 RPA 拉取时间） |
| `creatorCount` | 邀约达人数 |
| `productCount` | 计划内商品数 |
| `creatorAdded` | 已接受（已加商品）的达人数 |
| `creatorPosted` | 已推广（已发布内容）的达人数 |
| `freeSample` | 是否含免费样品（布尔，省略时为 null） |
| `freeSampleAutoReview` | 样品是否自动审批（布尔） |
| `onTop` | 是否置顶展示 |

### target-plan creators 字段

| 字段 | 含义 |
|---|---|
| `invitationCreatorId` | 邀约计划-达人关联 ID |
| `invitationId` | 所属邀约计划 ID |
| `creatorDatabaseId` | 达人数据库 ID（等同 `creator get/list` 的 `id`），可用于 `target-plan clear-creators --creator-id` |
| `creatorId` | 达人 TikTok Creator ID |
| `handle` | 达人 handle |
| `alias` | 达人昵称 |
| `region` | 达人所在地区 |
| `followerCount` | 粉丝数 |
| `categories` | 带货类目 |
| `gmv` | 最近 30 天 GMV |
| `orderCount` | 带货订单数 |
| `totalProducts` | 带货商品数 |
| `totalGmv` | 达人累计带货 GMV |
| `totalCommission` | 佣金总额 |
| `roi` | ROI |
| `itemsSold` | 商品售出量 |
| `liveCount` / `videoCount` | 产出直播数 / 视频数 |
| `level` | 达人等级 |
| `contentPosted` | 已发布内容数 |
| `productAdded` | 已添加商品数 |
| `inside` | 是否仍在计划中（false 表示已退出） |
| `remark` | 备注 |

`creators` 输出里的达人统计字段（`gmv`、`orderCount`、`totalGmv` 等）来自达人维度而非计划维度，是达人跨计划累计的全局数据，不要当成只算本计划的数字。

### target-plan products 字段

| 字段 | 含义 |
|---|---|
| `invitationProductId` | 邀约计划-产品关联 ID |
| `invitationId` | 所属邀约计划 ID |
| `productNo` | 店铺内产品编号 |
| `productName` / `productAvatar` | 产品名称 / 主图 URL |
| `inside` | 是否仍在该计划中 |
| `targetCommission` | 定向佣金（%） |
| `targetAdsCommission` | 定向广告佣金（%） |
| `price` / `priceUnit` | 产品最高价 / 币种 |
| `status` | 产品状态 |
| `itemsSold` | 售出量 |
| `cosRatio` / `adsCosRatio` | 标准佣金率 / 广告佣金率（%） |
| `hasOrderCreatorCount` | 已出单达人数 |
| `invitingCreatorCount` | 在邀达人数 |
| `sampleCount` | 免费样品数 |
| `avgReviewStar` | 平均评分 |
