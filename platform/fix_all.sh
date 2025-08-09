#!/bin/bash
set -euo pipefail

BASE="http://127.0.0.1:8000"

echo "🔄 Restarting API container..."
docker compose -f platform/docker-compose.yml down -v
docker compose -f platform/docker-compose.yml up -d --build

echo "⏳ Waiting for API..."
sleep 5

echo "🆕 Creating a fresh agent inside API..."
NEW=$(curl -s -X POST $BASE/agents \
  -H "Content-Type: application/json" \
  -d '{"name":"persistent-agent"}')

AGENT_ID=$(echo "$NEW" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
API_KEY=$(echo "$NEW" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -z "$AGENT_ID" || -z "$API_KEY" ]]; then
    echo "❌ Failed to create agent."
    exit 1
fi

echo "✅ Got new keys:"
echo "   AGENT_ID=$AGENT_ID"
echo "   API_KEY=$API_KEY"

echo "✏️ Updating generate_track.sh..."
sed -i '' "s/^AGENT_ID=.*/AGENT_ID=\"$AGENT_ID\"/" platform/generate_track.sh
sed -i '' "s/^API_KEY=.*/API_KEY=\"$API_KEY\"/" platform/generate_track.sh

echo "🧪 Running self-test..."
./platform/self_test.sh
