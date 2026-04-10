---
name: recruit
description: "Recruit, cache, and reuse domain expert agent personas. Use this skill whenever you need a domain expert for a discussion, planning session, code review, or any task that benefits from specialized knowledge. Triggers on: 'recruit', 'find an expert', 'create an expert', 'domain expert', 'specialist', 'I need someone who knows', 'get me an expert on', 'who should review this', 'assemble a team', 'what experts do I need', or when another skill needs to assemble a team of experts. Also use when browsing or managing cached experts: 'list experts', 'show cached experts', 'search for an expert'."
---

# /recruit — Expert Registry

Recruit, cache, and reuse domain expert agent personas. The registry is shared infrastructure — `/discuss`, `/work`, `/council`, and other skills use it to find or create experts. Users can also invoke it directly.

## User Commands

### `/recruit list`

Show all cached experts.

1. Read `<data-root>/experts/INDEX.md`
2. Print the Core Team table (permanent) and Domain Experts table (cached)
3. Show: name, domain, tags, last used, consumer skills

### `/recruit search <query>`

Find experts matching a keyword or domain.

1. `rg -i "<query>" knowledge/experts/INDEX.md` — scan the roster
2. `rg -i "<query>" knowledge/experts/*.md` — search persona text for deeper matches
3. Present matches with domain, tags, and last-used date
4. Offer to load a match or create a fresh expert

### `/recruit create <domain description>`

Create a new expert persona and add it to the registry.

1. **Analyze the domain**: What is the exact expertise needed? Is the domain well-established (base model sufficient) or cutting-edge/proprietary (deep research warranted)?
2. **Check for near-matches**: Run the search protocol first — avoid creating duplicates
3. **Build the persona**: Follow `references/expert-template.md` — name, thinking style, frameworks, looks_for, blind_spots
4. **Deep research** (if triggered — see criteria below): dispatch a research agent, inject findings into Research Context
5. **Save**: write to `knowledge/experts/<slug>.md`, update INDEX.md
6. **Confirm**: show the user the created persona summary

---

## Recruiting Protocol (Programmatic — for skills calling /recruit)

Other skills call this protocol during their setup phases. Follow these steps in order.

### Step 1: Search

```
rg -i "<domain_keyword>" <data-root>/experts/INDEX.md
```

Scan for matching tags and domains. If the INDEX has no hits, also try:

```
rg -i "<domain_keyword>" <data-root>/experts/*.md
```

### Step 2: Evaluate

For each candidate match, assess fit:
- **Domain alignment**: Does the expert's domain cover what's needed? Partial overlap is OK if the core area matches.
- **Research freshness**: If the expert's Research Context includes specific version-pinned or date-sensitive information, check if it's still accurate (>1 year → flag for refresh).
- **Thinking style fit**: Does the persona's thinking style match the task? A "risk-averse systems thinker" is the right choice for a migration review but may be too conservative for a brainstorming session.

### Step 3: Offer

Present matches to the caller (or user, if user-invoked):

> "Found cached expert **Dr. PostgreSQL** (database, postgresql, migration — last used 3 days ago). Reuse, or create a fresh expert for this domain?"

If no match: skip to Step 5.

### Step 4: Reuse

When reusing a cached expert:
1. Load the full file from `<data-root>/experts/<slug>.md`
2. Extract the Persona Prompt and Research Context sections
3. Update `last_used` to today's date in the file frontmatter
4. Add the calling skill to `consumers[]` if not already present
5. Return the persona text to the caller

### Step 5: Create (when no suitable match exists)

1. **Identify the domain**: Narrow and specific beats broad. "PostgreSQL migration specialist" beats "database expert."
2. **Build persona** using `references/expert-template.md`:
   - Choose a name that creates a character (not "Expert #1")
   - Define thinking style, key frameworks, what they look for, blind spots
   - Write the Persona Prompt (100-300 words, second person: "You are...")
