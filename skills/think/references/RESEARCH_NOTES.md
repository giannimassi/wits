# Primitive Selection Rationale

## Source Research

A Claude Research survey (613 sources, 20 min) cataloged **92 structured reasoning techniques**
across 7 domains: critical thinking, decision-making, cognitive debiasing, systems thinking,
intelligence community SATs, argument mapping, and metacognitive tools.

Full research saved at: `/tmp/critical-thinking-research-claude.md` (session artifact).
Gemini Deep Research was also initiated but results not yet extracted.

## Key Finding: Convergence Across Domains

Different fields independently invented structurally identical reasoning moves:
- Pre-mortem (cognitive psychology) = "What If?" analysis (intelligence community)
- Consider-the-Opposite (social psychology) = Devil's Advocacy (CIA) = Disconfirmation (philosophy)
- Reference Class Forecasting (behavioral economics) = Outside View (Kahneman) = Base Rate protocols

This convergence means **~12-15 composable primitives reconstruct 90%+ of the 92 frameworks**.

## Selection Criteria for the Initial 12

Each primitive in the v1 set was selected for:

1. **HIGH AI feasibility** — explicit procedural steps with defined inputs/outputs (65% of the 92
   frameworks rated HIGH; we selected only from that pool)
2. **Cross-domain recurrence** — appears in 3+ domains under different names (not domain-specific)
3. **Composability** — output of one can feed into another (pipeline-friendly)
4. **Minimal overlap** — each primitive covers a distinct reasoning move
5. **Proven in eval** — tested across software engineering, career, business, and interpersonal
   domains with measurable improvement over baseline

## The 12 and Their Lineage

| Primitive | Drawn From | Domains |
|-----------|-----------|---------|
| assumption-audit | CIA Key Assumptions Check, Argyris Ladder of Inference, SAST | IC, org learning, strategy |
| disconfirmation | Consider-the-Opposite (Lord 1984), ACH (Heuer), Falsification (Popper) | psychology, IC, philosophy |
| perspective-rotation | Red Team (CIA/military), DSRP Perspectives (Cabrera), Red Hat Analysis | IC, systems, military |
| pre-mortem | Gary Klein (2007), "What If?" (IC), prospective hindsight | cog psych, IC, decision science |
| hypothesis-generation | Strong Inference (Platt 1964), IBE (Peirce/Lipton), ACH | scientific method, epistemology, IC |
| steelman | Principle of Charity (Davidson), Dennett's 4 steps, Adversarial Collaboration | philosophy, rationalism |
| decomposition | Fermi estimation, Starbursting (IC 6W), DSRP Systems | physics, IC, systems |
| confidence-calibration | Superforecasting (Tetlock/GJP), Brier scores, CHAMPS KNOW | forecasting, IC, decision science |
| causal-mapping | Causal Loop Diagrams (Forrester/Meadows), System Archetypes (Senge) | system dynamics, org learning |
| matrix-evaluation | Decision Matrix (Pugh), ACH matrix, Morphological Analysis (Zwicky) | engineering, IC, policy |
| base-rate-anchoring | Reference Class Forecasting (Kahneman/Flyvbjerg), Outside View | behavioral econ, forecasting |
| inversion | Jacobi, Charlie Munger, Walton's critical questions (inverted) | mathematics, investing, logic |

## What Was Cut and Why

### HIGH feasibility but overlaps with existing primitives
- **Socratic Questioning** (Paul's 6 types) — overlaps with disconfirmation + assumption-audit
- **WRAP Framework** (Heath brothers) — essentially a wrapper around CTO + pre-mortem + base-rate
- **Structured Self-Critique** (IC) — overlaps with disconfirmation applied to own work
- **Indicators Validation** (IC) — too domain-specific (intelligence analysis)
- **Quadrant Crunching** (Pherson) — combinatorial variant of hypothesis-generation
- **IRAC** (legal reasoning) — domain-specific application of decomposition

### HIGH feasibility, candidates for v2
- **Scenario Analysis** (Shell/GBN) — 2x2 matrix futures exploration, useful for strategy
- **Wardley Mapping** — visual strategy tool, needs diagram output support
- **Network Analysis** (SNA) — entity relationship mapping, needs graph tools
- **Morphological Analysis** (Zwicky Box) — parameter space exploration, complements hypothesis-gen
- **Structured Analogies** — systematic historical comparison, needs retrieval
- **Implementation Intentions** (Gollwitzer) — if-then debiasing triggers for agents

### MEDIUM feasibility (conceptual, not procedural)
- **Cynefin** — used as triage inspiration but too conceptual for a standalone primitive
- **Bloom's Taxonomy** — calibration framework, influences triage design
- **OODA Loop** — conceptual cycle, already embedded in agent loop design
- **Reflective Equilibrium** — no clear termination criteria
- **Negative Capability** — dispositional, not procedural

### LOW feasibility (require human dynamics)
- **Crew Resource Management** — interpersonal authority gradients
- **Naturalistic Decision Making** — expertise-dependent pattern matching
- **Nominal Group Technique** — requires genuine group independence
- **Delphi Method** — requires real domain experts

## Expansion Roadmap

### v1.0 (current): 12 primitives
- Simple triage table (situation → primitives lookup)
- Tested across 4 domains with measurable improvement

### v1.1: 15-18 primitives
- Add scenario-analysis, morphological-analysis, structured-analogies
- Triage evolves: add "domain hints" (strategy tasks → scenario-analysis)
- Need: eval coverage for new primitives

### v2.0: 20+ primitives with smart routing
- Triage becomes a proper classifier, not a lookup table
- Agent-reported context (domain, stakes, time budget) feeds routing
- Primitives get "cost" metadata (token overhead, time overhead) for budget-aware selection
- Extension mechanism: users can add custom primitives that plug into routing

### Open Questions for Future Versions
- Should primitives have formal input/output schemas? (Gemini council feedback)
- Should there be a "primitive marketplace" where users share custom primitives?
- How do we measure which primitives are actually being used vs ignored?
- Should triage be adaptive (learn from which primitives helped in past sessions)?
