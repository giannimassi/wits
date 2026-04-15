# /discuss Skill — Orchestration Reference

**Scope**: Phase 2 (Discussion Loop) and Phase 3 (Synthesis). SKILL.md handles Phase 0 (Intake), Phase 1 (Recruiting), argument parsing, and file setup — then routes here.

**Assumed preconditions on entry:**
- `tmp/discuss-<session-id>/` exists with `timer.env`, empty `transcript.md`, empty `argument-map.md`, `notes/` dir
- `team.json` is written and contains the full roster
- `timer.env` contains `START_EPOCH`, `DURATION_SEC`, `MODE`
- Timer epoch is set to NOW (the moment Phase 2 begins — not from skill invocation)

---

## 1. Discussion Loop — Full Pseudocode

```
INIT:
  turn = 0
  consecutive_failures = 0
  converged = false
  wrap_up_turns = 0          # turns taken since entering wrap-up phase
  last_cartographer_turn = 0
  last_critic_turn = 0
  pending_research = {}      # map of agent_id -> research result (ready to inject)
  active_research_count = 0  # global cap: max 2 concurrent background tasks
  recruit_expert_count = 0   # per-session cap: max 2 mid-discussion recruits
  pending_missing_perspectives = []  # from last critic audit; injected into next facilitator context
  new_participant = null     # set when a recruit_expert was approved in the prior turn

REPEAT until converged == true:

  # Step 1: Check timer
  timer = run("bash scripts/discuss-timer.sh tmp/discuss-<id>/timer.env")
  # timer is JSON: {remaining_sec, remaining_human, elapsed_sec, phase, total_sec, synthesis_budget_sec}

  if timer.phase == "wrap-up":
    wrap_up_turns += 1
    if wrap_up_turns > 2 and not converged:
      FORCE SYNTHESIS (see Section 12)
      break

  # Step 2: Check for user interjection
  interjection = ""
  if file_exists("tmp/discuss-<id>/interjection.md") and file_nonempty("tmp/discuss-<id>/interjection.md"):
    interjection = read("tmp/discuss-<id>/interjection.md")
    # Do NOT clear yet — clear after facilitator acknowledges (see Section 7)

  # Step 3: Build facilitator context
  transcript_summary = build_transcript_summary(turn)
  # If turn > 15: last 10 turns in full + each earlier turn as one-line summary
  # Otherwise: full transcript

  # Compute pacing hint: expected turns ≈ duration_min / 2 (rough heuristic, 30s/turn minimum)
  expected_total_turns = max(5, DURATION_SEC / 120)
  expected_progress    = elapsed_sec / total_sec
  actual_progress      = turn / expected_total_turns
  pacing_hint = (
    "BEHIND_PACE: go deeper this turn — longer prompt, more substantive question, or request sidebar"
    if actual_progress < expected_progress - 0.15
    else "AHEAD_OF_PACE: tighten this turn — shorter prompt, prefer directed_turn, consider whether you're done"
    if actual_progress > expected_progress + 0.15
    else "ON_PACE"
  )

  facilitator_context = {
    topic_brief:      <from team.json>,
    mode:             <from team.json>,
    time_remaining:   timer.remaining_human,
    phase:            timer.phase,
    turn_number:      turn,
    expected_turns:   expected_total_turns,  # rough guide, not hard budget
    pacing_hint:      pacing_hint,
    team_roster:      <agent id + name + role, from team.json>,
    turn_stats:       <per-agent turn count, derived from transcript>,
    transcript_summary: transcript_summary,
    interjection:     interjection,  # empty string if none
    missing_perspectives: pending_missing_perspectives,  # from last critic audit, empty if none
    new_participant:  new_participant,  # name of just-added expert if any, null otherwise
    recruit_budget_remaining: 2 - recruit_expert_count  # how many more recruit_expert actions allowed
  }

  # Step 4: Dispatch facilitator
  action_raw = dispatch(facilitator_prompt, facilitator_context, model=opus)

  # Step 5: Parse ACTION JSON
  action = parse_action(action_raw)
  if action == MALFORMED:
    action_raw = dispatch(facilitator_prompt, facilitator_context + "\nYour response was not valid JSON. Return only the ACTION.", model=opus)
    action = parse_action(action_raw)
    if action == MALFORMED:
      log_to_transcript("[Facilitator response malformed — Turn " + turn + " skipped]")
      consecutive_failures += 1
      if consecutive_failures >= 2:
        FORCE SYNTHESIS (see Section 12)
        break
      continue

  consecutive_failures = 0  # reset on any valid action

  # Step 6: Handle interjection acknowledgment
  if interjection != "" and action.observed != nil:
    write("", "tmp/discuss-<id>/interjection.md")  # clear file
  # If interjection present but action.observed is missing: log warning, clear anyway on next round

  # Step 7: Execute the action
  turn += 1
  result = execute_action(action, timer)
  # execute_action handles all six action types — see Section 3

  # Step 8: Append result to transcript
  append_to_transcript(result)

  # Step 9: Cartographer seed (turn 1 only) + backstop (every ≥8 turns without update)
  # See Section 10 for the full rationale. The facilitator normally drives map updates
  # via request_map_update ACTION; this block only handles the seed and backstop.
  if turn == 1 and action.action != "request_map_update":
    # Seed: always run cartographer once after opening to initialize the map
    map_result = dispatch_cartographer(opening_transcript, empty_map)
    append_to_transcript(map_result)
    last_cartographer_turn = 1
  elif turn - last_cartographer_turn >= 8 and action.action != "request_map_update":
    # Backstop: facilitator has gone 8 turns without requesting a map update
    map_result = dispatch_cartographer(last_5_turns, current_map)
    append_to_transcript(map_result)
    last_cartographer_turn = turn

  # Step 10: Critic backstop (every ≥10 turns without review, mid/late phase only)
  # The facilitator is expected to request critic reviews via request_critic_review ACTION
  # when groupthink/anchoring is detected. This backstop only catches neglect.
  if (turn - last_critic_turn >= 10
      and action.action != "request_critic_review"
      and timer.phase in ("mid", "late")):
    critic_result = dispatch_critic(last_6_turns)
    append_to_transcript(critic_result)
    extract_missing_perspectives(critic_result)  # see Section 10 Post-Critic Hook
    last_critic_turn = turn

  # Step 11: Check convergence
  if action.action == "trigger_synthesis":
    converged = true
    break

  # Background research completions are injected into next dispatch for the requesting agent
  # (handled inside dispatch_participant — see Section 8)

END REPEAT

# Exit condition: converged OR time_phase == wrap-up with >2 turns elapsed
PROCEED TO PHASE 3 (see Section 14)
```

