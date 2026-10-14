# 浏览器自动化

本文档收录分身浏览器的页面管理、快照、元素交互、截图、等待、网络请求与控制台诊断。执行浏览器任务时按需读取相关章节。

## 目录

- [控制方式选择](#浏览器控制browser)
- [页面管理](#页面管理)
- [页面快照](#页面快照)
- [元素交互](#元素交互)
- [截图与脚本](#截图)
- [等待与对话框](#等待文本或元素状态)
- [网络与控制台诊断](#网络请求)

## 浏览器控制（Browser）

分身浏览器打开后，常规页面自动化优先使用 `CLI browser` 子命令。CLI 提供结构化页面快照、基于最新快照的 uid 定位、过期文档检查和敏感值保护，适合导航、点击、填写、等待、截图等常见操作。

### 推荐方式：CLI browser 子命令

huayoung-cli 内置了一组 browser 子命令，通过花漾客户端代理操作浏览器。优先使用这些高层命令完成常规页面操作；具体参数使用对应命令的 `--help` 查询。

> **关于 uid**：`browser snapshot` 返回无障碍树与 DOM 元数据混合快照。输出行大致为 `<depth>|[uid=<documentId>_<backendNodeId>] [tag=<tag>] <role> "<name>" [属性...]`，其中方括号表示字段可选，并不是实际输出字符。普通快照只有可操作节点包含 `uid=`；`--verbose` 还会为普通但可寻址的 DOM 节点提供 uid，供元素截图、脚本参数、hover 或拖拽目标等操作使用。

> 主页面快照会尽力合并同一浏览器 Target 内子 frame 的无障碍树，同源 iframe 通常可直接 snapshot/locate 并使用返回 uid。跨进程或受限 frame 若未出现，改用 `browser info` 返回的 CDP 端点做底层 frame 调试，并把它视为降级路径。
>
> uid 在同一页面文档内保持稳定，获取新快照不会让仍存在的元素 uid 失效。页面导航、刷新或文档切换后必须重新执行 `browser snapshot`；元素被前端重建时也可能产生新 uid。其他标签页生成快照不会影响当前页面。遇到 `STALE_UID`、`STALE_DOCUMENT`、`ELEMENT_DETACHED` 等错误时，应重新获取快照，不要重试旧 uid。

所有浏览器命令都需要 `--avatar-id` 参数。大部分支持 `--page-id`（默认 0 表示当前活动页面）。可对任意 browser 子命令执行 `--help` 查看详细参数。

### 特殊场景：CDP 直连

`avatar open` 返回的 `wsEndpoint`（如 `ws://127.0.0.1:PORT/devtools/browser/...`）是 CDP WebSocket 地址。通过 CDP 协议直连此地址，即可获得完整的浏览器控制能力，包括：

- 页面导航、快照、截图
- 元素点击、填充、拖拽等交互
- 网络请求拦截和监控
- JavaScript 执行
- 文件上传、对话框处理

CDP 直连适合 CLI 尚未覆盖的底层场景，例如自定义 CDP 域、复杂网络拦截或浏览器协议调试。使用 CDP 时，Agent 需要自行处理目标页面、frame、文档切换、节点过期和敏感数据，不能复用 CLI 快照中的 uid。

> **`wsEndpoint` 为空时**：手动从客户端界面打开的分身默认不会提供 CDP WebSocket；对已运行分身再次执行 `avatar open` 只能带到前台，不能补开端点。需要 CDP 时，先说明重启会中断现有标签页和未保存状态并取得明确确认，然后执行 `avatar close`，再使用 `avatar open` 重新打开。`browser info` 只能读取当前端点，不能为手动启动的现有进程补开端点。重开后仍为空则停止重试并报告异常。

> **典型流程**：
> 1. `huayoung-cli avatar open` 获取 `wsEndpoint`
> 2. 通过 CDP 协议（WebSocket）连接 `wsEndpoint`
> 3. 发送 CDP 命令操作浏览器

### 浏览器信息

```bash
huayoung-cli browser info --avatar-id $AVATAR_ID
```


### 页面管理

#### 列出所有标签页

```bash
huayoung-cli browser pages --avatar-id $AVATAR_ID
```

页面条目包含 `active` 与 `state`：`active=true` 表示它是 `--page-id 0` 使用的默认页面；`initializing` 表示已分配稳定 page ID、页面对象仍在初始化，`navigating` 表示导航尚未稳定，`ready` 表示可操作，`failed` 表示导航失败。导航中使用 `lastCommittedUrl` 判断已提交页面、使用 `pendingUrl` 判断目标地址；`documentId` 用于识别文档代际。

#### 新建标签页

```bash
# 新建并导航
huayoung-cli browser new-page --avatar-id $AVATAR_ID --url "https://example.com"

# 在后台打开
huayoung-cli browser new-page --avatar-id $AVATAR_ID --url "https://example.com" --background

# 慢页面可单独设置导航超时；即使超时也会返回已创建的 pageId
huayoung-cli browser new-page --avatar-id $AVATAR_ID --url "https://openai.com" --navigation-timeout 20000
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--url` | string | 否 | 打开后要导航的 URL |
| `--background` | bool | 否 | 在后台打开页面 |
| `--navigation-timeout` | int | 否 | 导航阶段超时，默认 15000ms；不影响已创建 pageId 的返回 |

new-page 将建页和导航分开报告。`navigation.state=completed` 时顶层 `state` 与 `pages` 中对应页面应已是 `ready`；`navigation.state=timeout` 时页面保留为 `navigating`，不要重复建页，应使用返回的 `pageId` 查询 `browser pages`，等待页面进入 `ready` 或 `failed`。

#### 激活标签页

```bash
huayoung-cli browser select-page --avatar-id $AVATAR_ID --page-id 2
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 是 | 要激活的页面 ID |

将指定标签页置于前台，并把它设为后续 `--page-id 0` 使用的默认页面。响应返回 `activePageId`、URL 和标题；可用 `--describe` 查看字段。

#### 关闭标签页

```bash
huayoung-cli browser close-page --avatar-id $AVATAR_ID --page-id 2
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 是 | 要关闭的页面 ID |

#### 页面导航

```bash
# 导航到 URL
huayoung-cli browser navigate --avatar-id $AVATAR_ID --url "https://example.com"

# 后退
huayoung-cli browser navigate --avatar-id $AVATAR_ID --type back

# 前进
huayoung-cli browser navigate --avatar-id $AVATAR_ID --type forward

# 刷新
huayoung-cli browser navigate --avatar-id $AVATAR_ID --type reload

# 指定超时
huayoung-cli browser navigate --avatar-id $AVATAR_ID --url "https://example.com" --timeout 10000
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--type` | string | 否 | 导航类型：url（默认）、back、forward、reload |
| `--url` | string | 否 | 目标 URL（type=url 时使用） |
| `--timeout` | int | 否 | 超时时间（毫秒，0 表示使用默认值） |


### 页面快照

```bash
# 获取页面无障碍树与 DOM 元数据混合快照
huayoung-cli browser snapshot --avatar-id $AVATAR_ID

# 包含更多无障碍节点和属性（仍受输出上限约束）
huayoung-cli browser snapshot --avatar-id $AVATAR_ID --verbose

# 仅获取某个元素的子树
huayoung-cli browser snapshot --avatar-id $AVATAR_ID --root-uid $UID

# 与某个历史快照比较，只返回元素增量
huayoung-cli browser snapshot --avatar-id $AVATAR_ID --since-snapshot-id $SNAPSHOT_ID

# 使用响应中的 nextCursor 继续读取同一个历史快照
huayoung-cli browser snapshot --avatar-id $AVATAR_ID --cursor $NEXT_CURSOR
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--verbose` | bool | 否 | 包含更多无障碍节点和属性，仍受快照输出上限约束 |
| `--root-uid` | string | 否 | 仅返回指定 uid 的元素子树 |
| `--since-snapshot-id` | string | 否 | 返回相对于指定历史快照的 added/changed/removed 增量 |
| `--cursor` | string | 否 | 继续读取上一页被截断的同一历史快照 |
| `--max-nodes` | int | 否 | 最大输出节点数，默认 1500，范围 1-5000 |

`--root-uid`、`--since-snapshot-id` 与 `--cursor` 三者不能同时使用。每个页面最多保留最近 5 个快照；cursor 超过保留范围或页面文档切换后会失效。


快照示例：

```
0|RootWebArea "百度一下"
1|uid=17_2 tag=input searchbox "搜索" name="wd" placeholder="请输入关键词" value=""
1|uid=17_3 tag=button button "百度一下" data-testid="search-submit"
1|uid=17_4 tag=a link "新闻" href="https://news.baidu.com/"
```

示例中的 uid 和属性仅用于说明格式，其中 `17` 是文档 ID，后半部分是 backend node ID。将快照中可操作节点的实际 `uid` 保存为 `$UID`，再用于 click、fill 等命令；没有 uid 的描述性节点不能用于交互。

普通快照每行使用十进制 `<depth>|` 前缀表示树层级，根节点从 `0|` 开始，不使用重复 Tab 缩进。后续行的 depth 更大表示进入子树，depth 相同表示同级，depth 变小表示返回对应层级。快照按 UTF-8 字节计算默认 50 KiB 输出预算。服务端会压缩语义文本中的连续空白，折叠无语义的 generic div/span，并移除与父节点文本重复的 InlineTextBox；`--verbose` 保留完整节点。普通快照按语义优先级排列同级子树，焦点、弹窗、错误和可操作元素优先于普通静态文本，因此不要把输出中的同级顺序当作严格 DOM 顺序。响应中的 `snapshotStats` 包含 `byteSize`、节点数、压缩/摘要/遗漏节点数、语义排序和截断状态。

大型 table、grid、list、listbox、menu 或 tree 默认只返回前 20 个条目并在节点行标注总数、已显示数和遗漏数；表格还会尽量给出列名。响应中的 `continuations` 提供两类续读入口：`reason=collection` 时使用其中的 `rootUid` 调用 `--root-uid` 展开该区域；`reason=page` 时直接把其中的 `cursor` 传给 `--cursor` 读取下一页。

#### 快照使用规范

1. 默认先使用普通快照；只有信息不足时才使用 `--verbose`。
2. 始终以目标页面最近一次生成的快照作为页面状态依据。同一文档内仍存在的元素 uid 可以跨快照复用；导航、刷新或元素被重建后应重新读取 uid。
3. 同名元素应结合树层级、`tag`、`href`、`data-testid`、`name` 等稳定属性判断，不要只按可访问名称猜测。
4. 操作后使用 `wait-for`、`pages`、新快照或截图做最小必要验证。
5. 如果 `snapshotStats.truncated=true` 或末尾出现 `[snapshot truncated ...]`，优先使用响应中的 `nextCursor` 读取下一页；如果 `continuations` 包含 `reason=collection`，使用对应 `rootUid` 获取局部完整子树。没有续读入口时再使用页面筛选或增量快照缩小范围。不要反复请求新的完整快照。
6. 快照可能包含页面文本和普通输入值，不要无必要地完整复制到日志或对话中。密码输入值会被自动脱敏，但其他敏感页面内容仍需谨慎处理。

#### 操作副作用

点击、坐标点击、hover、fill、type、press-key、drag、fill-form、upload-file 和 navigate 的成功响应包含 `effects`，可能包括 URL 变化、新建/关闭标签页、对话框、下载和失败网络请求。新页面通过浏览器 Target 事件和动作前后页面列表共同确认；`pageEffects.settled` 表示登记任务已收敛。若 `newPagePending=true` 或 `pageEffects.settled=false`，先执行 `browser pages` 获取最终页面 ID，不要把空的 `newPageIds` 解释为确定没有新页面。操作后应先检查 effects，再决定是否获取新快照。

### 元素交互

#### 语义定位元素

```bash
# 按角色和可访问名称定位
huayoung-cli browser locate --avatar-id $AVATAR_ID --role button --name "继续"

# 按表单语义或测试属性定位
huayoung-cli browser locate --avatar-id $AVATAR_ID --label "邮箱"
huayoung-cli browser locate --avatar-id $AVATAR_ID --placeholder "Email"
huayoung-cli browser locate --avatar-id $AVATAR_ID --test-id "submit-button"

# 组合条件、精确匹配或包含隐藏元素
huayoung-cli browser locate --avatar-id $AVATAR_ID --role button --name "提交" --exact
huayoung-cli browser locate --avatar-id $AVATAR_ID --css "form button.primary" --visible=false
```

`locate` 支持 `--role`、`--name`、`--text`、`--label`、`--placeholder`、`--test-id`、`--css`、`--exact`、`--visible` 和 `--max-results`。纯静态文本会映射到最近的可寻址祖先，因而返回的候选 role 可能与文本节点本身不同。无效 CSS 返回 `INVALID_LOCATOR`，不要把它当作 0 个结果。它返回 `returnedCount`、`totalCount`、`truncated`、`matches` 和 `unique`；`truncated=true` 时增加条件缩小范围。超长名称会截断并标记 `nameTruncated=true`。URL 与敏感输入值默认脱敏，`redactedFields` 列出受保护字段。

#### 点击元素

```bash
# 单击
huayoung-cli browser click --avatar-id $AVATAR_ID --uid $UID

# 双击
huayoung-cli browser click --avatar-id $AVATAR_ID --uid $UID --dblclick

# 操作成功后同时返回新快照
huayoung-cli browser click --avatar-id $AVATAR_ID --uid $UID --include-snapshot

# 独立设置各阶段超时
huayoung-cli browser click --avatar-id $AVATAR_ID --uid $UID \
  --dispatch-timeout 3000 \
  --navigation-timeout 10000 \
  --dom-timeout 5000 \
  --effect-timeout 1000 \
  --snapshot-timeout 5000
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--uid` | string | 是 | 元素 uid（从 snapshot 获取） |
| `--dblclick` | bool | 否 | 双击 |
| `--include-snapshot` | bool | 否 | 操作成功后返回新的页面快照 |
| `--dispatch-timeout` | int | 否 | 点击派发超时，默认 3000ms |
| `--navigation-timeout` | int | 否 | 已检测到导航后的等待超时，默认 10000ms |
| `--dom-timeout` | int | 否 | DOM 稳定等待超时，默认 5000ms |
| `--effect-timeout` | int | 否 | 新页面等副作用收集窗口，默认 1000ms |
| `--snapshot-timeout` | int | 否 | `--include-snapshot` 的快照生成超时，默认 5000ms |

点击响应中的 `action` 通过顶层 `stage`、`state` 和 `elapsedMs` 返回整体结果，并分别记录 `dispatch`、`navigation`、`dom`、`effects` 和 `snapshot` 的状态与耗时。`ACTION_TIMEOUT` 会同时指出失败阶段；`dispatch` 超时时动作状态为不确定，不能自动重试，应先检查页面状态。导航或 DOM 稳定超时不等同于点击未发生，应结合 `effects` 和页面状态判断。

对后台页面点击时，客户端会在派发前临时激活目标页并在完成后恢复原活动页，避免后台节流导致动作在 timeout 后延迟执行；`effects.targetPageActivated` 和 `effects.originalPageRestored` 可用于审计该行为。

#### 坐标点击

```bash
# 单击坐标
huayoung-cli browser click-at --avatar-id $AVATAR_ID --x 100 --y 200

# 双击坐标
huayoung-cli browser click-at --avatar-id $AVATAR_ID --x 100 --y 200 --dblclick
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--x` | int | 是 | X 坐标 |
| `--y` | int | 是 | Y 坐标 |
| `--dblclick` | bool | 否 | 双击 |

#### 悬停

```bash
huayoung-cli browser hover --avatar-id $AVATAR_ID --uid $UID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--uid` | string | 是 | 元素 uid |
| `--include-snapshot` | bool | 否 | 操作成功后返回新的页面快照 |

成功响应中的 `hover.persisted=true` 表示服务端在 DOM/effects 收集结束后已重新落定鼠标，并验证目标仍匹配 `:hover`。该状态会保持到下一次会移动鼠标的操作；悬停菜单出现后应立即读取新快照或 locate 菜单项并点击。

#### 填充输入框

```bash
huayoung-cli browser fill --avatar-id $AVATAR_ID --uid $UID --value "$VALUE"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--uid` | string | 是 | 元素 uid |
| `--value` | string | 是 | 填充值 |
| `--include-snapshot` | bool | 否 | 操作成功后返回新的页面快照 |

> **fill vs type**：`fill` 会替换 input、textarea、contenteditable 的现有文本，并按 option value 选择 select 选项；`type` 在当前焦点元素中逐字追加文本。站点自定义输入组件仍可能自行格式化值，可使用 `--include-snapshot` 核对结果。

#### 输入文本

```bash
# 输入文本
huayoung-cli browser type --avatar-id $AVATAR_ID --text "hello"

# 输入后按 Enter
huayoung-cli browser type --avatar-id $AVATAR_ID --text "search query" --submit-key Enter
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--text` | string | 是 | 输入文本 |
| `--submit-key` | string | 否 | 输入后按下的键（Enter、Tab、Escape） |

#### 按键

```bash
# 单键
huayoung-cli browser press-key --avatar-id $AVATAR_ID --key Enter

# 组合键
huayoung-cli browser press-key --avatar-id $AVATAR_ID --key Control+A
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--key` | string | 是 | 按键或组合键（如 Enter、Control+A、Control+Shift+R） |

修饰键：Control、Shift、Alt、Meta。组合键会把修饰键与主键分别派发，并在失败时释放已按下的修饰键。`Control+A` 使用 Chromium `SelectAll` 编辑命令保证输入框、文本域和可编辑区域可靠全选；在 macOS 上同时按跨平台语义转换为 `Meta+A`，也可显式使用 `Meta+A`。成功响应中的 `key.requested`、`key.effective` 和全选时的 `key.command=SelectAll` 可用于确认实际派发语义。

#### 拖拽

```bash
huayoung-cli browser drag --avatar-id $AVATAR_ID --from-uid $FROM_UID --to-uid $TO_UID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--from-uid` | string | 是 | 源元素 uid |
| `--to-uid` | string | 是 | 目标元素 uid |
| `--include-snapshot` | bool | 否 | 操作成功后返回新的页面快照 |

drag 使用共享 `DataTransfer` 派发 HTML5 drag/drop，并保证命令结束时释放鼠标。响应中的 `drag.accepted=true` 表示目标通过 dragover/drop 接受了拖拽；无法确认时返回 `DRAG_NOT_ACCEPTED`，不要当作成功继续。

#### 批量填充表单

```bash
huayoung-cli browser fill-form --avatar-id $AVATAR_ID --elements '[{"uid":"$EMAIL_UID","value":"$EMAIL"},{"uid":"$PASSWORD_UID","value":"$PASSWORD"}]'

# Windows 或复杂 JSON 推荐从文件/stdin 读取
huayoung-cli browser fill-form --avatar-id $AVATAR_ID --elements-file ./elements.json
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--elements` | string | 是 | JSON 数组，如 `[{"uid":"$UID","value":"$VALUE"}]` |
| `--elements-file` | string | 否 | 从 JSON 文件读取；`-` 表示 stdin，与 `--elements` 二选一 |
| `--include-snapshot` | bool | 否 | 全部填写成功后返回新的页面快照 |

批量填写部分失败返回 `FILL_FORM_PARTIAL_FAILURE`，details 包含 `completed`、`failedIndex`、`failedUid`、`causeCode` 和已发生的 `effects`。前面已经完成的字段不会自动回滚。

#### 上传文件

```bash
huayoung-cli browser upload-file --avatar-id $AVATAR_ID --uid $FILE_INPUT_UID --file-path "$FILE_PATH"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--uid` | string | 是 | 文件输入元素 uid |
| `--file-path` | string | 是 | 本地文件路径 |
| `--include-snapshot` | bool | 否 | 操作成功后返回新的页面快照 |

### 截图

```bash
# 截取当前视口（输出 base64）
huayoung-cli browser screenshot --avatar-id $AVATAR_ID

# 保存到文件
huayoung-cli browser screenshot --avatar-id $AVATAR_ID --file-path ./screenshot.png

# 截取完整页面
huayoung-cli browser screenshot --avatar-id $AVATAR_ID --full-page --file-path ./full.png

# 截取特定元素
huayoung-cli browser screenshot --avatar-id $AVATAR_ID --uid $UID

# 设置截图阶段超时
huayoung-cli browser screenshot --avatar-id $AVATAR_ID --uid $UID --timeout 8000

# 指定格式
huayoung-cli browser screenshot --avatar-id $AVATAR_ID --format jpeg --file-path ./shot.jpg
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--uid` | string | 否 | 元素 uid（截取特定元素） |
| `--full-page` | bool | 否 | 截取完整页面 |
| `--format` | string | 否 | 图片格式：png（默认）、jpeg、webp |
| `--file-path` | string | 否 | 保存到文件（不指定则输出 base64） |
| `--timeout` | int | 否 | 截图 resolve/scroll/bounds/capture 阶段总超时，默认 8000ms |

元素无有效边界时快速返回 `ELEMENT_NOT_SCREENSHOTTABLE`；截图阶段超时返回 `SCREENSHOT_TIMEOUT`，details 包含失败阶段和耗时。


### 执行 JavaScript

```bash
# 简单表达式
huayoung-cli browser evaluate --avatar-id $AVATAR_ID --function "document.title"

# 带参数的函数
huayoung-cli browser evaluate --avatar-id $AVATAR_ID --function "(text) => document.title = text" --args "New Title"

# 把快照 uid 对应的 DOM Element 作为参数（普通参数排在元素参数之前）
huayoung-cli browser evaluate --avatar-id $AVATAR_ID --function "(prefix, element) => prefix + element.textContent" --args "Text: " --element-uids $UID

# 异步函数
huayoung-cli browser evaluate --avatar-id $AVATAR_ID --function "async () => { const res = await fetch('/api/data'); return res.json() }"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--function` | string | 是 | JavaScript 函数体 |
| `--args` | stringSlice | 否 | 普通字符串参数列表，不会按 uid 解析 |
| `--element-uids` | stringSlice | 否 | 作为 DOM Element 传入的 uid 列表，排在普通参数之后 |


### 调整窗口大小

```bash
huayoung-cli browser resize --avatar-id $AVATAR_ID --width 1280 --height 800
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--width` | int | 是 | 宽度 |
| `--height` | int | 是 | 高度 |

### 等待文本或元素状态

```bash
# 等待文本出现（默认 30 秒超时）
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --text "登录成功"

# 等待多个文本之一（任一匹配即返回）
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --text "登录成功" --text "登录失败"

# 自定义超时
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --text "登录成功" --timeout 60000

# 等待元素状态
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --uid $UID --state visible
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --uid $UID --state hidden
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --uid $UID --state enabled
huayoung-cli browser wait-for --avatar-id $AVATAR_ID --uid $UID --state detached
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--text` | stringSlice | 否 | 等待出现的文本列表（支持多个，任一匹配即返回） |
| `--uid` | string | 否 | 等待状态变化的元素 uid，必须和 `--state` 一起使用 |
| `--state` | string | 否 | visible、hidden、enabled 或 detached |
| `--timeout` | int | 否 | 超时时间（毫秒），默认 30000 |

`--text` 与 `--uid/--state` 必须二选一。

文本模式成功时返回 `matchedText` 和 `elapsedMs`。文本等待超时返回 `WAIT_TIMEOUT`；参数模式冲突返回 `INVALID_WAIT_MODE`，无效状态返回 `INVALID_WAIT_STATE`。未指定的 `uid`、`state` 或 `text` 不会作为空字段发送。

元素等待超时同样返回 `WAIT_TIMEOUT`，并在错误详情中包含 page、document、uid、state 和耗时。`detached` 表示原 uid 已不再属于当前可操作 DOM：页面 document 已切换、节点已不在最新快照中、节点实时 `isConnected=false`，或解析时检测到 stale/detached 都会成功；成功响应的 `reason` 会区分 `document_changed`、`not_in_snapshot` 和 `dom_detached`。


### 处理浏览器对话框

```bash
# 接受对话框
huayoung-cli browser dialog --avatar-id $AVATAR_ID --action accept

# 拒绝对话框
huayoung-cli browser dialog --avatar-id $AVATAR_ID --action dismiss

# 接受 prompt 并输入文本
huayoung-cli browser dialog --avatar-id $AVATAR_ID --action accept --prompt-text "my input"
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--action` | string | 是 | 对话框操作：accept 或 dismiss |
| `--prompt-text` | string | 否 | prompt 对话框的输入文本 |

### 识别验证码

```bash
huayoung-cli browser captcha --avatar-id $AVATAR_ID
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |

### 网络请求

#### 列出网络请求

```bash
# 列出所有请求
huayoung-cli browser network list --avatar-id $AVATAR_ID

# 按资源类型过滤
huayoung-cli browser network list --avatar-id $AVATAR_ID --resource-types "xhr,fetch"

# 按 URL 关键词过滤（模糊匹配）
huayoung-cli browser network list --avatar-id $AVATAR_ID --url "api.example.com"

# 按 HTTP 方法过滤
huayoung-cli browser network list --avatar-id $AVATAR_ID --method POST

# 按状态码过滤
huayoung-cli browser network list --avatar-id $AVATAR_ID --status-code 200

# 组合过滤
huayoung-cli browser network list --avatar-id $AVATAR_ID --method POST --status-code 200 --url "api"

# 分页
huayoung-cli browser network list --avatar-id $AVATAR_ID --page-idx 0 --page-size 10
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--resource-types` | string | 否 | 资源类型过滤（逗号分隔，如 xhr、fetch、document、script 等） |
| `--url` | string | 否 | URL 关键词过滤（模糊匹配） |
| `--method` | string | 否 | HTTP 方法过滤（GET/POST/PUT/DELETE 等） |
| `--status-code` | int | 否 | HTTP 状态码过滤（如 200、404） |
| `--page-idx` | int | 否 | 页码（0 开始） |
| `--page-size` | int | 否 | 每页数量，默认 20 |


#### 获取网络请求详情

```bash
# 获取元数据详情（默认不返回请求体或响应体）
huayoung-cli browser network get --avatar-id $AVATAR_ID --reqid 5

# 显式读取经过脱敏的请求体或响应体
huayoung-cli browser network get --avatar-id $AVATAR_ID --reqid 5 --include-request-body
huayoung-cli browser network get --avatar-id $AVATAR_ID --reqid 5 --include-response-body

# 增大显式响应体限制（默认 50000 字节，超出会截断）
huayoung-cli browser network get --avatar-id $AVATAR_ID --reqid 5 --include-response-body --body-limit 200000
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--reqid` | int | 是 | 请求 ID（从 `network list` 获取） |
| `--include-request-body` | bool | 否 | 返回经过默认脱敏的请求体，默认 false |
| `--include-response-body` | bool | 否 | 返回经过默认脱敏的响应体，默认 false |
| `--body-limit` | int | 否 | 显式响应体最大字节数，默认 50000（超出截断，返回 bodyTruncated=true） |

`network list` 永不返回请求正文，只返回 `hasPostData`。URL 查询参数采用默认脱敏和安全参数 allowlist；Authorization、Cookie、Set-Cookie、Token、密码、OTP、Session、API Key，以及 device/client/user/trace 等标识 ID 默认脱敏。snapshot 与 locate 的 URL 属性复用相同策略；multipart 和二进制正文不会内联暴露。

浏览器动作使用 POST 且默认不做传输层自动重试。连接超时不代表动作一定未执行；不要直接重复 click、fill、type、press-key 或表单提交，应先用 `pages`、快照或目标状态检查动作是否已经生效。


### 控制台消息

#### 列出控制台消息

```bash
# 列出所有消息
huayoung-cli browser console list --avatar-id $AVATAR_ID

# 按类型过滤
huayoung-cli browser console list --avatar-id $AVATAR_ID --types "error,warn"

# 分页
huayoung-cli browser console list --avatar-id $AVATAR_ID --page-idx 0 --page-size 10
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--types` | string | 否 | 消息类型过滤（逗号分隔：log、warn、error、info、debug 等） |
| `--page-idx` | int | 否 | 页码（0 开始） |
| `--page-size` | int | 否 | 每页数量，默认 20 |


#### 获取控制台消息详情

```bash
huayoung-cli browser console get --avatar-id $AVATAR_ID --msgid 3
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--avatar-id` | int | 是 | 分身 ID |
| `--page-id` | int | 否 | 页面 ID，0 表示默认页面 |
| `--msgid` | int | 是 | 消息 ID（从 `console list` 获取） |


---
