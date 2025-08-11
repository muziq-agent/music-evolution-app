#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCR="$ROOT/.muziq_scratch"
API_LOG="$SCR/api.log";  API_PID="$SCR/api.pid"
WEB_LOG="$SCR/web.log";  WEB_PID="$SCR/web.pid"
FRONTEND_DIR="${FRONTEND_DIR:-$ROOT/.muziq_scratch/frontend}"
VITE_PORT="${VITE_PORT:-5173}"

detect_frontend() {
  if [ ! -f "$FRONTEND_DIR/package.json" ]; then
    # find first package.json with a vite dev script
    local found
    found="$(find "$ROOT" -maxdepth 3 -name package.json -print0 \
      | xargs -0 -I{} sh -c 'jq -er ".scripts.dev|contains(\"vite\")" {} >/dev/null 2>&1 && echo {}' \
      | head -n1 || true)"
    [ -n "$found" ] && FRONTEND_DIR="$(dirname "$found")"
  fi
}

is_running() { [ -f "$1" ] && kill -0 "$(cat "$1")" 2>/dev/null; }

start_api() {
  mkdir -p "$SCR"
  echo "▶️  Starting API (uvicorn) ..."
  uvicorn api.main:app --reload --host 127.0.0.1 --port 8000 >"$API_LOG" 2>&1 &
  echo $! > "$API_PID"
  echo "   → log: $API_LOG  (pid $(cat "$API_PID"))"
}

start_web() {
  detect_frontend
  if [ ! -f "$FRONTEND_DIR/package.json" ]; then
    echo "❌ Could not find a Vite app. Set FRONTEND_DIR and retry." >&2
    exit 1
  fi
  echo "▶️  Starting Vite in $FRONTEND_DIR on :$VITE_PORT ..."
  ( cd "$FRONTEND_DIR" && npm run dev -- --port "$VITE_PORT" --strictPort ) >"$WEB_LOG" 2>&1 &
  echo $! > "$WEB_PID"
  echo "   → log: $WEB_LOG  (pid $(cat "$WEB_PID"))"
}

stop_api() { if is_running "$API_PID"; then echo "⏹  Stopping API"; kill $(cat "$API_PID") || true; rm -f "$API_PID"; fi; }
stop_web() {
  # only kill vite/watchfiles to avoid nuking Codespaces node
  echo "⏹  Stopping frontend (vite)"; pkill -f "vite" || true; pkill -f "watchfiles" || true
  rm -f "$WEB_PID"
}

health() {
  curl -fsS http://127.0.0.1:8000/api/health >/dev/null 2>&1
}

wait_api() {
  echo -n "⏳ Waiting for API"; for i in {1..40}; do
    if health; then echo " — OK"; return 0; fi
    echo -n "."; sleep 0.25
  done; echo; echo "❌ API not responding"; exit 1
}

case "${1:-restart}" in
  start)
    start_api; wait_api; start_web
    ;;
  stop)
    stop_web; stop_api
    ;;
  restart)
    stop_web; stop_api
    start_api; wait_api; start_web
    ;;
  status)
    echo "API: $(is_running "$API_PID" && echo up || echo down)  log:$API_LOG"
    echo "WEB: $(is_running "$WEB_PID" && echo up || echo down)  log:$WEB_LOG"
    ;;
  logs)
    echo "---- API ($API_LOG) ----"; tail -n 80 -f "$API_LOG" &
    echo "---- WEB ($WEB_LOG) ----"; tail -n 80 -f "$WEB_LOG"
    ;;
  *)
    echo "Usage: $0 [start|stop|restart|status|logs]"; exit 2;;
esac
