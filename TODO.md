# MuzIQ — Demo Roadmap

## Phase 1 (Now)
- [x] Codespaces scaffold (FastAPI + Vite/React)
- [x] Offline AI-generated tracks (seed.json) with /api/generate
- [x] Frontend "Generate Track" button

## Phase 2 (Near-term)
- [ ] Replace offline seed with live AI generation API
      - Evaluate providers (Suno, Boomy, Mubert, Aiva, Soundraw)
      - Add secret management in Codespaces (Settings → Secrets)
      - Implement POST /api/generate calling provider, return metadata + audio URL
- [ ] Persist tracks to SQLite (sqlmodel / sqlalchemy) instead of in-memory
- [ ] Add simple audio player in frontend (HTML5 <audio>)

## Phase 3 (Showcase & Deploy)
- [ ] Vercel: host the frontend (check current pricing; basic tier likely sufficient)
- [ ] Fly.io or Railway: host FastAPI backend
- [ ] Health checks + CORS tighten for production

## Phase 4 (Graph & Ontology)
- [ ] Integrate graph-based music ontology (no Spotify/iTunes)
- [ ] Model lineage: new AI tracks link to earlier AI tracks (timestamped)
- [ ] Visualize graph (frontend) and expose `/api/graph` queries

## Phase 5 (Polish)
- [ ] Authentication (minimal)
- [ ] Rate limiting on /api/generate
- [ ] Better error handling & logs
