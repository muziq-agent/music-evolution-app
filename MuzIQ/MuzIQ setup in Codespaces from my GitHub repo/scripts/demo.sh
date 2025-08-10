#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

# activate venv (for backend)
if [ -f .venv/bin/activate ]; then
  . .venv/bin/activate
fi

# start backend in background
./backend/uvicorn.sh &

# start frontend in foreground (keeps terminal open)
cd frontend
npm run dev -- --host
