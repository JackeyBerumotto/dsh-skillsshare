# 达人包参考

达人包（creator pack）是**保存的筛选条件集合**，不是固定达人名单。每次查询时动态匹配，结果会随数据变化（新增达人、新索样记录、达人数据同步后都可能变）。两类：

| `groupType` | `typeName` | 含义 | 命中来源 |
|---|---|---|---|
| `SampleRequest` | 索样记录达人包 | 基于索样记录条件筛选 | 索样申请记录 |
| `Creator` | 常规达人包 | 基于达人库字段筛选 | 达人库 |

CLI 暴露三个只读子命令：`list` 看可见的达人包、`get` 看单个达人包的条件、`creators` 看当前命中的达人。`creators` 按 `groupType` 分流——索样包走索样分页、常规包走达人分页，两种 item 字段形状不同。

## 范围（scope）

每条记录的 `scope` 与 `--scope` 筛选参数的值集**不同**：

- 记录 `scope`：`team`（团队共用）、`mine`（我的个人包）、`other`（他人个人包）。
  - `personal=false` 或 `null` → `team`
  - `personal=true` 且创建人=当前用户 → `mine`
  - `personal=true` 且创建人≠当前用户 → `other`
- 筛选 `--scope`：`all`（默认，全部可见）、`team`、`mine`。

> `all` 受账号权限影响：非 boss 用户实际拿到"我的 + 团队共享"，不一定含他人个人包。

`typeName` 是 `groupType` 对应的中文展示名。

## 达人包列表

```bash
huayoungtk-cli creator-pack list
huayoungtk-cli creator-pack list --scope mine
huayoungtk-cli creator-pack list --scope team
huayoungtk-cli creator-pack list --type sample-request
huayoungtk-cli creator-pack list --type creator
huayoungtk-cli creator-pack list --describe
```

**过滤参数**：

- `--scope`：`all`（默认）/ `team` / `mine`。
- `--type`：`sample-request` / `creator`。

列表不展开筛选条件（详情用 `get`）。`estimateCount` 是上次估算值，可能非实时。

### list 字段

| 字段 | 含义 |
|---|---|
| `id` | 达人包 ID（`get`/`creators --id` 用这个） |
| `name` | 达人包名称 |
| `groupType` | 类型枚举（`SampleRequest`/`Creator`） |
| `typeName` | 类型展示名 |
| `scope` | 范围（`team`/`mine`/`other`） |
| `personal` | 是否个人包（布尔，可空） |
| `system` | 是否系统包 |
| `userId` | 创建人用户 ID |
| `estimateCount` | 上次估算命中数（可能非实时） |
| `conditionCount` | 筛选条件数量 |
| `lastEstimatedTime` | 上次估算时间 |
| `createTime` / `updateTime` | 创建 / 更新时间 |

## 达人包详情

`--id` 必填。

```bash
huayoungtk-cli creator-pack get --id <id>
huayoungtk-cli creator-pack get --id <id> --describe
```

`get` 展开筛选条件（`conditions`）。`estimateCount` 是最近一次估算结果，可能不是实时值。

### conditions

`conditions` 每项结构为 `{filedType, key, symbol, value}`：

| 字段 | 含义 |
|---|---|
| `filedType` | 条件字段类型 |
| `key` | 条件键 |
| `symbol` | 比较符（如 `>=`、`==`） |
| `value` | 条件值（多态，可能是数字、字符串、数组等） |

`logicalCondition` 表示条件间逻辑关系（`AND`/`OR`/`NOT`）。

### get 字段

除 list 的字段外，额外包含：

| 字段 | 含义 |
|---|---|
| `description` | 达人包描述 |
| `logicalCondition` | 条件间逻辑关系 |
| `conditions` | 筛选条件数组（见上） |

## 达人包命中达人

`--id` 与 `--favorite` 二选一：

- **SampleRequest（索样记录达人包）**：一行对应一笔索样记录，**同一达人多笔索样会出现多行，不去重**。默认排序 `applyTime:desc`。`--shop-id`/`--shop-code` 可选。
- **Creator（常规达人包）**：返回普通达人列表，默认排序 `lastSyncTime:desc`。**不支持 `--shop-id`/`--shop-code`**。
- **Favorite（手动关注）**：使用 `--favorite` 返回团队共享的手动关注达人。

