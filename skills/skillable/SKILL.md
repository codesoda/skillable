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
Read the picker flow from docs/interactive-selection.md — it has the alerter checklist command, AskUserQuestion fallback, and time window prompts.

If `--all` or `--projects` was provided, skip the picker. If `--days` was provided, skip the time window picker.

### Step 1: Locate session transcripts

Scan all detected agents for session files. Read docs/agent-sessions.md for the full map of 12 supported agents, their session directories, and file formats (JSONL, JSON, or SQLite).

Check which agent directories exist, report discovered agents, and collect sessions from all of them.

### Step 2: Filter to time window

Only include sessions modified within the `--days` window (default 7).

### Step 3: Extract tool calls

Read docs/extraction.md for the grep patterns to pull tool_use blocks from JSONL and the command normalization table.

### Step 4: Compute statistics

- Overall tool usage: count invocations per tool type
- Top 20 Bash commands (normalized)
- Skill invocations by skill name
- Bigrams and trigrams of consecutive tool calls
- Longer sequences (4-6 calls) repeating 3+ times — strongest skill candidates

### Step 5: Identify workflow clusters

Classify sessions by workflow markers. Read docs/workflow-markers.md for the detection table mapping markers (investigation, commit, PR creation, CI monitoring, etc.) to their tool call signatures.

### Step 6: Generate the report

Read docs/report-format.md for the full 8-section report template covering overview, tool breakdown, top commands, skill usage, clusters, n-grams, skillable workflows, and already well-served patterns.

### Step 7: Offer to create skills

Ask me which discovered workflows to turn into skills. For each selected:

1. If a `/skill-creator` skill is available, use it. Otherwise create `~/.claude/skills/skill-name/SKILL.md` following the spec at https://agentskills.io/specification
2. Design the workflow based on observed tool call sequences

### Step 8: Save the report

Save to `docs/plans/skill-analysis-DATE.md` (project-scoped) or a temp file (cross-project).

</required>

## Tips

- Only count top-level tool calls, not subagent internals
- Treat each session file as independent (no cross-session deduplication)
- Scan `~/.claude/skills/`, `~/.agent/skills/`, and `~/.codex/skills/` for existing skills to populate the "Exists?" column
- After the report, offer to symlink any skills missing from one location into the others
