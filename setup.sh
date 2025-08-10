
set -euo pipefail

# -------- settings (no spaces now) --------
SUBDIR="MuzIQ/codespaces-setup"

# Create project folders
mkdir -p "$SUBDIR/backend/app" "$SUBDIR/frontend" "$SUBDIR/graph" "$SUBDIR/scripts" ".devcontainer"

# ---------- devcontainer at REPO ROOT ----------
cat > ".devcontainer/devcontainer.json" << "JSON"
{
  "name": "MuzIQ Codespaces",
  "image": "mcr.microsoft.com/devcontainers/universal:2",
  "features": {
    "ghcr.io/devcontainers/features/node:1": { "version": "20" },
    "ghcr.io/devcontainers/features/python:1": { "version": "3.11" },
    "ghcr.io/devcontainers/features/ffmpeg:1": {}
  },
  "postCreateCommand": "cd MuzIQ/codespaces-setup && bash scripts/postCreate.sh",
  "postAttachCommand": "cd MuzIQ/codespaces-setup && bash scripts/demo.sh",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter",
        "esbenp.prettier-vscode",
        "ms-azuretools.vscode-docker"
      ]
    }
  },
  "forwardPorts": [5173, 8000],
  "portsAttributes": {
    "5173": { "label": "Vite dev server" },
    "8000": { "label": "FastAPI" }
  }
}
JSON

# ---------- scripts (postCreate + demo) ----------
cat > "$SUBDIR/scripts/postCreate.sh" << "BASH"
#!/usr/bin/env bash
set -e
# Python venv + backend deps
python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn[standard] pydantic[dotenv] httpx networkx soundfile librosa

# Frontend (Vite React) + deps
cd frontend
npm create vite@latest . -- --template react
npm install
npm install axios
