#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
if [ -f .venv/bin/activate ]; then . .venv/bin/activate; fi
./backend/uvicorn.sh &
cd frontend
npm run dev -- --host
