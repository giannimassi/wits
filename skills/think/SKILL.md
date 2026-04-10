---
name: thinking-tools
description: >
  Composable reasoning primitives for structured thinking. Use when facing a hard
  decision point, evaluating competing options, auditing assumptions, assessing risk,
  or any situation where "thinking harder" would help. Especially useful when injected
  into subagent prompts for implementation, review, or analysis tasks. Trigger on:
  thinking tools, reason through, think carefully, evaluate options, audit assumptions,
  pre-mortem, steelman, devil's advocate, red team, confidence check, decompose,
  or when dispatching agents that need structured reasoning.
---

# Thinking Tools

A toolkit of ~12 composable reasoning primitives drawn from intelligence analysis, cognitive science,
philosophy, and decision theory. Each primitive is a self-contained protocol that can be used
independently or combined.

## How to use these tools

There are two modes:

**Self-triggered (agent decides)**: When you hit a decision point, ambiguity, or feel uncertain,
pick the appropriate primitive from the catalog below and follow its protocol. You don't need
permission — if the situation calls for structured thinking, use it.

**Injected by orchestrator**: When dispatching a subagent for a tricky task, include specific
primitives in the prompt: "Use the pre-mortem and assumption-audit primitives from your thinking
tools before finalizing your approach."

## Output discipline

The primitives are **thinking scaffolding, not output format.** Output verbosity is controlled
by the `--explain` flag (default: `none`):

| Level | Behavior |
|-------|----------|
| `none` (default) | Clean results only. Do not label sections with primitive names. Show conclusions, not worksheets. |
| `scaffold` | Tag which primitives were used (e.g., "Used: assumption-audit, pre-mortem") but still present clean conclusions. |
| `full` | Show all intermediate reasoning artifacts — the full scoring tables, failure mode lists, and working. |

**Default (`none`) rules:**

- **Do not label sections** with primitive names ("Step 1: Assumption Audit", "Steelman phase").
  The consumer doesn't need to know which framework you used — they need the insight.
- **Show conclusions, not worksheets.** If you ran a matrix evaluation, present the recommendation
  and the key trade-offs — not the full scoring table. If you did a pre-mortem, present the
  top risks and mitigations — not all 5 failure modes with P/I/D ratings.
- **Be concise.** The primitives help you think more carefully, not write more words. A
  well-reasoned paragraph is better than a wall of structured artifacts.

**Triggers for `full` mode:** When the consumer explicitly asks for structured reasoning output
("show your work", "walk me through your thinking", "use thinking tools and show the output",
"--explain full"), present the full intermediate artifacts.

## Triage: Which tool do I need?

Read `references/triage.md` for the full decision guide. Quick reference:

| Situation | Reach for |
|-----------|-----------|
| About to commit to an approach | `assumption-audit` + `pre-mortem` |
| Choosing between alternatives | `hypothesis-generation` + `matrix-evaluation` |
| Reviewing someone else's work | `disconfirmation` + `steelman` |
| Something feels off but you can't say why | `perspective-rotation` + `inversion` |
| Making a prediction or estimate | `confidence-calibration` + `base-rate-anchoring` |
| Complex system with unclear dynamics | `causal-mapping` + `decomposition` |
| Need to stress-test a plan | `pre-mortem` + `disconfirmation` |
| Debugging a hard problem | `decomposition` + `assumption-audit` |

## The Primitives

Each primitive lives in `references/primitives/<name>.md`. They follow a consistent format:
trigger conditions, steps, output format. Each is ~200-400 words — small enough to hold in
context alongside your main task.

### Catalog

1. **assumption-audit** — Surface and stress-test unstated assumptions. From CIA Key Assumptions Check + Argyris Ladder of Inference.
2. **disconfirmation** — Actively seek evidence against your current position. From Consider-the-Opposite + ACH.
3. **perspective-rotation** — Look at the problem from 3+ different stakeholder/adversary viewpoints. From Red Team Analysis + DSRP Perspectives.
4. **pre-mortem** — Assume the plan has failed. Why? From Gary Klein's prospective hindsight.
5. **hypothesis-generation** — Force multiple competing explanations before committing to one. From Strong Inference + IBE.
6. **steelman** — Build the strongest possible version of the opposing argument before critiquing. From Dennett's 4 steps.
7. **decomposition** — Break an overwhelming problem into independently solvable pieces. From Fermi estimation + Starbursting.
8. **confidence-calibration** — Assign explicit probabilities and track what would change your mind. From Superforecasting + Brier scores.
9. **causal-mapping** — Trace cause-and-effect chains, identify feedback loops and leverage points. From system dynamics + Meadows.
10. **matrix-evaluation** — Score options against weighted criteria with sensitivity analysis. From decision matrices + ACH.
11. **base-rate-anchoring** — Start from the outside view before considering case-specific details. From Reference Class Forecasting + Kahneman.
12. **inversion** — Solve the opposite problem. "How would I make this worse?" From Jacobi + Charlie Munger.

## Combining Primitives

Primitives compose naturally. Common combinations:

- **Full decision audit**: `assumption-audit` → `hypothesis-generation` → `matrix-evaluation` → `pre-mortem`
- **Adversarial review**: `steelman` → `disconfirmation` → `perspective-rotation`
- **Estimation pipeline**: `decomposition` → `base-rate-anchoring` → `confidence-calibration`
- **Root cause analysis**: `causal-mapping` → `assumption-audit` → `inversion`

The output of one primitive can feed the next. An assumption-audit might surface assumptions
that become hypotheses for hypothesis-generation. A pre-mortem might reveal risks that
causal-mapping can trace to root causes.

## Important

These tools enhance thinking — they don't replace judgment. Skip a tool if it genuinely adds
no value to the current situation. Using all 12 on a trivial decision is worse than using none.
The triage table above helps calibrate when structured thinking earns its keep.
