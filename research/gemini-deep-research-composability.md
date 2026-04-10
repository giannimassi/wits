# The Architecture of Cognition: Designing Composable, Discoverable, and Shareable Critical Thinking Tools for Agentic AI Systems

> Source: Gemini Deep Research, 2026-04-10
> Query: Design space for composable, discoverable, shareable critical thinking tools for AI agents

## Summary

The transition from generative AI to agentic systems marks a shift from stateless interactions toward durable, goal-oriented compound systems. The core challenge is orchestration of specialized reasoning modules that can be discovered at runtime, composed into complex analytic workflows, and shared across heterogeneous agent frameworks.

## Tool Discovery and Semantic Routing

### Runtime Selection Patterns

| Framework | Discovery Mechanism | Primary Metadata | Routing Strategy |
|-----------|-------------------|-----------------|-----------------|
| LangChain | Registry-based | Function docstrings, JSON Schema | ReAct / OpenAI Tool Calling |
| CrewAI | Role-centric | Backstory, Goal, Task description | Hierarchical delegation |
| AutoGPT | Goal-driven | Prompt-embedded capability lists | Recursive autonomous loops |
| Claude Code | Progressive Disclosure | SKILL.md YAML frontmatter | Implicit activation via relevance |
| Semantic Kernel | Plugin-oriented | YAML descriptors, Semantic tags | Planner-based orchestration |
| OpenAI Assistants | Native Tool Calling | Function definitions (names/params) | Internal model-driven selection |

### Key Insight: Progressive Disclosure

Claude Code only loads skill name + short description (~100 tokens) at session start. Full SKILL.md loaded only when model determines relevance. This enables hundreds of skills without overwhelming context.

### Metadata Requirements for Discovery

- **Unique Name**: Gerund form (e.g., analyzing-hypotheses)
- **Explicit Trigger Phrases**: When to activate, not just what it does
- **Domain Constraints**: Data types/situations the tool is optimized for
- **Permission Schema**: Whether tool requires sensitive access (human-in-the-loop)

## Composable Tool Design (Unix Philosophy)

Small, sharp tools that do one thing well and work together through clean interfaces. Key patterns:

- **Middleware Chains**: Tools process agent's internal "thought" stream before action commitment
- **Recursive Decomposition**: Planning plugin breaks goals into sub-tasks, delegates to specialized sub-agents
- **Interoperability Layer**: Standardized message-passing between frameworks

Benefits: flexibility, scalability, maintainability (individual modules versioned/tested independently).

## Prompt-as-Tool Patterns

| Framework | Core Mechanism | Performance Lift |
|-----------|---------------|-----------------|
| ReAct | Interleaves Reasoning + Actions | Significant tool accuracy improvement |
| Tree of Thoughts | Multiple reasoning paths with backtracking | Near-human depth for complex strategy |
| Self-Refine | Iterative feedback/correction loop | ~4-7 points in reasoning accuracy |
| Reflexion | Verbal reflection on past failures | Improved multi-step planning |
| DSPy | Programmatic module optimization | Automated prompt optimization |
| Self-Consistency | Multi-path voting over reasoning chains | +12-18% over standard CoT |

## Agent Capability Sharing

### SKILL.md Format

- YAML frontmatter (name, description, license, model params)
- Core instructions (step-by-step procedural logic)
- Reference materials (additional text/assets loaded on demand)
- Deterministic scripts (Python/Bash for non-probabilistic tasks)

### Distribution Hubs

- LangChain Hub (prompts, chains, agent configs)
- OpenAI GPT Store (custom GPTs with Actions)
- Semantic Kernel Plugins (standardized modules)
- Model Context Protocol (MCP) (distributed tool servers)

## Critical Thinking Framework Survey

### Domain 1: Critical Thinking

| Framework | Origin | Core Mechanism | AI Suitability |
|-----------|--------|---------------|---------------|
| Paul-Elder | Foundation for Critical Thinking | 8 Elements & 10 Standards | High — metacognitive review |
| RED Model | Pearson / Watson-Glaser | Recognize, Evaluate, Draw | High — output gatekeeping |
| Toulmin Model | Stephen Toulmin | Claim, Data, Warrant, Backing | Medium — argument mapping |

### Domain 2: Decision-Making

| Framework | Origin | Core Mechanism | AI Suitability |
|-----------|--------|---------------|---------------|
| OODA Loop | Col. John Boyd (USAF) | Observe, Orient, Decide, Act | High — dynamic agents |
| Cynefin | Dave Snowden (IBM) | Context identification (5 domains) | High — meta-routing |
| RPD (Klein NDM) | Gary Klein | Pattern matching & mental simulation | Medium — needs "expert" memory |
| Pre-Mortem | Gary Klein | Prospective hindsight of failure | High — risk mitigation |

Cynefin as meta-tool: agent determines if situation is Clear, Complicated, Complex, or Chaotic, then selects appropriate reasoning strategy.

### Domain 3: Cognitive Debiasing

- **Confirmation Bias**: Force search for disconfirming evidence
- **Omission Bias**: "Could you be wrong?" / "What are you not seeing?"
- **Overconfidence**: Confidence calibration protocols

### Domain 4: Systems Thinking

| Technique | Core Mechanism | AI Suitability |
|-----------|---------------|---------------|
| Causal Loop Diagrams | Feedback loops (Reinforcing/Balancing) | Medium |
| Iceberg Model | Levels (Events, Patterns, Structure) | High |
| DSRP | Distinctions, Systems, Relationships, Perspectives | High |
| Stock-and-Flow | Accumulations and rates of change | Low |

### Domain 5: CIA Structured Analytic Techniques

- **ACH**: Matrix of hypotheses vs evidence, evaluate diagnosticity
- **Key Assumptions Check**: List, categorize as solid/unsupported/vulnerable
- **Red Teaming**: Adversarial perspective challenge
- **Devil's Advocacy**: Dedicated sub-agent challenges consensus

### Domain 6: Argument Mapping

- Mind Map Agents: Graph-based representations M(t)=(V(t),E(t),W(t),A(t))
- Rationale/MindMup: Break arguments into core components for inspection

### Domain 7: Metacognitive Tools

- **Confidence Calibration**: Expected Calibration Error (ECE) measurement
- **Epistemic Humility**: Cite provenance, acknowledge gaps, protect knowledge sanctuaries

## Quantitative Impact

| Methodology | Performance Gain | Mechanism |
|------------|-----------------|-----------|
| Self-Refine | +6.03% over few-shot | Iterative feedback loop |
| Self-Consistency | +12-18% over standard CoT | Majority voting |
| Constitutional AI | ~96% hallucination prevention | Constraint-based policy |
| Test-Time Compute (o1) | 9.3% → 74.4% (IMO exam) | Scaling inference-time budget |

Key finding: "RAG adds noise, but policy adds signal." Policy-driven governance: 87% accuracy vs 67% baseline vs 81% RAG.

## Design Implications for Wits Plugin

1. **Progressive disclosure** is the right discovery model (already used by Claude Code SKILL.md)
2. **Composability through clean interfaces**: each primitive takes context in, produces structured output
3. **Metadata-driven discovery**: trigger phrases in SKILL.md frontmatter are critical
4. **Self-Refine pattern validates our approach**: iterative structured thinking > single-pass reasoning
5. **Cynefin as meta-router**: the triage table in thinking-tools maps situations to primitives (same pattern)
6. **Confidence calibration is high-impact**: our confidence-calibration primitive is backed by +12-18% gains
