# Hypothesis Generation

From Platt's Strong Inference (1964) + Inference to Best Explanation (Peirce/Lipton).
The power comes from forcing multiple candidates BEFORE committing — elimination is
stronger than confirmation.

## When to use

You're diagnosing a problem, explaining an observation, or choosing an approach.
The natural instinct is to lock onto the first plausible explanation. This tool prevents that.

## Protocol

1. **State the observation or question** clearly. What are you trying to explain or decide?

2. **Generate 3+ competing hypotheses.** Rules:
   - Each must be genuinely plausible, not strawmen
   - At least one should challenge your initial instinct
   - Include at least one "uncomfortable" hypothesis (the explanation you hope isn't true)
   - If you can only think of 2, try inversion: "What would make the OPPOSITE of my
     first hypothesis true?"

3. **Identify discriminating evidence.** For each pair of hypotheses, what evidence
   would support one but not the other? This is the key step — non-discriminating
   evidence (consistent with all hypotheses) doesn't help you decide.

4. **Evaluate and rank.** Score each hypothesis by explanatory virtues:
   - Scope: how much of the evidence does it explain?
   - Simplicity: how many assumptions does it require?
   - Coherence: does it fit with what you already know?
   - Predictive power: what does it predict that you can check?

5. **Select, but hold loosely.** Pick the best-supported hypothesis as your working
   theory, but note what would cause you to switch to an alternative.

## Output format

```
QUESTION: [what are you trying to explain/decide?]
HYPOTHESES:
  H1: [description] — explanatory score: [scope/simplicity/coherence/prediction]
  H2: [description] — explanatory score: ...
  H3: [description] — explanatory score: ...
DISCRIMINATING EVIDENCE: [what distinguishes H1 from H2? H1 from H3?]
WORKING THEORY: [best-supported hypothesis]
SWITCHING CONDITION: [what would make you abandon this for an alternative]
```
