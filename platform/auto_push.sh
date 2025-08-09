#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git pull --rebase
git add -A
if git diff --cached --quiet; then
  echo "📭 Nothing to push."
  exit 0
fi
STAMP=$(date +"%Y-%m-%d %H:%M:%S")
HOST=$(hostname)
git commit -m "chore: auto-push from $HOST @ $STAMP"
git push origin main
echo "✅ Pushed."
