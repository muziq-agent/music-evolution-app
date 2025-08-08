#!/bin/bash

ONTOLOGY_FILE="ontology/genres.skos.ttl"

# Pick random genre if none given
if [ -z "$1" ]; then
    if [ -f "$ONTOLOGY_FILE" ]; then
        STYLE=$(grep -oP 'skos:prefLabel "\K[^"]+' "$ONTOLOGY_FILE" | shuf -n 1)
        echo "No style given — picked: $STYLE"
    else
        STYLE="Ambient"
        echo "No ontology found — defaulting to: $STYLE"
    fi
else
    STYLE="$1"
fi

DURATION=${2:-5}

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SAFE_STYLE=$(echo "$STYLE" | tr '[:upper:]' '[:lower:]')
OUTPUT_FILE="${SAFE_STYLE}_${TIMESTAMP}.wav"

echo "Starting MuzIQ API..."
docker compose up -d
sleep 5
echo "MuzIQ API is running on http://127.0.0.1:8000"

./generate_track.sh "$STYLE" "$DURATION" "$OUTPUT_FILE"

