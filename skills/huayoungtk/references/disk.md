# 花漾云盘参考

## 浏览文件

```bash
huayoungtk-cli disk list --path team_disk://
huayoungtk-cli disk list --path "team_disk://素材/商品图"
huayoungtk-cli disk list --path "user_disk://图片"
huayoungtk-cli disk list --path team_disk:// --page-size 100 --page-token <page-token>
huayoungtk-cli disk list --describe
```

- `--path` 必填，必须是以 `team_disk://` 或 `user_disk://` 开头的完整云盘路径。
- 网盘类型直接由路径协议确定，不需要也不允许单独传类型参数。
- 有下一页时，将返回的 `nextPageToken` 传给 `--page-token`。
- 返回的 `files[].uri` 是其他业务命令引用云盘文件时使用的路径。
- `directory: true` 表示目录，`directory: false` 表示文件。
- 其他业务命令需要引用云盘文件时，直接使用 `files[].uri`。

## 复制文件

`disk cp` 只支持本地文件与云盘文件之间复制。源路径和目标路径必须恰好一个是本地路径、一个是云盘协议路径。

```bash
huayoungtk-cli disk cp "./a.jpg" "team_disk://素材/a.jpg"
huayoungtk-cli disk cp "user_disk://图片/a.jpg" "./a.jpg"
huayoungtk-cli disk cp "./a.jpg" "team_disk://素材/a.jpg" --force
huayoungtk-cli disk cp "./a.jpg" "team_disk://素材/a.jpg"
huayoungtk-cli disk cp --describe
```

- 不支持云盘到云盘或本地到本地复制。
- 当前只支持文件，不支持复制目录。
- 目标路径必须包含文件名。
- 目标文件已存在时，用户明确确认覆盖后才能添加 `--force`。
- 执行前必须让用户确认完整的源路径和目标路径。

## 删除文件或目录

`disk rm` 只接受 `team_disk://` 或 `user_disk://` 路径。删除后无法恢复。

```bash
huayoungtk-cli disk rm "team_disk://素材/a.jpg"
huayoungtk-cli disk rm "user_disk://临时目录/" --recursive
huayoungtk-cli disk rm --describe
```

- 不接受本地路径。
- 不允许删除云盘根目录。
- 删除目录时路径必须以 `/` 结尾，并添加 `--recursive`。
- 执行前必须复述完整路径并获得用户明确确认。
