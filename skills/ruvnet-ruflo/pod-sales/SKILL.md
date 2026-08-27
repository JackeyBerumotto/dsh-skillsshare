---
name: pod-sales
description: 运行销售 business-pod 的一个 tick（ADR-164 §4.1，阶段 2）。加载 templates/sales.json，依据 pod-schema 校验，对照 ruflo 的智能体注册表解析智能体，通过阶段 2 的基于文件的存根账本预留预算（依据 ADR-164.1，原子 SQLite 追踪器属于阶段 3），构造逐智能体的演练提示词，经 federation_bbs_publish 的 JSONL 后端存储向 sales 房间发布摘要信封，并为 /loop 摄取输出一行结构化的 {podName, tickId, agentsRan, totalUsd, envelopeId, status}。默认演练；--live 保留给阶段 3。 | Run one tick of the sales business-pod (ADR-164 §4.1, Phase 2). Loads templates/sales.json, validates it against the pod-schema, resolves agents against ruflo's agent registry, reserves budget via the Phase-2 file-based stub ledger (atomic SQLite tracker is Phase 3 per ADR-164.1), constructs per-agent dry-run prompts, posts a summary envelope to room "sales" via the federation_bbs_publish JSONL backing store, and emits a structured {podName, tickId, agentsRan, totalUsd, envelopeId, status} line for /loop ingestion. Dry-run by default; --live is reserved for Phase 3.
argument-hint: "[--pod-template <path>] [--base-path <dir>] [--dry-run|--live] [--budget-cap-usd <amt>] [--tick-id <id>]"
allowed-tools: Bash
---

Surfaces `pod-tick.mjs` as a single-shot skill for the sales pod. Use when
Claude Code needs to demonstrate, smoke-test, or schedule one iteration of
the sales autopilot without spawning real LLM workers.

## Algorithm

Implementation: [`scripts/pod-tick.mjs`](../../scripts/pod-tick.mjs).

1. Parse args (`--pod-template`, `--base-path`, `--dry-run` / `--live`,
   `--budget-cap-usd`, `--tick-id`). `--live` is refused with exit code 3
   in Phase 2.
2. Load the pod template JSON (default: `templates/sales.json`).
3. Validate via `validatePodTemplate(json)` — schema in
   `v3/@claude-flow/cli/src/business-pods/pod-schema.ts` and inlined in
   `pod-tick.mjs` so the script runs without a built CLI. Throws with a
   JSON-pointer path on the first violation.
4. Resolve every `agent.agentType` against `KNOWN_AGENT_TYPES`. Unknown
   types abort with exit code 2 and an actionable error.
5. Reserve `min(budgetUsdPerRun, --budget-cap-usd)` USD against the
   file-based ledger at `<base-path>/budget/<roomId>.json`. Honors
   `reservationExpiryMs` (default 60_000 ms, bounded to [5000, 300000]
   per ADR-164.1 §3.2). `TODO(adr-164.1)`: swap the file ledger for the
   atomic SQLite tracker in Phase 3.
6. Build per-agent prompts (kickoff scoped to the bench description +
   pod's PII policy). In `--dry-run` they are logged to stderr and the
   model is never invoked.
7. Commit the reservation. Dry-run actual = $0; live actual = the
   reserved amount (Phase 3 wires real `claude -p` `--max-budget-usd`
   reporting).
8. Append a `pod-status` envelope to the Phase-1 backing store at
   `<base-path>/.agentbbs/room-<derivedRoomId>.jsonl` so subsequent
   `federation_bbs_watch` calls see the tick.
9. Emit a single JSON line on stdout:
   `{podName, tickId, agentsRan, totalUsd, envelopeId, status}`.

## Exit codes

- `0` — tick succeeded (`status === 'success'`)
- `2` — invalid template / unknown agent type / budget exhausted / arg error
- `3` — `--live` requested (refused in Phase 2)

## Phase 3 surfaces (not in this build)

- `--live` mode: dispatch each prompt through `claude -p` headless or a
  Managed Agent and capture the actual `--max-budget-usd` reported spend.
- Atomic SQLite budget tracker (ADR-164.1 §3.2).
- Multi-pod variants (`pod-marketing`, `pod-finance`, ...) — each gets its
  own skill once Phase 3 ships.
