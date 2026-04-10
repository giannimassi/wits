# wits

Composable reasoning skills for AI agents. Three skills that make Claude Code (and compatible agents) think harder when it matters.

Follows the [Agent Skills](https://agentskills.io) open standard. Works with Claude Code, Codex CLI, and any compatible agent.

## What's in the box

### `think` — 12 reasoning primitives

Structured thinking tools drawn from intelligence analysis (CIA SATs), cognitive science, philosophy, and decision theory. Each primitive is a self-contained protocol that an agent can apply independently or chain together.

| Primitive | What it does |
|-----------|-------------|
| assumption-audit | Surface and stress-test unstated assumptions |
| disconfirmation | Actively seek evidence against your current position |
| perspective-rotation | Look at the problem from 3+ different viewpoints |
| pre-mortem | Assume the plan has failed. Why? |
| hypothesis-generation | Force multiple competing explanations before committing |
| steelman | Build the strongest version of the opposing argument |
| decomposition | Break an overwhelming problem into independent pieces |
| confidence-calibration | Assign probabilities and track what would change your mind |
| causal-mapping | Trace cause-and-effect chains and feedback loops |
| matrix-evaluation | Score options against weighted criteria |
| base-rate-anchoring | Start from the outside view before case-specific details |
| inversion | Solve the opposite problem ("How would I make this worse?") |

The agent picks the right primitive(s) automatically based on a triage table, or you can inject specific ones into subagent prompts.

### `discuss` — facilitated multi-agent discussion

Spawns a team of AI agents to have a structured, time-limited discussion on any topic. Includes a facilitator, reasoning cartographer, critical lens, and domain experts recruited on the fly.

```
/discuss "Should we rewrite the billing system?" --mode converge --duration 10m
```

Requires Claude Code (uses the Task tool for subagent dispatch).

### `recruit` — expert persona recruitment

Create, cache, and reuse domain expert personas. Experts persist across sessions and are shared between skills.

```
/recruit create "PostgreSQL migration specialist"
/recruit search "database"
/recruit list
```

## Install

```bash
# Install all three skills
npx skills add giannimassi/wits@skills/think
npx skills add giannimassi/wits@skills/discuss
npx skills add giannimassi/wits@skills/recruit

# Or install just the one you need
npx skills add giannimassi/wits@skills/think
```

## Examples

**Engineering: "Should we rewrite this in Rust?"**
```
Use thinking tools to evaluate whether we should rewrite the hot path in Rust.
```
The agent runs assumption-audit (what are we assuming about the performance bottleneck?), base-rate-anchoring (what % of rewrites actually deliver the expected speedup?), and pre-mortem (if we do this and it fails, why?).

**Career: "Should I take this job offer?"**
```
Think carefully about whether I should leave my stable job for a Series A startup paying 30% more.
I have a mortgage and a kid starting school next year.
```
Triggers perspective-rotation (your future self, your partner, the startup's investors), assumption-audit (what does "stagnant" really mean?), and confidence-calibration (how certain are you about the startup's runway?).

**Business: "Should we enter this market?"**
```
/discuss "Should we launch a B2B product alongside our B2C offering?" --mode converge
```
Spawns domain experts (B2B SaaS, your industry, go-to-market strategy) and runs a structured discussion with synthesis and voting.

**Interpersonal: "How do I give difficult feedback?"**
```
Think through how to tell my co-founder that their technical decisions are slowing us down,
without damaging the relationship.
```
Uses steelman (what's the strongest case FOR their approach?) and perspective-rotation (how do they see their own decisions?).

**Research: "Which framework should we adopt?"**
```
/discuss "React Server Components vs Astro vs Next.js for our docs site" --size medium
```
Recruits framework-specific experts and runs a structured comparison with explicit trade-offs.

## How it works

**Think** is the core. 12 primitives, each ~200-400 tokens, composable in any combination. The agent auto-selects based on the problem type (choosing, validating, understanding, estimating, evaluating, creating) and stakes level.

**Discuss** orchestrates multi-agent conversations with structured roles (facilitator, cartographer, critic, domain experts). It uses **recruit** to assemble the right experts for the topic.

**Recruit** maintains a persistent expert registry. Personas are cached to disk and reused across sessions. Expert knowledge accumulates over time.

## Data storage

Persistent data (expert personas, discussion transcripts) is stored at:
- `~/.local/share/wits/` (default)
- Override with `WITS_DATA_DIR` environment variable

Think is stateless and stores nothing.

## Platform compatibility

| Skill | Claude Code | Codex CLI | Gemini CLI |
|-------|------------|-----------|------------|
| think | Yes | Yes | Yes (with adapter) |
| recruit | Yes | Yes | Yes |
| discuss | Yes | No (needs Task tool) | No (needs Task tool) |

## Roadmap

**v0.1** (current) — 12 primitives, discussion framework, expert recruitment

**v0.2** — expanded eval corpus, description optimization, confidence scoring improvements

**v1.0** — stable release with 15+ primitives, custom primitive extension API, cross-platform discuss fallback

## Uninstall

```bash
npx skills remove think
npx skills remove discuss
npx skills remove recruit
```

To also remove cached data:
```bash
rm -rf ~/.local/share/wits/
```

## License

MIT
