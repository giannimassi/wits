# Decomposition

From Fermi estimation + Starbursting (IC 6W technique) + DSRP Systems (Cabrera).
Break an overwhelming problem into pieces small enough to reason about independently.

## When to use

A problem feels too big, too vague, or too interconnected to tackle directly.
Also useful when you realize you're guessing at a number instead of estimating it.

## Protocol

1. **Identify the top-level question.** What exactly are you trying to answer, build,
   or estimate?

2. **Decompose using the method that fits:**

   **For estimates (Fermi):** Break the quantity into multiplicative components you can
   estimate independently. "How many piano tuners in Chicago?" becomes population ×
   piano ownership rate × tunings per year ÷ tunings per tuner per year.

   **For understanding (Starbursting/6W):** Generate questions across all six interrogatives:
   Who? What? Where? When? Why? How? Each answer spawns sub-questions. Breadth before depth.

   **For systems (DSRP):** Apply four operations:
   - Distinctions: What is this? What is it NOT?
   - Systems: What are its parts? What is it part of?
   - Relationships: What does it affect? What affects it?
   - Perspectives: Who sees this differently? Why?

3. **Check independence.** Are your sub-problems actually independent, or do they interact?
   Interacting sub-problems need to be solved together or in sequence.

4. **Solve pieces, then reassemble.** Work each piece, then combine. Check whether the
   reassembled answer makes sense as a whole (sanity check against intuition).

## Output format

```
TOP-LEVEL QUESTION: [what you're solving]
DECOMPOSITION METHOD: [Fermi / Starbursting / DSRP]
SUB-PROBLEMS:
1. [piece] — [estimate/answer]
2. [piece] — [estimate/answer]
3. ...
DEPENDENCIES: [which pieces interact]
REASSEMBLED ANSWER: [combined result]
SANITY CHECK: [does this pass the smell test?]
```
