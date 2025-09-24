#!/usr/bin/env bash
# sweep.sh — Move non-Hugo system files out of the repo root into an archive folder.
# Usage:
#   ./sweep.sh            -> Interactive run: shows list, asks confirm, then moves.
#   ./sweep.sh --list     -> Show what WOULD be moved (no changes).
#   ./sweep.sh --dry-run  -> Like --list but prints commands instead of running them.
#   ./sweep.sh --yes      -> Don't ask for confirmation; proceed.
#   ./sweep.sh --archive-dir DIR  -> put archive in DIR (default archive_YYYYmmdd-HHMMSS)
#
# Behavior:
#  - Detects repo root via `git rev-parse --show-toplevel`.
#  - Whitelist keeps Hugo-essential files/dirs.
#  - Moves everything else (except .git and the chosen archive dir) into the archive dir.
#  - Safe defaults: lists first, requires explicit confirm or --yes to perform moves.
#
set -euo pipefail

progname="$(basename "$0")"

show_help() {
  cat <<EOF
Usage: $progname [--list] [--dry-run] [--yes] [--archive-dir DIR] [--help]

Options:
  --list           Show what would be archived (no changes).
  --dry-run        Show commands that would run (no changes).
  --yes            Don't ask for confirmation; proceed with the move.
  --archive-dir    Directory name (under repo root) to place archived files.
  --help           Show this help and exit.

This script MOVES files/dirs that are NOT part of the Hugo site sources
into an archive folder, so the repo root becomes "clean" while everything
is still preserved in the archive.
EOF
}

# Defaults
LIST_ONLY=false
DRY_RUN=false
ASSUME_YES=false
ARCHIVE_DIR=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_ONLY=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --yes) ASSUME_YES=true; shift ;;
    --archive-dir) ARCHIVE_DIR="$2"; shift 2 ;;
    --help) show_help; exit 0 ;;
    *) echo "Unknown arg: $1"; show_help; exit 2 ;;
  esac
done

# Find repo root
if ! git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
  echo "❌ Not inside a git repository. Run this inside your repo."
  exit 1
fi
cd "$git_root"

# Default archive dir
if [[ -z "$ARCHIVE_DIR" ]]; then
  ARCHIVE_DIR="archive_$(date +'%Y%m%d-%H%M%S')"
fi

# Whitelist - items that should remain in repo root (Hugo project sources + admin files)
WHITELIST=(
  "content"
  "archetypes"
  "layouts"
  "static"
  "assets"
  "themes"
  "data"
  "i18n"
  "resources"
  ".github"
  "hugo.toml"
  "config.toml"
  "config.yaml"
  "config.yml"
  "README.md"
  "LICENSE"
  "LICENSE.md"
  "LICENSE.txt"
  "Makefile"
  "scripts"
  "package.json"
  "package-lock.json"
  "yarn.lock"
)

# Also exclude the archive dir and .git itself
EXCLUDE_NAMES=(".git")

# Build list of entries in repo root (including dotfiles except . and ..)
mapfile -t entries < <(printf '%s\n' .[^.]* * 2>/dev/null || true)

# Filter entries: skip '.' and '..'
candidates=()
for e in "${entries[@]}"; do
  # skip current and parent entries if they appear
  if [[ "$e" == "." || "$e" == ".." ]]; then
    continue
  fi
  # Skip if the target archive dir name equals entry
  if [[ "$e" == "$ARCHIVE_DIR" ]]; then
    continue
  fi
  # Skip .git and any exclude names
  skip=false
  for ex in "${EXCLUDE_NAMES[@]}"; do
    if [[ "$e" == "$ex" ]]; then
      skip=true
      break
    fi
  done
  $skip || candidates+=("$e")
done

# Determine which candidates are whitelisted
to_move=()
for e in "${candidates[@]}"; do
  wh=false
  for w in "${WHITELIST[@]}"; do
    # exact match
    if [[ "$e" == "$w" ]]; then
      wh=true
      break
    fi
  done
  if ! $wh; then
    to_move+=("$e")
  fi
done

# If nothing to move, exit
if [[ ${#to_move[@]} -eq 0 ]]; then
  echo "✅ Nothing to archive. Repo root already looks clean."
  exit 0
fi

# Print summary
echo "Repo root: $git_root"
echo "Archive target: $ARCHIVE_DIR"
echo
echo "Items that WILL be archived (moved into $ARCHIVE_DIR):"
for it in "${to_move[@]}"; do
  printf "  - %s\n" "$it"
done

if $LIST_ONLY || $DRY_RUN; then
  if $DRY_RUN; then
    echo
    echo "DRY RUN: Commands that would be executed:"
    echo "mkdir -p '$ARCHIVE_DIR'"
    for it in "${to_move[@]}"; do
      echo "mv -v '$it' '$ARCHIVE_DIR/'"
    done
  fi
  exit 0
fi

# Confirm
if ! $ASSUME_YES; then
  echo
  read -r -p "Proceed to move these items into '$ARCHIVE_DIR'? [y/N] " ans
  case "$ans$DRY_RUN" in
    ytrue|Ytrue|yestrue|YEStrue) echo "Dry-run only. No changes made."; exit 0 ;;
    y*|Y*|yes*|YES*) ;;
    *) echo "Aborted by user."; exit 0 ;;
  esac
fi

# Create archive dir
mkdir -p "$ARCHIVE_DIR"

# Move items
echo
echo "Moving..."
for it in "${to_move[@]}"; do
  if $DRY_RUN; then
    echo "mv -v '$it' '$ARCHIVE_DIR/'"
  else
    mv -v -- "$it" "$ARCHIVE_DIR/"
  fi
done

echo
echo "✅ Done. Archived ${#to_move[@]} items to: $ARCHIVE_DIR"
echo "Tip: inspect the archive directory, then commit what you want (e.g., 'git add -A' and commit)."
