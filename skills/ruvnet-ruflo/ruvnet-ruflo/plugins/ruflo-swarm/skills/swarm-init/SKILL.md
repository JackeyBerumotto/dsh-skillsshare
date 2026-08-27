---
name: swarm-init
description: 初始化带防漂移配置的多智能体集群。在启动需要 3 个以上协同智能体的复杂多文件任务（功能实现、跨模块重构、安全审计）时使用。单文件编辑或快速问答请跳过。 | Initialize a multi-agent swarm with anti-drift configuration. Use when starting a complex multi-file task that needs 3+ coordinated agents (feature implementation, refactor across modules, security audit). Skip for single-file edits or quick questions.
argument-hint: "[--topology hierarchical|mesh|hierarchical-mesh|ring|star|adaptive]"
allowed-tools: Bash(npx *) mcp__claude-flow__swarm_init mcp__claude-flow__swarm_status Task SendMessage
---
Initialize a hierarchical swarm for coordinated multi-agent work.

Via MCP: `mcp__claude-flow__swarm_init({ topology: "hierarchical", maxAgents: 8, strategy: "specialized" })`

Or via CLI:
```bash
npx @claude-flow/cli@latest swarm init --topology hierarchical --max-agents 8 --strategy specialized
```

Then spawn named agents in ONE message via Claude Code's `Task` tool with `name:` (for `SendMessage` addressability) and `run_in_background: true` (for parallel execution). Use `EnterWorktree` per agent for git-safe parallel work, and `SendMessage` for inter-agent coordination.

For larger teams (10+), use hierarchical-mesh topology:
```bash
npx @claude-flow/cli@latest swarm init --topology hierarchical-mesh --max-agents 15 --strategy specialized
```
