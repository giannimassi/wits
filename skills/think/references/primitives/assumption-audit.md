# Assumption Audit

From CIA Key Assumptions Check + Argyris Ladder of Inference. Surfaces beliefs you're
treating as facts without realizing it.

## When to use

You're about to commit to an approach, make a recommendation, or build on prior conclusions.
Any time you catch yourself thinking "obviously" or "of course" — that's an assumption.

## Protocol

1. **Extract**: List every assumption underlying your current position. Include:
   - What you believe about the inputs (data quality, completeness, meaning)
   - What you believe about the environment (constraints, stakeholder needs, timeline)
   - What you believe about causation (if I do X, Y will happen)
   - What you inherited from the prompt or prior context without questioning

2. **Rate each assumption**:
   - **Well-supported** — direct evidence exists
   - **Supported with caveats** — some evidence, but gaps
   - **Unsupported** — accepted without evidence (habit, convention, or inherited)

3. **Stress-test the load-bearing ones**: For each assumption rated "supported with caveats"
   or "unsupported" that your conclusion depends on, ask: "If this were wrong, would my
   conclusion change?" If yes, it's a critical vulnerability.

4. **Flag or fix**: Either gather evidence to support critical assumptions, or explicitly
   note them as risks in your output.

## Output format

```
ASSUMPTIONS:
- [assumption] — [well-supported | caveats | unsupported] — [load-bearing? y/n]
CRITICAL VULNERABILITIES: [list any unsupported + load-bearing assumptions]
ACTION: [what changes if these assumptions are wrong]
```
