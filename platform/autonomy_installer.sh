#!/bin/bash
set -e

PROJECT_ROOT="/Users/APM/Library/CloudStorage/OneDrive-Personal/Projects/MuzIQ/music-evolution-app"
PLATFORM_DIR="$PROJECT_ROOT/platform"
BACKUP_DIR="$PLATFORM_DIR/backups"
GENERATE_SCRIPT="$PLATFORM_DIR/generate_track.sh"
MAIN_PY="$PLATFORM_DIR/apps/api/main.py"

echo "🚀 Starting autonomy setup..."

# 1. Create backups
mkdir -p "$BACKUP_DIR"
TS=$(date +%Y%m%d_%H%M%S)
cp "$GENERATE_SCRIPT" "$BACKUP_DIR/generate_track.sh_$TS.bak" || echo "⚠️ No generate_track.sh found"
cp "$MAIN_PY" "$BACKUP_DIR/main.py_$TS.bak" || echo "⚠️ No main.py found"
echo "📦 Backup complete at $TS"

# 2. Restart API and refresh keys
echo "🔄 Restarting API container..."
cd "$PLATFORM_DIR"
docker compose restart api

echo "🔑 Requesting new API credentials..."
NEW_KEYS=$(curl -s -X POST http://127.0.0.1:8000/agents \
  -H "Content-Type: application/json" \
  -d '{"name": "local-demo"}')
NEW_AGENT_ID=$(echo "$NEW_KEYS" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
NEW_API_KEY=$(echo "$NEW_KEYS" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -n "$NEW_AGENT_ID" && -n "$NEW_API_KEY" ]]; then
  sed -i '' "s/^AGENT_ID=\".*\"/AGENT_ID=\"$NEW_AGENT_ID\"/" "$GENERATE_SCRIPT"
  sed -i '' "s/^API_KEY=\".*\"/API_KEY=\"$NEW_API_KEY\"/" "$GENERATE_SCRIPT"
  echo "✅ Updated generate_track.sh with:"
  echo "   AGENT_ID=$NEW_AGENT_ID"
  echo "   API_KEY=$NEW_API_KEY"
else
  echo "❌ Failed to retrieve API keys"
  exit 1
fi

# 3. Push updates to GitHub
echo "⬆️ Committing and pushing updates to GitHub..."
cd "$PROJECT_ROOT"
git add .
git commit -m "Auto-update: refreshed API keys and backups at $TS" || echo "ℹ️ No changes to commit"
git pull --rebase
git push origin main

# 4. Add auto-run on macOS startup (with test track generation)
ZSHRC="$HOME/.zshrc"
STARTUP_CMD="$PLATFORM_DIR/autonomy_installer.sh && $GENERATE_SCRIPT Ambient 3"
if ! grep -Fxq "$STARTUP_CMD" "$ZSHRC"; then
  echo "$STARTUP_CMD" >> "$ZSHRC"
  echo "🛠 Added auto-run with health test track on startup in ~/.zshrc"
else
  echo "ℹ️ Startup command already exists in ~/.zshrc"
fi

# 5. Immediate test run now
echo "🎵 Running immediate health check: generating test track..."
"$GENERATE_SCRIPT" Ambient 3 "health_check.wav"

echo "🎯 Autonomy setup complete!"

