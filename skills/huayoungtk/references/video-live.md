# 视频和直播参考

这里用于独立查询带货视频和带货直播。如果任务围绕某个达人展开，优先使用 `creator videos` 和 `creator lives`。

## 带货视频

查询方式：`--id` 或 `--media-id`。

`monitored=true` 表示视频已被关注/监控，系统每日自动同步。

### 视频列表

```bash
huayoungtk-cli video list
huayoungtk-cli video list --tab-type latest3day --page-size 5
huayoungtk-cli video list --authorization-status authorized
huayoungtk-cli video list --tag <tag-name>
huayoungtk-cli video list --describe
```

video list / live list 支持用 `--shop-id`（或 `--shop-code`，二选一）按店铺过滤。

排序字段包括 `id`、`postTime`、`viewCnt`、`likeCnt`、`commentCnt`、`favoriteCnt`、`retweetCnt`、`orderCount`、`ordersPm`、`itemsSold`、`gmv`、`estCommission`、`createTime`、`lastSyncTime`、`duration`、`handle`，默认 `id:desc`。

`ordersPm` 为千播订单数（每千次播放的订单数 = 订单数×1000/播放数），不是百分比，值可超过 100。

### 视频详情

```bash
huayoungtk-cli video get --id 123456
huayoungtk-cli video get --media-id 7493991083946247855
huayoungtk-cli video get --describe
```

### 视频和音频下载地址

按数据库 ID 或 TikTok `mediaId` 获取视频、音频的临时下载地址。命令只返回地址，不会下载文件。地址可能过期，应在实际下载前即时获取。

```bash
huayoungtk-cli video download-url --id <video-id>
huayoungtk-cli video download-url --media-id <media-id>
huayoungtk-cli video download-url --media-id <media-id> --describe
```

返回的 `videoUrl` 必定是有效的 HTTP/HTTPS 地址，否则命令报错。`audioUrl` 依赖服务端和 ApiWorker 已部署音频解析支持；暂不可用时返回 `null`。

如果执行下载的本机位于中国大陆，直连 TikTok CDN 可能不稳定或超时。CLI 成功返回下载地址只表示地址获取成功，不代表本机一定能访问该地址；遇到超时时，应提示用户检查网络出口，或改在能够稳定访问 TikTok 的机器上下载。

拿到地址下载后，可以使用 `ffmpeg` 进行转码、裁剪、抽取音频或音视频合并等后续处理。

临时签名地址应尽快使用；如果地址已过期，重新运行 `video download-url` 获取。

### 视频备注和标签

修改备注或标签前必须确认。

```bash
huayoungtk-cli video note --media-id <media-id> --remark "爆款"
huayoungtk-cli video note --media-id <media-id> --remark ""
huayoungtk-cli video tag --media-id <media-id> --tag "爆款视频"
huayoungtk-cli video tag --media-id <media-id> --tag "爆款视频" --remove
```

## 带货直播

查询方式：`--id` 或 `--media-id`。

### 直播列表

```bash
huayoungtk-cli live list
huayoungtk-cli live list --from 2026-05-06
huayoungtk-cli live list --shop-id <shop-id> --gmv-from 100 --sort gmv:desc
huayoungtk-cli live list --describe
```

排序字段包括 `id`、`startTime`、`endTime`、`gmv`、`itemsSold`、`estCommission`、`orderCount`、`viewCnt`、`likeCnt`、`commentCnt`、`handle`、`shopId`，默认 `startTime:desc`。

### 直播详情

```bash
huayoungtk-cli live get --id 123456
huayoungtk-cli live get --media-id 7630462341809998613
huayoungtk-cli live get --describe
```

### 直播备注

修改备注前必须确认。

```bash
huayoungtk-cli live note --id <live-id> --remark "备注"
huayoungtk-cli live note --media-id <media-id> --remark ""
```
