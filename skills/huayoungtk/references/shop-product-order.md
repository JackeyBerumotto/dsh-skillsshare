# 店铺、商品、订单和买家参考

## 店铺

### 店铺列表

```bash
huayoungtk-cli shop list
huayoungtk-cli shop list --type Local
huayoungtk-cli shop list --site Malaysia
huayoungtk-cli shop list --site United_States
huayoungtk-cli shop list -q <query>
huayoungtk-cli shop list --describe
```

排序字段包括 `createTime`、`name`、`type`、`lastSyncTime`、`healthStatus`、`healthScore`，默认 `createTime:desc`。

`healthScore` 是 TikTok 店铺体验分：小于 4 分表示需要关注，4 分及以上表示正常。评分缺失或为负数（包括 `-1` 未评级）时，CLI 输出 `null` 表示未知；真实 0 分保留为 `0`。

`--site` 按站点/地区（国家）过滤，取值即店铺返回的 `site` 字段。大小写、下划线、空格、连字符均等价（`United_States`、`United States`、`united-states` 都匹配）。

可选站点（平台支持的 TikTok 站点全集，与 `site` 字段一一对应）：

| 站点 | 说明 |
|------|------|
| `United_States` | 美国 |
| `United_Kingdom` | 英国 |
| `Singapore` | 新加坡 |
| `Malaysia` | 马来西亚 |
| `Indonesia` | 印度尼西亚 |
| `Thailand` | 泰国 |
| `Philippines` | 菲律宾 |
| `Vietnam` | 越南 |
| `Mexico` | 墨西哥 |
| `France` | 法国 |
| `Italy` | 意大利 |
| `Spain` | 西班牙 |
| `Ireland` | 爱尔兰 |
| `Germany` | 德国 |
| `Japan` | 日本 |
| `Brazil` | 巴西 |

注意：并非每个团队都开通了全部站点。传入团队未使用的站点会报错并列出该团队当前可用站点，可据此确认实际取值。

### 店铺详情

```bash
huayoungtk-cli shop get --shop-id <shop-id>
huayoungtk-cli shop get --shop-name <shop-name>
huayoungtk-cli shop get --describe
```

本文档中凡 `--shop-id` 处均可用 `--shop-code` 替代（二选一）；`shop get` 还支持 `--shop-name`，三者三选一。

店铺详情中的 `healthScore` 含义及未知值处理与店铺列表一致。

`shop list` 的每个店铺和 `shop get` 的 `shop` 都返回 `openApi`：

| 字段 | 准确含义 |
|---|---|
| `authorized` | 店铺是否已授权 TikTok OpenAPI。 |

### 店铺同步

`shop sync --execute-mode` 支持 `rpa|openapi`，默认 `rpa`。两种模式调用不同的后端接口，执行前必须向用户确认。

```bash
huayoungtk-cli shop list
huayoungtk-cli shop sync --shop-id <shop-id>
huayoungtk-cli shop sync --shop-id <shop-id> --sync product,order
huayoungtk-cli shop sync --shop-id <shop-id> --sync product --execute-mode openapi
huayoungtk-cli shop sync --shop-id <shop-id> --sync sample-request --execute-mode openapi
```

RPA 可同步 `product`、`order`、`sample-request`、`creator`、`target-plan`，并可逗号分隔多选。OpenAPI 更实时，一次只能明确指定 `product` 或 `sample-request`，并要求 `openApi.authorized=true`。

根据返回的 `executionMode` 和 `jobId` 查询最终状态。OpenAPI 使用 `job get --job-id <job-id> --execution-mode openapi`；活跃任务查不到时加 `--alive=false`。

### 店铺关联达人

```bash
huayoungtk-cli shop creators --shop-id <shop-id> --status Collaborating
huayoungtk-cli shop creators --shop-id <shop-id> --status HasOrder
huayoungtk-cli shop creators --shop-id <shop-id> --ranking gmv
huayoungtk-cli shop creators --shop-id <shop-id> --ranking gmv --month 2026-07
huayoungtk-cli shop creators --shop-id <shop-id> --first-order-from 2026-07-01 --first-order-to 2026-07-31
huayoungtk-cli shop creators --describe
```

