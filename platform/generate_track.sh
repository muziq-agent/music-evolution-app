#!/bin/bash
# Auto-backup before running
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/backup_restore.sh" backup

AGENT_ID="8283bac8cab0f1e7"
API_KEY="90d2db125c3a971038da5c6ba10ad9bd"

STYLE="$1"
DURATION="$2"
OUTPUT_FILE="$3"

if [ -z "$STYLE" ] || [ -z "$DURATION" ]; then
  echo "Usage: $0 <style> <duration_sec> [output_file]"
  exit 1
fi

STYLE_LOWER=$(echo "$STYLE" | tr '[:upper:]' '[:lower:]')
YEAR=$(date +%Y)
MONTH=$(date +%m)

if [ -z "$OUTPUT_FILE" ]; then
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  OUTPUT_FILE="${STYLE_LOWER}_${TIMESTAMP}.wav"
fi

mkdir -p "music-library/$STYLE_LOWER/$YEAR/$MONTH"

echo "Submitting job: style='$STYLE', duration=${DURATION}s..."
JOB_RESPONSE=$(curl -s -X POST http://127.0.0.1:8000/jobs \
  -H "Content-Type: application/json" \
  -H "x-agent-id: $AGENT_ID" \
  -H "x-api-key: $API_KEY" \
  -d "{\"task\":\"generate_track\",\"prompt\":\"$STYLE\",\"duration_sec\":$DURATION,\"format\":\"wav\"}")

echo "$JOB_RESPONSE"

