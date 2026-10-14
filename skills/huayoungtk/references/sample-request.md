# 索样申请参考

达人向 TikTok Shop 卖家申请免费样品时，系统会创建一笔索样请求（sample request）。索样请求的状态流转如下：

1. 待审批（ToReview）
索样请求创建后的初始状态。卖家可以选择同意、拒绝或搁置。

- 卖家同意后，系统生成索样订单，状态变为 **待发货（ReadyToShip）**。
- 卖家拒绝后，状态变为 **已拒绝（Reject）**。
- 卖家未在规定时间内处理，状态变为 **已过期（Expired）**。
- 搁置仅表示暂缓处理，不改变索样请求状态。

2. 已批准待发货（ReadyToShip）
卖家已同意索样申请并生成索样订单，等待卖家发货。

3. 已发货（Shipped）
样品已经发出，但达人尚未确认收货或进入内容产出阶段。

4. 已收货待产出（InProgress）
达人收到样品后，需要围绕该样品产出带货视频或直播。

5. 已完成（Completed）
达人已经为样品产出符合要求的视频或直播，索样履约完成。

6. 已取消（Cancelled）
达人主动取消索样请求。

7. 已逾期（Overdue）
如果达人收到样品后，未在规定期限内产出任何带货视频或直播，则视为已逾期。

## 状态说明
状态：`ToReview`、`ReadyToShip`、`Shipped`、`InProgress`、`Completed`、`Cancelled`、`Reject`、`Expired`、`Overdue`。

## 索样列表

```bash
huayoungtk-cli sample-request list --shop-id <shop-id>
huayoungtk-cli sample-request list --shop-id <shop-id> --status InProgress
huayoungtk-cli sample-request list --shop-id <shop-id> --sort gmv:desc --from 2026-05-06
huayoungtk-cli sample-request list --shop-id <shop-id> --person-in-charge <user-id>
huayoungtk-cli sample-request list --describe
```

排序字段包括 `applyTime`、`status`、`commissionRate`、`expiredTime`、`gmv`、`orderCount`、`videoCount`、`liveCount`、`videoGmv`、`liveGmv`、`videoOrderCount`、`liveOrderCount`、`mediaCount`、`orderCreateTime`、`orderPaidTime`、`orderRtsTime`、`orderSignedTime`、`orderCompletedTime`、`orderLatestRtsTime`、`orderCloseSlaTime`、`orderStatus`、`lastSyncTime`，默认 `applyTime:asc`。

注意：`list` 不返回待审批（ToReview）的索样，且禁止传入 `--status ToReview`；该参数会直接报错并引导使用 `sample-request list-to-review`。查看待审批索样必须用 `list-to-review`。

列表输出包含 `personInChargeNickName` 和 `personInChargeId`。

每条索样若已绑定合作单，会额外返回 `cooperationId` 和 `cooperation` 摘要（含 BD、合作状态、GMV/ROI、合作商品），用于从索样反向跳转到合作单。未绑定时省略。

## 待审批索样列表

专门查询待审批（ToReview）的索样，输出包含达人详情（粉丝数、ROI、标签等）和商品详情（价格、库存、评分等），便于进行审批分析。

`--shop-id` 必填，未指定会报错 `必须指定 --shop-id 或 --shop-code`；也可用 `--shop-code` 替代（二选一）。

```bash
huayoungtk-cli sample-request list-to-review --shop-id <shop-id>
huayoungtk-cli sample-request list-to-review --shop-id <shop-id> --all
huayoungtk-cli sample-request list-to-review --shop-id <shop-id> -q "handle_or_id"
huayoungtk-cli sample-request list-to-review --shop-id <shop-id> --sort commissionRate:desc
huayoungtk-cli sample-request list-to-review --shop-id <shop-id> --shelved
huayoungtk-cli sample-request list-to-review --describe
```

排序字段与 `list` 相同，默认 `applyTime:asc`。

默认排除已搁置的索样，`--all` 包含全部。

当用户需要查询某个店铺的待审批索样请求时，首先汇报总共有多少笔待审批的索样请求以及最近同步时间 `lastSyncTime`，然后以表格形式列出前 15 笔索样记录（除非用户特别指定要求查询多少笔记录），注意：只考虑待审批的索样请求，无需考虑其它状态的索样记录。

## 索样详情

获取索样的详细信息，包含与 list 一致的字段和 videoCount/liveCount。不再直接返回 videos/lives 数组，详细列表通过 `sample-request videos`/`sample-request lives` 获取。

通过 `--id`（数据库 ID）或 `--request-id`（TikTok 官方申请 ID）二选一查找，两者均可直接取自 `sample-request list` 输出的 `id`/`requestId` 字段。