---

## 2. ACTION Parsing

The facilitator's full output is multi-line narrative + a final JSON line. Extract the ACTION by finding **the last line matching `^{.*}$`** (line that starts and ends with curly braces, no leading whitespace).

```
lines = split(facilitator_output, "\n")
action_line = last line where line.strip() matches regex ^{.*}$
if no match: ACTION is MALFORMED
else: action = JSON.parse(action_line)
     if JSON.parse fails: ACTION is MALFORMED
```

### Output-size guard [CRITICAL]

Before parsing the ACTION, check the facilitator's total output size. The facilitator's job is a single routing decision, not content generation — if it produces a lot of text, it has overstepped its role (possibly running its own mini-discussion, dispatching sub-agents, or generating synthesis). This has been observed in practice: a single runaway facilitator turn produced 16K output tokens and fabricated discussion content.

```
if len(facilitator_output) > 8000 chars  (roughly 2000 tokens):
    log "[Facilitator overflow at turn N: produced X chars, expected <6000]"
    treat as MALFORMED regardless of whether trailing JSON is present
    retry ONCE with prompt prefix:
        "Your prior response was too long. Output ONLY: 2 sentences analysis + 1 sentence rationale + 1 line ACTION JSON. Do NOT dispatch sub-agents, call tools, or generate discussion content. Nothing else."
    if retry also overflows (>8000 chars):
        log "[Facilitator repeatedly overflowed — forcing synthesis]"
        force synthesis with reason "facilitator repeatedly overflowed output constraints"
```

A well-behaved facilitator turn is typically 1500-3000 characters. Overflow signals the agent has gone off-rails, not that the turn needed more words.

**Required fields by action type:**

| Action | Required fields |
|--------|-----------------|
| `directed_turn` | `action`, `target` (agent id), `prompt` |
| `short_react` | `action`, `target` (agent id), `prompt` |
| `parallel_round` | `action`, `prompt` |
| `sidebar` | `action`, `agent_a`, `agent_b`, `topic`, `turns` |
| `request_map_update` | `action` |
| `request_critic_review` | `action` |
| `recruit_expert` | `action`, `domain`, `rationale`, `source_turn` |
| `trigger_synthesis` | `action`, `reason` |

**Optional on any action:** `"observed": "<string>"` — present only when an interjection was in the facilitator context and the facilitator is acknowledging it.

