# Pre-Mortem

From Gary Klein (2007). Prospective hindsight increases risk identification by ~30%.
Kahneman called it "the single most effective debiasing procedure I know."

## When to use

You have a plan, approach, or decision and want to stress-test it before committing.
Works especially well right before implementation begins.

## Protocol

1. **Assume complete failure.** The plan has been executed. It failed spectacularly.
   This isn't hypothetical hedging — adopt the mindset that failure has already happened.

2. **Generate 5+ specific failure modes.** For each, describe:
   - What went wrong (the concrete failure, not vague "it didn't work")
   - Why it went wrong (the root cause or mechanism)
   - What early warning sign you missed

3. **Rate each failure mode:**
   - Probability: how likely is this? (high / medium / low)
   - Impact: how bad if it happens? (catastrophic / serious / manageable)
   - Detectability: would you notice before it's too late? (early / late / never)

4. **Mitigate the top risks.** For failures that are high-probability OR high-impact
   OR low-detectability, identify a specific action that reduces the risk.

## Output format

```
PLAN: [one-sentence summary of what you're about to do]
FAILURE MODES:
1. [what failed] — because [root cause] — warning sign: [signal]
   P: [h/m/l] | I: [cat/ser/man] | D: [early/late/never]
   MITIGATION: [specific action]
2. ...
TOP RISKS: [which failures need attention before proceeding]
```
