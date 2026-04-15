---
name: discuss
description: "Set up a team of AI agents to discuss any topic through facilitated conversation. Use this skill whenever the user wants to explore an idea with multiple perspectives, debate a decision, brainstorm solutions, get diverse viewpoints on a problem, weigh trade-offs, or have agents discuss something collaboratively. Triggers on: 'discuss', 'debate', 'let\\'s think about', 'explore the idea of', 'what do you think about', 'pros and cons of', 'should we', 'help me decide', 'brainstorm with a team', 'roundtable', 'get multiple perspectives', 'multi-perspective analysis', or any request for structured group deliberation on a topic."
---

# /discuss — Multi-Agent Discussion Framework

Set up a team of AI agents to have a structured, time-limited discussion on any topic. The agents discuss, debate, and explore the subject through facilitated conversation while you observe and optionally steer.

## Input

```
/discuss <topic> [--mode converge|explore] [--duration Nm] [--size small|medium|large|N] [--models mixed|all-opus|all-sonnet] [--from <path>]
```

| Flag | Default | Description |
|------|---------|-------------|
| `--mode` | `explore` | `converge` = reach a decision. `explore` = open-ended exploration |
| `--duration` | 10m (converge) / 15m (explore) | Discussion time budget (Phase 2 only) |
| `--size` | auto | Guest expert count. `small`=1-2, `medium`=2-3, `large`=3-4+, or integer 1-8. `0`=core team only |
| `--models` | `mixed` | `mixed`=Opus core + Sonnet experts. `all-opus` or `all-sonnet` |
| `--from` | none | Path to prior discussion dir for continuation (see `references/history.md`) |

## Workflow

### Step 1: Parse Arguments

Extract topic and flags from the user's input. Apply defaults for missing flags. If `--mode` is `converge`, default duration is 10m. If `explore`, 15m.

Generate a session ID: `discuss-$(date +%s)`

### Step 2: Load Prior Discussion (if --from)

If `--from` is provided, read `references/history.md` and follow the loading protocol. Load REPORT.md, argument-map.md, and team.json from the prior discussion.

### Step 3: Phase 0 — Intake

Dispatch a Sonnet intake agent using the prompt at `prompts/intake.md`. Pass the full raw user input as `{{raw_input}}`, plus any explicit flags as `{{mode}}`, `{{duration}}`, `{{size}}` (set to "unset" if not provided as flags).

The intake agent:
1. **Extracts embedded parameters from natural language** — "discuss X for five minutes" → duration=5, topic="X". "help me decide between A and B" → mode=converge. Explicit flags override natural language.
2. Asks 1-3 clarifying questions (present to user via AskUserQuestion)
3. Returns a refined topic brief + extracted parameters

The skill runner merges `extracted_params` from the intake agent with explicit flags (flags win). This means users can say things naturally:
- "discuss the meaning of light for five minutes" → explore mode, 5min, topic="the meaning of light"
- "help me decide between React and Vue for our dashboard" → converge mode, default duration
- "quick 3 minute brainstorm on team names" → explore mode, 3min

If the intake agent returns questions, present them to the user. After answers (or defaults accepted), the intake agent produces the final topic brief.

### Step 4: Phase 1 — Panel Selection & Recruiting

**Separation of concerns:** `/recruit` creates and caches individual experts. `/discuss` decides WHO should be on the panel. The steps below are discuss's responsibility — they call `/recruit` for per-persona create/fetch, but the selection algorithm lives here.

1. **Core team** (always present):
   - **Facilitator** (Opus) — read `<data-root>/experts/core/facilitator-knowledge.md`
   - **Cartographer** (Opus) — read `<data-root>/experts/core/cartographer-knowledge.md`
   - **Critical Lens** (Opus) — read `<data-root>/experts/core/critic-knowledge.md`

2. **Domain coverage** — identify needed voices by domain:
   - From the intake agent's topic brief, extract domain areas
   - For each domain, call `/recruit` (search → evaluate → offer → reuse/create) to get a primary expert
   - Number based on `--size` flag or auto-heuristic (1-2 domains → 1-2 experts, 3-4 → 2-3, 5+ → 3-4+)

