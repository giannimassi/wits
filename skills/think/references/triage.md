# Triage: Selecting the Right Thinking Tool

Inspired by Cynefin (problem-type classification) and the Pherson-Heuer SAT taxonomy.
The goal: spend 10 seconds picking the right tool rather than 10 minutes applying the wrong one.

## Step 1: What kind of thinking problem is this?

| Problem Type | Signal | Go-to Primitives |
|-------------|--------|-------------------|
| **Choosing** — multiple options, need to pick one | "Should we do A or B?" | `hypothesis-generation`, `matrix-evaluation`, `pre-mortem` |
| **Validating** — have a plan/belief, need to stress-test it | "Is this right?" "Will this work?" | `assumption-audit`, `disconfirmation`, `pre-mortem` |
| **Understanding** — something is unclear or confusing | "What's going on here?" "Why did this happen?" | `decomposition`, `causal-mapping`, `perspective-rotation` |
| **Estimating** — need to predict an outcome or quantity | "How long?" "How likely?" "How much?" | `base-rate-anchoring`, `decomposition`, `confidence-calibration` |
| **Evaluating** — reviewing someone else's work or argument | "Is this good?" "What's wrong with this?" | `steelman`, `disconfirmation`, `assumption-audit` |
| **Creating** — generating new ideas or approaches | "How could we solve this?" | `inversion`, `perspective-rotation`, `decomposition` |

## Step 2: How high are the stakes?

- **Low stakes** (easily reversible, limited blast radius): Use one primitive, keep it quick.
- **Medium stakes** (hard to reverse, affects others): Use 2-3 primitives in sequence.
- **High stakes** (irreversible, major consequences): Full pipeline — start with `assumption-audit`, apply 3-4 relevant primitives, end with `confidence-calibration`.

## Step 3: How much time/context do I have?

Each primitive adds ~200-400 tokens to your reasoning. If you're deep in a task and context
is precious, pick the single most impactful tool. If you're at a natural decision point
with room to think, chain 2-4 together.

## When NOT to use thinking tools

- The answer is obvious and low-stakes
- You're following a well-defined procedure with no judgment calls
- You've already applied these tools and are now just second-guessing yourself (that's anxiety, not analysis)