**Validation rules:**
- `target` must be an agent id present in `team.json`
- `agent_a` and `agent_b` must be different agent ids present in `team.json`; neither can be `facilitator` or `cartographer` or `critic`
- `turns` must be integer 2-6; if outside range, clamp to [2, 6]
- `trigger_synthesis` is rejected if current `timer.phase` is `"early"` — log warning, treat as MALFORMED and retry
- `recruit_expert` is rejected if current `timer.phase` is `"late"` or `"wrap-up"`, or if `recruit_expert_count >= 2` for this session — log reason, append `[recruit_expert rejected: <reason>]` to transcript, skip turn (do NOT increment turn counter, do NOT retry facilitator)

---

## 3. Turn Dispatch Per Action Type

### 3a. `directed_turn`

1. Look up target agent in `team.json` — get persona, model assignment
2. Load the agent's private notes file: `notes/<agent-id>-private.md` (empty if not yet created)
3. Check `pending_research` map — if entry exists for this agent, attach as `**Research result:** <findings>` and clear the entry
4. Build participant context (see participant prompt template): transcript + facilitator prompt + persona + private notes + timer JSON + research result if any
5. Dispatch with appropriate model (Opus for core team; Sonnet for domain experts unless `--models` flag overrides)
6. Parse participant response (see Section 9)
7. Return transcript entry

**Transcript format:**
```markdown
## Turn N — facilitator → <agent-name> [phase: <phase>, <remaining_human> remaining]
**Prompt:** "<facilitator's prompt text>"
### <agent-name>
<response content>

---
```

### 3a-b. `short_react` (brief reaction, ≤60 words)

Same dispatch mechanics as `directed_turn`, but participant is instructed to reply in **60 words or less**. Used by the facilitator when a quick reaction is more natural than a full turn — rebuttals, quick agreements with a push, late-phase tightening.

1. Look up target agent in `team.json`
2. Build participant context (persona, private notes, transcript, research-if-any) — same as `directed_turn`
3. Dispatch with a `style: "short_react"` flag in the participant context. The participant prompt template has a conditional block that enforces the cap.
4. After response: check `len(response.response.split()) <= 75` (15-word buffer for edge cases). If over-cap, log `[short_react over cap: <N> words — Turn <turn>]` and retry ONCE with a stricter prompt prefix: `"Your prior response was too long. Hard cap: 60 words. Respond in one or two short sentences. Nothing else."` If still over-cap, accept the response but note the overrun in the transcript.
5. Append to transcript:
   ```markdown
   ## Turn N — facilitator → <agent-name> [short_react, <phase>, <remaining_human> remaining]
   **Prompt:** "<facilitator's prompt text>"
   ### <agent-name> (≤60 words)
   <response content>

   ---
   ```

**Why enforce the cap at the skill-runner level, not just in the prompt**: participants routinely overshoot word caps. A single prompt instruction yields 150–200 words in practice. Rejecting-and-retrying once is the only reliable enforcement.

---

### 3b. `parallel_round`

Participants = all agents in `team.json` EXCEPT `facilitator`. Core team (cartographer, critic) participates unless the action is the opening round — in which case cartographer and critic are excluded (they listen first).

1. For each participant: build context same as directed_turn (persona, private notes, research results)
2. Dispatch ALL simultaneously (parallel Task calls)
3. Wait for all to complete
4. Collect responses. **Agents are blind to each other's responses within the round** — each agent receives only the transcript up to this point, not other agents' parallel responses
5. Append responses to transcript **in team.json roster order** (canonical ordering; see team.json `agents` array)
6. Process each response for `private_note` and `research_request` (see Sections 8 and 9)

**Transcript format:**
```markdown
## Opening Round (parallel)

### <agent-1-name> (<role>)
<response>

### <agent-2-name> (<role>)
<response>

---
```

For non-opening parallel rounds:
```markdown
## Parallel Round (Turn N)
**Prompt:** "<shared prompt>"

### <agent-1-name>
<response>

### <agent-2-name>
<response>

---
```

### 3c. `sidebar`

A mini-loop between two agents with the facilitator summarizing at the end.

