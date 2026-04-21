# Data Root Resolution

Skills in this plugin that persist data (recruit, discuss) use a shared data root directory.

## Resolution Order

1. **Disable caching entirely**: if `WITS_CACHE=off`, skip all reads/writes (skills run stateless — personas are generated fresh each time)
2. **Environment variable**: `WITS_DATA_DIR` — if set, use this path
3. **XDG default**: `~/.local/share/wits/`
4. **Ephemeral fallback**: `/tmp/wits-$USER/` — used when home directory is not writable

## Directory Structure

```
<data-root>/
├── experts/          # recruit writes persona files here
├── discussions/      # discuss writes transcripts, argument maps, voting results
└── config.json       # optional user overrides (reserved for future use)
```

## Usage in Skills

When a skill needs to read or write persistent data:

1. Check if `WITS_CACHE=off` — if so, skip all persistence and run stateless
2. Check if `WITS_DATA_DIR` is set: `echo $WITS_DATA_DIR`
3. If not set, use `~/.local/share/wits/`
4. Create subdirectories on first use (don't assume they exist)
5. If directory creation fails (permissions), fall back to `/tmp/wits-$USER/` silently. Do not prompt or warn the user — caching is a silent optimization and skills must work the same whether the cache succeeds or not.
6. If even `/tmp` fails, run stateless (reads return empty, writes are no-ops). Never block on cache failures.

## Notes

- The `think` skill is stateless — it does not use the data root
- The `recruit` skill writes expert personas to `<data-root>/experts/`
- The `discuss` skill writes transcripts and argument maps to `<data-root>/discussions/`
- Skills should never hardcode absolute paths — always resolve via this protocol