`--status Collaborating` 查询合作中但尚未出单的达人，`--status HasOrder` 查询已出单达人。GMV 排行不传月份表示全部时间；`--month` 表示一个自然月；连续月份使用 `--month-from/--month-to`。首单日期指达人第一次为该店铺出单的时间。

## 商品

商品状态：`Live`、`Deactivated`、`Reviewing`、`Suspended`、`Draft`、`Deleted`。

### 商品列表

`--shop-id` 必填。

```bash
huayoungtk-cli product list --shop-id <shop-id>
huayoungtk-cli product list --shop-id <shop-id> --status Live
huayoungtk-cli product list --shop-id <shop-id> -q "dress"
huayoungtk-cli product list --shop-id <shop-id> --sort itemsSold:desc
huayoungtk-cli product list --describe
```

排序字段包括 `id`、`createTime`、`updateTime`、`itemsSold`、`price`、`priceBottom`、`salePriceTop`、`salePriceBottom`、`quantity`、`cosRatio`、`adsCosRatio`、`cosRatioTop`、`cosRatioBottom`、`sampleCount`、`hasOrderCreatorCount`、`invitingCreatorCount`、`avgReviewStar`、`adsCost`、`status`、`lastSyncTime`，默认 `createTime:desc`。

佣金字段（`openCommission`、`openAdsCommission`、`historicalMinCommission`、`historicalMaxCommission`）统一为百分制（0-100），与 UI 展示一致。

`product list/get` 都返回以下商品经营统计字段，口径与商品管理页面一致：

| 字段 | 含义 |
|---|---|
| `orderCount` / `gmv` | 总出单数 / 总 GMV |
| `openPlanOrderCount` / `openPlanGmv` | 公开合作计划出单数 / 公开计划 GMV |
| `targetPlanOrderCount` / `targetPlanGmv` | 定向邀约计划出单数 / 定向计划 GMV |
| `commissionOrderCount` / `commissionGmv` | 达人带货出单数 / GMV |
| `partnerOrderCount` / `partnerGmv` | 服务商出单数 / GMV |

这些字段均统计该商品的有效订单。总计、达人带货和服务商维度排除索样订单与已取消订单；公开合作计划和定向邀约计划维度排除已取消订单。

每件商品的 `categories` 字段是 `{类目ID: 类目名}` map。要查看某个市场的全量类目树或反查兄弟类目，使用 `product-category list --country <code> --shop-type <Local|Global>`（详见 `references/product-category.md`）。

`product list` 只返回商品汇总信息，以及 `skuCount`、`lastSkuSyncTime`；不返回 SKU 明细。用户需要规格名称、规格描述、价格、库存、SKU 编码等详细 SKU 信息时，必须继续使用 `product get`，不要把商品级价格区间或总库存当成 SKU 数据。

### 商品详情

`--shop-id` 和 `--product-id` 必填。

```bash
huayoungtk-cli product get --shop-id <shop-id> --product-id <product-id>
huayoungtk-cli product get --describe
```

`product get` 的 `product.skus` 返回详细 SKU 列表，字段包括 `skuId`（TikTok SKU ID/编码）、`name`（规格名称）、`description`（规格描述）、`price`、`stock`、`currency`、`unit` 和 `image`。如果 `skus` 为空，表示后台当前没有该商品的 SKU 明细，通常需要先同步商品 SKU 数据。

### 商品关联达人

优先使用店铺参数加 `--product-id` 指定商品，CLI 会先确认商品存在。也可以使用 `--id` 直接传商品数据库 ID，即 `product list/get` 返回的 `id`，不是 `productId/productNo`。使用 `--id` 查询为空时，只表示没有匹配达人，不能据此判断商品是否存在；需要确认商品存在时，改用店铺参数加 `--product-id`。

