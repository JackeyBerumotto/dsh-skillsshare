# 手机管理参考

## 标识与前置条件

- `mobileId` 是平台手机记录 ID；所有后续命令都使用它。
- `code` 是手机自身标识，`deviceId` 是所属花漾客户端或流程执行器 ID，不要与 `mobileId` 混用。
- 先用 `mobile list` 确认用户有权限访问目标手机；操作类命令要求手机状态为 `ONLINE`。
- 页面源码、截图或导航等远程命令失败时，应提示用户：对应的客户端版本可能过旧、不支持手机远程调用，请升级客户端后重试。

## 查询

```bash
huayoungtk-cli mobile list
huayoungtk-cli mobile list --online
huayoungtk-cli mobile list --device-id <device-id>
huayoungtk-cli mobile list --query <keyword>
huayoungtk-cli mobile list --describe
huayoungtk-cli mobile get --mobile-id <mobile-id>
huayoungtk-cli mobile get --describe
```

## 当前界面源码

```bash
huayoungtk-cli mobile page-source --mobile-id <mobile-id> --output <source.xml>
huayoungtk-cli mobile page-source --describe
```

- 内容直接写入指定文件，命令结果只返回 `mobileId`、绝对路径 `path` 和字节数 `size`。
- 只有包含单个根元素、且根元素外没有非空文本的合法 XML 才会写入文件。
- 读取 iPhone 当前页面内容失败时，会自动重试一次；返回内容仍不是合法 XML 时报错且不写文件。
- 文件已存在时默认报错；只有用户明确同意覆盖后才使用 `--force`。

## 截图

```bash
huayoungtk-cli mobile screenshot --mobile-id <mobile-id> --output <image-file>
huayoungtk-cli mobile screenshot --describe
```

- 图片直接写入指定文件，命令结果返回 `mobileId`、绝对路径 `path`、实际图片 `format` 和字节数 `size`。
- 实际格式可能是 `png`、`jpeg` 或 `unknown`，不要仅根据文件扩展名判断。
- 文件已存在时默认报错；只有用户明确同意覆盖后才使用 `--force`。

## 打开 TikTok 达人首页

```bash
huayoungtk-cli mobile list --online
huayoungtk-cli mobile open-creator --mobile-id <mobile-id> --handle <creator-handle>
huayoungtk-cli mobile open-creator --describe
```

- 用户未明确指定手机时，先执行 `mobile list --online`，把可用手机展示给用户并让用户明确选择；即使只有一台可用手机，也应让用户确认。
- 用户已经明确指定 `mobileId` 或明确指定了唯一可识别的手机时，才可直接执行 `open-creator`。
- handle 可以带或不带 `@`；CLI 会规范化后返回。
- 跳转到达人首页通常需要 5-10 秒；执行后应等待命令完成，不要立即重复下发。
- 支持 Android 和 iPhone。
- `opened: true` 只表示客户端成功接收并执行打开指令，不代表 CLI 已验证最终页面确实是该达人首页。

## 打开 TikTok 视频

```bash
huayoungtk-cli mobile list --online
huayoungtk-cli mobile open-video --mobile-id <mobile-id> --aweme-id <aweme-id>
huayoungtk-cli mobile open-video --describe
```

- 用户未明确指定手机时，先执行 `mobile list --online`，把可用手机展示给用户并让用户明确选择；即使只有一台可用手机，也应让用户确认。
- 用户已经明确指定 `mobileId` 或明确指定了唯一可识别的手机时，才可直接执行 `open-video`。
- `awemeId` 是 TikTok 视频 ID。
- 跳转到视频通常需要 5-10 秒；执行后应等待命令完成，不要立即重复下发。
- 支持 Android 和 iPhone。
- `opened: true` 只表示客户端成功接收并执行打开指令，不代表 CLI 已验证最终页面确实是该视频。
