# 商品评论参考

商品评论是 TikTok Shop 买家对所售商品的评分与评价，可能包含星级评分（1-5）、星级、文字、图片、视频、卖家回复、SKU、买家 handle、商品 ID 和订单号。

## 抓取商品评论

`product-rating sync` 会创建异步 RPA 任务。执行前必须向用户确认目标店铺和抓取范围。`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须先向用户确认客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。不要在未确认店铺和抓取范围时直接执行。

插件执行由 CLI 自动选择关联实例：

```bash
huayoungtk-cli product-rating sync --shop-id <shop-id>
```

只抓取指定商品时增加 `--product-id`（值为商品的 `productNo`）：

```bash
huayoungtk-cli product-rating sync --shop-id <shop-id> --product-id <product-id>
```

`--shop-id` 也可用 `--shop-code` 替代。命令返回 `jobIds`；因为 CLI 每次只提交一个店铺，正常只包含一个任务 ID。随后用该 ID 查询任务状态：

```bash
huayoungtk-cli job get --job-id <job-id>
```

抓取整个店铺时不传 `--product-id`；不要用空商品 ID 模拟商品级抓取。

## 商品评论列表

`--shop-id` 可选（也可用 `--shop-code` 替代，二选一）；不传时查询所有可访问店铺。

```bash
huayoungtk-cli product-rating list --shop-id <shop-id>
huayoungtk-cli product-rating list --shop-id <shop-id> --star 1 --star 2 --last-hours 24
huayoungtk-cli product-rating list --shop-id <shop-id> --product-id <product-id>
huayoungtk-cli product-rating list --shop-id <shop-id> --has-img --last-hours 168
huayoungtk-cli product-rating list --shop-id <shop-id> --order-no <order-no>
huayoungtk-cli product-rating list --shop-id <shop-id> -q <query>
huayoungtk-cli product-rating list --shop-id <shop-id> --sort starLevel:asc
huayoungtk-cli product-rating list --describe
```

布尔筛选：

```bash
--has-img   # 评论带有图片
--has-video # 评论带有视频
--has-text  # 评论带有文字
--has-follow-review # 评论带有追评
--incentivized # 激励性评论
```
排序字段：`reviewTime`、`starLevel`。

## 评论统计

```bash
huayoungtk-cli product-rating stat --shop-id <shop-id> --last-days 7
huayoungtk-cli product-rating stat --shop-id <shop-id> --from 2026-05-01 --to 2026-05-18
huayoungtk-cli product-rating stat --shop-id <shop-id> --product-id <product-id> --last-days 30
huayoungtk-cli product-rating stat --describe
```

输出字段：`totalCount`、`oneStarCount`、`twoStarCount`、`threeStarCount`、`fourStarCount`、`fiveStarCount`。

## 每日评论统计

```bash
huayoungtk-cli product-rating daily-stat --shop-id <shop-id> --last-days 30
huayoungtk-cli product-rating daily-stat --shop-id <shop-id> --from 2026-05-01 --to 2026-05-18
huayoungtk-cli product-rating daily-stat --describe
```

输出为对象，`dailyStats` 字段是数组，每项包含 `day` 和各星级分布；顶层另含 `total`、`page`、`pageSize`。

## 评论追评

`product-rating list` 只返回 `hasFollowReview` 布尔，不返回追评正文。差评原因常藏在追评里，对 `hasFollowReview: true` 的评论按需拉取：

```bash
huayoungtk-cli product-rating follow-review --review-id <id>
huayoungtk-cli product-rating follow-review --describe
```

`--review-id` 取自 `product-rating list` 输出的评论 `id` 字段。无追评时 `followReview` 为 `null`；字段说明用 `--describe` 查看。

## 评论巡检流程

1. 如果用户要求先抓取最新数据，先确认店铺和抓取范围。`extension` 店铺不指定插件实例时省略 `--device-id`，明确指定时可传；`huayang` 店铺必须先向用户确认客户端设备并传 `--device-id`；`both` 店铺必须询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略或传用户明确指定的 Extension `deviceId`。执行 `product-rating sync` 后用 `job get` 等待任务完成；仅查询已有评论时不要触发同步。
2. 如果用户给的是店铺名，先解析 shop ID。
3. 查询近期低星评论，通常使用 `--star 1 --star 2`。
4. 仅在相关时增加图片、视频、文字等筛选条件。
5. 汇总商品、订单、买家、星级、评论文字、媒体情况和评论时间。
6. 对 `hasFollowReview: true` 的评论，用 `product-rating follow-review --review-id <id>` 拉取追评正文（差评原因常在追评里）。
7. 标记优先处理对象：近期一星评论、带图/视频评论、重复出现的商品问题、未回复评论。
8. 给出后续处理建议。除非用户确认，不要修改买家、商品或订单数据。
