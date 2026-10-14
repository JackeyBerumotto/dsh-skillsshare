# 合作单参考

合作单（Collaboration order）是 BD（负责商务拓展的业务员）与达人之间的「合作契约」：BD 认领达人后，根据合作进展会形成一笔合作单，记录合作商品、坑位费、线下索样等投入，并按月汇总 GMV、ROI。

合作单与索样有关联关系：每条索样记录都可绑定到一笔合作单（`cooperationId`），系统按达人+商品+申请时间自动匹配；合作单的「索样成本」来自绑定索样记录的汇总。

`sample-request list / list-to-review / get` 返回的每条索样会带 `cooperationId` 和 `cooperation` 摘要（含 BD、合作状态、GMV/ROI、合作商品），可据此从索样反向查询合作单；未绑定时省略。

## 业务阶段（--stage）

合作单有 5 个业务阶段，由 `auditStatus` 和 `status` 组合确定：

| stage | 业务含义 | 状态条件 |
|---|---|---|
| `no-order` | 已生效但未出单 | `audit_status=Approved, status<HasOrder` |
| `has-order` | 已生效且已出单 | `audit_status=Approved, status=HasOrder` |
| `pending` | 待审核 | `audit_status=Pending` |
| `archived` | 已归档（合作结束，保留统计） | `audit_status=Archived` |
| `cancelled` | 已取消或已拒绝 | `audit_status in {Refused, Cancel}` |

## 合作单列表

```bash
huayoungtk-cli collaboration-order list
huayoungtk-cli collaboration-order list --stage has-order
huayoungtk-cli collaboration-order list --stage archived --sort gmv:desc
huayoungtk-cli collaboration-order list --handle <creator-handle>
huayoungtk-cli collaboration-order list --creator-id <creator-id>
huayoungtk-cli collaboration-order list --user-id <bd-user-id>
huayoungtk-cli collaboration-order list --shop-id <shop-id>
huayoungtk-cli collaboration-order list --shop-code <shop-code>
huayoungtk-cli collaboration-order list --product-no <product-no>
huayoungtk-cli collaboration-order list --cooperation-id <id>
huayoungtk-cli collaboration-order list --region US
huayoungtk-cli collaboration-order list -q "dress"
huayoungtk-cli collaboration-order list --create-time-from 2026-01-01 --create-time-to 2026-03-31
huayoungtk-cli collaboration-order list --follower-cnt-from 10000
huayoungtk-cli collaboration-order list --describe
```

**过滤参数**：

- `--stage`：业务阶段（5 取 1，见上表），不传则不按阶段过滤。
- `--creator-id`：达人 ID 精确匹配。
- `--handle`：达人 handle 前缀匹配。
- `--user-id`：BD 跟进人用户 ID。
- `--shop-id` / `--shop-code`（二选一）：按合作商品所在店铺过滤。
- `--product-no` / `--product-spu`：按合作商品精确过滤。
- `--cooperation-id`：按合作单 ID 精确过滤。
- `--region`：达人所属国家（Alpha2 码，如 `US`/`UK`/`MY`）。
- `-q, --query`：模糊搜索（合作单 ID / 达人 handle / 商品 SPU/productNo）。
- `--create-time-from` / `--create-time-to`：创建时间范围（YYYY-MM-DD）。
- `--follower-cnt-from` / `--follower-cnt-to`：达人粉丝数范围。

**排序字段**（`--sort field[:asc|desc]`，默认 `createTime:desc`）：
`createTime`、`creatorId`、`contentType`、`status`、`orderCount`、`gmv`、`userId`、`auditStatus`。

## 合作单详情

```bash
huayoungtk-cli collaboration-order get --id <id>
huayoungtk-cli collaboration-order get --describe
```

`--id` 必填，来自 list 输出的 `id` 字段。

详情返回：基础信息（达人 handle/昵称、BD、合作形式、状态）+ ROI 概览（GMV/总成本/ROI）+ 分项成本（索样/线下索样/佣金/投流/坑位费）+ 订单数 + 合作商品列表（`products`）+ 合作店铺 ID（`shopIds`）+ 当前审批节点（`lastAudit`，无审批时省略）。

## 创建合作单

```bash
huayoungtk-cli collaboration-order create --id <sample-request-id>
huayoungtk-cli collaboration-order create --request-id "<apply-id>"
huayoungtk-cli collaboration-order create --id <sr-id> --content-type live
huayoungtk-cli collaboration-order create --id <sr-id> --input-type slot-fee --input-cost 500 --input-unit USD
huayoungtk-cli collaboration-order create --id <sr-id> --bd-user-id <bd-user-id>
huayoungtk-cli collaboration-order create --id <sr-id> --auto-allocate
huayoungtk-cli collaboration-order create --id <sr-id> --describe
```

