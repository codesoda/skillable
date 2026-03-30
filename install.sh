#!/bin/sh
set -eu

# ============================================================================
# Skillable Installer
#
# Usage:
#   From a clone:   sh install.sh
#   From GitHub:    curl -sSf https://raw.githubusercontent.com/codesoda/skillable/main/install.sh | sh
# ============================================================================

PROJECT_NAME="skillable"
SKILL_NAME="skillable"
REPO_OWNER="${SKILLABLE_REPO_OWNER:-codesoda}"
REPO_NAME="${SKILLABLE_REPO_NAME:-skillable}"
REPO_REF="${SKILLABLE_REPO_REF:-main}"
RAW_BASE="${SKILLABLE_RAW_BASE:-https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${REPO_REF}}"

AGENT_SKILLS_DIR="${AGENT_SKILLS_DIR:-$HOME/.agent/skills}"

AUTO_YES=0
SOURCE_DIR=""
SOURCE_MODE="remote"
TMP_DIR=""

# --- Helpers ----------------------------------------------------------------

info()  { printf "[%s] %s\n" "$PROJECT_NAME" "$*"; }
warn()  { printf "[%s] WARNING: %s\n" "$PROJECT_NAME" "$*" >&2; }
die()   { printf "[%s] ERROR: %s\n" "$PROJECT_NAME" "$*" >&2; exit 1; }

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT INT TERM

usage() {
  cat <<'EOF'
Install the skillable skill for Claude Code, Codex, and other agents.

Usage:
  sh install.sh [options]
  curl -sSf https://raw.githubusercontent.com/codesoda/skillable/main/install.sh | sh

Options:
  --yes     Non-interactive mode; accept all defaults.
  --help    Show this help text.

Environment variables:
  AGENT_SKILLS_DIR          Override canonical skills root (default: ~/.agent/skills)
  SKILLABLE_REPO_OWNER      Override repo owner for remote fetches.
  SKILLABLE_REPO_NAME       Override repo name for remote fetches.
  SKILLABLE_REPO_REF        Override repo ref/branch for remote fetches.
  SKILLABLE_RAW_BASE        Override full raw base URL for remote fetches.
EOF
}

prompt_yes_no() {
  question="$1"
  default="${2:-yes}"

  if [ "$AUTO_YES" -eq 1 ]; then return 0; fi

  if [ "$default" = "yes" ]; then
    prompt="[Y/n]"; fallback="yes"
  else
    prompt="[y/N]"; fallback="no"
  fi

  if [ -r /dev/tty ] && [ -w /dev/tty ]; then
    while :; do
      printf "%s %s " "$question" "$prompt" > /dev/tty
      if ! IFS= read -r answer < /dev/tty; then break; fi
      case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        [Nn]|[Nn][Oo])     return 1 ;;
        "")
          if [ "$fallback" = "yes" ]; then return 0; fi
          return 1
          ;;
        *) printf "Please answer yes or no.\n" > /dev/tty ;;
      esac
    done
  fi

  [ "$fallback" = "yes" ]
}

fetch_to_file() {
  url="$1"; out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"; return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -qO "$out" "$url"; return 0
  fi
  return 1
}

# --- Source resolution ------------------------------------------------------

resolve_source_dir() {
  # Running from inside the repo?
  if [ -d "./skills" ]; then
    SOURCE_DIR="$(pwd)"
    SOURCE_MODE="local"
    info "Using local source at ${SOURCE_DIR}."
    return 0
  fi

  # Script lives next to skills/?
  case "$0" in
    */*)
      script_dir="$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)"
      if [ -n "$script_dir" ] && [ -d "$script_dir/skills" ]; then
        SOURCE_DIR="$script_dir"
        SOURCE_MODE="local"
        info "Using source next to install.sh at ${SOURCE_DIR}."
        return 0
      fi
      ;;
  esac

  # Remote fetch
  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/${PROJECT_NAME}.XXXXXX")"
  SOURCE_DIR="${TMP_DIR}"
  SOURCE_MODE="remote"

  mkdir -p "${SOURCE_DIR}/skills/${SKILL_NAME}"

  src_url="${RAW_BASE}/skills/${SKILL_NAME}/SKILL.md"
  dest="${SOURCE_DIR}/skills/${SKILL_NAME}/SKILL.md"
  info "Fetching SKILL.md..."
  if ! fetch_to_file "$src_url" "$dest"; then
    die "Unable to download ${src_url}"
  fi
}

# --- Installation -----------------------------------------------------------

install_to_agent_dir() {
  target="${AGENT_SKILLS_DIR}/${SKILL_NAME}"
  mkdir -p "$AGENT_SKILLS_DIR"

  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi

  if [ "$SOURCE_MODE" = "local" ]; then
    ln -s "${SOURCE_DIR}/skills/${SKILL_NAME}" "$target"
    info "Symlinked ${target} -> ${SOURCE_DIR}/skills/${SKILL_NAME}"
  else
    mkdir -p "$target"
    cp -R "${SOURCE_DIR}/skills/${SKILL_NAME}/." "$target/"
    info "Copied ${SKILL_NAME} to ${target}"
  fi
}

symlink_agent_dir() {
  tool_name="$1"
  tool_skills_dir="$2"

  target="${tool_skills_dir}/${SKILL_NAME}"
  source="${AGENT_SKILLS_DIR}/${SKILL_NAME}"

  mkdir -p "$tool_skills_dir"

  if [ -e "$target" ] || [ -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -s "$source" "$target"
  info "${tool_name}: ${target} -> ${source}"
}

# --- Main -------------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --yes)  AUTO_YES=1 ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1 (use --help)" ;;
  esac
  shift
done

info "skillable installer"
info "===================="

resolve_source_dir

# 1. Install to canonical ~/.agent/skills/skillable
info ""
info "Installing to ${AGENT_SKILLS_DIR}/${SKILL_NAME}..."
install_to_agent_dir

# 2. Symlink into agent-specific skill directories if available
info ""

if command -v claude >/dev/null 2>&1; then
  claude_dir="$HOME/.claude/skills"
  if prompt_yes_no "Claude Code detected — symlink to ${claude_dir}/${SKILL_NAME}?" yes; then
    symlink_agent_dir "Claude Code" "$claude_dir"
  fi
fi

if command -v codex >/dev/null 2>&1; then
  codex_dir="$HOME/.codex/skills"
  if prompt_yes_no "Codex detected — symlink to ${codex_dir}/${SKILL_NAME}?" yes; then
    symlink_agent_dir "Codex" "$codex_dir"
  fi
fi

info ""
info "Done! Use skillable in your agent to analyze tool usage patterns."
