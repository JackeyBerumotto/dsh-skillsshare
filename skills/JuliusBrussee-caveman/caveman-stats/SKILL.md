---
name: caveman-stats
description: >
  显示当前会话的真实 token 用量和预估节省。直接读取 Claude Code 会话日志——无 AI 估算。通过 /caveman-stats 触发。输出由 mode-tracker 钩子注入；模型本身不计算这些数字。 |
  Reads directly from the Claude Code session log — no AI estimation.
  Triggers on /caveman-stats. Output is injected by the mode-tracker hook;
  the model itself does not compute the numbers.
---

This skill is delivered by `hooks/caveman-stats.js` (read by `hooks/caveman-mode-tracker.js` on `/caveman-stats`). The model does not need to do anything when this skill fires — the hook returns `decision: "block"` with the formatted stats as the reason. The user sees the numbers immediately.
