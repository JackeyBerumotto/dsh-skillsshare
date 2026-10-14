# 通用参考

## 安装与升级

安装或升级 CLI：

```bash
npm install -g @huayoung/huayoungtk-cli --allow-scripts=@huayoung/huayoungtk-cli
huayoungtk-cli skills install
huayoungtk-cli skills list
huayoungtk-cli skills uninstall
```

查看当前版本：

```bash
huayoungtk-cli --version
```

CLI 最多每 24 小时自动检查一次 npm registry：

- 发现新版本但仍可继续使用时，命令成功后可能在 stderr 输出"发现新版本"提示，stdout 的 JSON 不受影响。主动告知用户当前版本与最新版本，并建议运行上述两条命令升级。
- 当前版本过低时，业务命令会返回 `CLI_VERSION_TOO_OLD`，且不会执行。明确要求用户依次运行上述两条命令，升级后再重试。
- `--help`、`--version` 和 `skills` 命令不受强制升级限制。

## 认证（多用户身份）

CLI 支持本地保存多组（团队 × 用户）凭证：一个用户身份就是一组账号，命令执行时按"当前用户身份"调 API。用户身份名取自授权 Key 的授权名称（服务端权威），CLI 不生成、不可改。

### 登录

```bash
huayoungtk-cli auth login --token <access-key>                 # 用户身份名取自授权 Key 的授权名称（服务端权威）
huayoungtk-cli auth login --token <access-key> --endpoint <url> # 自定义 API 地址
```

- 同账号（teamId + userId 相同）重新 login → 覆盖授权 Key 与用户身份名（跟随服务端），用户身份数量不变
- 不同账号 login → 新建用户身份，自动切到新用户身份；名字取自各自授权 Key

### 查看 / 切换用户身份

```bash
huayoungtk-cli auth status                       # 当前用户身份 + endpoint + 授权 Key 状态
huayoungtk-cli auth check                        # 验证授权 Key
huayoungtk-cli auth profile list                 # 列出所有用户身份，标记 current
huayoungtk-cli auth profile switch <name|index>  # 切换 current
huayoungtk-cli auth profile delete <name|index>  # 删指定用户身份（不能删 current）
huayoungtk-cli auth logout                       # 删 current 用户身份
```

`switch` 和 `delete` 都接受用户身份的 `name` 或 `index`（数字）作为定位符。用户身份名由授权 Key 决定，无法在 CLI 修改。

### 查看配置

```bash
huayoungtk-cli config show --json
```

```json
{
  "profiles": {
    "1": {
      "index": 1,
      "name": "团队A/用户A",
      "teamId": "...",
      "userId": "...",
      "accessKey": "abcd***wxyz",
      "endpoint": "https://api.szdamai.com"
    }
  },
  "current": "1"
}
```

`profiles` 列出所有用户身份，`current` 表示当前身份的 index。`accessKey` 始终脱敏，只显示首尾各 4 个字符；较短的授权 Key 显示为 `***`。

### 调用日志

每次 CLI 调用都会向 `~/.huayoungtk-cli/logs/huayoungtk-cli-YYYY-MM-DD.log` 追加纯文本日志。首行依次记录时间、耗时、当前用户身份、teamId、userId、成功/失败状态、退出码和完整命令参数；失败调用的错误信息单独写在下一行。授权 Key、密码等凭证参数的值会自动脱敏为 `<redacted>`。

日志按本地日期切分，最多保留最近 10 个按日日志文件。若设置了 `HUAYOUNGTK_CLI_CONFIG_DIR`，日志目录也随之改变为 `<config-dir>/logs/`。

需要定位日志文件并交给技术人员排错时，运行：

```bash
huayoungtk-cli logs
huayoungtk-cli logs --jq '.logs[0].path'  # 只取最新日志文件的绝对路径
```

输出包含日志目录和每个日志文件的日期、绝对路径、字节数及修改时间，并按日期从新到旧排列；命令只列文件，不读取或上传内容。向技术人员发送文件前先告知用户日志包含命令参数和错误信息，不要把整份日志直接粘贴到群聊。`logs` 不读写用户配置，在 OpenClaw 下无需 `--openclaw-user-id`。

CLI 配置或网络异常时可运行诊断：

```bash
huayoungtk-cli doctor
```

## 输出与过滤

- 默认输出为 JSON。
- 使用 `--jq` 过滤 JSON 字段或数组。
- 使用 `-o ndjson` 输出逐行 JSON。
- 使用 `--describe` 查看输出字段说明。
- 命令语法不确定时，使用 `--help`。
- 示例变量统一写成小写 kebab-case 尖括号占位符，例如 `<shop-id>`、`<shop-code>`、`<product-id>`、`<creator-handle>`。

## 店铺标识

凡是接受 `--shop-id` 的命令，都可用 `--shop-code` 替代，二者二选一：

- `--shop-id <shop-id>`：店铺 ID（数字）。
- `--shop-code <shop-code>`：TikTok 店铺代码。传入时 CLI 会先解析为 shop-id 再发请求。

`shop get` 还额外支持 `--shop-name <shop-name>`，与 `--shop-id`/`--shop-code` 三选一。
不知道 shop-id 或 shop-code 时，先用 `shop list` 查看。

## 分页

常见分页参数：

```bash
--page <page-number>
--page-size <page-size>
--page-token <page-token>
```

探索数据时建议从较小页数开始，例如 `--page-size 10`；用户需要更完整覆盖时再扩大范围。

## 日期处理

用户使用相对时间时，在答复中写清楚实际日期范围，并转换为命令支持的 `--from` / `--to` 绝对日期。`product-rating stat/daily-stat` 还支持 `--last-days` 作为替代。

## 安全策略

只读命令可以直接执行。以下会修改数据或触发 RPA 的命令必须先确认：

- 备注：`buyer note`、`video note`、`live note`、`product note`
- 标签：`creator tag`、`buyer tag`、`video tag`
- 状态：`creator status`
- 索样动作：`sample-request shelve`、`sample-request approve`、`sample-request reject`
- 合作单：`collaboration-order create`
- 店铺同步：`shop sync`
- 任务取消：`job cancel`

对于不可撤销动作，执行前必须复述目标 ID 和计划动作。

## 失败处理

- 找不到 CLI：检查 `PATH` 是否包含 npm 全局 bin 目录。
- 认证缺失或失效：向用户索要授权 Key。
- 缺少店铺 ID：先运行 `shop list` 或 `shop get`。多数命令支持 `--shop-id` 或 `--shop-code` 二选一。
- 插件分身店铺提示没有在线插件设备：提醒用户先打开该店铺的插件浏览器，再重试；此时省略 `--device-id`。
- `huayang` 店铺或 `both` 店铺选择客户端浏览器执行时，若提示必须传 `--device-id`：运行 `device list --shop-id <shop-id> --online`，只展示在线客户端设备，让用户选择后再带 `--device-id` 重试。
- 显式传入的 `--device-id` 被提示不在线、类型错误或对店铺不可用：重新运行 `device list --shop-id <shop-id> --online`，按当前执行方式只展示匹配的设备并让用户重新选择。
- 查询结果为空：说明当前筛选条件、分页和日期范围，并建议扩大筛选。
- 权限错误或服务端错误：先报告错误和下一步诊断命令，确认原因后再重试修改类命令。