3. **Deep research** (if triggered — see criteria below): dispatch a research subagent, save findings under `## Research Context`
4. **Save**: write to `<data-root>/experts/<slug>.md`
5. **Update INDEX.md**: add a row to the Domain Experts table with name, domain, tags, last used, created date
6. Return the persona text to the caller

---

## Expert File Format

See `references/expert-template.md` for the full template. Key fields:

```yaml
---
name: <Display name — creates a character, e.g. "Dr. PostgreSQL">
domain: <Specific area, e.g. "PostgreSQL internals and migration patterns">
tags: [database, postgresql, migration, schema]
thinking_style: <How they approach problems>
frameworks: [CAP theorem, ACID vs BASE, migration state machines]
looks_for: <What draws their attention>
blind_spots: <Known limitations — helps callers know when to balance>
created: YYYY-MM-DD
last_used: YYYY-MM-DD
consumers: [discuss, work]
source_tasks: [plans/discuss-skill.md]
---
```

Followed by three sections: `## Persona Prompt`, `## Research Context`, `## Performance Notes`.

---

## Storage

Expert data is stored under the **wits data root** (see `references/data-root.md` for resolution logic):

- Default: `~/.local/share/wits/experts/`
- Override: set `WITS_DATA_DIR` environment variable
- Fallback: `/tmp/wits-$USER/experts/` (ephemeral, with warning)

```
<data-root>/experts/
├── INDEX.md                   # Expert roster — scan this first
├── core/                      # Core team — permanent, pre-built via deep research
│   ├── facilitator-knowledge.md
│   ├── cartographer-knowledge.md
│   └── critic-knowledge.md
└── <domain-slug>.md           # Cached domain experts (accumulated over time)
```

**Resolving the expert directory**: Check `$WITS_DATA_DIR/experts/` first, then `~/.local/share/wits/experts/`. Create the directory on first use if it doesn't exist.

**Core team** (`experts/core/`) holds knowledge bases for permanent roles (facilitator, reasoning cartographer, critical lens). These are built once during skill creation via deep research and loaded at session start — not at runtime. They are not domain experts; they do not use the expert-template format.

**Domain experts** (`experts/*.md`) are cached personas created on demand and reused across sessions and skills.

> **Data handling notice**: Expert personas may contain domain-specific information. In regulated environments, ensure the data root is on an appropriate storage volume.

---

## Integration Guide (for skill authors)

Skills that need domain experts call the recruiting protocol during their setup phase. Pattern:

```
1. Identify needed domains from the task/topic
2. For each domain:
   a. Call: Search <data-root>/experts/INDEX.md for matches
   b. Evaluate fit (domain alignment, research freshness, thinking style)
   c. If good match → reuse (load persona, update last_used + consumers[])
   d. If no match → create (build persona, optionally deep-research, save)
3. Return assembled persona prompts to calling skill
```

Skills that currently use the registry: `/discuss` (Phase 1: Recruiting).

When calling the protocol programmatically, pass:
- The domain description (what expertise is needed)
- The task context (what the expert will be doing — affects thinking style selection)
- Whether deep research is acceptable (some callers are latency-sensitive)

---

## Deep Research Trigger Criteria

Default: rely on base model knowledge. Deep research adds 3-5 minutes — only trigger when justified.

Trigger deep research when ANY of these are true:
- The domain involves technology less than 2 years old (base model training data too thin)
- The domain is proprietary or company-specific (internal APIs, custom frameworks)
- The calling skill or user explicitly requests it (`needs_deep_research: true` or "research this domain")
- A prior use of this expert produced weak contributions flagged in `## Performance Notes`

Do NOT trigger deep research when:
- The domain is a well-established technology (PostgreSQL, Go, React, etc.)
- The task is exploratory and approximate knowledge is sufficient
- Time budget is tight

When triggering: warn the caller — "Recruiting may take 3-5m due to domain research."
