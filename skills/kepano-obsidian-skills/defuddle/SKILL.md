---
name: defuddle
description: 使用 Defuddle CLI 从网页提取干净的 markdown 内容，去除杂乱与导航以节省 token。当用户提供要阅读或分析的 URL，或面对在线文档、文章、博文或任何标准网页时，用它替代 WebFetch。不要用于以 .md 结尾的 URL——它们本身已是 markdown，请直接使用 WebFetch。 | Extract clean markdown content from web pages using Defuddle CLI, removing clutter and navigation to save tokens. Use instead of WebFetch when the user provides a URL to read or analyze, for online documentation, articles, blog posts, or any standard web page. Do NOT use for URLs ending in .md — those are already markdown, use WebFetch directly.
---

# Defuddle

Use Defuddle CLI to extract clean readable content from web pages. Prefer over WebFetch for standard web pages — it removes navigation, ads, and clutter, reducing token usage.

If not installed: `npm install -g defuddle`

## Usage

Always use `--md` for markdown output:

```bash
defuddle parse <url> --md
```

Save to file:

```bash
defuddle parse <url> --md -o content.md
```

Extract specific metadata:

```bash
defuddle parse <url> -p title
defuddle parse <url> -p description
defuddle parse <url> -p domain
```

## Output formats

| Flag | Format |
|------|--------|
| `--md` | Markdown (default choice) |
| `--json` | JSON with both HTML and markdown |
| (none) | HTML |
| `-p <name>` | Specific metadata property |
