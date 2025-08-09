#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BKP_DIR="$ROOT/platform/backups"
mkdir -p "$BKP_DIR"

backup_now() {
  TS=$(date +%Y%m%d_%H%M%S)
  cp "$ROOT/platform/generate_track.sh" "$BKP_DIR/generate_track.sh_${TS}.bak"
  cp "$ROOT/platform/apps/api/main.py" "$BKP_DIR/main.py_${TS}.bak"
  echo "✅ Backup complete at $TS"
}

restore_latest() {
  restore_one() {
    local name="$1"
    local dest="$2"
    local latest=$(ls -t "$BKP_DIR" | grep "$name" | head -n 1 || true)
    if [[ -n "$latest" ]]; then
      cp "$BKP_DIR/$latest" "$dest"
      echo "  ✅ $dest <- $latest"
    else
      echo "  ⚠️ No backup for $dest"
    fi
  }
  restore_one generate_track.sh "$ROOT/platform/generate_track.sh"
  restore_one main.py "$ROOT/platform/apps/api/main.py"
  chmod +x "$ROOT"/platform/*.sh 2>/dev/null || true
  echo "✅ Restore complete."
}

case "${1:-}" in
  backup)  backup_now ;;
  restore) restore_latest ;;
  *) echo "Usage: $0 {backup|restore}"; exit 1 ;;
esac
