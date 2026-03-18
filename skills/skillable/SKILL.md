---
name: skillable
description: Analyze Claude Code tool call patterns across sessions to discover common workflows, suggest new skills, and identify what's already well-served. Use when you want to understand usage patterns and find automation opportunities.
---

# Skillable — Tool Usage Pattern Analysis & Skill Discovery

Analyze Claude Code session transcripts to discover common tool call patterns, identify workflows that could become skills, and generate a structured report.

## Arguments

- `$ARGUMENTS` — Scope of analysis. Options:
  - *(empty)* — Analyze the current project only
  - `--all` — Analyze ALL projects
  - `--projects <name1> <name2> ...` — Analyze specific projects by name (matches directory names loosely)
  - `--days <N>` — Look back N days (default: 7)

## Workflow

### Step 0: Determine project scope (interactive selection)

If **no arguments are provided** (no `--all`, no `--projects`), present an interactive project picker using the `agent-ui` skill's checklist dialog.

First, scan for all available projects:

```bash
# List all project directories, extract human-readable names
ls ~/.claude/projects/ | grep -o 'projects-[^/]*' | sed 's/projects-//' | sort
```

Then present a multi-select checklist to the user using the `agent-ui` tool:

```bash
alerter -title "Skillable — Select Projects" \
  -message "Choose which projects to analyze:" \
  -checklist "All projects" "<project1>" "<project2>" "<project3>" ...
```

If the `agent-ui`/`alerter` tool is not available or fails, fall back to presenting the list in the terminal and asking the user to pick:

```
Select projects to analyze:

[ ] All projects

[ ] ai-barometer
[ ] cadence-cli
[ ] dataclaw-dl
[ ] gitleaks-rs
[ ] obie-obie-loop
[ ] vibe-code-audit
[ ] x-agent
... (all discovered projects with recent sessions)

Enter project names (space-separated), "all", or press Enter for current project only:
```

Use the `AskUserQuestion` tool to collect the user's selection. If they pick "All projects", treat as `--all`. Otherwise, filter to the selected project(s).

Next, if `--days` was not provided, ask about the time window:

```
Time window:

( ) Last 3 days
( ) Last 7 days (default)
( ) Last 14 days
( ) Last 30 days
( ) Custom (specify days)
```

Use `AskUserQuestion` or `alerter` to collect. Default to 7 days if the user skips.

**If `--all` or `--projects` was provided**, skip the project picker. **If `--days` was provided**, skip the time window picker.

### Step 1: Locate session transcripts

Session transcripts are stored as JSONL files under `~/.claude/projects/`. Each project directory is named with a mangled path pattern like `-Users-chrisraethke-projects-<project-name>/`.

```bash
# For current project: use the current working directory to find the project key
PROJECT_DIR=$(pwd)

# For --all: scan all project directories
ls ~/.claude/projects/

# For --projects: match by name
ls -d ~/.claude/projects/*<name>*
```

### Step 2: Filter to time window

Only include sessions modified within the `--days` window (default 7):

```bash
# Find JSONL files modified in the last N days
find ~/.claude/projects/<project-dir>/ -name "*.jsonl" -mtime -7
```

Count sessions and report scope:
```
Scanning: <project(s)>
Period: last 7 days
Sessions found: <N>
```

### Step 3: Extract tool calls from JSONL transcripts

Each JSONL file contains one JSON object per line. Tool calls appear as assistant messages with `tool_use` content blocks. Extract:
- Tool name (Read, Write, Edit, Bash, Grep, Glob, Agent, Skill, etc.)
- For Bash calls: the command (first word or recognizable pattern like `git`, `cargo`, `gh`, `npm`)
- For Skill calls: the skill name
- Timestamp ordering (line order = chronological)

Use grep/jq to extract efficiently:

```bash
# Extract tool names from a session file
grep -o '"type":"tool_use"' <file> | wc -l  # count
grep '"tool_use"' <file> | grep -o '"name":"[^"]*"'  # tool names
```

For Bash commands, extract the command field and normalize:
- `git status` → `git-status`
- `git add <files>` → `git-add`
- `cargo test <args>` → `cargo-test`
- `gh pr create <args>` → `gh-pr-create`
- `./scripts/cargo-agent.sh` → `cargo-agent-sh`
- `gh run view <id> --log-failed` → `gh-run-view-log-failed`

Write intermediate results to a temp file for analysis:
```
<session-id> <tool1> <tool2> <tool3> ...
```

### Step 4: Compute statistics