1. Validate: `agent_a` and `agent_b` must be domain experts (not facilitator, cartographer, or critic). Clamp `turns` to [2, 6].
2. **Agent A first turn**: dispatch agent_a with sidebar prompt: `"You're in a 1:1 conversation with <agent_b_name> about: <topic>. <facilitator's prompt if any>"`
3. **Agent B response**: dispatch agent_b with: `"You're in a 1:1 conversation with <agent_a_name> about: <topic>.\n\n<agent_a_name>: <agent_a_response>"`
4. **Alternate** for `turns` total (agent A turn 1, agent B turn 1, agent A turn 2... etc.). Each agent receives the running sidebar exchange.
5. After all turns complete, dispatch facilitator (fresh call) with sidebar exchange text and instruction: "Write a 1-2 sentence summary of this sidebar exchange for the main group." Facilitator returns plain text summary (not an ACTION).
6. Append full exchange + summary to transcript

**Transcript format:**
```markdown
## Sidebar: <agent-a-name> ↔ <agent-b-name> (Turns N–M)
**Topic:** <topic>
<agent-a-name>: <msg>
<agent-b-name>: <msg>
<agent-a-name>: <msg>
**Summary (facilitator):** <1-2 sentence summary>

---
```

### 3d. `request_map_update`

1. Read current `argument-map.md`
2. Extract last 5 transcript entries
3. Dispatch cartographer with: last 5 turns + current map
4. Cartographer returns structured markdown update (new_claims, new_rebuttals, gaps, position_momentum)
5. Append update to `argument-map.md`
6. Append abbreviated notice to transcript

**Transcript format:**
```markdown
## Map Update (after Turn N)
### cartographer
<argument map update>

---
```

### 3e. `request_critic_review`

1. Extract last 6 transcript entries
2. Dispatch critic with those entries + critic prompt
3. Critic returns bias audit + observations
4. Append to transcript

**Transcript format:**
```markdown
## Critical Review (after Turn N)
### critic
<bias audit and observations>

---
```

### 3f. `trigger_synthesis`

1. Log the reason to transcript: `**Synthesis triggered:** <reason>`
2. Set `converged = true`
3. Exit the discussion loop
4. Proceed to Phase 3

### 3g. `recruit_expert` (mid-discussion panel expansion)

Invoked when the facilitator names a structural voice gap — usually in response to a `missing_perspectives` flag from the critic (see Section 11). The handler invokes `/recruit` to produce a persona, asks the user for approval, and appends to the roster.

**Preconditions** (validated in Section 2 before reaching this handler):
- `timer.phase` is `"early"` or `"mid"`
- `recruit_expert_count < 2` (per-session cap; initialize at loop start)

**Steps:**

1. **Invoke `/recruit create`** with the `domain` field from the action. Pass the `rationale` as additional context so the recruit skill can evaluate reuse of existing experts. Recruit follows its normal search → evaluate → offer → reuse/create flow and returns:
   ```
   {persona_name, persona_slug, stance, model_recommendation, persona_file_path}
   ```

2. **Ask the user** using the same mechanism SKILL.md Step 4 uses for initial roster confirmation. Prompt:
   ```
   Critical Lens flagged a missing perspective mid-discussion:
     Domain:    <action.domain>
     Rationale: <action.rationale> (surfaced at turn <source_turn>)

   Proposed expert: <persona_name> — <stance>, <model_recommendation>
   Knowledge base: <persona_file_path>

   Add to the panel? [y=add / n=decline / skip=ignore for now]
   ```

3. **On `y`**:
   - Append the persona to `team.json` `agents` array (end of list, preserving existing order)
   - Increment `recruit_expert_count`
   - Append to transcript:
     ```
     ## Panel Update (after Turn N)
     **Added:** <persona_name> (<role>) — model: <model>
     **Reason:** <action.rationale>
     **Flagged by:** Critical Lens, turn <source_turn>
     ---
     ```
   - The new expert is visible to `turn_stats`, fairness tracking, and all future dispatches from the next loop iteration onward.
   - On the next facilitator turn, inject an additional context field `new_participant: <persona_name>` so the facilitator can introduce them (e.g. via a targeted `directed_turn` asking them to speak to the gap).

4. **On `n` (decline)**:
   - Do NOT add to `team.json`
   - Increment `recruit_expert_count` anyway (declines count toward the cap to prevent repeated asks)
   - Append to transcript: `**Panel update declined:** user opted not to add <domain>; gap noted for final report`
   - Flag in session metadata so the synthesis includes "known gaps" section

5. **On `skip`**:
   - Do NOT add, do NOT increment the counter
   - Append to transcript: `**Panel update deferred:** <domain> held; critic may re-flag`

6. **Auto-approve mode** (`--auto-expand` flag, if set):
   - The first `recruit_expert` per session auto-approves without asking. Subsequent recruits still prompt.

