# Causal Mapping

From system dynamics (Forrester/Meadows), causal loop diagrams, and Meadows' 12 Leverage Points.
Makes invisible feedback loops and delayed effects visible.

## When to use

You're dealing with a system where actions have non-obvious consequences, things that
"should work" don't, or the same problems keep recurring despite fixes.

## Protocol

1. **Identify the key variables.** What are the 5-10 things that matter in this system?
   Include both the things you're trying to change and the things that resist change.

2. **Map the causal links.** For each pair of variables, ask:
   - Does A affect B? (direction)
   - Is the effect reinforcing (+) or balancing (-)? 
     - Reinforcing: more A leads to more B (or less A leads to less B)
     - Balancing: more A leads to less B
   - Is there a delay? (effects that take time to materialize are the most dangerous)

3. **Identify loops.** Trace paths that circle back:
   - **Reinforcing loops (R):** self-amplifying — growth or collapse
   - **Balancing loops (B):** self-correcting — stabilize or resist change
   
4. **Find leverage points.** Where in the system would a small change have the biggest
   effect? Meadows' hierarchy (from weakest to strongest):
   - Weakest: adjusting parameters (numbers, thresholds)
   - Moderate: changing feedback loops, information flows, rules
   - Strongest: changing goals, paradigms, or the system's ability to self-organize

5. **Check for unintended consequences.** Trace your proposed intervention through the
   map. What second and third-order effects does it trigger?

## Output format

```
KEY VARIABLES: [list]
CAUSAL LINKS:
  A → (+) → B [delay: none/short/long]
  B → (-) → C
  ...
LOOPS:
  R1: A → B → C → A (reinforcing: [description])
  B1: X → Y → X (balancing: [description])
LEVERAGE POINTS: [where to intervene, ranked by strength]
UNINTENDED CONSEQUENCES: [second/third-order effects of proposed action]
```
