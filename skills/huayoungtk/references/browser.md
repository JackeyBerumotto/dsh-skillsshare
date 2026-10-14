# 店铺浏览器远程控制参考

## 设备选择与边界

- `browser` 命令控制的是花漾客户端中的店铺浏览器，不是手机，也不是浏览器插件实例。
- 所有 `browser` 命令都必须传 `--device-id`。这里不适用“插件店铺可省略 `--device-id`”的店铺 RPA 规则。
- 用户未明确指定设备时，先执行 `device list --shop-id <shop-id> --online`，只展示 `App` 和 `TeamRpaExecutor` 类型的设备，让用户明确选择。即使只有一台，也必须让用户确认。
- 未指定设备时，先列出在线的 `App` 和 `TeamRpaExecutor` 设备并让用户选择；`Extension` 类型的插件实例不适用于 `browser` 命令。
- CLI 会校验设备在线、类型正确且对目标店铺可用，不符合条件时不会发送远程命令。
- `browser` 命令失败时，目标花漾客户端版本较低可能是原因之一，可建议用户升级客户端后重试；失败原因不一定是版本问题。

## 打开 TikTok 达人首页

```bash
huayoungtk-cli device list --shop-id <shop-id> --online
huayoungtk-cli browser open-creator --device-id <device-id> --shop-id <shop-id> --handle <creator-handle>
huayoungtk-cli browser open-creator --device-id <device-id> --shop-code <shop-code> --handle <creator-handle>
huayoungtk-cli browser open-creator --describe
```

- `--shop-id` 与 `--shop-code` 二选一。
- handle 可以带或不带 `@`。
- 命令会启动或复用该店铺的浏览器，并在当前页面打开达人首页。
- 首次启动店铺浏览器可能需要几分钟；等待命令完成，不要重复下发。
- `opened: true` 表示客户端成功执行打开操作，不表示 CLI 已通过页面内容再次核验达人身份。

## 当前页面截图

```bash
huayoungtk-cli browser screenshot --device-id <device-id> --shop-id <shop-id> --output <image-file>
huayoungtk-cli browser screenshot --device-id <device-id> --shop-code <shop-code> --output <image-file>
huayoungtk-cli browser screenshot --describe
```

- 只截取该店铺浏览器当前激活的页面，不遍历其他标签页。
- 截图不会自动启动浏览器；应先用 `browser open-creator` 或由用户在该设备上打开目标店铺浏览器。
- 图片以 PNG 写入文件，结果返回 `deviceId`、`shopId`、绝对路径 `path`、`format` 和字节数 `size`。
- 文件已存在时默认报错；只有用户明确同意覆盖后才使用 `--force`。
