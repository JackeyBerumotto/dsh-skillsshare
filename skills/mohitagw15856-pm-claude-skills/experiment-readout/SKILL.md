---
name: experiment-readout
description: "分析已完成的 A/B 测试，撰写基于真实统计的诚实结果报告。当被要求解读 A/B 测试、分析实验结果、检验结果是否具有统计显著性，或依据测试数据决定是否上线时使用。产出一份报告——计算得出的提升幅度、p 值与置信区间、显著性判定、护栏指标检查，以及明确的上线／不上线／继续迭代建议。内置仅依赖标准库的显著性计算器。 | Analyse a finished A/B test and write an honest results readout with real statistics. Use when asked to read out an A/B test, analyse experiment results, check if a result is statistically significant, or decide ship/no-ship from test data. Produces a readout — the computed lift, p-value & confidence interval, a significance verdict, guardrail check, and a clear ship / no-ship / iterate recommendation. Includes a stdlib significance calculator."
---

# Experiment Readout Skill

A test result is only a decision if the statistics are sound — and "variant looks higher" is not a
result. This skill computes the lift, the p-value, and a confidence interval from the raw counts, checks
the guardrails, and writes an honest readout with a clear ship/no-ship call — flagging the traps
(peeking, underpowered, novelty, a significant but tiny effect) that make teams ship noise.

## Required Inputs

Ask for these only if they aren't already provided:

- **The metric & data** — for a conversion test: users and conversions per variant (control vs. treatment). For a continuous metric: mean, SD, and n per variant.
- **The hypothesis** — what you expected and the minimum effect that matters.
- **Guardrail metrics** — what shouldn't get worse (revenue, latency, retention).
- **Test setup** — planned sample size/duration, and whether it ran to plan (for the peeking check).

## Output Format

### Experiment Readout: [test name]

**1. Result** — computed (use the helper): control vs. treatment rate, **absolute & relative lift**, **p-value**, and the **confidence interval** on the difference.

| Variant | N | Conversions | Rate |
|---|---|---|---|
| Control | | | |
| Treatment | | | |

→ Lift: **X%** (CI: [a%, b%]) · p = **0.0xx**

**2. Verdict** — significant at the stated bar or not, *and* whether the effect is **big enough to matter** (a significant +0.2% may not be worth the complexity). Distinguish statistical from practical significance.

**3. Guardrails** — did anything you promised not to harm move? A win that tanks a guardrail isn't a win.

**4. Validity checks** — was it run to the planned sample (no peeking/early-stopping)? Sample-ratio mismatch? Novelty/seasonality? Call out anything that undermines the result.

**5. Recommendation** — **ship / no-ship / iterate / re-run**, with the reason. If inconclusive, say so — "no significant difference" is a valid, useful result, not a failure to spin.

## Programmatic Helper

`scripts/ab_significance.py` (stdlib only) computes the two-proportion z-test, p-value, lift, and CI:

```bash
# python3 ab_significance.py <control_n> <control_conv> <treat_n> <treat_conv>
python3 scripts/ab_significance.py 10000 800 10000 880
python3 scripts/ab_significance.py 10000 800 10000 880 --json
```

## Quality Checks

- [ ] Lift, p-value, and a confidence interval are computed (not just "higher")
- [ ] Statistical significance AND practical significance are both assessed
- [ ] Guardrail metrics are checked, not just the primary
- [ ] Validity is checked: ran to planned n, no peeking, no sample-ratio mismatch
- [ ] An inconclusive result is reported honestly, not spun into a win
- [ ] The recommendation is explicit (ship/no-ship/iterate/re-run)

## Anti-Patterns

- [ ] Do not call significance by eye — compute the p-value and CI; a higher number isn't a result
- [ ] Do not ignore the confidence interval — a CI spanning zero (or huge) means you don't actually know the effect
- [ ] Do not confuse statistical with practical significance — a tiny significant lift may not be worth shipping
- [ ] Do not trust a peeked/early-stopped test — stopping when it looks good inflates false positives massively
- [ ] Do not spin a null result — "no detectable difference" is honest and often the right call

## Based On

Frequentist A/B analysis — two-proportion z-test, confidence intervals, guardrails, and the peeking/practical-significance pitfalls.
