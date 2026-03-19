# Workflow Markers

Classify each session by the presence of these tool call patterns:

| Marker | Detection |
|--------|-----------|
| Investigation | Heavy Read/Grep/Glob without much Edit |
| Commit | `git-add` + `git-commit` or `Skill:commit` |
| PR creation | `gh-pr-create` |
| PR review response | `gh-api` reading PR comments + Edit + push |
| CI monitoring | `gh-run-view` or `gh-run-list` |
| Build/test cycle | `cargo-test`, `cargo-agent-sh`, `npm-agent-sh` |
| Branch setup | `git-checkout-b` or `git-switch-c` |

A session can match multiple markers. Report session counts and percentages per workflow type.