```bash
huayoungtk-cli product creators --shop-id <shop-id> --product-id <product-id> --status Promoted
huayoungtk-cli product creators --shop-code <shop-code> --product-id <product-id> --status HasOrder
huayoungtk-cli product creators --id <id> --status Promoted
huayoungtk-cli product creators --id <id> --status HasOrder
huayoungtk-cli product creators --id <id> --ranking gmv
huayoungtk-cli product creators --id <id> --ranking gmv --month 2026-07
huayoungtk-cli product creators --id <id> --first-order-from 2026-07-01 --first-order-to 2026-07-31
huayoungtk-cli product creators --describe
```

`Promoted` 表示推广过该商品，包括尚未出单的达人；`HasOrder` 只保留该商品订单数至少为 1 的达人。首单日期指达人第一次卖出该商品的时间。GMV 排行的月份参数规则与 `shop creators` 相同。

店铺和商品达人排行属于聚合结果时，后台可能不返回关联记录 ID、店铺 ID 或某些统计字段。CLI 会省略这些字段，不会用 `0` 冒充真实值；查询对象本身分别放在顶层 `shopId` 或 `productDatabaseId`。

### 商品备注

修改备注前必须确认。

```bash
huayoungtk-cli product note --shop-id <shop-id> --product-id <product-id> --remark "备注"
```

## 订单

订单状态：`to_ship`、`shipped`、`pending`、`completed`、`cancellation`、`fail_delivery`。

### 订单列表

```bash
huayoungtk-cli order list --shop-id <shop-id>
huayoungtk-cli order list --shop-id <shop-id> --status to_ship
huayoungtk-cli order list --shop-id <shop-id> --from 2026-05-06 --sort amount:desc
huayoungtk-cli order list --shop-id <shop-id> --creator <creator-handle>
huayoungtk-cli order list --shop-id <shop-id> --promotion-type Video
huayoungtk-cli order list --shop-id <shop-id> --order-type organic
huayoungtk-cli order list --shop-id <shop-id> --order-type all --status all   # 跳过所有默认过滤
huayoungtk-cli order list --id <buyer-id>          # 按买家数据库 ID 筛选
huayoungtk-cli order list --handle <buyer-handle>  # 按买家 handle 前缀筛选
huayoungtk-cli order list --describe
```

**默认过滤行为**（与产品"看达人有效订单"语义对齐）：

- 订单类型默认 `real`（真实订单，`freeSample=false`）
- 订单状态默认排除 `cancellation`（已取消）

两个默认都可以显式跳过：

| 想看 | 命令 |
|---|---|
| 默认（真实订单 + 排除已取消） | `order list --shop-id <id>` |
| 全部订单（含索样 + 含已取消） | `order list --shop-id <id> --order-type all --status all` |
| 只看索样订单（仍排除已取消） | `order list --shop-id <id> --order-type sample` |
| 只看已取消订单 | `order list --shop-id <id> --status cancellation` |
| 真实订单（含已取消） | `order list --shop-id <id> --status all` |

排序字段包括 `id`、`shopId`、`amount`、`createTime`、`freeSample`、`status`、`quantity`、`cosFee`，默认 `createTime:desc`。

`--id` 与 `--handle` 同时传参id有更高优先级。买家的 ID/handle 可通过 `buyer list` 或 `buyer get` 获取。

参数 `--promotion-type` 用于按达人带货流量来源类型筛选，可选值：`Showcase`（橱窗）、`Video`（视频）、`Livestream`（直播）、`AffiliateProductPage`（联盟商品页）、`ExternalTrafficProgram`（外部流量）。

参数 `--order-type` 是订单类型预设，默认 `real`；显式传 `--free-sample` 或 `--has-creator` 时自动让位（覆盖默认）：

| 值 | 含义 | 等价字段组合 |
|---|---|---|
| `all` | 不过滤 | 不传 freeSample |
| `sample` | 达人索样订单 | `--free-sample=true` |
| `real` | 真实订单（全部） | `--free-sample=false` |
| `affiliate` | 真实订单（达人带货） | `--free-sample=false --has-creator=true` |
| `organic` | 真实订单（自然流量） | `--free-sample=false --has-creator=false` |