3. **Stance diversity** — explicit anti-homogeneity step [NEW]:
   - After domain picks, classify each selected expert's `stance` (implied or explicit frontmatter field).
     Common stances: `analytical-structural`, `risk-averse-systems-thinker`, `high-risk-pragmatist`, `academic-theorist`, `lived-user`, `skeptic-of-expertise`, `contrarian-by-design`.
   - Check: are all experts the same stance class? (e.g. four flavors of "careful analytical professional")
   - **If panel is stance-homogeneous**: add at least one counterbalancing voice. Defaults by context:
     - Analytical-heavy panel + decision has a build-vs-analyze axis → add a `high-risk-pragmatist` (e.g. `high-velocity-indie-builder`)
     - Academic-heavy panel → add a practitioner with lived experience
     - Industry-heavy panel + topic is novel → add an outsider/contrarian
   - The point: the panel should have at least two stance classes represented before the discussion starts. **Diversity is not a bonus feature; it's a precondition for non-laundered consensus.**

4. **Model diversity** (laundered-certainty mitigation):
   - All-Sonnet personas share base-model priors. When a discussion has genuinely contested dimensions, assign at least one persona to a different model (`model: "opus"` in team.json) OR dispatch via a different subagent_type (codex/gemini) if available.
   - Per `--models` flag:
     - `mixed` (default): Opus for core team, Sonnet for most experts, **at least one expert on Opus** if panel size ≥ 3
     - `all-opus`: Opus for everyone
     - `all-sonnet`: Sonnet everywhere except core team

5. **Facilitator panel review** [NEW]:
   - Before locking the roster, dispatch the facilitator ONCE with the proposed panel + topic brief.
   - Prompt: "Here's the proposed panel: [list]. Topic: [brief]. Critique it: what stance is missing? Who would disagree with the emerging frame for reasons none of these people would voice? Answer in 3-5 sentences. If the panel is adequate, say 'adequate' and why."
   - If facilitator flags a gap: recruit one more expert to fill it (call `/recruit create` with the gap description) before proceeding. Max one additional recruit from this step — if the facilitator keeps flagging gaps after that, proceed anyway and note the limitation in the final report.

6. Present the assembled roster to the user: "Your discussion team: [names + roles + stances + models]"
   - Show the stance distribution explicitly
   - User can say "add <domain>" or "remove <name>" to customize
   - Once confirmed, write `team.json` to `tmp/discuss-<session-id>/`

### Step 5: Phase 2 — Discussion

This is the main discussion loop. **Read `references/orchestration.md`** for the complete implementation.

**Setup:**
1. Create session directory: `tmp/discuss-<session-id>/`
2. Write `timer.env` with `START_EPOCH=$(date '+%s')` and `DURATION_SEC=<duration in seconds>`
3. Initialize empty files: `transcript.md`, `argument-map.md`, `notes/shared.md`, `interjection.md`
4. If `--from` was provided, prepend the continuation context to `transcript.md`

**Timer:** Check time with `bash scripts/discuss-timer.sh tmp/discuss-<session-id>/timer.env` — returns JSON with `remaining_sec`, `phase`, etc.

**Opening:** Seed + react, not a parallel press release. The first domain expert (by roster order) drops a 2-sentence provocation; the remaining experts respond in ≤60 words each with one agreement + one push. Runs deterministically before the loop. See `references/orchestration.md` Section 0.

**Loop:** Follow the orchestration reference. The loop dispatches the facilitator each round, parses its ACTION, executes it, appends to transcript. Cartographer and critic fire on facilitator decision (`request_map_update` / `request_critic_review`); soft backstops at 8 / 10 turns prevent neglect.

**User interjection:** Between rounds, check if the user has sent a message. If so, write to `interjection.md` for the facilitator to process.

**Prompts:** Each agent is dispatched with its prompt template from `prompts/`:
- Facilitator: `prompts/facilitator.md` — returns ACTION JSON
- Cartographer: `prompts/cartographer.md` — returns argument map update
- Critic: `prompts/critic.md` — returns bias audit
- Domain experts: `prompts/participant.md` — with persona injected from expert registry

### Step 6: Phase 3 — Synthesis

Triggered when the facilitator returns `trigger_synthesis` or wrap-up phase forces it.

