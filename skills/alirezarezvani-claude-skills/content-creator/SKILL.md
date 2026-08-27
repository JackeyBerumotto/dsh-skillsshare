---
name: "content-creator"
description: "已弃用的重定向技能，将旧的「content creator」请求路由到正确的专家技能。当用户调用「content creator」、要求撰写博客文章、文章、指南或品牌声音分析（路由到 content-production），或要求规划内容、构建主题集群或创建内容日历（路由到 content-strategy）时使用。它不直接处理请求，而是识别用户意图，将写作/SEO/品牌声音类任务重定向到 content-production，将规划类任务重定向到 content-strategy。 | Deprecated redirect skill that routes legacy 'content creator' requests to the correct specialist. Use when a user invokes 'content creator', asks to write a blog post, article, guide, or brand voice analysis (routes to content-production), or asks to plan content, build a topic cluster, or create a content calendar (routes to content-strategy). Does not handle requests directly — identifies user intent and redirects to content-production for writing/SEO/brand-voice tasks or content-strategy for planning tasks."
license: MIT
metadata:
  version: 2.0.0
  author: Alireza Rezvani
  category: marketing
  updated: 2026-03-06
  status: deprecated
---

# Content Creator → Redirected

> **This skill has been split into two specialist skills.** Use the one that matches your intent:

| You want to... | Use this instead |
|----------------|-----------------|
| **Write** a blog post, article, or guide | [content-production](../content-production/) |
| **Plan** what content to create, topic clusters, calendar | [content-strategy](../content-strategy/) |
| **Analyze brand voice** | [content-production](../content-production/) (includes `brand_voice_analyzer.py`) |
| **Optimize SEO** for existing content | [content-production](../content-production/) (includes `seo_optimizer.py`) |
| **Create social media content** | [social-content](../social-content/) |

## Why the Change

The original `content-creator` tried to do everything: planning, writing, SEO, social, brand voice. That made it a jack of all trades. The specialist skills do each job better:

- **content-production** — Full pipeline: research → brief → draft → optimize → publish. Includes all Python tools from the original content-creator.
- **content-strategy** — Strategic planning: topic clusters, keyword research, content calendars, prioritization frameworks.

## Proactive Triggers

- **User asks "content creator"** → Route to content-production (most likely intent is writing).
- **User asks "content plan" or "what should I write"** → Route to content-strategy.

## Output Artifacts

| When you ask for... | Routed to... |
|---------------------|-------------|
| "Write a blog post" | content-production |
| "Content calendar" | content-strategy |
| "Brand voice analysis" | content-production (`brand_voice_analyzer.py`) |
| "SEO optimization" | content-production (`seo_optimizer.py`) |

## Communication

This is a redirect skill. Route the user to the correct specialist — don't attempt to handle the request here.

## Related Skills

- **content-production**: Full content execution pipeline (successor).
- **content-strategy**: Content planning and topic selection (successor).
- **content-humanizer**: Post-processing AI content to sound authentic.
- **marketing-context**: Foundation context that both successors read.
