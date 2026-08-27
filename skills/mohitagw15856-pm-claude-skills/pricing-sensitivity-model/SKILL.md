---
name: pricing-sensitivity-model
description: "Van Westendorp 价格敏感度分析，基于真实问卷答案计算——交叉点通过插值求得，而非肉眼从图表读取。当用户已拥有（或计划开展）四问定价调研（太便宜/便宜/贵/太贵），并需要最优价格点、可接受区间和有据可依的解读时使用。产出 OPP/IPP 与 PMC–PME 区间、四条累计曲线的数据，以及一份带实时收入假设分析的真实 .xlsx 文件——由内置零依赖脚本完成。 | Van Westendorp price sensitivity, computed from real survey answers — crossings found by interpolation, not read off a chart by eye. Use when someone has (or plans) the four-question pricing survey (too cheap / cheap / expensive / too expensive) and needs the optimal price point, the acceptable range, and a defensible readout. Produces OPP/IPP and the PMC–PME range, the four cumulative curves as data, and a real .xlsx with a live revenue what-if — via the bundled zero-dependency script."
---

# Pricing Sensitivity Model (Van Westendorp)

The Van Westendorp Price Sensitivity Meter is fifty years old and still the fastest honest answer to "what should this cost?" — but most readouts are someone squinting at where four lines seem to cross. This skill computes the crossings: cumulative curves built from the actual responses, intersections found by linear interpolation, non-monotone respondents dropped and counted.

## Required Inputs

- **Survey responses** — per respondent, the four classic answers as prices: *too cheap* (quality suspect), *cheap* (a bargain), *expensive* (getting dear), *too expensive* (out of the question). 20+ valid responses for a stable read; the script warns below that and refuses below 5.
- **Segment splits** (optional) — the tool doesn't segment; run it per segment and compare, which is usually where the real finding is.

If the survey hasn't run yet, produce the four questions verbatim and the screener instead, then stop — don't invent responses.

## Output Format

1. **The four points** — **OPP** (optimal price point: too-cheap × too-expensive crossing), **IPP** (indifference: cheap × expensive), and the acceptable range **PMC–PME**. Each with one sentence of meaning, not just the acronym.
2. **Data hygiene** — valid n, dropped non-monotone count (a high drop rate is itself a finding: respondents didn't understand the category or the questions).
3. **The recommendation** — a price *inside* the range with reasoning; note that OPP minimises purchase *resistance*, which is not the same as maximising revenue — premium positions price above OPP deliberately.
4. **The caveat** — VW measures perception, not demand; pair with a real willingness-to-pay test before betting the pricing page on it.

## Programmatic Helper

This skill ships `scripts/van_westendorp.py` — **zero dependencies** (stdlib zip+XML):

```bash
python3 scripts/van_westendorp.py analyze pricing.xlsx --responses-file survey.json
# survey.json: [{"too_cheap":5,"cheap":9,"expensive":18,"too_expensive":30}, …]
```

It prints the points (`n=40 OPP=12.05 IPP=12.75 range=9.66–15.05 dropped=1`) and writes an `.xlsx` with a **Summary** sheet (the four points + a live revenue what-if: edit the candidate price, buyers and revenue recalculate) and a **Curves** sheet (the four cumulative curves as plottable data). Requires a code-execution environment.

## Quality Checks

- [ ] Crossings were computed by the script from the actual responses — never estimated from a description of the data
- [ ] Valid n and dropped count are reported, with the warning surfaced when n < 20
- [ ] Every acronym (OPP/IPP/PMC/PME) is glossed in plain words at first use
- [ ] The recommended price is inside PMC–PME, and the OPP ≠ revenue-maximum distinction is stated
- [ ] The "perception, not demand" caveat appears before any commitment language

## Anti-Patterns

- [ ] Do not fabricate or extend survey responses — with no data, deliver the survey design and stop
- [ ] Do not read OPP as "the right price" — it is the least-resisted price, and premium strategies ignore it on purpose
- [ ] Do not hide the dropped respondents — non-monotone answers are evidence about the survey, not noise to delete
- [ ] Do not report a single point without the range — the range is the finding; the point is a summary of it
- [ ] Do not pool segments that obviously differ (SMB with enterprise) — the pooled curves cross somewhere nobody actually is
