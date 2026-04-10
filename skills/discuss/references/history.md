# Discussion History — Saving & Continuation

Reference for the skill runner. Covers: saving artifacts after Phase 3, updating INDEX.md, and loading a prior discussion via `--from`.

---

## 1. Saving a Discussion (end of Phase 3)

Run this immediately after the synthesis output is written, before reporting completion to the user.

### 1.1 Generate the slug

Derive from the refined topic brief (not the raw user input). Rules:
- Lowercase, kebab-case
- Strip stop words (a, the, for, in, of, on, to, with)
- Max 40 characters — truncate at the last full word before the limit
- Examples: `postgres-migration-strategy`, `ai-product-roadmap-q2`, `team-hiring-process`

```bash
# Construct destination path
DATE=$(date -u '+%Y-%m-%d')
SLUG="<derived-slug>"
DEST="work/discussions/${DATE}-${SLUG}"
```

### 1.2 Copy artifacts from tmp/

Source: `tmp/discuss-<session-id>/`
Destination: `work/discussions/<date>-<slug>/`

Files to copy:
```
REPORT.md          ← synthesis output (written during Phase 3)
transcript.md      ← full discussion transcript
argument-map.md    ← cartographer's final Toulmin map
team.json          ← assembled team roster + persona prompts
timer.env          ← timer state (for phase reconstruction)
interjection.md    ← observer interjections (may be empty)
notes/             ← entire directory (public shared.md + per-agent private files)
```

```bash
mkdir -p "${DEST}/notes"
cp "tmp/discuss-${SESSION_ID}/REPORT.md" "${DEST}/REPORT.md"
cp "tmp/discuss-${SESSION_ID}/transcript.md" "${DEST}/transcript.md"
cp "tmp/discuss-${SESSION_ID}/argument-map.md" "${DEST}/argument-map.md"
cp "tmp/discuss-${SESSION_ID}/team.json" "${DEST}/team.json"
cp "tmp/discuss-${SESSION_ID}/timer.env" "${DEST}/timer.env"
cp "tmp/discuss-${SESSION_ID}/interjection.md" "${DEST}/interjection.md" 2>/dev/null || true
cp "tmp/discuss-${SESSION_ID}/notes/"* "${DEST}/notes/" 2>/dev/null || true
```

### 1.3 Write meta.json

Get the current timestamp from the system clock (never infer it):

```bash
ENDED=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
```

Schema:

```json
{
  "session_id": "<uuid>",
  "topic": "<refined topic brief — one sentence>",
  "mode": "converge | explore",
  "duration_sec": 900,
  "started": "2026-04-08T14:30:00Z",
  "ended": "2026-04-08T14:52:14Z",
  "expert_ids": ["db-migration-specialist", "distributed-systems-architect"],
  "parent_discussion": null,
  "key_outcome": "<one sentence: what was decided or discovered>"
}
```

**All fields are REQUIRED.** If a field cannot be determined, use `null` rather than omitting it.

Field notes:
- `session_id`: the `discuss-NNNN` session ID generated at the start
- `topic`: refined topic brief — one sentence
- `expert_ids`: IDs from `team.json` — include only guest experts, not core team (facilitator, cartographer, critic)
- `parent_discussion`: path to the prior discussion directory, or `null` if this is a standalone session
- `key_outcome`: derive from the synthesis REPORT.md — the single most important sentence. In convergence mode: the decision reached. In exploration mode: the most significant insight. **MUST NOT be omitted.**
- `duration_sec`: Phase 2 wall time only (not including intake, recruiting, or synthesis)
- `started`: **MUST** be read from `timer.env` START_EPOCH and converted to ISO 8601: `date -u -r $START_EPOCH '+%Y-%m-%dT%H:%M:%SZ'`
- `ended`: **MUST** be read from the system clock at save time: `date -u '+%Y-%m-%dT%H:%M:%SZ'`

Write to `${DEST}/meta.json`.

### 1.4 Update INDEX.md

File: `work/discussions/INDEX.md`

Read the file first, then append one row to the table:

```markdown
| 2026-04-08 | Postgres migration strategy | converge | Chose blue-green migration with 2-phase cutover | work/discussions/2026-04-08-postgres-migration-strategy/ |
```