**Turn counting:** a `recruit_expert` action does NOT increment the turn counter. It's a panel operation, not a content turn. Cartographer/critic auto-dispatches are also suppressed for this action.

**Failure modes:**
- `/recruit` cannot produce a viable persona → log `[recruit_expert for <domain> failed: <reason>]`, do not increment counter, continue
- User response timeout (>60s) → treat as `skip`, continue

---

## 4. Parallel Round Semantics

**Blind within round**: when dispatching a parallel round, every agent receives the transcript as it was **before** the round started. No agent sees another's in-progress parallel response. The combined output is canonical only after all agents have responded and the skill runner has appended them in roster order.

**Roster order**: defined by the `agents` array index in `team.json`. Index 0 is always `facilitator`, then `cartographer`, then `critic`, then guest experts in recruitment order. Facilitator does not participate in parallel rounds as a content contributor.

**Failure in parallel round**: if one agent fails or times out, log `[<agent-name> did not respond — Turn N skipped]` in that agent's slot and continue with the rest. A partial parallel round is better than a full skip.

---

## 5. Sidebar Execution — Detailed Steps

```
sidebar_exchange = []
current_speaker = agent_a

for i in range(action.turns):
  if i == 0:
    prompt = "You're in a 1:1 conversation with <agent_b_name> about: <topic>."
  else:
    prior = sidebar_exchange[-1]
    prompt = "<prior_speaker_name>: <prior_speaker_response>"

  response = dispatch_participant(current_speaker, context=transcript + sidebar_prompt + prior_exchange)
  sidebar_exchange.append({speaker: current_speaker, text: response.response})
  process_private_note(response, current_speaker)
  # No research_request processing in sidebars — phase-gated anyway

  current_speaker = agent_b if current_speaker == agent_a else agent_a

# Facilitator summary (separate dispatch — plain text, not ACTION)
summary_prompt = "Summarize this sidebar exchange in 1-2 sentences for the main group:\n\n" + format_exchange(sidebar_exchange)
summary = dispatch(facilitator_prompt_summary_variant, summary_prompt, model=opus)

# Append to transcript
append_to_transcript(format_sidebar(sidebar_exchange, summary, action.topic))
```

**Max sidebar turns**: 6. If `action.turns` > 6, clamp to 6 and log a warning.
**Min sidebar turns**: 2. A 1-turn sidebar is just a directed turn; reject and convert to `directed_turn` if `turns` < 2.

---

## 6. Transcript Management

**Transcript is append-only.** Never rewrite or truncate `transcript.md`. All appends go to the end.

**Initialization** (done in Phase 1 before loop starts):
```markdown
# Discussion: <topic>
**Mode:** <mode>
**Team:** <comma-separated agent names>
**Started:** <ISO timestamp>
**Duration:** <N minutes>

---
```

**Per-turn append**: use Edit tool targeting the last `---` as anchor, expanding below it. This prevents full-file rewrites on long transcripts.

**Turn numbering**: turns are numbered globally across the full discussion. Map updates, critic reviews, and sidebars get their own section headers (not turn numbers). Only facilitator-initiated agent speaking turns increment the turn counter.

**Observer note format** (when interjection present — appended before the turn that follows it):
```markdown
## Observer Note (before Turn N)
> User: "<interjection text>"

```

---

## 7. User Interjection Handling

**File path**: `tmp/discuss-<session-id>/interjection.md`

**Check timing**: interjections are checked at the top of each loop iteration, before facilitator dispatch. Messages sent during an active agent dispatch are picked up at the next loop iteration.

**Write mechanism**: the skill runner (main Claude Code context) monitors for user chat messages between loop iterations. When a new user message arrives:
1. Write the message to `interjection.md`
2. On the next loop iteration it will be picked up

**Facilitator acknowledgment flow**:
1. If `interjection.md` is non-empty: attach its contents to the facilitator context as `**Observer note:** <text>`
2. Facilitator must include `"observed": "<1-sentence acknowledgment>"` in its ACTION JSON
3. After facilitator returns: if `action.observed` is present, clear `interjection.md` (write empty string)
4. If `action.observed` is absent but interjection was sent: log warning, carry the interjection forward to the next facilitator turn (do not clear the file)

**What facilitator can do with an interjection**:
- Redirect the discussion toward the raised point
- Ask a specific agent to address it directly (via `directed_turn`)
- Table it with explanation (`"observed": "Tabling read replicas until we finish the current thread on schema migration"`)
- Trigger a `parallel_round` with the interjection as the prompt

**The user never becomes a discussion participant.** Interjections are always mediated by the facilitator.

---

