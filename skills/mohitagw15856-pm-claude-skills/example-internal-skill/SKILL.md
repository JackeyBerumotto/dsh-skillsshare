---
name: example-internal-skill
description: "一个示例私有技能——请替换我。用于演示组织私有技能的加载、覆盖，并保持在你自己的网络之内。会在 /v1/skills 中以 source:private 生成此描述。 | An example private skill — replace me. Use when demonstrating that org-private skills load, override, and stay inside your network. Produces this description in /v1/skills with source:private."
---
# Example Internal Skill
Private skills live here, never leave your infra, and override curated skills on name collision. Delete this folder and add your own.
## Required Inputs
- Your organisation's real internal SOPs, converted with `pm-claude-skills migrate`.
## Output Format
- Whatever your org needs — this is yours.
## Quality Checks
- [ ] This example was replaced with something real
## Anti-Patterns
- [ ] Do not put secrets in skill files — they're plain text on your infra
