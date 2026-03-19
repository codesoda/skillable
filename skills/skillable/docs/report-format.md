# Report Format

Generate a markdown report with these 8 sections.

## Section 1: Overview

```
# Tool Usage Analysis

Scope: project-name(s)
Period: date-range
Sessions: N | Tool Calls: N
```

## Section 2: Tool Usage Breakdown

Table of tool counts and percentages.

## Section 3: Top Commands

Top 20 normalized Bash commands with counts.

## Section 4: Existing Skill Usage

Table of skill invocations — shows what is already working well.

## Section 5: Workflow Clusters

Session classification table with counts and percentages per workflow type.

## Section 6: Common Sequences (n-grams)

Top bigrams, trigrams, and notable longer sequences.

## Section 7: Skillable Workflows

The key output. Table of workflows that could become skills:

```
| # | Workflow | Frequency | Sequence | Effort Saved | Exists? |
|---|----------|-----------|----------|-------------|---------|
| 1 | CI fix cycle | 8 sessions/wk | gh-run-view > grep > Read > Edit > push | ~15 calls/session | No |
| 2 | PR review response | 12 sessions/wk | gh-api comments > Read > Edit > commit > push | ~10 calls/session | No |
```

For each workflow include:
- Frequency: how often it occurs
- Canonical sequence: the typical tool call chain
- Effort saved: approximate tool calls eliminated per invocation
- Exists?: whether a skill already covers this (check ~/.claude/skills/, ~/.agent/skills/, ~/.codex/skills/)

## Section 8: Already Well-Served

Patterns that do not need a new skill:

```
| Pattern | Why |
|---------|-----|
| Investigation (Read/Grep/Glob) | Open-ended; Agent subagents handle this |
| Commit workflow | /commit skill already exists |
| Simple git operations | Too simple for a skill (1-2 commands) |
```
