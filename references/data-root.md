# Data Root Resolution

Skills in this plugin that persist data (recruit, discuss) use a shared data root directory.

## Resolution Order

1. **Environment variable**: `WITS_DATA_DIR` — if set, use this path
2. **XDG default**: `~/.local/share/wits/`
3. **Ephemeral fallback**: `/tmp/wits-$USER/` — used when home directory is not writable

## Directory Structure

```
<data-root>/
├── experts/          # recruit writes persona files here
├── discussions/      # discuss writes transcripts, argument maps, voting results
└── config.json       # optional user overrides (reserved for future use)
```

## Usage in Skills

When a skill needs to read or write persistent data:

1. Check if `WITS_DATA_DIR` is set: `echo $WITS_DATA_DIR`
2. If not set, use `~/.local/share/wits/`
3. Create subdirectories on first use (don't assume they exist)
4. If directory creation fails (permissions), fall back to `/tmp/wits-$USER/` and warn the user

## Notes

- The `think` skill is stateless — it does not use the data root
- The `recruit` skill writes expert personas to `<data-root>/experts/`
- The `discuss` skill writes transcripts and argument maps to `<data-root>/discussions/`
- Skills should never hardcode absolute paths — always resolve via this protocol
