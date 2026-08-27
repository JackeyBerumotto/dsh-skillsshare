---
name: init-project
description: 初始化带有 MCP 工具、钩子和智能体配置的新 Ruflo 项目。在全新仓库中搭建 Ruflo，或当用户说「init ruflo」、「set up ruflo」，或询问如何从零引导 MCP 服务器、钩子和智能体配置时使用。 | Initialize a new Ruflo project with MCP tools, hooks, and agent configuration. Use when setting up Ruflo in a fresh repo, or when the user says "init ruflo", "set up ruflo", or asks how to bootstrap the MCP server, hooks, and agent configs from scratch.
argument-hint: "[--preset standard|minimal|full]"
allowed-tools: Bash(npx *) Read Write Edit
---
Run `npx @claude-flow/cli@latest init --wizard` to set up the project interactively, or `npx @claude-flow/cli@latest init --preset standard` for defaults.

This creates CLAUDE.md, .claude/settings.json, and .claude-flow/ config with MCP server registration for the `ruflo` MCP tools.