## 8. Background Research Dispatch

**Trigger**: participant returns a `research_request` field in their structured response (see Section 9).

**Phase gate**: only dispatch research in `early` or `mid` phases. In `late` or `wrap-up`, silently drop the request and log: `[Research request from <agent> dropped — phase: <phase>]`

**Who can request**: only domain experts and the intake agent. If `cartographer`, `critic`, or `facilitator` include a `research_request`, drop it silently.

**Concurrent cap**: max 2 background research tasks globally at any time. Track with `active_research_count`. If at cap, queue the request and dispatch when a slot opens (at the top of the next loop iteration after a task completes).

**Dispatch**:
```
timeout_ms = min(
  estimated_minutes * 60000,
  (timer.remaining_sec - timer.synthesis_budget_sec) * 1000
)
if timeout_ms <= 0: drop request (no time left outside synthesis budget)
if research_request.estimated_minutes is missing: use 2 minutes

dispatch background Task(
  model: sonnet,
  prompt: "Research the following topic and return a concise summary (3-5 sentences max): <topic>",
  timeout: timeout_ms,
  run_in_background: true
)
active_research_count += 1
```

**Injection**: when the background task completes, store result in `pending_research[agent_id]`. On the agent's next turn (directed or parallel), attach as `**Research result:** <findings>` at the top of their context, then clear the entry.

**Failure**: if research task times out or crashes, log `[Background research for <agent> timed out — skipped]` to transcript. Do not inject anything.

---

## 9. Private Notes Extraction

**Participant response schema**:
```json
{
  "response": "<the contribution — goes into transcript>",
  "research_request": {"topic": "...", "estimated_minutes": 2},
  "private_note": "..."
}
```

**Parsing**:
1. Try to parse agent output as JSON
2. If valid JSON: extract `response`, `research_request`, `private_note` fields
3. If not valid JSON or `response` field missing: treat entire output as `response` with no research_request and no private_note

**Private note handling**:
```
if private_note is non-empty:
  timer_now = run("date -u '+%Y-%m-%dT%H:%M:%SZ'")
  append to notes/<agent-id>-private.md:
    "[Turn N — <timestamp>] <private_note text>"
```

**Notes file is loaded** in that agent's context on every subsequent dispatch (in addition to the transcript). Notes persist for the full discussion session.

**Notes appear in the final report** as an appendix section: one subsection per agent that wrote notes.

---

## 10. Cartographer and Critic — Facilitator-Driven with Soft Backstops

The cartographer and critic fire primarily on facilitator decision (`request_map_update` / `request_critic_review`), not on a fixed turn cadence. The facilitator knows the momentum of the discussion; a hardcoded "every 3 turns" fires mid-sidebar or mid-productive exchange and breaks the conversation.

Soft backstops protect against a facilitator that forgets to audit: if too many turns pass without a map update or critic review, the skill runner forces one after the current turn's main action is appended.

### Cartographer Seed (turn 1 only)

The cartographer MUST run once after the opening to seed the argument map — no facilitator permission required for this. This is the only hardcoded cartographer dispatch:

```
if turn == 1 AND action.action != "request_map_update":
  dispatch cartographer with:
    - the opening round transcript
    - empty argument-map.md
  append result to argument-map.md AND to transcript as:
    "## Map Update (after Turn 1 — seed)\n### cartographer\n<update>\n\n---"
  last_cartographer_turn = 1
```

After this seed, all further cartographer dispatches are facilitator-initiated (`request_map_update`) or triggered by the backstop below.

### Cartographer Backstop

```
turns_since_map_update = turn - last_cartographer_turn
if turns_since_map_update >= 8 AND action.action != "request_map_update":
  log "[Cartographer backstop fired — last update was turn <last_cartographer_turn>]"
  dispatch cartographer (same mechanics as Section 3d)
  last_cartographer_turn = turn
```

8 turns is the soft ceiling. The facilitator is expected to request map updates more often than that — the backstop is a safety net, not the primary mechanism. If it fires more than once per discussion, the facilitator prompt is failing to trigger map updates when it should (see facilitator.md "When to request a map update").

### Critic Backstop

```
turns_since_critic_review = turn - last_critic_turn
if turns_since_critic_review >= 10 AND action.action != "request_critic_review" AND timer.phase in ("mid", "late"):
  log "[Critic backstop fired — last review was turn <last_critic_turn>]"
  dispatch critic (same mechanics as Section 3e)
  last_critic_turn = turn
```

