# Agent Session Locations

Scan for sessions from all agents that are installed. Skip any agent whose directories do not exist.

## JSONL agents (parse directly)

### Claude Code

- Path: `~/.claude/projects/<encoded-path>/`
- Format: JSONL (one JSON object per line)
- Encoding: absolute repo path with `/` replaced by `-`
- Example: repo at `/Users/foo/bar` produces `~/.claude/projects/-Users-foo-bar/`

### Codex

- Path: `~/.codex/sessions/YYYY/MM/DD/*.jsonl`
- Format: JSONL
- Override: `CODEX_HOME` env var changes the base directory

## JSON agents (normalize to extract tool calls)

These store sessions as JSON files. Extract tool call sequences by reading each JSON and pulling out tool-use entries.

### Cursor

- macOS: `~/Library/Application Support/Cursor/User/workspaceStorage/*/chatSessions/`
- Linux: `~/.config/Cursor/User/workspaceStorage/*/chatSessions/`

### Copilot (VS Code)

- macOS: `~/Library/Application Support/Code/User/workspaceStorage/*/chatSessions/`
- Linux: `~/.config/Code/User/workspaceStorage/*/chatSessions/`

### Cline

- Check multiple IDE locations (Code, Cursor, Windsurf, VSCodium):
  - `<IDE Config>/User/globalStorage/saoudrizwan.claude-dev/tasks/`
  - `<IDE Config>/User/globalStorage/cline.cline/tasks/`
- Fallback: `~/.cline/tasks/`, `~/.cline/task-history/`

### Roo Code

- `<IDE Config>/User/globalStorage/rooveterinaryinc.roo-cline/tasks/`
- `<IDE Config>/User/globalStorage/roocode.roo-code/tasks/`
- Fallback: `~/.roo/tasks/`, `~/.roo/task-history/`

### Kiro

- macOS/Linux: `~/.local/share/kiro/User/globalStorage/kiro.kiroagent/workspace-sessions/`
- Format: JSON (prefer `.json` over `.chat` files for same session)

### Amp Code

- Primary: `~/.local/share/amp/threads/` (JSON)
- Fallback: `~/.amp/file-changes/` (JSON/JSONL)

### Windsurf

- macOS: `~/Library/Application Support/Windsurf/User/workspaceStorage/*/chatSessions/`
- Linux: `~/.config/Windsurf/User/workspaceStorage/*/chatSessions/`

### Antigravity

- macOS: `~/Library/Application Support/Antigravity/User/workspaceStorage/*/chatSessions/`
- Linux: `~/.config/Antigravity/User/workspaceStorage/*/chatSessions/`

### OpenCode

- macOS: `~/Library/Application Support/opencode/storage/`
- Linux: `~/.local/share/opencode/storage/`
- Structure: `session/*.json`, `message/*.json`, `part/*.json` (reassemble per session ID)

## SQLite agents (query database)

### Warp

- Path: `~/.local/share/warp/history.sqlite`
- Tables: `ai_queries`, `agent_tasks`
- Override: `WARP_DB_PATH` env var

## Discovery strategy

1. Check which agent directories exist on the machine
2. Report discovered agents to the user
3. For agents with JSONL sessions, parse directly
4. For JSON agents, extract tool-use entries from the JSON structure
5. For SQLite agents, query the database tables
6. Merge all tool call sequences into a unified analysis, tagged by agent
7. In the report, break down usage per agent so users can compare patterns across tools