显式 `--order-type` 与 `--free-sample` / `--has-creator` 同时传会报错（互斥）。

### 订单详情

```bash
huayoungtk-cli order get --order-no <order-no>
huayoungtk-cli order get --describe
```

订单列表和详情均返回 `orderId` 与 `shopId`；发送命令会根据 `orderId` 自动识别店铺，`shopId` 只需用于筛选可用设备。

### 给订单买家发送店铺私信

发送私信会产生实际外部影响，执行前必须让用户确认目标订单、私信内容和图片，并主动询问用户是否要带上订单中的商品信息或云盘图片。`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须先向用户确认客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。

```bash
huayoungtk-cli order list --shop-id <shop-id>
huayoungtk-cli order send-message --order-id <order-id> --content "私信内容"
huayoungtk-cli disk list --path "team_disk://素材"
huayoungtk-cli disk cp "./本地图片.jpg" "user_disk://图片/本地图片.jpg"
huayoungtk-cli order send-message --order-id <order-id> --content "请查看图片" --image <disk-uri>
huayoungtk-cli order send-message --order-id <order-id> --content "请查看相关商品" --include-products
huayoungtk-cli job get --job-id <job-id>
```

- `--order-id` 是 `order list/get` 返回的 TikTok Shop 订单 ID。
- CLI 会根据订单自动读取所属店铺，无需也不允许另外传入店铺 ID。
- `extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须让用户从客户端设备中选择并传 `--device-id`；`both` 店铺必须先询问执行方式，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。
- `--content` 必填且最多 2000 字符。
- 发送前询问用户是否要带上商品信息；用户明确需要时才添加 `--include-products`。
- `--image` 只支持以 `team_disk://` 或 `user_disk://` 开头的云盘文件，不接受本地路径或普通 URL；可使用 `huayoungtk-cli disk` 命令查看或上传图片。
- 先使用 `disk list` 让用户选择已有图片；用户明确需要时才添加 `--image`，且只能使用返回的 `uri`。
- 用户指定本地图片时，先确认完整的本地源路径和云盘目标 URI，再使用 `disk cp <local-path> <disk-uri>` 上传；上传成功后使用目标 URI。详情参考 `disk --help` 和 `references/disk.md`。
- `--image` 可重复传递；支持 `jfif/pjpeg/jpeg/pjp/jpg/png`。CLI 会在创建任务前确认云盘文件存在且当前身份有权访问。文本、图片和商品合计最多 5 条消息。
- `--include-products` 会自动读取并发送该订单中的商品，无需另外提供商品 ID。
- 命令返回 `jobId`；任务创建成功不代表私信已经发送成功，应使用 `job get` 查询进度。

## 买家

查询方式：`--id` 或 `--handle`。

### 买家列表

```bash
huayoungtk-cli buyer list
huayoungtk-cli buyer list --shop-id <shop-id>
huayoungtk-cli buyer list --has-contact
huayoungtk-cli buyer list --tag "VIP" --region TH
huayoungtk-cli buyer list --sort orderAmount:desc
huayoungtk-cli buyer list --describe
```

排序字段包括 `id`、`orderCount`、`orderAmount`、`lastBuyTime`、`firstBuyTime`、`createTime`、`lastSyncTime`。

### 买家详情

```bash
huayoungtk-cli buyer get --id 123456
huayoungtk-cli buyer get --handle some_buyer_handle
huayoungtk-cli buyer get --describe
```

### 买家备注和标签

修改备注或标签前必须确认。

```bash
huayoungtk-cli buyer note --id 123456 --remark "VIP 买家"
huayoungtk-cli buyer note --id 123456 --remark ""
huayoungtk-cli buyer tag --id 123456 --tag "VIP"
huayoungtk-cli buyer tag --id 123456 --tag "VIP" --remove
```
