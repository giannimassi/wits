# NGT Convergence Voting Protocol

Nominal Group Technique adapted for AI agent teams. Used to close convergence-mode discussions by
independently ranking options and aggregating scores to surface consensus — or expose genuine splits.

---

## When to Invoke

Invoke NGT when **all three** conditions hold:

1. Mode is `converge`
2. The facilitator returns `{"action": "trigger_synthesis"}`, OR the discussion has entered wrap-up
   phase and the facilitator has not triggered synthesis within 2 turns
3. The current argument map contains at least 2 distinct positions (otherwise there is nothing to vote on)

Do not invoke NGT in exploration mode. Do not invoke before the `mid` phase has been reached (the
facilitator's neutrality constraint prevents premature closure).

---

## Step 1 — Option Extraction

Dispatch the **cartographer** with the full argument map and the following instruction:

> Draft 3–5 distinct options from the claim registry. Each option is one sentence — a position
> statement the group could commit to. Options must be genuinely distinct (not paraphrases). Include
> at least one that reflects a minority view if it was argued with evidence.

The cartographer returns options in this format (already defined in its wrap-up behavior):

```
1. Option A: [one-sentence position statement]
2. Option B: [one-sentence position statement]
3. Option C: [one-sentence position statement]
```

Cap at 5 options. If the cartographer returns 6+, ask it to collapse the two most similar ones.
Label options alphabetically (A, B, C, …) for unambiguous reference in rankings.

---

## Step 2 — Independent Ranking

Dispatch **each participant in parallel** — this means all domain experts plus the critic. The
facilitator does NOT vote (neutrality constraint).

Each voter receives:
- The option list from Step 1
- A single instruction: rank every option from 1 (best) to N (worst). No ties. No abstentions.

Expected response format:

```json
{"rankings": {"option_a": 1, "option_b": 3, "option_c": 2}}
```

If a voter returns malformed JSON or omits an option, treat that voter's ballot as invalid and
exclude it from the tally. Log the exclusion.

---

## Step 3 — Tallying

For each option, compute its score using **inverse rank points**:

```
score(option) = sum over all valid voters of (N + 1 - rank_i(option))
```

Where N = total number of options and rank_i is that voter's rank for the option.

Rank 1 (best) = N points. Rank N (worst) = 1 point.

Produce a score distribution table:

| Option | Description (truncated) | Raw Score | % of Max |
|--------|--------------------------|-----------|----------|
| A      | [first ~6 words]         | 11        | 73%      |
| B      | [first ~6 words]         |  8        | 53%      |
| C      | [first ~6 words]         |  5        | 33%      |

Max possible score for one option = N × V, where V = number of valid voters.

Sort by descending score. The top-scoring option is the provisional winner.

---

## Step 4 — Split Detection

A split exists when:

```
(winner_score - runner_up_score) / winner_score ≤ 0.15
```

That is, the runner-up is within 15% of the winner's score. When this condition holds, both options
are "split items" requiring a final round.

If no split: skip to Step 6.

---

## Step 5 — Final Round (splits only)

Run one directed turn per voter asking them to argue explicitly for their top pick on the split
items. Prompt template:

> "We have a split between Option [X] and Option [Y]. You ranked [your top pick] first. In 2–3
> sentences, make your strongest case for it, specifically addressing why it beats [the other split
> item]."

After all arguments are collected, re-run the full vote (Steps 2–3) on the split items only. The
other options retain their original scores.

Cap at one re-vote. If the split persists after the final round, report it as "unresolved split"
and document both positions as co-equal findings in the synthesis.

---

## Step 6 — Confidence Calculation

```
confidence = (winner_score - runner_up_score) / max_possible_score
```

Where `max_possible_score = N × V` (all voters give the winner rank 1, and it still gets N points
each time).

Express as a percentage. Interpretation guidance:

| Confidence | Signal |
|-----------|--------|
| ≥ 60%     | Strong consensus — synthesis leads with the winner |
| 30–59%    | Moderate consensus — note runner-up as viable alternative |
| < 30%     | Weak consensus — treat as rough majority, highlight dissent prominently |

---

## Step 7 — Output

The skill runner assembles the synthesis block:

```
**Decision**: [winning option, full text]
**Confidence**: [X]%

**Score Distribution**
[table from Step 3]

**Dissenting Views**
[List each voter who ranked the winner 3rd or below. For each: agent name + their top pick + one
sentence from their Step 5 argument, or from their discussion turns if Step 5 was not triggered]

**Open Questions**
[Any claims marked as gaps in the final argument map that the vote does not resolve]
```

A voter counts as a dissenter if they ranked the winner at position 3 or lower (not just "below
2nd") — this catches meaningful dissent without flagging mild preference differences.

---

## Worked Example

**Setup**: 3 agents vote on 4 options. N = 4. V = 3. Max possible score = 4 × 3 = 12.

**Options**:
- Option A: Migrate fully to DynamoDB single-table design in one cutover.
- Option B: Run Postgres and DynamoDB in parallel for 90 days before cutover.
- Option C: Migrate to Aurora Postgres first, then evaluate NoSQL later.
- Option D: Stay on Postgres and optimize with read replicas and partitioning.

**Ballots**:

| Voter    | A | B | C | D |
|----------|---|---|---|---|
| expert-1 | 1 | 2 | 3 | 4 |
| expert-2 | 3 | 1 | 2 | 4 |
| critic   | 2 | 1 | 3 | 4 |

**Inverse rank points** (N + 1 - rank = 5 - rank):

| Voter    | A | B | C | D |
|----------|---|---|---|---|
| expert-1 | 4 | 3 | 2 | 1 |
| expert-2 | 2 | 4 | 3 | 1 |
| critic   | 3 | 4 | 2 | 1 |
| **Total**| **9** | **11** | **7** | **3** |

**Score Distribution**:

| Option | Description                        | Score | % of Max |
|--------|------------------------------------|-------|----------|
| B      | Run Postgres and DynamoDB in par…  | 11    | 92%      |
| A      | Migrate fully to DynamoDB single…  |  9    | 75%      |
| C      | Migrate to Aurora Postgres first…  |  7    | 58%      |
| D      | Stay on Postgres and optimize wi…  |  3    | 25%      |

**Split check**: (11 - 9) / 11 = 18% — above the 15% threshold. No split. Proceed to Step 6.

**Confidence**: (11 - 9) / 12 = 16.7%

This is below 30% — weak consensus. Synthesis should acknowledge Option A as a strong alternative.

**Dissenting views**: expert-1 ranked Option B second (ranked A first). Include their argument for
Option A in the dissent block.

**Output**:
> Decision: Run Postgres and DynamoDB in parallel for 90 days before cutover.
> Confidence: 17% (weak — Option A is a viable alternative held by expert-1)
