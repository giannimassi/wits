# Base-Rate Anchoring

From Reference Class Forecasting (Kahneman & Lovallo, 2003; Flyvbjerg, 2004) + the Outside View.
Kahneman's own team estimated a textbook would take 18-30 months. The reference class of similar
projects showed 7-10 years. It took 8 years.

## When to use

You're estimating something — time, cost, probability, effort — and have detailed knowledge
of the specific case. That detailed knowledge is exactly what makes you overconfident.

## Protocol

1. **Identify the reference class.** What category of things is this an instance of?
   "This software project" → "software projects of similar scope and team size."
   Be specific enough to be useful, broad enough to have data.

2. **Find the base rate.** What's the typical outcome for this reference class?
   - How long do they usually take?
   - How often do they succeed?
   - What's the typical range of outcomes (not just the average)?

3. **Make your inside-view estimate.** Based on the specific details of THIS case,
   what do you think the answer is?

4. **Compare and adjust.** Your final estimate should anchor on the base rate and
   adjust for case-specific factors. Not the other way around.
   - If your inside view differs significantly from the base rate, you need a
     SPECIFIC, ARTICULABLE reason why this case is different
   - "We're better / smarter / more motivated" is not a valid reason (everyone thinks that)
   - Valid reasons: genuinely different technology, proven team track record on similar
     projects, structural differences in the problem

5. **State your final estimate** with the base rate visible for context.

## Output format

```
REFERENCE CLASS: [what category this belongs to]
BASE RATE: [typical outcome for this class]
INSIDE VIEW: [my case-specific estimate]
DELTA: [how much my estimate differs from the base rate]
JUSTIFICATION FOR DELTA: [specific, articulable reasons — or "none, adjusting toward base rate"]
FINAL ESTIMATE: [anchored on base rate, adjusted for justified factors]
```
