# 达人参考

达人是可通过视频或直播推广商品的 TikTok 用户。

合作状态：`NotContacted`(未接触)、`Contacted`（已触达）、`Collaborating`（合作中）、`HasOrder`（已出单）。

查找方式： `--id`（数据库ID）、`--handle`（TikTok handle）、`--cid`（TikTok Creator ID）

## 达人列表

```bash
huayoungtk-cli creator list
huayoungtk-cli creator list --status HasOrder
huayoungtk-cli creator list --region TH --status Collaborating
huayoungtk-cli creator list --region TH --status HasOrder
huayoungtk-cli creator list --favorite
huayoungtk-cli creator list --region TH --sort followerCnt:desc
huayoungtk-cli creator list --person-in-charge <user-id>
huayoungtk-cli creator list --describe
```

排序字段包括 `id`、`createTime`、`followerCnt`、`rating`、`level`、`lastSyncTime`、`lastOrderTime`、`handle`、`region`、`status`、`liveCount`、`videoCount`、`gmv`、`gmv4me`、`itemsSold`、`itemsSold4me`、`influence`、`roi`。

`influence`（话语权/GMV 占比）和 `returnRate`（退货率）均为百分制（0-100），无数据时为 0。

`--favorite` 只返回团队手动关注的达人；关注关系为团队共享，可与其它列表筛选参数组合。

## 国家达人 GMV 排行

`creator top` 按达人给当前团队带货的 GMV 查询指定国家的头部达人。不传月份按全部时间累计 GMV 排名；`--month` 表示单个自然月；`--month-from/--month-to` 表示连续月份，并按所选月份的月均 GMV 排名。这里查询的是团队达人数据，不是公海达人搜索。

```bash
huayoungtk-cli creator top --region TH --limit 10
huayoungtk-cli creator top --region TH --month 2026-07 --limit 10
huayoungtk-cli creator top --region TH --month-from 2026-05 --month-to 2026-07
huayoungtk-cli creator top --describe
```

`--gmv-usd-from` 可排除低于指定美元 GMV 的达人，默认是 `0`。

输出中的 `creators[].rank` 是名次，`creators[].gmv` 是本次排行直接使用的 GMV；不要改用 `creator list` 的其它 GMV 字段解释排名。`aggregation=total` 表示全部时间累计，`aggregation=monthly-average` 表示所选月份月均。

## 达人详情

```bash
huayoungtk-cli creator get --handle ashfarienaz
huayoungtk-cli creator get --id 363364238753849
huayoungtk-cli creator get --describe
```

## 达人带货能力

带货能力分为三种数据口径，不要混用：

| 命令 | 数据范围 | 统计周期 |
|---|---|---|
| `creator capability` | 达人在公海达人库中的整体带货能力 | 最近30天 |
| `creator capability4me` | 达人为当前团队所有店铺带货的数据 | 最近30天 |
| `creator capability-total` | 达人为当前团队所有店铺带货的数据 | 全部时间 |

用户询问达人整体市场表现时用 `creator capability`；询问“给我带货”或当前团队合作表现时，根据时间范围使用 `creator capability4me` 或 `creator capability-total`。用户要求比较时调用相应的两条或三条命令，不要拿公海 GMV 解释为给我带货 GMV。

`creator capability` 可查看 GMV、GPM、预计履约率、视频/直播表现和类目 GMV。团队达人直接传 `--id`、`--handle` 或 `--cid`；尚未加入团队达人库的公海达人需要传 `--region` 和 `--handle`/`--cid`，或传 `--region` 和 `--global-id`。

`creator capability4me` 的最近30天数据不包含视频数和直播数，输出中没有这两个字段。`creator capability-total` 才包含全部时间的视频数和直播数。三个命令中 `null` 表示没有数据，`0` 表示真实数值为零。公海数据使用 `gmvPerCustomer`，给我带货数据使用 `gmvPerOrder`，两者不是同一概念。

