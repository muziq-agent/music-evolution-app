#!/usr/bin/env bash
set -euo pipefail

# Start API in background
echo "🚀 Starting API..."
bash .muziq_scratch/start_api.sh &
API_PID=$!

# Trap CTRL+C to kill both processes
trap "echo '🛑 Stopping...'; kill $API_PID; exit 0" INT

# Start frontend (blocks until stopped)
echo "🚀 Starting frontend..."
bash .muziq_scratch/start_web.sh
