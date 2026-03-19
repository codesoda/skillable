# Interactive Project Selection

Scan for available projects:

```bash
ls ~/.claude/projects/ | grep -o 'projects-[^/]*' | sed 's/projects-//' | sort
```

Present a multi-select checklist via `agent-ui` if available:

```bash
alerter -title "Skillable — Select Projects" \
  -message "Choose which projects to analyze:" \
  -checklist "All projects" "project1" "project2" "project3" ...
```

If `alerter` is unavailable, fall back to `AskUserQuestion` with a text list:

```
Select projects to analyze (space-separated), "all", or Enter for current project only:

  ai-barometer, cadence-cli, dataclaw-dl, ...
```

Then ask about time window (skip if `--days` was provided):

```
Time window: 3 days / 7 days (default) / 14 days / 30 days / custom
```

Use `AskUserQuestion` or `alerter` to collect. Default to 7 days if skipped.
