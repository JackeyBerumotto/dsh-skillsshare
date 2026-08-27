---
name: doc-gen
description: 生成并维护带漂移检测的文档。当用户要求编写/更新/刷新文档、检测文档与代码的漂移，或安排周期性文档维护时使用。 | Generate and maintain documentation with drift detection. Use when the user asks to write/update/refresh docs, detect doc drift against code, or schedule recurring documentation maintenance.
argument-hint: "[--target PATH]"
allowed-tools: Bash(npx *) mcp__claude-flow__hooks_worker-dispatch mcp__claude-flow__memory_store CronCreate Read Write
---
Generate docs via MCP worker dispatch:
`mcp__claude-flow__hooks_worker-dispatch({ trigger: "document" })`

For continuous doc maintenance via CronCreate:
`CronCreate({ schedule: "0 */2 * * *", prompt: "Run document worker" })`

Detect drift by comparing current code against existing docs and flagging inconsistencies.

Scoped generation:
- API docs: `npx @claude-flow/cli@latest hooks worker dispatch --trigger document --scope api`
- Full project: `npx @claude-flow/cli@latest hooks worker dispatch --trigger document --scope full`

Store the approach: `mcp__claude-flow__memory_store({ key: "doc-pattern", value: "APPROACH", namespace: "patterns" })`
