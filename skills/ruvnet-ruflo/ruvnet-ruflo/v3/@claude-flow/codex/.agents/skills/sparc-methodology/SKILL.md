---
name: sparc-methodology
description: >
  SPARC 开发工作流（规格、伪代码、架构、精化、完成）。使用场景：新功能、复杂实现、架构变更。跳过场景：简单修复、文档、配置。 |
  Use when: new features, complex implementations, architectural changes.
  Skip when: simple fixes, documentation, configuration.
---

# Sparc Methodology Skill

## Purpose
SPARC development workflow (Specification, Pseudocode, Architecture, Refinement, Completion).

## When to Trigger
- new features
- complex implementations
- architectural changes

## When to Skip
- simple fixes
- documentation
- configuration

## Commands

### Specification Phase
Define requirements and acceptance criteria

```bash
npx @claude-flow/cli hooks route --task "specification: [requirements]"
```

### Architecture Phase
Design system structure

```bash
npx @claude-flow/cli hooks route --task "architecture: [design]"
```



## Best Practices
1. Check memory for existing patterns before starting
2. Use hierarchical topology for coordination
3. Store successful patterns after completion
4. Document any new learnings