```bash
huayoungtk-cli creator-pack creators --id <id>
huayoungtk-cli creator-pack creators --id <id> --page 2 --page-size 30
huayoungtk-cli creator-pack creators --id <id> --sort applyTime:asc
huayoungtk-cli creator-pack creators --id <索样包id> --shop-id <shop-id>
huayoungtk-cli creator-pack creators --favorite
huayoungtk-cli creator-pack creators --id <id> --describe
```

**参数**：

- `--id`：达人包 ID（与 `--favorite` 二选一，来自 `list` 的 `id`）。
- `--favorite`：查看团队手动关注的达人（与 `--id` 二选一）。
- `--page`：页码（默认 1）。
- `--page-size`：每页数量（默认 15）。
- `--sort`：`field[:asc|desc]`。索样包默认 `applyTime:desc`，常规包默认 `lastSyncTime:desc`。目前仅支持对应默认字段（可翻转方向）。
- `--shop-id` / `--shop-code`：仅索样包有效，按店铺筛选；常规包或手动关注传了报错。

### 输出结构

```json
{
  "pack": {"id": ..., "name": "...", "groupType": "...", "typeName": "..."},
  "creators": [...],
  "page": {"page": 1, "pageSize": 15, "total": 42}
}
```

`pack` 标识结果来源；手动关注结果的 `pack.groupType` 为 `Favorite`。`creators` 的 item 字段依 `pack.groupType` 而定，详见 `--describe`。

### 索样包 creators 字段（每行=一笔索样记录）

| 字段 | 含义 |
|---|---|
| `id` | 索样记录 ID |
| `requestId` | 申请 ID |
| `orderId` | 订单号 |
| `creatorHandle` / `creatorNickname` | 达人 handle / 昵称 |
| `productId` / `productName` | 商品编号 / 名称 |
| `sku` | SKU 描述 |
| `commissionRate` | 佣金率（%） |
| `status` | 索样状态 |
| `shelved` | 是否搁置 |
| `requestTime` / `expireTime` | 申请 / 过期时间 |
| `videoCount` / `liveCount` | 产出视频 / 直播数 |
| `orderCount` / `gmv` / `itemsSold` | 订单数 / GMV / 售出量 |
| `orderStatus` | 订单状态 |
| `shopId` | 店铺 ID |
| `updateTime` | 最后同步时间 |

### 常规包 creators 字段（瘦身集，无"为我"带货维度）

| 字段 | 含义 |
|---|---|
| `id` / `handle` / `creatorId` | 达人记录 ID / handle / TikTok Creator ID |
| `nickname` / `avatar` | 昵称 / 头像 |
| `region` | 地区 |
| `status` | 合作状态（CLI 翻译：`Sent`→`Contacted`） |
| `mcnType` | MCN 类型（CLI 翻译：`None`→`Unknown`、`NoPartner`→`Independent`、`BoundedPartner`→`Agency`） |
| `followers` / `level` | 粉丝数 / 等级 |
| `gmv` | 最近 GMV |
| `itemsSold` / `orderCount` | 售出量 / 订单数 |
| `liveCount` / `videoCount` | 产出直播 / 视频数 |
| `returnRate` | 退货率（%） |
| `roi` | ROI |
| `lastSyncTime` | 最后同步时间 |

> 常规包返回的是 `TkshopCreatorDto`（比 `creator list` 的 `TkshopCreatorDetailVo` 瘦），无 `gmv4me`/`itemsSold4me`/`commissionRevenue4me`/`sampleRequestCount` 等"为我"带货维度。需要这些字段用 `creator get --id` 单查。

## 典型工作流

1. `creator-pack list` 看可见达人包，按 `--scope`/`--type` 缩小范围。
2. `creator-pack get --id <id>` 看筛选条件，确认这个包筛的是什么。
3. `creator-pack creators --id <id>` 看当前命中的达人；`estimateCount` 过期或想看实际名单时用这个。
4. `creator-pack creators --favorite` 看团队手动关注的达人。
5. 需要单个达人完整字段时，从 `creators` 拿 `handle`/`creatorId`，再用 `creator get` 单查。