```bash
huayoungtk-cli creator capability --handle sahabatpadienterprise
huayoungtk-cli creator capability --region MY --handle public_creator
huayoungtk-cli creator capability4me --handle sahabatpadienterprise
huayoungtk-cli creator capability-total --handle sahabatpadienterprise
huayoungtk-cli creator capability --describe
huayoungtk-cli creator capability4me --describe
huayoungtk-cli creator capability-total --describe
```

粉丝画像请使用 `creator follower-profile`。成本构成、投入、产出和 ROI 请使用 `creator roi-details`，不要从 `capability-total` 推断这些字段。

## 达人粉丝画像

使用 `creator follower-profile` 单独查看粉丝画像，包括性别分布、年龄分布和地理位置分布。

```bash
huayoungtk-cli creator follower-profile --handle ashfarienaz
huayoungtk-cli creator follower-profile --id 363364238753849
huayoungtk-cli creator follower-profile --describe
```

返回字段：`followerCount`、`gender`、`age`、`location`。分布值为百分制(0-100)；无数据时对应字段值为 `"暂无数据"`。

## 达人带货视频

`monitored=true` 表示视频已被关注/监控，系统每日自动同步。

```bash
huayoungtk-cli creator videos --handle ashfarienaz
huayoungtk-cli creator videos --handle ashfarienaz --from 2026-04-01 --to 2026-04-30
huayoungtk-cli creator videos --handle ashfarienaz --authorization-status authorized
huayoungtk-cli creator videos --handle ashfarienaz --tag <tag-name>
huayoungtk-cli creator videos --handle ashfarienaz --sort gmv:desc
huayoungtk-cli creator videos --describe
```

排序字段包括 `postTime`、`viewCnt`、`likeCnt`、`commentCnt`、`favoriteCnt`、`retweetCnt`、`orderCount`、`ordersPm`、`itemsSold`、`gmv`、`estCommission`、`duration`、`handle`。

`ordersPm` 为千播订单数（每千次播放的订单数 = 订单数×1000/播放数），不是百分比，值可超过 100。

## 达人带货直播

```bash
huayoungtk-cli creator lives --handle suphap2539
huayoungtk-cli creator lives --handle suphap2539 --from 2026-05-01
huayoungtk-cli creator lives --handle suphap2539 --sort gmv:desc
huayoungtk-cli creator lives --describe
```

排序字段包括 `startTime`、`endTime`、`gmv`、`itemsSold`、`estCommission`、`orderCount`、`viewCnt`、`likeCnt`、`commentCnt`、`handle`。

## 达人合作商品

使用 `creator products` 查看达人合作商品列表，包括公开佣金、公开广告佣金、定向佣金、定向广告佣金、订单数、GMV 等。

佣金字段（`openCommission`、`openAdsCommission`、`targetCommission`、`targetAdsCommission`）统一为百分制（0-100），与 UI 展示一致。

默认返回最多 200 条商品，可用 `--page-size` 缩小批量。`freeSample`、`planId`、`planName` 仅在商品关联邀约计划时返回。

```bash
huayoungtk-cli creator products --handle sahabatpadienterprise
huayoungtk-cli creator products --handle sahabatpadienterprise --page-size 50
huayoungtk-cli creator products --describe
```

## 达人索样记录

使用 `creator sample-requests` 查看达人发起的索样申请记录，包括商品、店铺、索样状态、产出作品数、带货订单数等。索样状态语义见 [索样申请参考](./sample-request.md)。

`commissionRate` 为百分制（0-100）。

```bash
huayoungtk-cli creator sample-requests --handle sahabatpadienterprise
huayoungtk-cli creator sample-requests --id 363364238753849
huayoungtk-cli creator sample-requests --handle sahabatpadienterprise --shop-id <shop-id>
huayoungtk-cli creator sample-requests --handle sahabatpadienterprise --sort gmv:desc
huayoungtk-cli creator sample-requests --handle sahabatpadienterprise --from 2026-01-01 --to 2026-03-31
huayoungtk-cli creator sample-requests --describe
```

