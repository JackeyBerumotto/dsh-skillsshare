---
name: "codebase-onboarding"
description: "分析代码库并为工程师、技术负责人和外包人员生成入职文档。快速收集事实，产出可复用的入职材料。在为新工程师做入职引导、为新项目编写架构概览文档，或为陌生仓库准备技术负责人简报时使用。 | Analyze a codebase and generate onboarding documentation for engineers, tech leads, and contractors. Fast fact-gathering and repeatable onboarding outputs. Use when onboarding a new engineer, writing architecture-overview docs for a new project, or producing tech-lead briefings for unfamiliar repos."
---

# Codebase Onboarding

**Tier:** POWERFUL  
**Category:** Engineering  
**Domain:** Documentation / Developer Experience

---

## Overview

Analyze a codebase and generate onboarding documentation for engineers, tech leads, and contractors. This skill is optimized for fast fact-gathering and repeatable onboarding outputs.

## Core Capabilities

- Architecture and stack discovery from repository signals
- Key file and config inventory for new contributors
- Local setup and common-task guidance generation
- Audience-aware documentation framing
- Debugging and contribution checklist scaffolding

---

## When to Use

- Onboarding a new team member or contractor
- Rebuilding stale project docs after large refactors
- Preparing internal handoff documentation
- Creating a standardized onboarding packet for services

---

## Quick Start

```bash
# 1) Gather codebase facts
python3 scripts/codebase_analyzer.py /path/to/repo

# 2) Export machine-readable output
python3 scripts/codebase_analyzer.py /path/to/repo --json

# 3) Use the template to draft onboarding docs
# See references/onboarding-template.md
```

---

## Recommended Workflow

1. Run `scripts/codebase_analyzer.py` against the target repository.
2. Capture key signals: file counts, detected languages, config files, top-level structure.
3. Fill the onboarding template in `references/onboarding-template.md`.
4. Tailor output depth by audience:
   - Junior: setup + guardrails
   - Senior: architecture + operational concerns
   - Contractor: scoped ownership + integration boundaries

---

## Onboarding Document Template

Detailed template and section examples live in:
- `references/onboarding-template.md`
- `references/output-format-templates.md`

---

## Common Pitfalls

- Writing docs without validating setup commands on a clean environment
- Mixing architecture deep-dives into contractor-oriented docs
- Omitting troubleshooting and verification steps
- Letting onboarding docs drift from current repo state

## Best Practices

1. Keep setup instructions executable and time-bounded.
2. Document the "why" for key architectural decisions.
3. Update docs in the same PR as behavior changes.
4. Treat onboarding docs as living operational assets, not one-time deliverables.