**Convergence mode:** Read `references/ngt-voting.md` and execute the NGT protocol:
1. Cartographer drafts options from argument map
2. All participants rank independently
3. Tally, detect splits, run final round if needed
4. Produce: decision + rationale + dissent + confidence

**Exploration mode:** The skill runner synthesizes directly:
- Ideas map: main threads explored (as nested bullet list)
- Key insights: non-obvious findings
- Open questions: what deserves further investigation
- Surprising connections: unexpected links
- Recommended next steps

Both modes compile: full transcript, argument map, agent notes appendix.

### Step 7: Save Discussion History

Read `references/history.md` and follow the saving protocol:
1. Copy all artifacts from `tmp/discuss-<session-id>/` to `<data-root>/discussions/<date>-<slug>/`
2. Write REPORT.md (the synthesis output), meta.json
3. Update `<data-root>/discussions/INDEX.md`
4. Clean up tmp directory

Present the final output to the user.

## Key Rules

- **The facilitator controls the discussion.** The skill runner handles mechanics (timer, files, dispatch). The facilitator handles ALL content decisions (who speaks, about what, when to synthesize). The skill runner MUST dispatch the facilitator before every content round — never decide to run a parallel round, directed turn, or trigger synthesis without the facilitator's ACTION directing it.
- **Use `/recruit` for experts.** You MUST invoke the `/recruit` skill for expert creation, not create personas inline. The recruit skill handles caching in `<data-root>/experts/`, INDEX.md updates, and reuse checking. Inline-created experts are lost after the session.
- **Platform requirement.** This skill requires the Task tool (for spawning subagents). It works in Claude Code but NOT in Codex CLI or Gemini CLI. The `/think` and `/recruit` skills work on all platforms.
- **Graceful degradation without recruit.** If `/recruit` is unavailable, discuss will use generic participant roles instead of domain-specific expert personas. Quality degrades but the skill still functions.
- **Check timer before every facilitator dispatch.** The timer MUST be read via `scripts/discuss-timer.sh` before EVERY facilitator dispatch. The timer JSON determines the facilitator's phase context, which directly affects its behavior. Never skip the timer check.
- **Fresh instances per turn.** Every agent dispatch is a new context. The transcript IS the memory. No persistent agent state.
- **Neutrality constraint.** The facilitator cannot express content positions — process guidance only.
- **Time awareness.** Every agent prompt includes current phase and remaining time. Agents adjust behavior accordingly.
- **Progressive disclosure.** This SKILL.md is the entry point. Heavy logic lives in `references/`:
  - `references/orchestration.md` — the full discussion loop (686 lines)
  - `references/ngt-voting.md` — NGT convergence protocol (211 lines)
  - `references/history.md` — saving and loading discussions (204 lines)

## Error Handling

- **Malformed facilitator ACTION:** Retry once with error prompt. If still malformed, skip turn.
- **Agent timeout/crash:** Log `[agent X did not respond]` to transcript, continue.
- **2 consecutive failures:** Force synthesis.
- **Wrap-up without synthesis:** If facilitator hasn't triggered synthesis within 2 turns of wrap-up, force it.
- **Background research in late/wrap-up:** Rejected automatically. Results from earlier research still injected.

## File Structure

```
.claude/skills/discuss/
├── SKILL.md                 # This file — entry point (<500 lines)
├── references/
│   ├── orchestration.md     # Discussion loop implementation (686 lines)
│   ├── ngt-voting.md        # NGT convergence protocol (113 lines)
│   └── history.md           # Discussion saving + --from loading (112 lines)
├── prompts/
│   ├── intake.md            # Intake agent — clarifying questions
│   ├── facilitator.md       # Facilitator — ACTION schema + turn management
│   ├── cartographer.md      # Reasoning cartographer — Toulmin mapping
│   ├── critic.md            # Critical lens — bias audit + devil's advocacy
│   └── participant.md       # Domain expert template (persona injected)
├── scripts/
│   └── discuss-timer.sh     # Timer check utility (JSON output)
└── evals/
    └── evals.json           # Test cases

<data-root>/experts/           # Shared expert registry (via /recruit skill)
├── core/                     # Core team knowledge bases
│   ├── facilitator-knowledge.md
│   ├── cartographer-knowledge.md
│   └── critic-knowledge.md
└── <domain-experts>.md       # Cached expert personas
```