排序字段：`applyTime`、`status`、`commissionRate`、`expiredTime`、`gmv`、`orderCount`、`videoCount`、`liveCount`、`mediaCount`、`lastSyncTime`，默认 `applyTime:desc`。

## 达人邀约计划

使用 `creator target-plans` 查看达人当前生效的邀约计划。

```bash
huayoungtk-cli creator target-plans --handle sahabatpadienterprise
huayoungtk-cli creator target-plans --describe
```

## 达人投入产出（ROI）

使用 `creator roi-details` 查看达人的投入产出汇总，包括总投入成本、净产出 GMV、ROI、索样成本、佣金成本、投流成本、其它支出等。

```bash
huayoungtk-cli creator roi-details --handle sahabatpadienterprise
huayoungtk-cli creator roi-details --id 363364238753849
huayoungtk-cli creator roi-details --cid <cid>
huayoungtk-cli creator roi-details --describe
```

字段：`totalCost`、`netGmv`、`roi`、`sampleRequestCost`、`commissionCost`、`adsCost`、`otherCost`、`sampleRequestCount`、`grossGmv`、`shops`、`videos`、`lives`、`products`、`itemsSold`、`unit`、`updateTime`。

关系：`totalCost` 含索样成本、佣金成本、投流成本和其它支出；`otherCost` 为手动录入成本合计（坑位费+线下佣金+其他）；ROI = netGmv / totalCost。达人尚未计算过 ROI 时各数值为 0。

## 达人合作单

使用 `creator collaboration-orders` 查看达人名下的合作单列表，包含合作形式、合作状态、投入产出、订单数、跟进人、合作商品等。

```bash
huayoungtk-cli creator collaboration-orders --handle sahabatpadienterprise
huayoungtk-cli creator collaboration-orders --id 363364238753849
huayoungtk-cli creator collaboration-orders --describe
```

字段：`id`、`products`、`contentType`、`creatorStatus`、`status`、`remark`、`input`、`output`、`orderCount`、`itemsSold`、`roi`、`shopNames`、`personInChargeId`、`personInChargeName`、`createTime`、`stopTime`、`unit`、`lastCalcTime`。

状态语义：`creatorStatus`（合作状态）取值 `NotContacted`/`Contacted`/`Collaborating`/`HasOrder`；`status`（审核状态）取值：`Archived`=已归档、`Pending`=待审核、`Approved`=生效中、`Refused`=已拒绝、`Cancel`=已取消。`input` 为总成本，`output` 为 GMV；ROI = 产出 / 投入。默认按创建时间倒序返回最近 20 条。

## 达人合作店铺

```bash
huayoungtk-cli creator shops --handle ashfarienaz
huayoungtk-cli creator shops --describe
```

## 达人与授权店铺的合作关系

使用 `creator shop-cooperation` 查看某达人在当前用户各授权店铺中的合作情况。结果包含合作状态、合作商品、定向邀约计划、视频数、直播数、索样记录数、首单时间、最后一笔订单时间、有效订单数和给我带货 GMV。

命令返回全部授权店铺。没有合作记录的店铺显示为「未接触」，数量为 0，时间为 `null`，明细为空数组。
传 `--shop-id` 时只返回指定店铺；该店铺必须在当前用户的授权范围内。

```bash
huayoungtk-cli creator shop-cooperation --handle ashfarienaz
huayoungtk-cli creator shop-cooperation --id 363364238753849
huayoungtk-cli creator shop-cooperation --id 363364238753849 --shop-id 276377792151553
huayoungtk-cli creator shop-cooperation --describe
```

字段：`creatorId`；`shops` 数组每项含 `shopId`、`shopName`、`shopCode`、`cooperationStatus`、`firstOrderTime`、`lastOrderTime`、`orderCount`、`gmv`、`videoCount`、`liveCount`、`sampleRequestCount`、`products`、`targetPlans`。

