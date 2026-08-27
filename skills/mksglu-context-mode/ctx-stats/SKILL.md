---
name: ctx-stats
description: |
  显示 context-mode 本次会话节省了多少上下文窗口。显示 token 消耗、上下文节省比率和按工具的明细。只读——仅显示统计，无重置功能。要彻底清空知识库，请改用 ctx_purge。触发方式：/context-mode:ctx-stats。 |
  Displays token consumption, context savings ratio, and per-tool breakdown.
  Read-only — shows stats only, no reset capability.
  To wipe the knowledge base entirely, use ctx_purge instead.
  Trigger: /context-mode:ctx-stats
user-invocable: true
---

# Context Mode Stats

Show context savings for the current session.

## Instructions

1. Call the `mcp__context-mode__ctx_stats` MCP tool (no parameters needed).
2. **CRITICAL**: You MUST copy-paste the ENTIRE tool output as markdown text directly into your response message. Do NOT summarize, do NOT collapse, do NOT paraphrase. The user must see the full tables without pressing ctrl+o. Copy every line exactly as returned by the tool.
3. After the full output, add ONE sentence highlighting the key savings metric, e.g.:
   - "context-mode saved **12.4x** — 92% of data stayed in sandbox."
   - If no data yet: "No context-mode calls yet this session."

## Purge

- **`ctx_purge(confirm: true)`** — Permanently deletes all indexed content from the knowledge base. Use `/context-mode:ctx-purge` for this.