#### 4a. Overall tool usage
Count total invocations per tool type. Present as a table:
```
| Tool | Count | % of Total |
```

#### 4b. Top Bash commands
Normalize and count Bash commands. Present top 20.

#### 4c. Skill usage
Count Skill invocations by skill name.

#### 4d. Bigrams and trigrams
Count consecutive tool call pairs (bigrams) and triples (trigrams) to find common sequences.

#### 4e. Notable n-grams
Look for longer sequences (4-6 calls) that repeat 3+ times. These are the strongest skill candidates.

### Step 5: Identify workflow clusters

Classify each session by the presence of workflow markers:

| Marker | Detection |
|--------|-----------|
| Investigation | Heavy Read/Grep/Glob without much Edit |
| Commit | `git-add` + `git-commit` or `Skill:commit` |
| PR creation | `gh-pr-create` |
| PR review response | `gh-api` reading PR comments + Edit + push |
| CI monitoring | `gh-run-view` or `gh-run-list` |
| Build/test cycle | `cargo-test`, `cargo-agent-sh`, `npm-agent-sh` |
| Branch setup | `git-checkout-b` or `git-switch-c` |

Report session counts per workflow type.

### Step 6: Generate the report

Structure the output as a markdown report with these sections:

---

#### Section 1: Overview
```
# Tool Usage Analysis

**Scope**: <project(s)>
**Period**: <date range>
**Sessions**: <N> | **Tool Calls**: <N>
```

#### Section 2: Tool Usage Breakdown
Table of tool counts and percentages.

#### Section 3: Top Commands
Top 20 Bash commands with counts.

#### Section 4: Existing Skill Usage
Table of skill invocations — shows what's already working well.

#### Section 5: Workflow Clusters
Session classification table with counts and percentages.

#### Section 6: Common Sequences (n-grams)
Top bigrams, trigrams, and notable longer sequences.

#### Section 7: Skillable Workflows (the key output)

Present a table of workflows that **could become skills**, with evidence:

```
## Skillable Workflows

| # | Workflow | Frequency | Sequence | Effort Saved | Exists? |
|---|----------|-----------|----------|-------------|---------|
| 1 | CI fix cycle | 8 sessions/wk | gh-run-view → grep → Read → Edit → push | ~15 calls/session | No |
| 2 | PR review response | 12 sessions/wk | gh-api comments → Read → Edit → commit → push | ~10 calls/session | No |
| ...
```

For each skillable workflow, include:
- **Frequency**: How often it occurs
- **Canonical sequence**: The typical tool call chain
- **Effort saved**: Approximate tool calls eliminated per invocation
- **Exists?**: Whether there's already a skill for this (check `~/.claude/skills/`)

#### Section 8: Already Well-Served Patterns

List common workflows that DON'T need a new skill, and why:

```
## Already Well-Served (no skill needed)

| Pattern | Why it's fine |
|---------|--------------|
| Investigation (Read/Grep/Glob) | Open-ended; Agent subagents handle this |
| Commit workflow | `/commit` skill already exists |
| RALPH validation | `/ralph` skill already exists |
| Simple git operations | Too simple for a skill (1-2 commands) |
```

---

### Step 7: Offer to create skills

After presenting the report, ask the user:

```
Would you like me to create SKILL.md files for any of these?
Specify by number, or "all" to create all recommended skills.
```

If the user selects skills to create:
1. Create `~/.claude/skills/<name>/SKILL.md` for each
2. Follow the standard SKILL.md format (YAML frontmatter with name, description, allowed-tools)
3. Design each skill's workflow based on the observed tool call sequences

### Step 8: Save the report

Save the analysis report to `docs/plans/skill-analysis-<date>.md` (for project-scoped) or to a temp file for cross-project analyses.

## Tips for efficient analysis

- **JSONL files can be large** — use grep/awk to extract just the tool call data, don't read entire files
- **Parallelize** — when scanning multiple projects, process them concurrently
- **Normalize commands** — group variations of the same command (e.g., `git add .` and `git add src/foo.rs` are both `git-add`)
- **Ignore Agent/subagent internals** — only count top-level tool calls, not what subagents do internally
- **Session deduplication** — some sessions may be continuations of others; treat each JSONL as independent
- **Existing skills check** — scan `~/.claude/skills/` for existing skill directories to populate the "Exists?" column

## Example invocations

```
/skillable                           # Analyze current project, last 7 days
/skillable --all                     # Analyze all projects, last 7 days
/skillable --all --days 30           # All projects, last 30 days
/skillable --projects ai-barometer cadence-cli   # Specific projects
```
