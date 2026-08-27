---
name: test-gaps
description: 检测缺失的测试覆盖并生成测试建议。当用户询问覆盖缺口、未被测试的代码或接下来该写什么测试时使用；在添加新功能后找出仍需测试的部分时也可使用。 | Detect missing test coverage and generate test suggestions. Use when the user asks about coverage gaps, untested code, or what tests to write next; also after adding a feature to find what still needs tests.
argument-hint: "[--path PATH] [--limit N]"
allowed-tools: Bash(npx *) mcp__claude-flow__hooks_worker-dispatch Read Grep
---
Find test coverage gaps via CLI:
```bash
npx @claude-flow/cli@latest hooks coverage-gaps --format table --limit 20
npx @claude-flow/cli@latest hooks coverage-route --task "add auth tests"
npx @claude-flow/cli@latest hooks coverage-suggest --path src/
```

Or dispatch the testgaps worker via MCP:
`mcp__claude-flow__hooks_worker-dispatch({ trigger: "testgaps" })`

For continuous detection, use `/loop` with the `loop-worker` skill targeting the `testgaps` worker.