```bash
huayoungtk-cli sample-request get --id <id>
huayoungtk-cli sample-request get --request-id <request-id>
huayoungtk-cli sample-request get --describe
```

## 关联视频和直播

```bash
huayoungtk-cli sample-request videos --id <id>
huayoungtk-cli sample-request videos --request-id <request-id>
huayoungtk-cli sample-request lives --id <id>
huayoungtk-cli sample-request lives --request-id <request-id>
huayoungtk-cli sample-request videos --describe
huayoungtk-cli sample-request lives --describe
```

## 搁置或取消搁置

仅对 `ToReview` 状态的索样有效。执行前必须确认。`--id` 与 `--request-id` 二选一，前者是数据库 ID（来自 `list`/`list-to-review`/`get` 输出的 `id`），后者是 TikTok 官方申请 ID（来自 `requestId` 字段）。

```bash
huayoungtk-cli sample-request shelve --id <sample-request-id>
huayoungtk-cli sample-request shelve --request-id <request-id>
huayoungtk-cli sample-request shelve --id <sample-request-id> --unshelve
huayoungtk-cli sample-request shelve --request-id <request-id> --unshelve
```

输出结构：

```json
{"action":"搁置/取消搁置","id":123,"shelved":true,"success":true}
```

## 同意或拒绝

这些动作会触发 RPA，且不可撤销。执行前必须确认具体目标和动作。

```bash
huayoungtk-cli sample-request approve --id <sample-request-id>
huayoungtk-cli sample-request approve --request-id <request-id>
huayoungtk-cli sample-request reject --id <sample-request-id>
huayoungtk-cli sample-request reject --request-id <request-id>
```

根据索样所属店铺的 `browserType` 决定执行方式：

- `browserType=extension`：不指定具体实例时省略 `--device-id`，由 CLI 自动选择关联插件实例；只有用户明确要求指定插件实例时，才查询 Extension 设备并传对应的 `--device-id`。
- `browserType=huayang`：执行前运行 `device list --shop-id <shop-id> --online`，只展示客户端设备，由用户选择；命令必须带用户选择的 `--device-id`。
- `browserType=both`：必须先询问用户使用客户端浏览器还是插件执行。选择客户端时按 `huayang` 处理，必须传用户选择的 `--device-id`；选择插件时可省略 `--device-id`，只有用户明确要求指定插件实例时才传对应的 Extension `deviceId`。
- 插件店铺没有关联的在线插件设备时，先提醒用户打开安装了插件的浏览器并确保插件在线，不要改用不关联的客户端设备。

## 索样审批流程

索样审批包含查询、评估、收集决策、最终确认和执行。不要边看边执行，批量审批时先收集完整决策，再统一确认和执行。

1. 读取系统参数：
   - `huayoungtk-cli settings get --key CREATOR_CLAIM_BEFORE_APPROVE`
   - `huayoungtk-cli settings get --key CREATOR_ASSIGNMENT`
   - 如果 `CREATOR_CLAIM_BEFORE_APPROVE=OFF`：继续后续审批流程，不需要前置认领或合作单。
   - 如果 `CREATOR_CLAIM_BEFORE_APPROVE=ON` 且 `CREATOR_ASSIGNMENT` 的值为 `OTM_PRODUCT` 或 `OTM_SPU`：进入「创建合作单-审批」流程。对未绑定 `cooperationId` 的 `ToReview` 索样，先按 `references/collaboration-order.md` 执行 `huayoungtk-cli collaboration-order create --id <sr-id> --auto-allocate`；`--auto-allocate` 让合作单创建时自动认领达人，避免因达人未认领导致创建失败。创建成功后索样自动绑定 `cooperationId`，再继续 `approve`/`reject`/`shelve`。如果索样已带 `cooperationId`，不要重复创建合作单。
   - 如果 `CREATOR_CLAIM_BEFORE_APPROVE=ON` 且 `CREATOR_ASSIGNMENT=OTO`：先完成达人认领，不使用 `collaboration-order create`，也不需要 `--auto-allocate`；索样记录上的达人字段是 `creatorHandle`，用 `huayoungtk-cli creator claim --handle <creatorHandle>` 认领当前索样对应的达人，成功后再继续 `approve`/`reject`/`shelve`。
   - 如果 `CREATOR_ASSIGNMENT=OFF`：达人分配模式未开启，继续后续审批流程。
   - 如果配置查询失败、返回空值或未知值：不要继续审批，先向用户说明配置状态无法确认。