- `products`：合作商品列表，包含商品信息、带货统计、佣金、成本、价格、首末单时间、视频/直播/索样统计和关联邀约计划。
- `targetPlans`：定向邀约计划列表，包含计划信息、邀约关系、计划统计、样品设置和达人参与情况。
- `firstOrderTime`、`lastOrderTime`：首单时间和最后一笔订单时间，无数据时为 `null`。

合作状态（`cooperationStatus`）取值：`未接触` / `已触达` / `合作中` / `已出单`。

`creator shops` 适合查看达人已合作或已触达的店铺；`creator shop-cooperation` 适合查看全部授权店铺及其合作数据。

## 达人与商品的合作关系

使用 `creator product-cooperation` 查看达人在指定商品上的合作类型和带货数据。

```bash
huayoungtk-cli creator product-cooperation --id 123456 --product-id 987654321
huayoungtk-cli creator product-cooperation --handle example_creator --product-id 987654321
huayoungtk-cli creator product-cooperation --describe
```

字段：`creatorId`、`shopId`、`shopName`、`productId`、`productName`、`productAvatar`、`cooperationType`、`currentCommission`、`currentAdsCommission`、`commission`、`adsCommission`、`openCommission`、`openAdsCommission`、`targetCommission`、`targetAdsCommission`、`adsCost`、`videoCount`、`liveCount`、`sampleRequestCount`、`sampleRequestCost`、`firstOrderTime`、`lastOrderTime`、`orderCount`、`itemsSold`、`gmv`、`unit`、`currency`、`planId`、`planName`、`freeSample`、`price`、`priceUnit`、`status`、`pdpLink`。

- `cooperationType`：`开放计划` 或 `定向计划`。
- `currentCommission`、`currentAdsCommission`：当前合作类型对应的佣金比例，取值范围 0-100。
- `commission`、`adsCommission`：该达人为商品带来的预估佣金金额，与 `creator shop-cooperation` 商品明细中的同名字段同义。
- `openCommission`、`openAdsCommission`：开放计划佣金比例。
- `targetCommission`、`targetAdsCommission`：定向计划佣金比例。
- `firstOrderTime`、`lastOrderTime`：无订单时为 `null`。

## 导入公海达人

将公海达人导入当前团队达人库。`--id` 必须使用 `global-creator search/get/candidates` 返回的公海 ES ID，不是团队达人数据库 ID；使用 `--handle` 时必须同时指定公海国家代码 `--region`。一次最多导入 200 个达人，同一次调用只能指定一个国家代码。

```bash
huayoungtk-cli creator import --region US --id <global-creator-id>
huayoungtk-cli creator import --region US --handle <handle> --tag <tag>
huayoungtk-cli creator import --region US --id <id-1>,<id-2>
```

导入接口不返回新增数量或团队达人 ID；成功表示请求已提交完成。需要设置初始合作状态时可传 `--status NotContacted|Contacted|Collaborating|HasOrder`。需要批量导入时，应先确认公海 ID、国家和标签，再执行命令。

## 认领达人

将达人认领给当前登录用户（BD），用于 OTO 分配模式下的前置认领动作。

```bash
huayoungtk-cli creator claim --id <creator-id>
huayoungtk-cli creator claim --handle <handle>
huayoungtk-cli creator claim --cid <cid>
```

达人查找方式与 `creator get` 一致（`--id` / `--handle` / `--cid` 三选一）。

输出：`{"ok": true, "message": "已认领达人", "id": <id>}`。重复认领同一达人不会报错。

### 与 settings 配置的关系

`creator claim` 是否可用、是否必须，取决于以下配置（均通过 `settings get --key <KEY>` 读取）：

