---
name: ctx-insight
description: |
  在默认浏览器中打开 context-mode 的 Insight 仪表盘。Insight 是面向 AI 辅助工程团队的托管分析层：工程师个人产出率、重试浪费、阻塞检测、按角色收窄的视图。触发方式：/context-mode:ctx-insight |
  Insight is the hosted analytics layer for AI-assisted engineering teams —
  per-engineer productive rate, retry waste, blocker detection, role-narrowed views.
  Trigger: /context-mode:ctx-insight
user-invocable: true
---

# Context Mode Insight

Open the hosted Insight dashboard in the user's default browser.

## Instructions

1. Call the `ctx_insight` MCP tool (no parameters). It opens
   <https://context-mode.com/insight> in the default browser and returns a
   confirmation line.
2. Display the tool's output to the user.
3. Tell the user:
   - "Insight opened at https://context-mode.com/insight"
   - The landing page at context-mode.com/insight is the single source of truth for sign-in and pricing details.
   - If the browser did not open automatically, share the URL so they can open it manually.