2. 解析 `shopId`。如果用户没有明确店铺，先用 `shop list` 或 `shop get` 找到店铺；无法唯一匹配时让用户选择。
3. 用 `sample-request list-to-review --shop-id <shop-id>` 查询待审批索样。默认先取 `--page-size 15`，除非用户指定数量。默认不查询或展示已搁置的索样请求，除非用户明确要求查看搁置项、全部索样或包含搁置项。
4. 先汇报 `total` 和 `lastSyncTime`。如果 `lastSyncTime` 距今超过 48 小时，提示用户数据可能过期；用户确认更新后，执行 `shop sync --shop-id <shop-id> --sync sample-request`，默认 `--execute-mode rpa`。OpenAPI 更实时；选择 `--execute-mode openapi` 前确认店铺 `openApi.authorized=true`，该模式不使用设备。RPA 模式下，`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须先让用户选择客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。同步任务创建后，根据返回的 `executionMode` 查询 `jobId`；OpenAPI 传 `job get --job-id <job-id> --execution-mode openapi`。任务已结束且当前查询找不到时加 `--alive=false`。任务成功后重新执行 `list-to-review`。
5. 展示待审批索样时，只展示 `ToReview` 相关结果，并原则上忽略 `shelved=true` 的记录。数量大于 15 时按 15 笔一页展示和决策，除非用户要求更多或更少。先让用户完成当前 15 笔的动作选择，再进入下一批 15 笔；不要一次性把大量索样全部展开给用户决策，除非用户明确要求。每行优先包含：`requestId`、达人 handle/昵称、商品名、`productCategories`、`requestTime`、`expireTime`、`gmv4me`、`itemsSold4me`、`sampleRequestCount`、`otherShopSampleRequests`、`otherShopSameProductRequests`、`gmv`、`itemsSold`、`creatorFollowerCount`。
6. 审批评估先看索样列表自带字段，不要一开始就展开所有详情。优先判断商品类目匹配度、达人带货能力、历史为我带货表现和重复索样风险。只对候选、争议或准备同意的对象补查更多命令，避免无谓扩大查询。
7. 类目匹配是核心加分项。先读取样品商品类目 `productCategories`，再用 `creator capability --handle <creator-handle>` 查看 `gmvByChannel`。如果 `gmvByChannel` 中的类目与 `productCategories` 有交集，且交集类目的 GMV 占比较高，视为强加分项。也可以用 `creator get --handle <creator-handle>` 查看达人 `categories`；如果 `categories` 与 `productCategories` 有交集，也视为加分项。`gmvByChannel` 优先级高于 `categories`，因为它代表实际成交类目分布。
8. 达人整体带货能力是基础加分项。用 `creator capability --handle <creator-handle>` 查看 `capability.gmv` 和 `capability.itemsSold`。如果 GMV 和售出件数较高，说明达人公开市场成交能力强，是加分项。若 GMV/销量高且类目与样品匹配，推荐权重应明显提高。
9. 达人粉丝规模是辅助加分项。用 `creator get --handle <creator-handle>` 查看粉丝数字段，如 `followerCnt`。粉丝数量非常高说明潜在曝光能力强，是加分项。但粉丝数不能单独决定审批，应结合 `gmv`、`itemsSold`、类目匹配和历史为我带货表现判断。
10. 达人为当前卖家或当前店铺的历史带货表现是重要加分项。优先查看索样记录中的 `gmv4me` 和 `itemsSold4me`；需要补查时，用 `creator capability4me --handle <creator-handle>` 看最近30天，用 `creator capability-total --handle <creator-handle>` 看全部时间。如果给我带货 GMV 或销量较高，说明达人已经为我产生过成交，是强加分项。该信号通常比公海带货能力更贴近审批决策。若给我带货数据高且类目匹配，应优先推荐同意。
11. 重复索样风险是核心减分项。查看索样记录中的 `sampleRequestCount`、`otherShopSampleRequests`、`otherShopSameProductRequests`。其中 `otherShopSameProductRequests != 0` 是明确减分项，表示达人已经在其它店铺索过同样商品，可能存在重复拿样、内容重复、合作冲突或样品浪费风险。`sampleRequestCount` 和 `otherShopSampleRequests` 可作为辅助风险指标，数量很高时提示达人索样行为频繁，但不一定直接否决。
12. 其它风险项也要纳入判断：`expireTime` 已过或临近过期、商品库存不足、商品评分低、达人退货率 `creatorCancelRate` 高、当前店铺或其它店铺重复索样过多。
13. `搁置` 是索样审批里的特殊动作。业务含义不是正式拒绝，而是把该索样放到不显眼的位置，避免继续干扰卖家视线；如果后续不处理，这笔索样会在到期后自动变为已过期。因此默认查询和审批时应自动忽略已搁置的索样请求；当判断一笔索样不适合同意时，优先建议 `搁置`，而不是 `拒绝`；只有用户明确要求直接拒绝，或业务场景明确必须拒绝时，才建议 `拒绝`。推荐 `搁置` 时，应说明这是暂不处理、降低干扰、等待自然过期的处理方式。
14. 需要判断受众匹配时，用 `creator follower-profile --handle <creator-handle>` 查看 `followerCount`、`gender`、`age`、`location`。地区、年龄和性别要与商品及店铺市场匹配。
15. 仍然证据不足时，再查 `creator videos`、`creator lives`、`creator sample-requests`，或用 `sample-request get/videos/lives` 看索样详情与关联内容。优先查有争议或准备同意的对象，避免无谓扩大查询。
16. 给每笔索样推荐一个动作：`同意`、`搁置` 或 `请求更多信息`。默认不要把 `拒绝` 作为常规推荐动作；当判断不适合同意时，通常推荐 `搁置`。建议必须给出简短理由，至少引用 2 类证据。优先引用：类目匹配、历史为我 GMV/销量、公开市场 GMV/销量、粉丝数量、重复索样风险、商品库存、商品评分、过期时间、受众匹配度。
17. 多笔索样审批时，要在当前会话中记录每一批的用户最终决策结果，包括 `id` 或 `requestId`、店铺、达人 handle、商品、建议动作和用户确认动作。每批结束时输出“本批决策记录表”，列出 `requestId`、达人、商品、建议动作和用户确认动作。用户完成当前批次后，再查询或展示下一批待审批索样。直到用户确认所有批次都审批完毕，再汇总完整审批计划。
18. 多笔索样审批不要每确认一笔或每确认一页就立刻执行动作。先把所有批次的决策收集完整，最后统一展示完整审批计划并请求用户最终确认；确认后再一次性触发审批动作。`approve` / `reject` / `shelve` 都应在最终确认后统一执行，避免边决策边修改状态。
19. 最终执行前必须复述完整计划，确认信息必须包含 `id` 或 `requestId`、店铺、达人 handle、商品、动作和执行方式。`huayang` 店铺以及 `both` 店铺选择客户端浏览器执行时，还必须包含用户选择的 `deviceId`；选择插件执行且用户明确指定插件实例时，也要包含对应的 Extension `deviceId`，未指定具体实例时省略。如果审批前需要创建合作单，完整计划中也要列出 `collaboration-order create` 步骤。等待用户明确确认后，才能执行 `approve`、`reject`、`shelve` 或 `collaboration-order create`。

## 执行后的状态查询

`approve` / `reject` 返回 `success=true` 和 `jobId`，只表示任务已创建。任务完成前索样状态仍为 `ToReview`；完成后，同意变为 `ReadyToShip`，拒绝变为 `Reject`。刚提交就查到 `ToReview` 是正常的，不要重复提交。

不需要每次执行后都强制轮询。**用户主动询问「这笔到底成功了没」、或怀疑目标可能已被 TikTok 端处理（如 `expireTime` 已过、被达人取消）时**，再用 `jobId` 查询：

```bash
huayoungtk-cli job get --job-id <job-id>                 # 任务还在跑/最近完成时
huayoungtk-cli job get --job-id <job-id> --alive=false   # 任务已结束、当前查不到时看历史
```

常见终态：

- `status=Succeed` —— RPA 跑通，TikTok 端动作已生效。
- `status=Failed` + `description` 含「该笔索样请求已被处理或已过期」—— 目标在 TikTok 端已过期（系统状态仍是 ToReview），RPA 被对方忽略；可向用户解释这是 TikTok 端判定，不是 CLI 报错。

直接使用 `job get` 查询任务结果，无需让用户前往平台页面查询 `jobId`。

## 常用审批命令

```bash
huayoungtk-cli settings get --key CREATOR_CLAIM_BEFORE_APPROVE
huayoungtk-cli settings get --key CREATOR_ASSIGNMENT
huayoungtk-cli sample-request list-to-review --shop-id <shop-id>
huayoungtk-cli sample-request list-to-review --shop-id <shop-id> --all
huayoungtk-cli sample-request get --id <sample-request-id>
huayoungtk-cli collaboration-order create --id <sample-request-id>
huayoungtk-cli creator capability --handle <creator-handle>
huayoungtk-cli creator capability4me --handle <creator-handle>
huayoungtk-cli creator capability-total --handle <creator-handle>
huayoungtk-cli creator videos --handle <creator-handle> --sort gmv:desc
huayoungtk-cli creator lives --handle <creator-handle> --from 2026-05-01
huayoungtk-cli sample-request shelve --id <sample-request-id>
huayoungtk-cli sample-request shelve --request-id <request-id>
huayoungtk-cli sample-request approve --id <sample-request-id>
huayoungtk-cli sample-request approve --request-id <request-id>
huayoungtk-cli sample-request reject --id <sample-request-id>
huayoungtk-cli sample-request reject --request-id <request-id>
```
