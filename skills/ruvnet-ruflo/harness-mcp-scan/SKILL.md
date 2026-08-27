---
name: harness-mcp-scan
description: 通过 `harness mcp-scan <path>` 对 harness 声明的 MCP 面进行静态安全扫描。读取 `.mcp/servers.json` 与 `.harness/claims.json`。纯读取操作，不做分发。当发现结果达到或超过 `--fail-on` 严重级别时以退出码 1 结束。 | Static security scan of a harness's declared MCP surface via `harness mcp-scan <path>`. Reads `.mcp/servers.json` + `.harness/claims.json`. Pure-read, no dispatch. Exits 1 on findings at or above `--fail-on` severity.
argument-hint: "[--path .] [--fail-on low|medium|high] [--format table|json]"
allowed-tools: Bash
---

Calls `harness mcp-scan` to enumerate every declared MCP server + tool
and flag policy / permission / dependency issues. Never executes any
tool; pure static analysis.

## Algorithm

Implementation: [`scripts/mcp-scan.mjs`](../../scripts/mcp-scan.mjs).

1. Invoke the pinned `harness` binary (`metaharness@~0.3.0`, resolved from a
   local install or the one-time `~/.ruflo/metaharness-cache-<pin>` cache —
   never `@latest`): `harness mcp-scan <path> --json`.
2. Parse `findings[]` with `{ severity, id, server, tool, message }`.
3. `--fail-on <severity>`: exit 1 when any finding is at or above that
   level. Default `high`.
4. Output JSON (default) or markdown table.

## Severity rank

| Severity | Rank |
|---|---:|
| low | 1 |
| medium | 2 |
| high | 3 |

`--fail-on high` (default) only fails on HIGH; `--fail-on medium` also
fails on MEDIUM; `--fail-on low` fails on any finding.

## CI integration

```yaml
- name: MCP static scan
  run: node plugins/ruflo-metaharness/scripts/mcp-scan.mjs --fail-on high
```

The exit code is the only thing CI watches; the JSON output goes to
artifacts for human review.

## Graceful degradation

When `harness` binary is unavailable (no network, blocked registry),
emits structured `{ degraded: true, reason: 'metaharness-not-available' }`
and exits 0. Ruflo continues — ADR-150 architectural constraint.
