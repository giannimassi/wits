# Confidence Calibration

From Superforecasting (Tetlock, GJP/IARPA) + Brier scores + "What Would Change My Mind?"
(Popper/LessWrong). Superforecasters outperformed CIA analysts with classified access
by calibrating confidence granularly and tracking accuracy.

## When to use

You're making a claim, prediction, or recommendation and want to be honest about how
certain you actually are. Especially important when others will act on your assessment.

## Protocol

1. **State your claim** in a form that's verifiable. Vague claims ("this might work")
   can't be calibrated. Make it specific: "This approach will pass all tests on the
   first run" or "The root cause is X."

2. **Assign a probability.** Use granular percentages, not buckets:
   - 50% = coin flip, you genuinely don't know
   - 60-70% = leaning toward, but wouldn't be surprised if wrong
   - 80-90% = confident, would be surprised if wrong
   - 95%+ = very confident, would need strong evidence to update

3. **Justify the number.** What evidence supports this confidence level? What's the
   reference class (how often do similar things turn out this way)?

4. **Pre-commit to updating.** State specifically:
   - What evidence would move you UP (toward more confident)?
   - What evidence would move you DOWN (toward less confident)?
   - What would make you ABANDON this position entirely?

5. **Distinguish uncertainty types:**
   - Aleatory (irreducible randomness — can't be reduced by more information)
   - Epistemic (knowledge gap — could be reduced by investigation)
   If it's epistemic, is it worth investigating before proceeding?

## Output format

```
CLAIM: [specific, verifiable statement]
CONFIDENCE: [X%] — because [evidence and reference class]
WOULD INCREASE IF: [specific evidence]
WOULD DECREASE IF: [specific evidence]
WOULD ABANDON IF: [specific evidence]
UNCERTAINTY TYPE: [aleatory / epistemic / mixed]
```
