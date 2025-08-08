#!/bin/bash
# refresh_keys.sh — Restart API, get fresh keys, update generate_track.sh

echo "🔄 Restarting API container..."
cd "/Users/APM/Library/CloudStorage/OneDrive-Personal/Projects/MuzIQ/music-evolution-app/platform" || exit
docker compose restart api
sleep 2

echo "🔑 Requesting new API credentials..."
NEW_KEYS=$(curl -s -X POST http://127.0.0.1:8000/agents \
  -H "Content-Type: application/json" \
  -d '{"name": "local-demo"}')

NEW_AGENT_ID=$(echo "$NEW_KEYS" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
NEW_API_KEY=$(echo "$NEW_KEYS" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -z "$NEW_AGENT_ID" || -z "$NEW_API_KEY" ]]; then
  echo "❌ Failed to get new keys. Check if API is running."
  exit 1
fi

# Update generate_track.sh
sed -i '' "s/^AGENT_ID=\".*\"/AGENT_ID=\"$NEW_AGENT_ID\"/" generate_track.sh
sed -i '' "s/^API_KEY=\".*\"/API_KEY=\"$NEW_API_KEY\"/" generate_track.sh

echo "✅ Updated generate_track.sh with:"
echo "   AGENT_ID=$NEW_AGENT_ID"
echo "   API_KEY=$NEW_API_KEY"

