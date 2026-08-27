---
name: federation-status
description: 显示联邦健康状态——节点、会话、信任级别和消息指标。当用户问「联邦是否健康？」「显示节点」「联邦状态」，或想检查跨安装的代理连通性时使用。 | Show federation health — peers, sessions, trust levels, and message metrics. Use when the user asks "is federation healthy?", "show peers", "federation status", or wants to inspect cross-installation agent connectivity.
allowed-tools: Bash(npx *) mcp__claude-flow__memory_search Read
argument-hint: ""
---
Show the current state of the federation.

Steps:
1. `npx -y -p @claude-flow/plugin-agent-federation@latest ruflo-federation status` -- overall health
2. `npx -y -p @claude-flow/plugin-agent-federation@latest ruflo-federation peers` -- list peers with trust levels and scores
3. Summarize: active sessions, messages exchanged, PII redactions, threat detections

Search memory for federation history:
`mcp__claude-flow__memory_search({ query: "federation peer trust", namespace: "federation" })`