**创建前判断**：

1. 读取 `references/settings.md`。
2. 查询 `CREATOR_CLAIM_BEFORE_APPROVE` 和 `CREATOR_ASSIGNMENT`。
3. 只有 `CREATOR_CLAIM_BEFORE_APPROVE=ON` 且 `CREATOR_ASSIGNMENT=OTM_PRODUCT` 或 `OTM_SPU` 时，索样审批前才需要先创建合作单。
4. 如果 `CREATOR_ASSIGNMENT=OTO`，先完成达人认领，不使用 `collaboration-order create`。
5. 如果 `CREATOR_ASSIGNMENT=OFF` 或 `CREATOR_CLAIM_BEFORE_APPROVE=OFF`，索样审批不需要前置创建合作单。

**业务场景**：在 `OTM_PRODUCT` / `OTM_SPU` 达人分配模式下，合作单记录 BD 与达人围绕商品或 SPU 的合作关系。当团队开启「索样审批的达人认领」（`settings get --key CREATOR_CLAIM_BEFORE_APPROVE` 返回 `ON`）时，`ToReview` 索样需要先通过 `collaboration-order create` 绑定合作单，再继续审批。本命令补齐 CLI 的这条链路。

**安全规则**：`collaboration-order create` 是写操作。执行前先向用户复述索样 ID、达人、商品、归属 BD 和计划投入信息，并等待用户明确确认。

**参数**（除索样 ID 外全部可选）：

- `--id` / `--request-id` 二选一：索样记录 ID 或 TikTok 官方申请 ID。两者与 `sample-request get` 语义一致。
- `--content-type`：合作形式，`video` / `live`，默认 `video`。
- `--bd-user-id`：合作单归属 BD，默认当前登录用户。
- `--input-type`：投入类型，`slot-fee`（坑位费）/ `commission`（线下佣金）/ `other`（其他）。仅传 `--input-cost` 时默认 `slot-fee`。
- `--input-cost`：投入成本金额（正数），需配合 `--input-type`（或被默认为 slot-fee）。
- `--input-unit`：投入成本币种（USD/CNY/...），默认取索样上的 `unit`。
- `--auto-allocate`：达人未认领时是否自动 allocate（仅特定团队配置需要）。
- `--remark`：合作单备注。

只需指定索样，CLI 会自动补齐达人、商品和开始时间等创建合作单所需的信息。

**创建完成后**：索样自动绑定 `cooperationId`。当 `CREATOR_CLAIM_BEFORE_APPROVE=ON` 且 `CREATOR_ASSIGNMENT=OTM_PRODUCT` 或 `OTM_SPU` 时，再执行 `sample-request approve/reject/shelve`。

**常见错误**：

- 「未开启合作单机制，请联系管理员」→ 团队 `bdConfig.cooperationEnabled=false`。
- 「已经有当前达人的合作单了，请勿重复创建」→ 该 BD 已对该达人有有效合作单，先用 `collaboration-order list --creator-id <creator-id>` 查现存合作单，展示后询问用户下一步，不要重复创建。
- 「达人未认领，无法创建合作单」→ 加 `--auto-allocate`。
- 「商品不是合作商品，无法添加投入」→ 投入绑定的 productId 必须先在合作单上，这条通常发生在 `--input-type` 显式指定 productId 的场景；本命令默认用 SR 的 productNo 解析，所以正常不会触发。

## 字段速查

### 合作单状态枚举

- **合作状态 status**（`TkShopStatus`）：`NotContacted`（未接触）/ `Sent`（已触达）/ `Collaborating`（合作中，达人有处于待发货/发货中/In-progress/已完成的索样）/ `HasOrder`（已出单）。
- **审核状态 auditStatus**（`TkshopAuditStatus`）：`Pending`（待审）/ `Approved`（生效中）/ `Refused`（已拒绝）/ `Cancel`（已取消）/ `Archived`（已归档）。

### 成本字段

| 字段 | 含义 |
|---|---|
| `srCost` | 索样成本（系统从绑定的索样记录汇总） |
| `offlineSrCost` | 线下索样成本（手工录入的线下送样记录） |
| `commissionCost` | 佣金成本 |
| `adsCost` | 投流成本 |
| `inputCost` | 线下投入（坑位费等） |
| `costAmount` | 总投入（以上成本之和） |
| `gmv` | 产出 GMV |
| `roi` | ROI = gmv / costAmount |

### 审批节点 lastAudit

待审核合作单（或最近一次审批）的信息：`auditId`、`auditLevel`、`departmentId`（0=公司审批，>0=部门审批）、`status`、`handleUserId`、`handleTime`、`handleRemark`。
