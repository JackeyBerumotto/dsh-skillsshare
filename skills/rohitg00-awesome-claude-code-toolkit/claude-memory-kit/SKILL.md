---
name: claude-memory-kit
description: "面向 Claude Code 的持久记忆系统：两层架构（热缓存 + 知识库 wiki）、安全 hooks、/close-day 每日收尾综合。零外部依赖。 | Persistent memory system for Claude Code. Two-layer architecture (hot cache + knowledge wiki), safety hooks, /close-day end-of-day synthesis. Zero external dependencies."
author: awrshift
version: 3.2.0
tags: [memory, context-management, productivity, agent-memory]
repository: https://github.com/awrshift/claude-memory-kit
license: MIT
---

# Claude Memory Kit

Your Claude agent remembers everything across sessions and projects.

## What it does

- **Persistent memory** — MEMORY.md hot cache + knowledge wiki with [[wikilinks]]
- **Multi-project support** — per-project backlogs and context isolation
- **Safety hooks** — prevent context loss during compression and long sessions
- **`/close-day`** — one command captures your entire day
- **`/tour`** — interactive guided walkthrough

## Quick Start

```bash
git clone https://github.com/awrshift/claude-memory-kit.git my-project
cd my-project
claude
```

## Built from production

700+ sessions across 7 projects. Adapted from Karpathy/Cole Medin's knowledge base pattern, simplified for daily CLI use.
