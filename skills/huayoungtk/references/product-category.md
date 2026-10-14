# 商品类目参考

TikTok Shop 商品按区域（region）维护类目树。CLI 提供只读查询，主要用途：

- 反查类目 ID 的可读名称（配合 `product list/get`、`sample-request list-to-review`、`creator capability` 中的类目字段）
- 把媒体端识别出的商品词（达人主页标题、hashtag、封面 alt 等）归一化到标准类目
- 查询某一级类目下的二/三级子类目

类目 ID 在所有 CLI 命令中是同一套：`product list.categories` 的 key、`sample-request list-to-review.productCategories` 的 key、`creator capability.gmvByChannel` 的 key 都是同一组 TikTok Shop 类目 ID。

## 类目列表

```bash
huayoungtk-cli product-category list --country TH --shop-type Local
huayoungtk-cli product-category list --country TH --shop-type Local --level 1
huayoungtk-cli product-category list --country TH --shop-type Local --parent-id 600001
huayoungtk-cli product-category list --country TH --shop-type Local -q Kitchen
huayoungtk-cli product-category list --country TH --shop-type Local --flat
huayoungtk-cli product-category list --country TH --shop-type Global
huayoungtk-cli product-category list --country TH --shop-type Local --describe
```

参数：

- `--country`（必填）：2 字母国家码，如 `TH`、`MY`、`VN`、`PH`、`ID`、`SG`、`US`、`GB`、`JP`、`KR`、`DE`、`FR`、`ES`、`IT`、`MX`、`BR`、`AE`、`SA`、`TR`、`CN`、`HK`、`TW`、`AU`、`CA` 等。
- `--shop-type`（必填）：`Local`（本土店）或 `Global`（跨境店）。不同店铺类型可能使用不同的类目树。不知道店铺类型时，先跑 `shop get --shop-id <id>` 看 `type` 字段。
- `--level`：按层级过滤，如 `1` 只返回一级类目。默认 0 表示不过滤。
- `--parent-id`：只返回指定父类目 ID 下的直接子类目。
- `-q, --query`：按类目名称子串模糊匹配（大小写不敏感）。
- `--flat`：扁平输出，默认是树形（嵌套 `children`）。

## 输出字段

顶层：

| 字段 | 说明 |
|---|---|
| `country` | 查询的国家/市场代码（2 字母） |
| `currency` | 市场币种（CLI 内置静态映射，未覆盖的国家返回空串） |
| `shopType` | 店铺类型（Local/Global，必传） |
| `lastSyncTime` | 类目数据最近一次同步时间（UTC+8，格式 `2006-01-02 15:04:05`；尚未同步时省略） |
| `categories` | 类目列表，默认树形，`--flat` 时扁平 |

`categories` 元素：

| 字段 | 说明 |
|---|---|
| `id` | TikTok Shop 类目 ID |
| `name` | 类目名称（按 region 本地化） |
| `level` | 层级（0=根、1=一级、2=二级、3=三级...） |
| `parentId` | 父类目 ID，根节点省略 |
| `path` | 从根到当前节点的完整路径数组，每项含 `id` 和 `name` |
| `children` | 子类目列表（仅树形模式返回；叶子节点为 `[]`） |

## 输出示例（树形，默认）

```json
{
  "country": "TH",
  "currency": "THB",
  "shopType": "Local",
  "lastSyncTime": "2026-06-29 16:30:00",
  "categories": [
    {
      "id": "600001",
      "name": "Home Supplies",
      "level": 1,
      "path": [{"id": "600001", "name": "Home Supplies"}],
      "children": [
        {
          "id": "851848",
          "name": "Home Organizers",
          "level": 2,
          "parentId": "600001",
          "path": [
            {"id": "600001", "name": "Home Supplies"},
            {"id": "851848", "name": "Home Organizers"}
          ],
          "children": []
        }
      ]
    }
  ]
}
```

## 输出示例（--flat）

```json
{
  "country": "TH",
  "currency": "THB",
  "shopType": "Local",
  "categories": [
    {"id": "600001", "name": "Home Supplies", "level": 1, "path": [{"id": "600001", "name": "Home Supplies"}]},
    {"id": "851848", "name": "Home Organizers", "level": 2, "parentId": "600001", "path": [...]}
  ]
}
```

## 已知限制

- **不返回 `lastSyncTime` 之外的其他同步元信息**。
- **不返回 `localName`**：每个 region 只返回一套本地化 `name`。
- **不支持 `--lang` 切换**：类目名按 region 一套返回，无法切换语言。
- **`currency` 由 CLI 内置静态映射**：未覆盖的国家返回空串，不影响 `categories` 数据本身。
- **国家码合法性**：CLI 只校验是否 2 字母；如果该 region 尚无类目数据，返回 `categories: []`。

## 常见工作流

### 反查类目 ID 的名称

`creator capability --handle <handle>` 输出的 `gmvByChannel` 是 `{categoryId: {name, gmv}}`，其中 `gmv` 是 0 到 1 的占比，CLI 已自动把 categoryId 翻译成类目名。如果想看完整类目层级或兄弟类目：

```bash
huayoungtk-cli product-category list --country TH --shop-type Local --parent-id 600001
```

### 把商品词归一化到类目

媒体端首页分析提取出关键词后，按名称模糊搜索该市场的标准类目：

```bash
huayoungtk-cli product-category list --country TH --shop-type Local -q Kitchen
```

### 查看一个市场的一级类目全貌

```bash
huayoungtk-cli product-category list --country TH --shop-type Local --level 1
```

## 与其他命令的衔接

| 命令 | 类目相关字段 | 说明 |
|---|---|---|
| `product list` / `product get` | `categories` | `{id: name}` map，自动富化 |
| `sample-request list-to-review` | `productCategories` | `{id: name}` map，自动富化 |
| `creator capability` | `gmvByChannel` | `{id: {name, gmv}}` map，自动富化 |
| `creator get` / `target-plan creators` | `categories` | 原始字符串（逗号分隔 ID），未富化 |

所有命令共用同一套 TikTok Shop 类目 ID。

## 注意事项

- `product-category list` 是只读查询，可以直接执行。
- 如果某 region 一次都没同步过，会返回 `categories: []`，可以换其他 region 试（如 MY/VN/PH）。
- 类目数据按 region 维护，跨 region 不能复用——同一个 `id` 在不同 region 可能含义不同。
