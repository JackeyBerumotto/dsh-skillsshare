---
name: quote-card
description: "从客户证言、评论、访谈或长文本中提炼出最具传播力的一句引语，并排版成干净的引言卡片。当被要求为社交媒体/营销制作 pull-quote、证言图或「引言卡片」时使用。产出一条精心剪辑、带署名的引语及 2-3 个备选，结构上适合在 playground 中导出为效果出色的 PNG。 | Pull the single most shareable quote out of a testimonial, review, interview, or long text and format it as a clean quote card. Use when asked to make a pull-quote, testimonial graphic, or 'quote card' for social/marketing. Produces a tightly-edited quote with attribution and 2-3 alternates, structured to look great exported as a PNG from the playground."
---

# Quote Card Skill

The best quote in a testimonial or interview is usually buried in a paragraph. This skill finds it, tightens
it to its sharpest form (without changing the meaning), and formats it as a clean **quote card** with
attribution — built to export as an image via **🖼️ Save as image** in the playground.

## Required Inputs

Ask for these only if they aren't already provided:

- **The source text** — the testimonial, review, interview transcript, or passage.
- **Attribution** — name, title, company (whatever is known and approved to use).
- **Angle** (optional) — what you want the quote to emphasize (results, ease, trust, speed).
- **Length limit** (optional) — if it's for a specific format.

## Output Format

### Quote card

> **"[The tightened pull-quote — the single most compelling line, edited for punch, meaning intact.]"**
>
> — **[Name]**, [Title], [Company]

*(Light editing is fine — trimming filler, joining two adjacent sentences. Use an ellipsis `…` for removed middles and `[ ]` for any inserted word. Never change what they meant.)*

**Alternate pulls (2–3)** — other strong lines from the source, each with attribution, so they can choose the angle.

**Editing note** — exactly what you trimmed or adjusted from the original, so it can be approved against the source.

**Caption** — a one-line lead-in for the post body beside the image.

## Quality Checks

- [ ] The main quote is the genuinely strongest, most specific line in the source
- [ ] Edits tighten without distorting meaning; cuts marked with `…`, insertions with `[ ]`
- [ ] Attribution is complete and matches what was provided
- [ ] 2–3 alternates give a real choice of angle
- [ ] The editing note lets someone verify the quote against the original
- [ ] Short and punchy enough to look great as an exported card

## Anti-Patterns

- [ ] Do not fabricate or embellish a quote — only use words that are in (or faithfully trimmed from) the source
- [ ] Do not change the meaning to make it punchier — fidelity over flash
- [ ] Do not pick a generic line ("It's great!") when a specific, vivid one exists
- [ ] Do not hide your edits — the editing note must reflect every change
- [ ] Do not invent attribution — use only what's given, flag what's missing

## Based On

Testimonial/pull-quote editing for marketing (find the strongest line, faithful tightening, clear attribution).
