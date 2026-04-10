# Disconfirmation

From Consider-the-Opposite (Lord et al., 1984) + Analysis of Competing Hypotheses (Heuer, CIA).
Research showed that "generate reasons you might be wrong" outperformed "be fair and unbiased"
(which had literally zero effect on actual bias).

## When to use

You've formed a position, selected an approach, or are about to approve something.
The natural tendency is to look for confirming evidence. This tool forces the opposite.

## Protocol

1. **State your current position** in one sentence.

2. **Generate 3-5 specific reasons** why this position could be wrong. Not vague doubts —
   concrete scenarios, evidence, or mechanisms. For each:
   - What specific evidence would you expect to see if this were wrong?
   - Does that evidence exist? Have you looked?

3. **Check for diagnosticity**: Is the evidence you're relying on actually diagnostic?
   Evidence that's consistent with BOTH your position AND the alternative isn't helping
   you decide — it's just making you feel more confident without justification.

4. **Verdict**: After genuinely engaging with the counter-evidence, has your confidence
   changed? State your updated position and confidence level.

## Output format

```
POSITION: [your current conclusion]
COUNTER-EVIDENCE:
1. [reason this could be wrong] — [evidence status: exists/absent/unchecked]
2. ...
DIAGNOSTICITY CHECK: [is your key evidence actually discriminating?]
UPDATED POSITION: [same/modified/reversed] — confidence: [low/medium/high]
```
