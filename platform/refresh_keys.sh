#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BASE="http://127.0.0.1:8000"

echo "🔄 Restarting API container..."
docker compose -f "$ROOT/docker-compose.yml" restart api

echo "🔑 Requesting new API credentials..."
NEW=$(curl -s -X POST "$BASE/agents" -H "Content-Type: application/json" -d '{"name":"local-auto"}')
AGENT_ID=$(echo "$NEW" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
API_KEY=$(echo "$NEW" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

# Patch generate_track.sh
sed -i '' "s/^AGENT_ID=.*/AGENT_ID=\"$AGENT_ID\"/" "$ROOT/generate_track.sh"
sed -i '' "s/^API_KEY=.*/API_KEY=\"$API_KEY\"/" "$ROOT/generate_track.sh"

echo "✅ Updated generate_track.sh with:"
echo "   AGENT_ID=$AGENT_ID"
echo "   API_KEY=$API_KEY"
