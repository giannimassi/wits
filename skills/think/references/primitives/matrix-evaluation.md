# Matrix Evaluation

From weighted decision matrices (Pugh, 1991) + Analysis of Competing Hypotheses (Heuer, CIA).
Replaces gut-feel comparison with structured scoring. The sensitivity analysis at the end
is where the real insight lives.

## When to use

You have 2+ options to choose between and the decision isn't obvious. Especially useful
when different options win on different criteria and you need to weigh trade-offs.

## Protocol

1. **List your options** (2-5 is ideal; more than 5, filter first).

2. **Define evaluation criteria.** What dimensions matter? Common ones:
   - Feasibility, impact, risk, cost, time, maintainability, reversibility
   - Include at least one criterion you'd rather ignore (it's probably important)

3. **Weight the criteria.** Assign relative importance (must sum to 100% or use 1-5 scale).
   This is where your values become explicit instead of hidden.

4. **Score each option** against each criterion (1-5 or 1-10 scale).
   - Score independently: don't let a high score on one criterion bias another
   - Be specific about WHY you gave each score

5. **Calculate weighted totals.** Option score = Σ(criterion weight × criterion score).

6. **Run sensitivity analysis.** This is the critical step most people skip:
   - Which criterion's weight, if changed, would flip the winner?
   - Which single score, if revised, would change the outcome?
   - If you're wrong about your top-weighted criterion, does the answer change?

## Output format

```
OPTIONS: [A, B, C]
CRITERIA (weighted):
  [criterion 1] (W%) | [criterion 2] (X%) | [criterion 3] (Y%) | ...

SCORES:
  Option A: [s1] | [s2] | [s3] | ... → TOTAL: [weighted sum]
  Option B: [s1] | [s2] | [s3] | ... → TOTAL: [weighted sum]
  Option C: [s1] | [s2] | [s3] | ... → TOTAL: [weighted sum]

WINNER: [highest scoring option]
SENSITIVITY: [what would have to change to flip the result]
DECISION: [final choice, accounting for anything the matrix can't capture]
```
