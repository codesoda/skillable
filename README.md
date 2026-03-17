# Skillable

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that analyzes tool call patterns across your sessions to discover common workflows, suggest new skills, and identify what's already well-served.

## What it does

Skillable scans your Claude Code session transcripts and:

- **Extracts tool call sequences** from JSONL session files
- **Computes usage statistics** — tool frequency, top commands, skill usage
- **Identifies workflow clusters** — investigation, commit, PR creation, CI monitoring, etc.
- **Discovers repeating patterns** — bigrams, trigrams, and longer n-grams
- **Recommends new skills** — workflows that could be automated based on your actual usage
- **Highlights well-served patterns** — things that already have skills or don't need one

## Installation

Copy the `SKILL.md` file into your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/skillable
cp SKILL.md ~/.claude/skills/skillable/SKILL.md
```

## Usage

```
/skillable                                        # Analyze current project, last 7 days
/skillable --all                                  # Analyze all projects, last 7 days
/skillable --all --days 30                        # All projects, last 30 days
/skillable --projects my-app my-lib               # Specific projects
```

## Output

Skillable generates a structured markdown report with:

1. **Overview** — scope, period, session/tool call counts
2. **Tool Usage Breakdown** — counts and percentages per tool
3. **Top Commands** — most-used Bash commands
4. **Existing Skill Usage** — which skills you already use
5. **Workflow Clusters** — session classification
6. **Common Sequences** — repeating tool call patterns
7. **Skillable Workflows** — recommended new skills with frequency, sequence, and effort saved
8. **Already Well-Served** — patterns that don't need a skill

After the report, it offers to create `SKILL.md` files for any recommended workflows.

## License

MIT
