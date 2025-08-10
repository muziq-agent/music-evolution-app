#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
. ../.venv/bin/activate
exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
