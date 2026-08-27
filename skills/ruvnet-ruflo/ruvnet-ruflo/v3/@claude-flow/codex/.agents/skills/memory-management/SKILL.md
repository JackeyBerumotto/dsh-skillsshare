---
name: memory-management
description: >
  带 HNSW 向量搜索的 AgentDB 记忆系统。使用场景：需要存储模式、搜索解决方案、语义查找。跳过场景：无需学习、临时性任务。 |
  Use when: need to store patterns, search for solutions, semantic lookup.
  Skip when: no learning needed, ephemeral tasks.
---

# Memory Management Skill

## Purpose
AgentDB memory system with HNSW vector search.

## When to Trigger
- need to store patterns
- search for solutions
- semantic lookup

## When to Skip
- no learning needed
- ephemeral tasks

## Commands

### Store Data
Store a pattern in memory

```bash
npx @claude-flow/cli memory store --key "key" --value "value" --namespace patterns
```

### Search Data
Semantic search in memory

```bash
npx @claude-flow/cli memory search --query "search terms" --limit 10
```



## Best Practices
1. Check memory for existing patterns before starting
2. Use hierarchical topology for coordination
3. Store successful patterns after completion
4. Document any new learnings
