#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"        # -> platform/
PROJ="$(cd "$ROOT/.." && pwd)"               # -> project root

mkdir -p "$ROOT" "$ROOT/backups"

# --- refresh_keys.sh ---
cat > "$ROOT/refresh_keys.sh" <<'EOF'
#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="http://127.0.0.1:8000"

echo "🔄 Restarting API container..."
docker compose -f "$ROOT/docker-compose.yml" restart api >/dev/null

echo "🔑 Requesting new API credentials..."
NEW=$(curl -s -X POST "$BASE/agents" -H "Content-Type: application/json" -d '{"name":"local-auto"}')
AGENT_ID=$(echo "$NEW" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
API_KEY=$(echo "$NEW" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -z "${AGENT_ID:-}" || -z "${API_KEY:-}" ]]; then
  echo "❌ Failed to parse credentials: $NEW"
  exit 1
fi

# Update generate_track.sh in the same folder
sed -i '' "s/^AGENT_ID=.*/AGENT_ID=\"$AGENT_ID\"/" "$ROOT/generate_track.sh" || true
sed -i '' "s/^API_KEY=.*/API_KEY=\"$API_KEY\"/" "$ROOT/generate_track.sh" || true

echo "✅ Updated generate_track.sh with:"
echo "   AGENT_ID=$AGENT_ID"
echo "   API_KEY=$API_KEY"

# Optional quick self-test
RESP=$(curl -s -X POST "$BASE/jobs" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "x-agent-id: $AGENT_ID" \
  -d '{"task":"generate_track","prompt":"Ambient","duration_sec":2,"format":"wav"}')
echo "🧪 API replied: $RESP"
EOF

# --- auto_push.sh ---
cat > "$ROOT/auto_push.sh" <<'EOF'
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
EOF

# --- backup_restore.sh ---
cat > "$ROOT/backup_restore.sh" <<'EOF'
#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BKP="$ROOT/platform/backups"
mkdir -p "$BKP"

backup_now() {
  TS=$(date +%Y%m%d_%H%M%S)
  for f in generate_track.sh apps/api/main.py refresh_keys.sh auto_push.sh backup_restore.sh autonomy_installer.sh; do
    if [[ -f "$ROOT/platform/$f" ]]; then
      cp "$ROOT/platform/$f" "$BKP/${f//\//_}_$TS.bak"
      echo "  📦 $f"
    fi
  done
  echo "✅ Backup complete at $TS"
}

restore_latest() {
  restore_one() {
    local pattern="$1"; local dest="$2"
    local latest=$(ls -t "$BKP" | grep "$pattern" | head -n 1 || true)
    if [[ -n "$latest" ]]; then
      cp "$BKP/$latest" "$dest"
      echo "  ✅ $dest <- $latest"
    else
      echo "  ⚠️ No backup for $dest"
    fi
  }
  restore_one generate_track.sh "$ROOT/platform/generate_track.sh"
  restore_one main.py "$ROOT/platform/apps/api/main.py"
  restore_one refresh_keys.sh "$ROOT/platform/refresh_keys.sh"
  restore_one auto_push.sh "$ROOT/platform/auto_push.sh"
  restore_one backup_restore.sh "$ROOT/platform/backup_restore.sh"
  restore_one autonomy_installer.sh "$ROOT/platform/autonomy_installer.sh"
  chmod +x "$ROOT"/platform/*.sh 2>/dev/null || true
  echo "✅ Restore complete."
}

case "${1:-}" in
  backup)  backup_now ;;
  restore) restore_latest ;;
  *) echo "Usage: $0 {backup|restore}"; exit 1 ;;
esac
EOF

# --- self_test.sh ---
cat > "$ROOT/self_test.sh" <<'EOF'
#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
echo "🧪 Self-test: generate Ambient track (3s)…"
./generate_track.sh Ambient 3
echo "✅ Test done — check platform/music-library."
EOF

# --- system_commands.md (append) ---
cat >> "$PROJ/system_commands.md" <<'EOF'

## 🔧 Helper Scripts (regenerated)
### 🔄 Refresh API Keys
```bash
./platform/refresh_keys.sh

