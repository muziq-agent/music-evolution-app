# MuzIQ Codespaces Setup (from GitHub repo)

## Goal
Demo MuzIQ in **GitHub Codespaces** with:
- FastAPI backend
- Vite + React frontend
- Graph-based music knowledge representation
- Focus on **AI-generated** and other **non-restricted** sources only

## Current Status
- Local setup had API key mismatches; we moved to Codespaces to keep secrets in the cloud and the environment consistent.
- Demo mode starts both backend and frontend automatically on container attach.

## Getting Started (in Codespaces)
1. Rebuild the container (F1 → **Dev Containers: Rebuild and Reopen in Container**).
2. After it opens, demo mode auto-starts:
   - Backend on **8000**
   - Frontend on **5173**
3. In the **PORTS** panel, click the **5173** link to open the app.

## Real AI Generation (optional)
- Add repository **Codespaces Secrets** in GitHub:
  - `MUSIQ_GENERATION_PROVIDER=replicate`
  - `REPLICATE_API_TOKEN=<your-token>`
- Then replace `<model-version>` in `backend/app/main.py` with your chosen model version.

## Manual commands (if you ever want them)
- Backend: `./backend/uvicorn.sh`
- Frontend: `cd frontend && npm run dev`

## Structure
This setup lives under:
`MuzIQ/codespaces-setup`
