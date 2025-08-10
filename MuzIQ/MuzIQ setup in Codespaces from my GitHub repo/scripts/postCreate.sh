#!/usr/bin/env bash
set -e
# Create Python venv and install backend deps
python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn[standard] pydantic[dotenv] httpx networkx soundfile librosa

# Create frontend app with Vite (React) and deps
cd frontend
npm create vite@latest . -- --template react
npm install
npm install axios