Column mapping:
- **Date**: `YYYY-MM-DD` (same as slug prefix)
- **Topic**: refined topic brief (may truncate to ~50 chars with ellipsis if longer)
- **Mode**: `converge` or `explore`
- **Key Outcome**: same as `key_outcome` in meta.json
- **Path**: relative path from hq root, trailing slash

Use Edit to append the row — match the last table row as the anchor for the old_string. Never use Write to overwrite INDEX.md.

### 1.5 Cleanup

Remove the tmp directory only after confirming the save succeeded (DEST directory exists and contains REPORT.md):

```bash
if [ -f "${DEST}/REPORT.md" ]; then
  rm -rf "tmp/discuss-${SESSION_ID}"
fi
```

---

## 2. The --from Flag (Multi-Session Continuation)

Used when the user provides `--from <path>` to resume or fork a prior discussion.

### 2.1 Validation (Phase 0, before intake)

Check that the path is usable before proceeding:

1. Verify the directory exists: `[ -d "<path>" ]`
2. Verify `REPORT.md` exists: `[ -f "<path>/REPORT.md" ]`
3. Verify `team.json` exists: `[ -f "<path>/team.json" ]`

If validation fails: surface a clear error to the user:
> "Prior discussion not found at `<path>`. Expected REPORT.md and team.json. Check the path and try again."

If `argument-map.md` is missing (e.g., older session): continue without it — treat argument map context as unavailable and note it in the opening context injection.

### 2.2 Load prior artifacts

Read all three files into the skill runner's working context:
- `<path>/REPORT.md` → prior synthesis
- `<path>/argument-map.md` → prior argument map (if present)
- `<path>/team.json` → prior team roster

Read `<path>/meta.json` if present — extract `topic`, `mode`, and `key_outcome` for display.

### 2.3 Offer team reassembly (Phase 1 replacement)

Present the prior team to the user:

> "Prior discussion: **<prior topic>** (<date>)
> Team: facilitator, cartographer, critic, Dr. PostgreSQL (DB Migration), Maya (Distributed Systems)
> Reassemble the same team, or modify the roster?"

User responses:
- "Same team" / no input → copy `team.json` directly, skip recruiting
- "Add <domain>" → keep existing experts, recruit one new domain expert via the registry
- "Remove <name>" → drop that expert from team.json, proceed
- "New team" → run full recruiting from scratch (Phase 1 as normal)

Write the final `team.json` to `tmp/discuss-<new-session-id>/team.json` before Phase 2 begins.

### 2.4 Inject prior context into Phase 2 opening

Before dispatching the first facilitator turn, prepend this block to the transcript file:

```markdown
# Continuation Context

This discussion continues from: <path>
Prior topic: <prior topic brief>
Prior mode: <mode>
Key outcome: <key_outcome from prior meta.json>

## Prior Synthesis
<full contents of prior REPORT.md>

## Prior Argument Map
<full contents of prior argument-map.md, or "(not available)" if missing>

---
# Discussion: <new topic>
```

This ensures all agents in Phase 2 receive prior synthesis and argument map via their transcript context — no special per-agent injection needed.

### 2.5 Set parent_discussion in new meta.json

When writing meta.json at the end of Phase 3, set:

```json
"parent_discussion": "work/discussions/2026-04-08-postgres-migration-strategy/"
```

Use the path exactly as provided in `--from` (normalize to trailing-slash form if missing).

---

## Quick Reference

| Step | When | What |
|------|------|------|
| Generate slug | End of Phase 3 | Kebab-case, max 40 chars, from refined topic |
| Copy artifacts | End of Phase 3 | tmp/ → work/discussions/<date>-<slug>/ |
| Write meta.json | End of Phase 3 | Session metadata + key_outcome + expert_ids |
| Update INDEX.md | End of Phase 3 | Append one row — use Edit, not Write |
| Cleanup tmp | End of Phase 3 | Only after REPORT.md confirmed at destination |
| Validate --from | Phase 0 (before intake) | Check dir + REPORT.md + team.json exist |
| Load prior artifacts | Phase 0 | REPORT.md, argument-map.md, team.json |
| Offer team reassembly | Phase 1 replacement | Same / add / remove / new |
| Inject prior context | Phase 2 opening | Prepend to transcript before first facilitator dispatch |
| Set parent_discussion | End of Phase 3 | Path to prior discussion in meta.json |
