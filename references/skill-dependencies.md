# Skill Dependencies & Platform Requirements

## Dependency Graph

```
think ─── (standalone, no dependencies)

discuss ──→ recruit (discuss invokes /wits:recruit to assemble expert personas)

recruit ─── (standalone)
```

## Platform Requirements

| Skill | Requires | Works On |
|-------|----------|----------|
| **think** | None | Any Claude Code environment, Codex CLI, Gemini CLI (with adapter) |
| **recruit** | File system write access (for expert cache) | Any Claude Code environment |
| **discuss** | `Task` tool (for spawning subagents) | Claude Code only (requires Agent/Task tool for multi-agent dispatch) |

## Graceful Degradation

- **discuss without recruit**: If recruit is unavailable or the user skips persona assembly, discuss will use generic participant roles instead of domain-specific expert personas. Quality degrades but the skill still functions.
- **discuss outside Claude Code**: The discuss skill requires the Task tool to spawn facilitator, cartographer, critic, and participant subagents. In environments without Task (Codex CLI, Gemini CLI), discuss will not work. Think and recruit remain fully functional.
- **recruit without file system**: If the data root is not writable, recruit will create expert personas in `/tmp/wits-$USER/experts/` (ephemeral, lost on reboot). A warning is shown.
