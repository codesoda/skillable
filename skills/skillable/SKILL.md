---
name: skillable
description: Use when you want to analyze tool call patterns across agent sessions, discover common workflows, suggest new skills, or identify what is already well-served.
---

Analyze agent session transcripts to discover common tool call patterns, identify workflows that could become skills, and generate a structured report.

## Arguments

- `$ARGUMENTS` — Scope of analysis. Options:
  - (empty) — Analyze the current project only
  - `--all` — Analyze ALL projects
  - `--projects name1 name2 ...` — Analyze specific projects by name (matches directory names loosely)
  - `--days N` — Look back N days (default: 7)

<required>

## Workflow

### Step 0: Determine project scope

If no arguments are provided, present an interactive project picker.
Read `docs/interactive-selection.md` for the picker UI details.

If `--all` or `--projects` was provided, skip the picker. If `--days` was provided, skip the time window picker.

### Step 1: Locate session transcripts

Scan all detected agents for session files. Read `docs/agent-sessions.md` for the full list of agents, session paths, and file formats.

At minimum, check for:
- Claude Code: `~/.claude/projects/` (JSONL, repo-scoped dirs)
- Codex: `~/.codex/sessions/YYYY/MM/DD/` (JSONL, date-based hierarchy)
- OpenCode: `~/Library/Application Support/opencode/storage/` or `~/.local/share/opencode/storage/` (JSON fragments reassembled per session)

Report which agents were found and how many sessions per agent.

### Step 2: Filter to time window

Only include sessions modified within the `--days` window (default 7):

```bash
find ~/.claude/projects/project-dir/ -name "*.jsonl" -mtime -7
```

### Step 3: Extract tool calls

Read `docs/extraction.md` for JSONL parsing details and command normalization rules.

### Step 4: Compute statistics

- Overall tool usage: count invocations per tool type
- Top 20 Bash commands (normalized)
- Skill invocations by skill name
- Bigrams and trigrams of consecutive tool calls
- Longer sequences (4-6 calls) repeating 3+ times — strongest skill candidates

### Step 5: Identify workflow clusters

Classify sessions by workflow markers:

| Marker | Detection |
|--------|-----------|
| Investigation | Heavy Read/Grep/Glob without much Edit |
| Commit | `git-add` + `git-commit` or `Skill:commit` |
| PR creation | `gh-pr-create` |
| PR review response | `gh-api` reading PR comments + Edit + push |
| CI monitoring | `gh-run-view` or `gh-run-list` |
| Build/test cycle | `cargo-test`, `cargo-agent-sh`, `npm-agent-sh` |
| Branch setup | `git-checkout-b` or `git-switch-c` |

### Step 6: Generate the report

Read `docs/report-format.md` for the full 8-section report template.

### Step 7: Offer to create skills

Ask the user which discovered workflows to turn into skills. For each selected:

1. Create `~/.claude/skills/skill-name/SKILL.md`
2. Use standard SKILL.md format (YAML frontmatter with name, description, allowed-tools)
3. Design the workflow based on observed tool call sequences

### Step 8: Save the report

Save to `docs/plans/skill-analysis-DATE.md` (project-scoped) or a temp file (cross-project).

</required>

## Tips

- Use grep/awk to extract tool call data from JSONL — do not read entire files
- Parallelize when scanning multiple projects
- Normalize command variations (e.g. `git add .` and `git add src/foo.rs` are both `git-add`)
- Only count top-level tool calls, not subagent internals
- Treat each JSONL as independent (no session deduplication)
- Scan `~/.claude/skills/`, `~/.agent/skills/`, and `~/.codex/skills/` for existing skills to populate the "Exists?" column
- After the report, offer to symlink any skills missing from one location into the others (e.g. a skill only in `~/.claude/skills/` could be symlinked into `~/.agent/skills/` so Codex can use it too, and vice versa)