| 配置 key | 取值 | 对 creator claim 的影响 |
|---|---|---|
| `CREATOR_ASSIGNMENT` | `OFF` | 不可用。达人分配未开启 |
| `CREATOR_ASSIGNMENT` | `OTO` | 推荐使用。OTO 模式不走合作单，认领即建立归属关系 |
| `CREATOR_ASSIGNMENT` | `OTM_PRODUCT` / `OTM_SPU` | 不推荐。OTM 模式需要合作单记录归属，应改用 `collaboration-order create`；`claim` 只建归属关系、不建合作单，OTM 下不完整 |
| `BD_CLAIM_CREATOR` | `ON` | 允许 BD 自行认领达人，可用 `creator claim` |
| `BD_CLAIM_CREATOR` | `OFF` | 不允许 BD 自行认领，应由管理员分配 |
| `CREATOR_CLAIM_BEFORE_APPROVE` | `ON`（且 `CREATOR_ASSIGNMENT=OTO`） | 索样审批前必须先 `claim` 该达人，否则审批流程不应继续 |
| `CREATOR_CLAIM_BEFORE_APPROVE` | `OFF` | 审批前无需认领，`claim` 仅在主动建立归属时使用 |

典型用法：索样审批流程中，先读 `CREATOR_CLAIM_BEFORE_APPROVE` 和 `CREATOR_ASSIGNMENT`，确认是 OTO 路径后再对每笔待审批索样对应的达人执行 `creator claim`，然后才 `approve`/`reject`/`shelve`。详见 [索样申请参考](./sample-request.md)。

## 加为星标达人

使用 `creator star` 创建 RPA 任务，将指定达人加为某个 TikTok Shop 店铺的星标达人。

```bash
huayoungtk-cli creator star --handle <handle> --shop-id <shop-id>
huayoungtk-cli creator star --id <creator-id> --shop-code <shop-code>
huayoungtk-cli creator star --describe
```

达人通过 `--id` / `--handle` / `--cid` 三选一指定，店铺通过 `--shop-id` / `--shop-code` 二选一指定。`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须先查询客户端设备并让用户选择，再传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。

输出包含 `creatorId`、`shopId`、`jobId` 和 `message`。接口成功只表示任务已创建，随后用 `job get --job-id <jobId>` 查询实际执行结果。星标属于指定店铺，不是达人全局属性；当前 CLI 不支持取消已经生效的星标。

## 联系方式

```bash
huayoungtk-cli creator contact --handle <creator-handle>
huayoungtk-cli creator contact --id <creator-id>
huayoungtk-cli creator contact --describe
```

## 取消认领

取消当前登录用户（BD）对指定达人的认领，是 `creator claim` 的反操作。

```bash
huayoungtk-cli creator unclaim --id <creator-id>
huayoungtk-cli creator unclaim --handle <handle>
huayoungtk-cli creator unclaim --cid <cid>
```

达人查找方式与 `creator claim` 一致（`--id` / `--handle` / `--cid` 三选一）。

输出：`{"ok": true, "message": "已取消认领", "id": <id>}`。

### 前置校验

执行前会先用 `creator get` 检查达人是否被任一 BD 认领：

- 完全无人认领 → 直接报错 `该达人 <id> 当前无人认领，无需取消`
- 已被认领 → 继续取消认领

**局限**：CLI 只能确认达人是否已被认领，无法确认认领人是否为当前用户。取消前应核对达人当前负责人。

### 与 settings 配置的关系

| 配置 key | 取值 | 对 creator unclaim 的影响 |
|---|---|---|
| `CREATOR_ASSIGNMENT` | `OFF` | 不可用。达人分配未开启 |
| `CREATOR_ASSIGNMENT` | `OTO` | 仅删除归属关系，无合作单可影响 |
| `CREATOR_ASSIGNMENT` | `OTM_PRODUCT` / `OTM_SPU` | **会连带处理该达人名下的合作单**：已 `Approved` 的合作单被归档（`Archived`），`Pending` 的合作单被取消（`Cancel`）。建议执行前先用 `collaboration-order list --creator-id <id>` 确认会受影响的合作单 |
| `BD_CLAIM_CREATOR` | `ON` / `OFF` | 与 `creator claim` 同语义。OFF 时业务规则上不应使用 |

`CREATOR_CLAIM_BEFORE_APPROVE` 与取消认领无关——它只控制审批前置，不限制取消动作。

## 保存达人分析

`creator note add` 把一段达人分析文本归档到指定达人名下。同一达人可保存多次分析，全部保留、按创建时间倒序，用 `creator note list` 回看历史。内容约定使用 **Markdown 格式**（标题、列表、表格等），便于结构化记录达人画像、带货表现、合作建议等结论。建议单条分析正文不超过 3000 字，内容过长时可能被截断或保存失败。

```bash
huayoungtk-cli creator note add --handle ashfarienaz --content "## 达人画像\n粉丝 50w，泰国美妆头部..."
huayoungtk-cli creator note add --id 363364238753849 --content "$(cat analysis.md)"
huayoungtk-cli creator note list --handle ashfarienaz
huayoungtk-cli creator note add --describe
```

达人查找方式与 `creator get` 一致（`--id` / `--handle` / `--cid` 三选一）。`add` 是写操作，执行前需征得用户确认。

## 修改达人数据

以下命令执行前必须确认。

```bash
huayoungtk-cli creator status --handle ashfarienaz --shop-id 123456 --status Collaborating
huayoungtk-cli creator status --handle ashfarienaz --shop-id 123456 --status Contacted

