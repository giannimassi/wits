# Expert Persona Template

Use this template when creating a new domain expert for the expert registry.

## File Format

```markdown
---
name: <Display Name — e.g., "Dr. PostgreSQL", "Maya the Architect">
domain: <Primary domain — e.g., "PostgreSQL internals and migration patterns">
stance: <One of: analytical-structural | risk-averse-systems-thinker | high-risk-pragmatist | academic-theorist | lived-user | skeptic-of-expertise | contrarian-by-design | practitioner-not-credentialed>
tags: [<3-6 searchable tags — include the stance as a tag too: `stance-<name>`>]
thinking_style: <How they approach problems — e.g., "Systems thinker, traces second-order effects">
frameworks: [<Key mental models they use>]
looks_for: <What draws their attention — e.g., "Data integrity risks, rollback strategies">
blind_spots: <Known limitations — e.g., "Over-optimizes for consistency at expense of availability">
created: <YYYY-MM-DD>
last_used: <YYYY-MM-DD>
consumers: [<skills that have used this expert>]
source_tasks: [<plan files or discussions that spawned this expert>]
---

## Persona Prompt

<The full persona instruction that gets injected into the agent's context. Written in second person ("You are..."). Should be 100-300 words covering: who they are, how they think, what they prioritize, how they communicate.>

## Research Context

<Any deep-research findings that informed this persona. Include specific facts, patterns, techniques, or references that ground the expert's knowledge beyond base model training. If no deep research was done, note "Built from base model knowledge.">

## Performance Notes

<Optional. After the expert has been used in discussions, note what worked well and what didn't. Did they contribute unique insights? Were they too narrow? Did they miss important angles? This helps future reuse decisions.>
```

## Guidelines for Building Experts

1. **Specificity over breadth**: "PostgreSQL migration specialist" is better than "database expert." The narrower the domain, the more distinctive the contributions.

2. **Thinking style matters**: Two database experts with different thinking styles (e.g., "risk-averse, traces failure modes" vs "optimistic, looks for elegant solutions") will contribute differently to the same discussion. Pick the style that fits the discussion's needs.

3. **Blind spots are features**: Documenting blind spots isn't a weakness — it helps the facilitator know when to bring in a counterbalancing perspective. An expert who "over-optimizes for consistency" pairs well with one who "prioritizes availability."

4. **Frameworks ground reasoning**: Listing specific frameworks (CAP theorem, Toulmin model, Jobs-to-be-done) gives the agent concrete tools to use. Vague frameworks like "analytical thinking" don't add value.

5. **Research context compounds**: When deep research is done, save the findings here. Next time this expert domain is needed, the research carries forward — no re-research required.

6. **Name gives personality**: "Dr. PostgreSQL" performs differently than "Database Expert #1." Names create a character the agent can inhabit, leading to more distinctive contributions.

7. **Stance is a first-class field**: The `stance` field tells callers (like `/discuss`) what cognitive archetype this expert represents — independent of their domain. Two PostgreSQL experts can have the same domain but opposite stances (one `risk-averse-systems-thinker`, one `high-risk-pragmatist`). `/discuss`'s panel-selection algorithm uses this field to prevent stance-homogeneous panels (where all voices implicitly share the same worldview). If the stance genuinely doesn't fit one of the listed options, add a new one — but prefer the existing taxonomy for discoverability.
