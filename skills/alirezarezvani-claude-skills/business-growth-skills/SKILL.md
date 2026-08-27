---
name: "business-growth-skills"
description: "本插件内置 4 个业务与增长技能的路由器/索引：customer-success-manager（健康评分、流失风险、扩展）、sales-engineer（RFP 分析、竞争矩阵、PoC 规划）、revenue-operations（管道、预测准确率、GTM 效率）以及 contract-and-proposal-writer。当增长/收入请求无法明显对应到单一技能、需要挑选合适技能时使用（例如「哪些账户有风险」「我们该竞标这份 RFP 吗」）。 | Router/index for the 4 business & growth skills bundled in this plugin: customer-success-manager (health scoring, churn risk, expansion), sales-engineer (RFP analysis, competitive matrices, PoC planning), revenue-operations (pipeline, forecast accuracy, GTM efficiency), and contract-and-proposal-writer. Use when a growth/revenue request doesn't obviously match one skill and you need to pick the right one (e.g., 'which accounts are at risk', 'should we bid on this RFP')."
version: 2.9.0
author: Alireza Rezvani
license: MIT
tags:
  - business
  - customer-success
  - sales
  - revenue-operations
  - growth
agents:
  - claude-code
  - codex-cli
  - openclaw
---

# Business & Growth Skills — Router

This plugin bundles **4 skills** (this router is the 5th folder under `business-growth/skills/`). Each skill is self-contained.

## Routing table

Match the request, then load `business-growth/skills/<skill>/SKILL.md`. If multiple rows match, ask one clarifying question first.

| Request signals | Skill | Path |
|---|---|---|
| Customer health scores, churn risk, expansion plays | customer-success-manager | `skills/customer-success-manager/` |
| RFP/RFI coverage, competitive positioning, PoC plans | sales-engineer | `skills/sales-engineer/` |
| Pipeline coverage, forecast accuracy (MAPE), GTM efficiency | revenue-operations | `skills/revenue-operations/` |
| Proposals, contracts, statements of work, DPAs | contract-and-proposal-writer | `skills/contract-and-proposal-writer/` |

## Quick start

```bash
# Example: route an account-health request
cat business-growth/skills/customer-success-manager/SKILL.md
python3 business-growth/skills/customer-success-manager/scripts/health_score_calculator.py --help
```

## Rules

- Route to exactly one skill, then follow that skill's workflow. This router ships no tools of its own.
- Use the skills' Python scorers for metrics, not manual estimates; deal/contract outputs are drafts for human legal/commercial review.
