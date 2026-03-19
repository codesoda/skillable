#!/bin/sh
set -eu

# Lint all SKILL.md files using nori-lint.
# Works locally and in CI.
#
# Set ANTHROPIC_API_KEY to enable LLM rules.
# Without it, only static rules run.

# Source .env.local if present (local API key)
if [ -f ".env.local" ]; then
  set -a
  . ./.env.local
  set +a
fi

LINT_DIR="${1:-skills}"
TMP_CONFIG=""
CONFIG_FLAG=""

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  TMP_CONFIG="$(mktemp "${TMPDIR:-/tmp}/nori-lint-config.XXXXXX")"
  trap 'rm -f "$TMP_CONFIG"' EXIT INT TERM
  printf '{"anthropic_api_key":"%s","rules":{"disabled":["first_person","unexplained_url"]}}\n' "$ANTHROPIC_API_KEY" > "$TMP_CONFIG"
  CONFIG_FLAG="--config $TMP_CONFIG"
fi

if command -v nori-lint >/dev/null 2>&1; then
  nori-lint lint "$LINT_DIR" $CONFIG_FLAG
else
  npx nori-lint lint "$LINT_DIR" $CONFIG_FLAG
fi
