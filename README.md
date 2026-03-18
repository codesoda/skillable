# Skillable

Agents accumulate patterns you never notice. Skillable mines your session transcripts to surface repeating workflows — so you can turn them into skills instead of doing the same 12-step dance every time.

Works with [Claude Code](https://docs.anthropic.com/en/docs/claude-code), [Codex](https://openai.com/index/introducing-codex/), and other agents that support skills.

## Install

### Using npx skills (recommended)

```bash
npx skills add codesoda/skillable
```

### From GitHub (one-liner)

```sh
curl -sSf https://raw.githubusercontent.com/codesoda/skillable/main/install.sh | sh
```

Installs to `~/.agent/skills/skillable` and symlinks into `~/.claude/skills/` if Claude Code is detected.

### From a clone

```sh
git clone https://github.com/codesoda/skillable.git
cd skillable
sh install.sh
```

Local installs use symlinks so edits to the repo are immediately reflected.

## Usage

```
/skillable                                        # Analyze current project, last 7 days
/skillable --all                                  # Analyze all projects, last 7 days
/skillable --all --days 30                        # All projects, last 30 days
/skillable --projects my-app my-lib               # Specific projects
```

## What you get

A structured markdown report covering:

1. **Overview** — scope, period, session/tool call counts
2. **Tool Usage Breakdown** — counts and percentages per tool
3. **Top Commands** — most-used Bash commands
4. **Existing Skill Usage** — which skills you already use
5. **Workflow Clusters** — session classification
6. **Common Sequences** — repeating tool call patterns (bigrams, trigrams, n-grams)
7. **Skillable Workflows** — recommended new skills with frequency, sequence, and effort saved
8. **Already Well-Served** — patterns that don't need a skill

After the report, it offers to create `SKILL.md` files for any recommended workflows.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENT_SKILLS_DIR` | `~/.agent/skills` | Override canonical install location |
| `SKILLABLE_REPO_OWNER` | `codesoda` | Override repo owner for remote fetches |
| `SKILLABLE_REPO_NAME` | `skillable` | Override repo name for remote fetches |
| `SKILLABLE_REPO_REF` | `main` | Override branch/ref for remote fetches |

## License

MIT
