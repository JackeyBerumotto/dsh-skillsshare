# 客户端基础

本文档收录安装、客户端连接、输出约定、状态检查、技能管理和配置。仅在处理这些主题时读取。

## 目录

- [安装 / 升级](#安装--升级)
- [客户端连接](#客户端连接)
- [输出格式](#输出格式)
- [客户端状态](#客户端状态status)
- [技能管理](#技能管理skills)
- [配置](#配置)

## 安装 / 升级

安装或升级都执行以下两条命令：

```bash
npm install -g @huayoung/huayoung-cli
huayoung-cli skills install
```

## 客户端连接

使用 huayoung-cli 前，确保花漾桌面客户端已打开并登录。如果 CLI 提示客户端离线，客户端可能未启动。


## 输出格式

多数业务命令直接输出 JSON object/array，不保证使用统一的 `ok/data/error` 包装；`status` 等诊断命令可能输出人类可读文本。解析输出时应以命令的实际结果及当前 CLI 的 `--describe` 为准。

通用参数（大部分命令支持）：

| 参数 | 短写 | 说明 |
|------|------|------|
| `--output` | `-o` | 输出格式：json（默认）、ndjson |
| `--jq` | | 使用 jq 表达式过滤输出 |
| `--jq-file` | | 从文件读取 jq 表达式，避免 Windows 引号转义 |
| `--describe` | | 输出字段说明（不调用 API，无需提供必填参数） |

### 使用 `--describe` 获取输出字段

1. 在解析不熟悉的命令输出前，优先执行同一命令的 `--describe`。
2. `--describe` 只返回字段说明，不调用业务 API，也不需要提供该命令的必填业务参数。
3. CLI 升级后，以当前版本的 `--describe` 输出为准。
4. 命令不支持 `--describe` 时，使用 `--help` 查询。

> **Windows 参数注意**：复杂 jq、JSON、JavaScript 或带引号/空格的值可能被 PowerShell 与 `.cmd` 多层转义。jq 优先使用 `--jq-file`；批量表单优先使用 `--elements-file`，也可传 `--elements-file -` 从 stdin 读取。含 `&` 的 URL 仍应使用正确的 PowerShell 引号并在操作后核对最终 URL。

- stdout 是数据，stderr 是进度/提示信息

---


## 客户端状态（Status）

检查花漾桌面客户端是否在线。

```bash
huayoung-cli status
```

如果客户端离线，需提醒用户：请确保客户端已打开并已登录。

---


## 技能管理（Skills）

管理 AI Agent 技能的安装和卸载。

```bash
# 安装技能（自动检测 AI Agent 类型）
huayoung-cli skills install

# 指定安装给 Claude Code
huayoung-cli skills install --agent claude-code

# 指定安装给 Codex
huayoung-cli skills install --agent codex

# 安装到自定义目录（适用于未内置支持的 AI Agent）
huayoung-cli skills install --target-dir /path/to/agent/skills

# 查看可用技能
huayoung-cli skills list

# 卸载技能（仅当用户明确要求卸载 skill 时使用）
huayoung-cli skills uninstall
```

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `--agent` | string | 否 | 目标 AI Agent：claude-code、codex、hermes、openclaw（省略则自动检测） |
| `--target-dir` | string | 否 | 自定义安装目录（与 --agent 互斥，适用于未内置支持的 Agent） |

---

## 配置

配置可选，存储在 `~/.huayoung-cli/config.json`，通常无需手动修改。

环境变量：
- `HUAYOUNG_CLI_CONFIG_DIR` — 自定义配置目录（默认 `~/.huayoung-cli`）
