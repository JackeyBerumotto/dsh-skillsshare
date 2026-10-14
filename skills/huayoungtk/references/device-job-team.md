# 设备、任务和团队参考

## 设备

设备用于执行 RPA 任务。

设备类型：`App`（花漾客户端）、

### 设备列表

```bash
huayoungtk-cli device list
huayoungtk-cli device list --shop-id <shop-id> --online
huayoungtk-cli device list --describe
```

device list 的 `--shop-id` 也可用 `--shop-code` 替代（二选一）。

当需要给用户展示设备列表时，分别用"花漾客户端"代替 `App`，用"花漾流程执行器"代替 `TeamRpaExecutor`、用"插件"代替`Extension`。

所有店铺 RPA 命令都按 `browserType` 处理设备：`extension` 店铺不指定具体插件实例时省略 `--device-id`，用户明确指定实例时可传对应的 Extension `deviceId`；`huayang` 店铺必须先查询客户端设备并让用户选择，再传用户选择的 `--device-id`；`both` 店铺必须先询问用户使用客户端浏览器还是插件执行，选择客户端时必须传用户选择的 `--device-id`，选择插件时可省略，用户明确指定插件实例时可传对应的 Extension `deviceId`。

## 任务

任务状态：`Pending`、`Scheduled`、`Running`、`Succeed`、`Failed`、`Cancelled`。

### 任务详情

```bash
huayoungtk-cli job get --job-id <job-id>
huayoungtk-cli job get --job-id <job-id> --alive=false
huayoungtk-cli job get --job-id <job-id> --execution-mode openapi
```

`creator send-message`、`creator sync`、`shop sync` 和 `target-plan create` 都会返回 `executionMode`。用 `job get` 查询这些任务时，应将该值传给 `--execution-mode`。`--execution-mode` 只支持 `rpa|openapi`，默认 `rpa`。OpenAPI 任务先用 `--execution-mode openapi` 轮询；活跃任务查不到时加 `--alive=false` 查询归档结果。`job list` 和 `job cancel` 当前仍只管理 RPA 任务。

### 任务列表

列出当前用户发起的任务，支持按任务类型、状态、达人 handle、店铺、创建时间筛选。

```bash
huayoungtk-cli job list
huayoungtk-cli job list --status Running
huayoungtk-cli job list --job-type SendInvite --sort createTime:desc
huayoungtk-cli job list --handle <handle>
huayoungtk-cli job list --from 2026-06-01 --to 2026-06-13
huayoungtk-cli job list --page 2 --page-size 5
huayoungtk-cli job list --describe
```

排序字段：`createTime`、`executeEndTime`，方向 `asc`/`desc`，默认 `createTime:desc`。每页默认 15 条。

### 取消任务

取消任务会修改平台状态。执行前必须向用户确认。

```bash
huayoungtk-cli job cancel --job-id <job-id>
```

## 团队

### 团队信息

```bash
huayoungtk-cli team info
huayoungtk-cli team info --describe
```

用团队信息查看团队身份、套餐和配额。