huayoungtk-cli creator tag --handle ashfarienaz --tag vip
huayoungtk-cli creator tag --handle ashfarienaz --tag vip --tag active
huayoungtk-cli creator tag --handle ashfarienaz --tag vip --remove
```

## 达人信息更新

发起异步任务，从 TikTok Shop 同步指定达人的最新信息，含基本信息（如粉丝数、等级、评价等）、粉丝画像、带货能力。
返回 jobId 用于追踪任务进度。本命令每次同步一个达人。

```bash
huayoungtk-cli creator sync --handle <handle> --shop-id <shop-id>
huayoungtk-cli creator sync --id <creator-id> --shop-id <shop-id>
huayoungtk-cli creator sync --cid <cid> --shop-id <shop-id>
huayoungtk-cli creator sync --handle <handle> --shop-id <shop-id> --execute-mode openapi
```

输出包含 `jobId`、`executionMode` 和 `message`。

`--shop-id`（或 `--shop-code`，二选一）必填。达人查找方式与 `creator get` 一致（`--id`/`--handle`/`--cid` 三选一）。
如果用户没有明确指定 shop-id，需要你给出建议，则要求给出站点和拟更新达人所属国家一致的店铺。
`--execute-mode` 支持 `rpa|openapi`，默认 `rpa`。OpenAPI 更实时，但要求店铺 `openApi.authorized=true`；OpenAPI 忽略 `--device-id`。RPA 模式下，`extension` 店铺不指定插件实例时省略 `--device-id`；`huayang` 店铺执行前必须用 `device list --shop-id <shop-id> --online` 查找并让用户选择客户端设备，再传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行。

根据输出的 `executionMode` 查询任务状态。OpenAPI 使用 `job get --job-id <job-id> --execution-mode openapi` 轮询，活跃任务查不到时加 `--alive=false` 查询归档结果；RPA 任务结束后加 `--alive=false` 查询历史状态。

## 发送站内消息

发起异步任务，给达人发送 TikTok Shop 站内消息。
返回 jobId 用于追踪任务进度。本命令仅发送给单个达人。

```bash
huayoungtk-cli creator send-message --handle <handle> --shop-id <shop-id> --content "消息内容"
huayoungtk-cli creator send-message --handle <handle> --shop-id <shop-id> --image "team_disk://素材/example.jpg"
huayoungtk-cli creator send-message --handle <handle> --shop-id <shop-id> --content "请查看商品" --product-id <product-id>
huayoungtk-cli creator send-message --handle <handle> --shop-id <shop-id> --card-title "新品推荐" --content "请查看" --product-id <product-id>
huayoungtk-cli creator send-message --handle <handle> --shop-id <shop-id> --content "消息内容" --execute-mode openapi
```

`--content`、`--image`、`--product-id` 至少指定一项，也可以同时指定，合计最多发送 5 条。普通文本最多 2000 字符；`--image` 和 `--product-id` 均可重复。

图片必须使用 `disk list` 返回的 `team_disk://` 或 `user_disk://` URI；本地图片先用 `disk cp` 上传（可使用 `huayoungtk-cli disk` 命令查看或上传图片）。普通图片支持 jpeg/jpg/png。商品 ID 必须属于执行任务的店铺。

