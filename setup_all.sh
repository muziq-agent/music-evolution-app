#!/bin/bash
set -euo pipefail
ROOT_DIR="$(pwd)"
BASE="http://127.0.0.1:8000"

echo "🔧 Stopping containers and nuking storage..."
docker compose -f platform/docker-compose.yml down -v || true
rm -rf "$ROOT_DIR/platform/storage" || true

echo "🏗️ Rebuilding API container..."
docker compose -f platform/docker-compose.yml up -d --build

echo "⏳ Waiting for API..."
sleep 5

echo "🆕 Creating a new agent..."
NEW=$(curl -s -X POST "$BASE/agents" \
  -H "Content-Type: application/json" \
  -d '{"name":"auto-setup-agent"}')

echo "📜 API replied: $NEW"
AGENT_ID=$(echo "$NEW" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
API_KEY=$(echo "$NEW" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -z "$AGENT_ID" || -z "$API_KEY" ]]; then
  echo "❌ Failed to get keys. Check API logs."
  exit 1
fi

echo "✏️ Updating generate_track.sh..."
sed -i '' "s/^AGENT_ID=\".*\"/AGENT_ID=\"$AGENT_ID\"/" platform/generate_track.sh
sed -i '' "s/^API_KEY=\".*\"/API_KEY=\"$API_KEY\"/" platform/generate_track.sh

echo "✅ Keys updated:"
echo "   AGENT_ID=$AGENT_ID"
echo "   API_KEY=$API_KEY"

echo "🧪 Running self-test..."
./platform/self_test.sh

echo "⬆️ Pushing changes to GitHub..."
git add -A
git commit -m "Auto-setup: refreshed keys and rebuilt API" || true
git push origin main || true

echo "🎉 Setup complete."

