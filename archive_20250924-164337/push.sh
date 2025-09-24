#!/usr/bin/env bash
set -euo pipefail

MSG=${1:-"update posts"}

git add content/posts
git commit -m "$MSG"
git push origin main

