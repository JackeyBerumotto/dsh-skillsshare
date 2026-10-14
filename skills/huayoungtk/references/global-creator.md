# 公海达人库

公海达人库用于在团队达人库之外发现 TikTok Shop 达人。

## 搜索达人

```bash
huayoungtk-cli global-creator search --region <country-code>
huayoungtk-cli global-creator search --region <country-code> --followers-from 10000 --category Beauty --sort gmv:desc
huayoungtk-cli global-creator search --region <country-code> --handles <creator-handle-1>,<creator-handle-2>
```

- `--region` 必填，一次只查一个国家。
- `--handles` 用于精确批量查询，最多 200 个；未传时可用 `--handle` 模糊搜索。
- 默认按粉丝数降序，分页结果只返回适合筛选的达人摘要。
- `--gmv-from`、`--gmv-to` 使用所选国家的本地货币。
- 佣金率、互动率、履约率和粉丝画像占比都直接传百分数，例如 `--post-rate-from 80` 表示最低 80%。
- 联系方式可用 `--has-contact`、`--without-contact` 筛选；`--contacts-all-empty` 表示 UI 所支持的联系方式全部为空，不能与前两者同时使用。
- 完整筛选条件和排序别名使用 `huayoungtk-cli global-creator search --help` 查看。

## 筛选精选公海达人

`global-creator candidates` 使用 ES 画像条件搜索精选公海达人，并继续排除不适合本次定向邀约的达人。它只查询候选人，不会发送邀约。

```bash
huayoungtk-cli global-creator candidates --shop-id <shop-id> --region US --category Beauty --followers-from 10000 --gmv-from 5000 --limit 100
huayoungtk-cli global-creator candidates --shop-id <shop-id> --region US --filter-has-order-by-shop --filter-has-allocated --exclude-team-library --limit 200
huayoungtk-cli global-creator candidates --shop-id <shop-id> --region US --category Beauty --followers-from 10000 --gmv-from 5000 --limit 100 --cursor <next-cursor>
```

- 命令固定按定向邀约场景筛选，无需额外指定场景参数。
- 画像条件与 `global-creator search` 一致，包括类目、粉丝数、GMV、销量、粉丝画像、互动率和履约率等。
- 默认不排除当前店铺已邀约达人；需要排除时显式指定 `--filter-invited-by-shop`。
- `--filter-invited-team-shop-id` 可排除其他店铺已经邀约过的达人。`--filter-invited-product` 排除当前店铺已邀约过指定商品的达人。
- `--filter-has-order-by-shop`、`--filter-has-order-team-shop-id`、`--filter-has-allocated` 和 `--exclude-team-library` 默认关闭，不要在未询问用户时擅自开启。
- `--limit` 为本次希望得到的可用候选人数，范围 1–2000。业务过滤可能需要后端多轮读取 ES；后端提前超时时 `timedOut` 为 `true`。
- `matchedCount` 是从当前游标位置开始、业务排除前的 ES 画像剩余命中数；首次查询时可视为画像条件总命中数。`candidateCount` 才是本次返回的可用候选人数。
- 输出存在 `nextCursor` 时可通过 `--cursor` 继续查询。必须原样保留店铺、画像条件、业务过滤和排序，只增加或替换 `--cursor`，否则可能漏掉或重复达人。
- 使用非 ID 字段排序时，命令会排除该排序字段缺失的达人，以保证多次游标查询稳定。

### 从商品优秀达人画像寻找候选人

当用户希望为某个商品快速邀约合适达人时：

1. 用 `product creators --shop-id <shop-id> --product-id <product-id> --ranking gmv --page-size 1` 找 GMV 最高达人。
2. 用 `product creators --shop-id <shop-id> --product-id <product-id> --first-order-from <YYYY-MM-DD> --first-order-to <YYYY-MM-DD>` 找目标时间范围内的首单达人。
3. 用 `creator get`、`creator follower-profile` 和 `creator capability` 分析这些优秀达人的国家、类目、粉丝量、粉丝画像、带货及内容表现，提取共同特征并转换成范围条件。
4. 用 `global-creator candidates` 搜索相似且通过邀约业务过滤的公海达人。不要把所有字段都做精确匹配；优先使用能解释带货表现的少量核心条件，并在候选过少时逐步放宽。
5. 用户确认候选人后，将公海 ES 记录 ID `candidates[].id` 传给 `target-plan create --source global --id ...` 发起定向邀约。必须保留 `--source global`；OpenAPI 公海邀约由 CLI 解析为 `handles`，不得把该 ID 当作团队达人 `creatorIds`。

## 查看完整资料

```bash
huayoungtk-cli global-creator get --region <country-code> --handle <creator-handle>
huayoungtk-cli global-creator get --region <country-code> --id <global-creator-id>
huayoungtk-cli global-creator get --region <country-code> --handle <creator-handle> --section contacts,sales
```

默认返回可用的全部公海资料，按以下卡片组织：

- `basic`、`identifiers`、`contacts`、`audience-profile`
- `sales`、`collaboration`
- `commerce-video`、`all-video`、`commerce-live`、`all-live`
- `channel-distribution`、`category-distribution`

`commerce-` 表示带货内容，`all-` 表示全部内容。金额保留两位小数，同时尽量返回 USD、本地金额和币种；`available: false` 表示没有该项数据，`disclosed: false` 表示该金额未披露，`authorized: false` 时 GMV 可能是平台给出的区间上限。所有比例输出为百分数。

## 查看字段能力

```bash
huayoungtk-cli global-creator fields
huayoungtk-cli global-creator fields --filterable
huayoungtk-cli global-creator fields --sortable
huayoungtk-cli global-creator fields --section commerce-video
```

`fields` 展示公海达人资料字段及其所属卡片。`filterable` 表示 CLI 已提供对应搜索参数，`sortable` 表示该字段支持排序。字段可排序不代表它能直接作为 `--sort` 名称使用；具体名称以 `global-creator search --help` 为准。
