# 邀约计划模板参考

邀约计划模板是在花漾界面中为某个店铺保存的一组邀约配置，包括商品与佣金、话术、联系方式和执行规则。CLI 只负责查看和使用已有模板；模板的创建、修改和删除在花漾界面中完成。

## 查找模板

先确定执行邀约的店铺，再查询该店铺的模板：

```bash
huayoungtk-cli target-plan-template list --shop-id <shop-id>
huayoungtk-cli target-plan-template list --shop-code <shop-code>
```

从 `templates[].id` 取得模板 ID。需要核对模板保存的配置时：

```bash
huayoungtk-cli target-plan-template get --shop-id <shop-id> --id <template-id>
huayoungtk-cli target-plan-template get --shop-code <shop-code> --id <template-id>
```

不要把模板 ID 当作 TikTok 邀约计划 ID，也不要只根据模板名称猜测 ID。

## 使用模板创建邀约

```bash
huayoungtk-cli target-plan create --template-id <template-id> --source team --region US --handle <creator-handle-1>,<creator-handle-2> --shop-id <shop-id>
```

使用模板时仍必须明确提供：

- 本次执行的店铺：`--shop-id` 或 `--shop-code`。
- 达人来源：`--source team/global`。
- 达人国家：`--region`。
- 达人标识：`--handle`、`--id` 或 `--cid`。
- 客户端浏览器店铺需要的 `--device-id`；插件店铺可省略。

模板中的商品佣金、话术、联系方式和执行规则会作为本次命令的默认配置。命令行明确传入的同名参数优先于模板，适合临时覆盖某项配置：

```bash
huayoungtk-cli target-plan create --template-id <template-id> --source team --region US --handle <creator-handle> --shop-id <shop-id> --content "本次使用的新话术"
```

如果模板缺少创建计划所需的商品、话术或站点必填联系方式，CLI 会报错；根据错误补充相应参数后再执行。

## 输出

`target-plan-template list` 返回：

- `total`：模板数量。
- `templates[].id`、`name`、`shopId`：模板标识和所属店铺。
- `templates[].valid`：模板配置是否能够正常读取；为 `false` 时查看 `parseError`，不要使用该模板创建任务。
- `templates[].planPolicy`、`productCount`：计划策略和商品数摘要。
- `templates[].updater`、`updateTime`、`createTime`：编辑信息。

`target-plan-template get` 还返回 `settings`，其中是模板保存的邀约配置。

不确定输出结构时使用：

```bash
huayoungtk-cli target-plan-template list --describe
huayoungtk-cli target-plan-template get --describe
```
