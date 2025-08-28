#!/usr/bin/env bash
# Simple Hugo deploy script for GitHub Pages (Project Pages)
# - Builds site with clean destination
# - Pushes contents to gh-pages branch using a temporary clone
# Requirements: git, rsync, hugo (extended if your theme needs SCSS)

set -euo pipefail

# --- Edit below to match your repo ---
REPO_URL="https://github.com/jukejeew/sarazian.git"
BRANCH="gh-pages"
BASEURL="https://jukejeew.github.io/sarazian/"
# -------------------------------------

echo "[1/4] Clean build with Hugo"
hugo --cleanDestinationDir --minify --baseURL "$BASEURL"

echo "[2/4] Prepare temporary clone for branch: $BRANCH"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Try shallow clone of gh-pages; if branch doesn't exist yet, create orphan
if git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$TMP_DIR"; then
  echo "✓ Cloned $BRANCH"
else
  echo "Branch $BRANCH not found; creating orphan branch"
  git clone "$REPO_URL" "$TMP_DIR"
  pushd "$TMP_DIR" >/dev/null
  git checkout --orphan "$BRANCH"
  rm -rf ./*
  popd >/dev/null
fi

echo "[3/4] Sync public/ to temp repo"
rsync -av --delete public/ "$TMP_DIR"/

echo "[4/4] Commit & push"
pushd "$TMP_DIR" >/dev/null
git add -A
if git commit -m "Deploy $(date -u +'%Y-%m-%d %H:%M:%S') [skip ci]"; then
  git push origin "$BRANCH"
  echo "✓ Deployed to $BRANCH"
else
  echo "No changes to commit."
fi
popd >/dev/null

echo "Done. Visit: ${BASEURL}"
