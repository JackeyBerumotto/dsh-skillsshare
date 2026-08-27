---
name: agile-product-owner
description: 面向高级产品负责人的敏捷产品负责工具包，包括符合 INVEST 原则的用户故事生成、冲刺规划、待办管理和速率跟踪。适用于故事撰写、冲刺规划、干系人沟通和敏捷仪式。 | Agile product ownership toolkit for Senior Product Owner including INVEST-compliant user story generation, sprint planning, backlog management, and velocity tracking. Use for story writing, sprint planning, stakeholder communication, and agile ceremonies.
---

# Agile Product Owner

Complete toolkit for Product Owners to excel at backlog management and sprint execution.

## Core Capabilities
- INVEST-compliant user story generation
- Automatic acceptance criteria creation
- Sprint capacity planning
- Backlog prioritization
- Velocity tracking and metrics

## Key Scripts

### user_story_generator.py
Generates well-formed user stories with acceptance criteria from epics.

**Usage**: 
- Generate stories: `python scripts/user_story_generator.py`
- Plan sprint: `python scripts/user_story_generator.py sprint [capacity]`

**Features**:
- Breaks epics into stories
- INVEST criteria validation
- Automatic point estimation
- Priority assignment
- Sprint planning with capacity
