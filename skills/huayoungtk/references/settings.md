# 团队/CLI 配置参考

使用 `settings` 命令查看当前团队的业务配置，结果以枚举值返回。

## 读取配置

```bash
huayoungtk-cli settings get --key <key>
```

输出格式为 `{"KEY": "VALUE"}`，直接用 key 作为 JSON 字段名。

## 查看字段说明

不确定 key 的含义或返回值枚举时，使用 `--describe`，不调用 API：

```bash
huayoungtk-cli settings get --describe
```

该命令会返回所有支持的 key、每个 key 的业务含义以及可能的枚举值。

## 支持的 key

| key | 含义 | 返回值 |
|-----|------|--------|
| `CREATOR_ASSIGNMENT` | 达人分配模式 | `OFF` / `OTO` / `OTM_PRODUCT` / `OTM_SPU` |
| `CREATOR_CLAIM_BEFORE_APPROVE` | 索样审批的达人认领 | `ON` / `OFF` |
| `BD_CLAIM_CREATOR` | 是否允许 BD 自行认领达人 | `ON` / `OFF` |
| `COLLABORATION_ORDERS_CREATE_DIRECT` | 分配/认领达人时是否直接创建合作单 | `ON` / `OFF` |
| `COLLABORATION_ORDERS_CREATE_RULE` | 创建合作单审核机制 | `NO_APPROVAL` / `MANAGER_APPROVAL` / `BOSS_APPROVAL` |
| `COLLABORATION_ORDERS_PRODUCT_ASSIGN` | BD 认领商品审核机制 | `NO_APPROVAL` / `MANAGER_APPROVAL` / `BOSS_APPROVAL` |

### 返回值说明

#### CREATOR_ASSIGNMENT

- `OFF`：达人分配模式未开启，此时 `CREATOR_CLAIM_BEFORE_APPROVE`、`BD_CLAIM_CREATOR`、`COLLABORATION_ORDERS_CREATE_DIRECT`、`COLLABORATION_ORDERS_CREATE_RULE`、`COLLABORATION_ORDERS_PRODUCT_ASSIGN` 等参数没有意义
- `OTO`：一个达人只对应一个 BD（One-To-One），此时不使用合作单，`COLLABORATION_ORDERS_CREATE_DIRECT`、`COLLABORATION_ORDERS_CREATE_RULE`、`COLLABORATION_ORDERS_PRODUCT_ASSIGN` 等参数没有意义。审批索样前需要先认领达人时，用 `huayoungtk-cli creator claim --handle <handle>`（或 `--id`/`--cid`）
- `OTM_PRODUCT`：一个达人可对应多个 BD，互斥粒度为商品 ID（同一达人，针对同一商品只能归属一个 BD），使用合作单记录达人与 BD 的合作关系。
- `OTM_SPU`：一个达人可对应多个 BD，互斥粒度为商品 SPU（同一达人，针对跨店铺同一 SPU 的商品只能归属一个 BD），使用合作单记录达人与 BD 的合作关系。

#### CREATOR_CLAIM_BEFORE_APPROVE

- `ON`：索样审批前需要先完成达人归属动作，再执行 `approve`/`reject`/`shelve`。
  - `CREATOR_ASSIGNMENT=OTO`：先由 BD 认领该达人。
  - `CREATOR_ASSIGNMENT=OTM_PRODUCT` 或 `OTM_SPU`：先创建合作单。
  - `CREATOR_ASSIGNMENT=OFF`：达人分配模式未开启，无需前置认领或合作单。
  - `CREATOR_ASSIGNMENT` 返回其他未知值：按 CLI 报错提示处理。
- `OFF`：审批人无需先认领，可直接对 `ToReview` 的索样进行 `approve`/`reject`/`shelve`。

#### BD_CLAIM_CREATOR

- `ON`：BD 可以主动认领达人。
- `OFF`：只能由管理员分配达人。

#### COLLABORATION_ORDERS_CREATE_DIRECT

- `ON`：分配或认领达人时可直接生成合作单。
- `OFF`：分配/认领仅建立归属关系，不自动创建合作单。

#### COLLABORATION_ORDERS_CREATE_RULE

- `NO_APPROVAL`：创建合作单无需审核。
- `MANAGER_APPROVAL`：创建合作单只需部门审核（一级审核）。
- `BOSS_APPROVAL`：创建合作单需部门审核后，再由公司审核（二级审核）。

#### COLLABORATION_ORDERS_PRODUCT_ASSIGN

- `NO_APPROVAL`：认领或分配商品无需审核。
- `MANAGER_APPROVAL`：认领或分配商品只需部门审核（一级审核）。
- `BOSS_APPROVAL`：认领或分配商品需部门审核后，再由公司审核（二级审核）。

## 示例

```bash
huayoungtk-cli settings get --key CREATOR_ASSIGNMENT
huayoungtk-cli settings get --key CREATOR_CLAIM_BEFORE_APPROVE
huayoungtk-cli settings get --key BD_CLAIM_CREATOR
huayoungtk-cli settings get --key COLLABORATION_ORDERS_CREATE_DIRECT
huayoungtk-cli settings get --key COLLABORATION_ORDERS_CREATE_RULE
huayoungtk-cli settings get --key COLLABORATION_ORDERS_PRODUCT_ASSIGN
```

## 注意事项

- `settings` 是只读命令，可以直接执行。
- 如果返回了未预期的值，优先使用 `settings get --help` 查看当前 CLI 版本支持的 key 列表。
- 配置为空或返回未知枚举值时，CLI 使用对应的默认值（例如 `NO_APPROVAL`、`OFF` 或 `OTM_PRODUCT`）。