The critic backstop only fires in `mid` or `late` phase — early-phase audits are premature (groupthink can't form in 2 turns). If a discussion reaches wrap-up without a critic dispatch, the facilitator has failed its job; the skill runner logs it in the final report.

### Why No Fixed Cadence

Observed failure mode (4 transcripts, April 2026): fixed-cadence auto-dispatch interrupted productive sidebars and forced map updates in the middle of contested exchanges. The map update arrived when the group was mid-disagreement; by the time cartographer finished, the momentum was gone.

The facilitator sees the state of the discussion and decides when an audit would land well. This is the same pattern used elsewhere in the skill — process decisions belong to the facilitator, mechanics to the skill runner.

### Coordination Note

If both backstops fire on the same turn: dispatch cartographer first, then critic. Each receives the transcript state after the turn's main action was appended.

### Post-Critic Hook
See the next subsection for `missing_perspectives` handling — this runs after ANY critic dispatch (backstop, facilitator-initiated, or opening-audit via future extension).

### Post-Critic Hook: Missing Perspectives Extraction

After any critic dispatch (auto or manual via `request_critic_review`), parse the critic's JSON response for a `missing_perspectives` field:

```
critic_response = dispatch_critic(...)
if critic_response.missing_perspectives is a non-empty list:
  # Filter out perspectives the critic itself recommended holding (see critic.md Recommendation section)
  flaggable = [p for p in critic_response.missing_perspectives if not p.hold_recommendation]
  pending_missing_perspectives = flaggable
else:
  pending_missing_perspectives = []
```

`pending_missing_perspectives` is injected into the NEXT facilitator context (not the current turn's — the facilitator already dispatched). The facilitator reads it, decides whether to issue `recruit_expert`, and if so, names the gap in the action. After the facilitator acts on (or explicitly dismisses) the list, it is cleared:

```
# After parsing this turn's facilitator action:
if action.action == "recruit_expert":
  # facilitator acted on a flagged gap — clear the pending list
  pending_missing_perspectives = []
elif pending_missing_perspectives is non-empty AND action.action != "request_critic_review":
  # facilitator saw the list but chose a different action — keep carrying for one more turn, then auto-clear
  pending_missing_perspectives_age += 1
  if pending_missing_perspectives_age >= 2:
    pending_missing_perspectives = []
    pending_missing_perspectives_age = 0
```

This prevents the same flagged gap from badgering the facilitator forever while still giving it two turns to act before the signal decays.

---

## 11. Error Handling

### Agent Timeout or Crash

```
if dispatch returns timeout or exception:
  log_to_transcript("[<agent-name> did not respond — Turn " + turn + " skipped]")
  consecutive_failures += 1
  if consecutive_failures >= 2:
    FORCE SYNTHESIS (Section 12)
    break
  continue loop (do not increment turn counter for failed turns)
```

Consecutive failures only count against the limit if they are sequential. A successful turn resets `consecutive_failures = 0`.

### Malformed ACTION (Facilitator)

```
action = parse_action(raw_output)
if MALFORMED:
  retry_output = dispatch(facilitator_prompt + "\nYour response was not valid JSON. Return only the ACTION.", model=opus)
  action = parse_action(retry_output)
  if MALFORMED:
    log_to_transcript("[Facilitator response malformed — Turn " + turn + " skipped]")
    consecutive_failures += 1
    if consecutive_failures >= 2:
      FORCE SYNTHESIS
      break
    continue
```

### Malformed Participant Response

Participant responses that fail JSON parsing are not errors — the full output is used as the `response` field. This is the graceful fallback (see Section 9). Only log an error if the output is completely empty.

### Research Task Failure

Drop silently with a transcript log. Never let a research failure block the discussion loop.

---

## 12. Wrap-Up Enforcement and Force Synthesis

### Wrap-Up Detection

Each loop iteration, if `timer.phase == "wrap-up"`: increment `wrap_up_turns`. The facilitator prompt already includes phase-specific instructions to trigger synthesis. But if it hasn't after 2 turns:

```
if timer.phase == "wrap-up" AND wrap_up_turns > 2 AND NOT converged:
  FORCE SYNTHESIS
```

### Force Synthesis

Force synthesis is identical to `trigger_synthesis` action, with a system-generated reason:

```
log_to_transcript("**Synthesis triggered:** [Forced — " + reason + "]")
where reason is one of:
  - "time expired in wrap-up phase"
  - "2 consecutive agent failures"
  - "maximum turns exceeded"
converged = true
exit loop
proceed to Phase 3
```

**Before forcing**: append a final-statements round to give agents one last contribution if time allows (remaining_sec > 30). Skip if time is truly exhausted.

---

## 13. Transcript Truncation for Facilitator

When `turn > 15`, the facilitator receives a truncated transcript to avoid context overload:

```
if turn > 15:
  recent_turns = last 10 full turn entries from transcript
  earlier_turns = turns 1 through (total - 10)
  summaries = []
  for each earlier_turn:
    summaries.append(one_line_summary(earlier_turn))
    # Format: "Turn N [<agent>]: <15-word summary of contribution>"

  transcript_summary = (
    "**Earlier discussion (summarized):**\n" +
    join(summaries, "\n") +
    "\n\n**Recent turns (full):**\n" +
    join(recent_turns, "\n")
  )
else:
  transcript_summary = full transcript contents
```

One-line summary format: `Turn N [<agent-name>]: <key point in ≤15 words>`

This truncation is for the **facilitator only**. Participant agents in directed turns and parallel rounds always receive the **full transcript** — their context is more bounded (they contribute, not manage), so the full text gives them the best grounding.

---

## 14. Phase 3: Synthesis

Phase 3 runs for `synthesis_budget` seconds (from timer). The synthesis is handled by a dedicated synthesis agent dispatched by the skill runner.

### Inputs compiled for synthesis agent

1. **Full transcript** from `transcript.md`
2. **Argument map** from `argument-map.md` (cartographer's final state)
3. **Agent notes** from `notes/<agent>-private.md` for all agents that wrote notes
4. **Team roster** from `team.json` (agent names and roles for attribution)
5. **Mode** (`converge` or `explore`)
6. **Topic brief** (from Phase 0)

### Convergence Mode Output

The synthesis agent produces:

```markdown
## Synthesis

### Decision
<The decision reached, or "Rough consensus with noted dissent" if split>

### Rationale
<Key arguments that won — attributed to agents who made them>

### Dissenting Views
<Who disagreed and the strongest form of their argument>

### Confidence
<confidence percentage from NGT voting, or qualitative assessment if NGT wasn't run>

### Open Questions
<What wasn't resolved — numbered list>
```

**NGT result integration**: if NGT voting was run (see `references/ngt-voting.md`), include the score distribution and the confidence percentage in the Synthesis section. The synthesis agent receives the NGT results as part of its input.

### Exploration Mode Output

```markdown
## Synthesis

### Ideas Map
<Main threads explored — each thread as a header with 2-3 sentence summary>

### Key Insights
<Non-obvious findings that emerged — attributed where relevant>

### Surprising Connections
<Unexpected links between ideas that surfaced during discussion>

### Open Questions
<What deserves further investigation — numbered list>

### Recommended Next Steps
<Concrete actions if any emerged — omit section if none>
```

### Common to Both Modes

After the mode-specific synthesis, append:

```markdown
---

## Appendix: Agent Notes

### <agent-name>
<contents of notes/<agent>-private.md>

[repeated for each agent that wrote notes]

---

*Discussion ran for <elapsed_time>. <N> agents participated across <turn> turns.*
```

### Output Files

After synthesis is complete, the skill runner saves all artifacts to `work/discussions/<YYYY-MM-DD>-<slug>/`:

```
REPORT.md          ← synthesis output (the deliverable)
transcript.md      ← full discussion transcript
argument-map.md    ← cartographer's final Toulmin map
team.json          ← team roster + persona prompts
notes/             ← all agent notes (public + private)
meta.json          ← {topic, mode, duration_sec, timestamp, expert_ids[], parent_discussion?}
```

Update `work/discussions/INDEX.md` with a one-line entry:
```
| 2026-04-08 | postgres-migration | converge | 15m | Recommend Option B (staged migration) | 78% confidence |
```

---

## Quick Reference: Loop State Variables

| Variable | Type | Description |
|----------|------|-------------|
| `turn` | int | Counts facilitator-initiated content turns (not map/critic auto-dispatches) |
| `consecutive_failures` | int | Resets to 0 on any successful turn; triggers force synthesis at 2 |
| `converged` | bool | Set true by `trigger_synthesis` or force synthesis |
| `wrap_up_turns` | int | Turns elapsed since entering wrap-up phase |
| `last_cartographer_turn` | int | Used to avoid double-dispatch |
| `last_critic_turn` | int | Used to avoid double-dispatch |
| `pending_research` | map[agent_id → result] | Ready-to-inject research results |
| `active_research_count` | int | Global cap: never exceed 2 |
| `interjection_pending` | bool | True if interjection.md is non-empty |
