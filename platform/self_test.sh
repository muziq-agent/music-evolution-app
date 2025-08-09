#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
echo "🧪 Self-test: generate Ambient track (3s)…"
./generate_track.sh Ambient 3
echo "✅ Test complete — check music-library."
