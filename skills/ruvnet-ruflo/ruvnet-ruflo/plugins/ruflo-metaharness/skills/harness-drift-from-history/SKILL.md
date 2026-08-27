---
name: harness-drift-from-history
description: 一条命令的漂移检测。将 audit-list + oia-audit + audit-trend 组合为单一原语：在 `metaharness-audit` 命名空间中查找最近的审计，对当前仓库运行全新审计，按 ADR-152 §3.1 相似度进行差异比对，并在结构距离超过 `--threshold` 时告警。ADR-150 深度集成的第 53 次迭代。 | One-command drift detection. Composes audit-list + oia-audit + audit-trend into a single primitive — finds the most recent audit in `metaharness-audit` namespace, runs a fresh audit against the current repo, diffs them via ADR-152 §3.1 similarity, and alerts when structural distance crosses `--threshold`. Iter 53 of ADR-150 deep integration.
argument-hint: "[--path .] [--baseline-since 7d] [--threshold 0.95] [--dry-run] [--format json|table]"
allowed-tools: Bash
---

The natural ops question after running `oia-audit` weekly is "did anything drift?" Before this skill, the answer required a three-step sequence:

```bash
npx ruflo metaharness audit-list --format json   # → pick a key by hand
npx ruflo metaharness oia-audit --format json > /tmp/curr.json
npx ruflo metaharness audit-trend \
  --baseline-key <picked-key> --current /tmp/curr.json \
  --alert-on-distance-below 0.95
```

This skill collapses it into one command:

```bash
npx ruflo metaharness drift-from-history --threshold 0.95
```

## What it does

1. Lists records from `metaharness-audit` namespace via audit-list.mjs
2. Picks the most recent record by `startedAt` (or `--baseline-since 7d` skips anything newer than 7 days)
3. Runs a fresh `oia-audit` against the current path
4. Diffs the two via audit-trend, applying `--alert-on-distance-below ${threshold}`
5. Returns the structured drift report

## Architectural constraint inheritance (ADR-150)

| Constraint | How drift-from-history satisfies it |
|---|---|
| Removable | Pure subprocess composition over existing scripts — no new `@metaharness/*` import |
| Optional | If oia-audit reports `degraded:true`, this skill exits 3 with a degraded payload |
| Graceful | Empty audit history → exit 2 with hint to seed it; never crashes |
| CI-gate | Smoke step 17z16 anchors the dispatcher entry + subcommand listing |

## Exit codes

- 0 — similarity ≥ threshold (or threshold not crossed)
- 1 — drift detected: similarity < threshold (alert fired)
- 2 — config error (no history, audit-list failed)
- 3 — upstream metaharness absent (degraded payload returned)

## Example

```bash
$ npx ruflo metaharness drift-from-history --threshold 0.95
# drift-from-history

Baseline:        audit-2026-06-16T22-58-47-840Z
Current:         2026-06-16T23:05:02.231Z

Structural similarity: 1 (near-identical)
Distance:              0

✓ similarity ≥ 0.95 — OK
```

## Implementation

[`scripts/drift-from-history.mjs`](../../scripts/drift-from-history.mjs)