需要把标题、正文与图片或商品放在同一张消息卡片时添加 `--card-title`：标题最多 50 字符，正文最多 200 字符，并且只能搭配一张图片或 1–5 个商品。带标题的消息卡片仅支持 US、GB、MX 店铺。普通消息不需要 `--card-title`。

达人使用 `--id`、`--handle`、`--cid` 三选一指定；店铺使用 `--shop-id`、`--shop-code` 二选一指定。

输出包含 `creatorHandle`、`shopId`、可选的 `images`/`productIds`、`executionMode`、`jobId` 和结果说明。

`--execute-mode` 支持 `rpa|openapi`，默认 `rpa`。OpenAPI 更实时，要求店铺 `openApi.authorized=true`；支持普通文本、图片和商品消息，不支持带 `--card-title` 的组合消息卡片，并忽略 `--device-id`。RPA 模式下，`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺执行前必须查询客户端设备并让用户选择，再传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。

根据输出的 `executionMode` 查询任务状态。OpenAPI 使用 `job get --job-id <job-id> --execution-mode openapi`，活跃任务查不到时加 `--alive=false`；RPA 任务结束后用 `job get --job-id <job-id> --alive=false` 查询历史状态。

## 查询站内消息

查看指定店铺与单个达人的最新消息，按时间从新到旧返回。店铺必须已完成 TikTok OpenAPI 授权；先用 `shop get` 确认 `openApi.authorized=true`。

```bash
huayoungtk-cli creator messages --handle <creator-handle> --shop-id <shop-id> --limit 20
huayoungtk-cli creator messages --handle <creator-handle> --shop-id <shop-id> --limit 20 --sync
huayoungtk-cli creator messages --describe
```

首次查询会初始化该会话的最新一页消息。结果中的 `messages` 仍为空时，不要自行再次同步；先询问用户是否需要同步该会话，获得确认后才可添加 `--sync` 重新执行。每次最多返回最新 100 条。

输出包含 `conversationId`、`chatId`、`messages`、`hasMore` 和同步结果。`conversationId` 是 TikTok 会话 ID；`chatId` 是本地会话 ID。

## 达人分析流程

1. 用 `creator list` 搜索和筛选达人，列表已包含 GMV、ROI、订单数等带货数据。
2. 用 `creator get` 查看达人完整信息（联系方式、标签、屏蔽状态等）。
3. 用 `creator capability` 查看公海最近30天带货能力；用 `creator capability4me` 查看给我带货最近30天数据；用 `creator capability-total` 查看给我带货全部时间数据。如需粉丝画像，用 `creator follower-profile`。
4. 评估商业价值时，明确对比上述三种口径，不能把公海数据与给我带货数据混称为“达人 GMV”。
5. 推荐下一步动作：建联、合作、观察、拒绝、打标签或更新状态。
6. 需要归档分析结论时，用 `creator note add` 保存（内容用 Markdown）；同一达人可多次保存，用 `creator note list` 回看。
7. 修改备注、标签或合作状态前，先征得用户确认。
