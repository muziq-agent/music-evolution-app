#!/bin/bash
# refresh_keys.sh — restart API, mint fresh keys, patch generator, and self-test
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"     # platform/
BASE="http://127.0.0.1:8000"
GEN="$ROOT/generate_track.sh"

say() { printf "%s\n" "$*"; }

say "🔄 Restarting API container..."
docker compose -f "$ROOT/docker-compose.yml" restart api >/dev/null || {
  say "❌ Could not restart API. Is Docker running?"
  exit 1
}

# Wait for health
for i in {1..20}; do
  if curl -fs "$BASE/health" | grep -q '"ok":true'; then
    break
  fi
  sleep 0.5
done

say "🔑 Requesting new API credentials..."
NEW=$(curl -fs -X POST "$BASE/agents" \
  -H "Content-Type: application/json" \
  -d '{"name":"local-auto"}') || { say "❌ /agents call failed"; exit 1; }

AGENT_ID=$(echo "$NEW" | sed -E 's/.*"agent_id":"([^"]+)".*/\1/')
API_KEY=$(echo "$NEW" | sed -E 's/.*"api_key":"([^"]+)".*/\1/')

if [[ -z "${AGENT_ID:-}" || -z "${API_KEY:-}" || "$AGENT_ID" == "$NEW" ]]; then
  say "❌ Could not parse credentials: $NEW"
  exit 1
fi

# Patch generate_track.sh robustly (update if present, otherwise insert at top)
if grep -q '^AGENT_ID=' "$GEN"; then
  sed -i '' "s/^AGENT_ID=.*/AGENT_ID=\"$AGENT_ID\"/" "$GEN"
else
  printf 'AGENT_ID="%s"\n%s' "$AGENT_ID" "$(cat "$GEN")" > "$GEN.tmp" && mv "$GEN.tmp" "$GEN"
fi

if grep -q '^API_KEY=' "$GEN"; then
  sed -i '' "s/^API_KEY=.*/API_KEY=\"$API_KEY\"/" "$GEN"
else
  printf 'API_KEY="%s"\n%s' "$API_KEY" "$(cat "$GEN")" > "$GEN.tmp" && mv "$GEN.tmp" "$GEN"
fi

chmod +x "$GEN"

say "✅ Updated generate_track.sh with:"
say "   AGENT_ID=$AGENT_ID"
say "   API_KEY=$API_KEY"

# Quick API sanity check (no files written)
say "🧪 Sanity check: /jobs (2s Ambient)…"
RESP=$(curl -fs -X POST "$BASE/jobs" \
  -H "Content-Type: application/json" \
  -H "x-api-key: $API_KEY" \
  -H "x-agent-id: $AGENT_ID" \
  -d '{"task":"generate_track","prompt":"Ambient","duration_sec":2,"format":"wav"}' \
  || true)

if echo "$RESP" | grep -q '"job_id"'; then
  say "✅ Keys valid. API returned: $RESP"
else
  say "❌ API did not accept keys. Response:"
  echo "$RESP"
  exit 1
fi

# End‑to‑end test (writes a file & RDF)
if [[ -x "$ROOT/self_test.sh" ]]; then
  "$ROOT/self_test.sh"
else
  say "ℹ️ self_test.sh not found; skipping end‑to‑end test."
fi

