# JSONL Extraction & Command Normalization

## Parsing tool calls

Each JSONL line is one JSON object. Tool calls appear as assistant messages with `tool_use` content blocks. Extract:

- Tool name: Read, Write, Edit, Bash, Grep, Glob, Agent, Skill, etc.
- For Bash calls: the command (first word or recognizable pattern)
- For Skill calls: the skill name
- Line order = chronological

```bash
grep '"tool_use"' session.jsonl | grep -o '"name":"[^"]*"'
```

## Command normalization

Normalize Bash commands by stripping arguments and joining subcommands with hyphens:

| Raw command | Normalized |
|---|---|
| `git status` | `git-status` |
| `git add src/foo.rs` | `git-add` |
| `cargo test --release` | `cargo-test` |
| `gh pr create --title ...` | `gh-pr-create` |
| `./scripts/cargo-agent.sh` | `cargo-agent-sh` |
| `gh run view 123 --log-failed` | `gh-run-view-log-failed` |

Write intermediate results to a temp file:

```
session-id tool1 tool2 tool3 ...
```
