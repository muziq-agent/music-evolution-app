# Platform Status — MuzIQ

## Overview
The MuzIQ platform is now functional for generating AI music tracks locally via Dockerized FastAPI backend.  
It uses an Agent ID + API key authentication system and stores generated music in an organized local library.

---

## Current Capabilities
- **Generate AI music** with custom style & duration  
- **API key + agent ID** system with `refresh_keys.sh` to rotate credentials instantly  
- **Auto folder organization** by style/year/month  
- **Backup & restore system** for `generate_track.sh` and `main.py`  
- **Docker-based API** (`platform-api-1`) running locally on port `8000`  
- **Music library** saved in `/music-library` with `.wav` and `.ttl` metadata

---

## Key Files
- `platform/generate_track.sh` → Script to generate tracks from CLI  
- `platform/refresh_keys.sh` → Refresh API keys & restart container  
- `platform/backup_restore.sh` → Backup & restore key scripts  
- `apps/api/main.py` → FastAPI backend core logic

---

## Example Usage
```bash
# Generate 3 seconds of Ambient music
./platform/generate_track.sh Ambient 3

# Refresh API credentials
./platform/refresh_keys.sh

# Backup current scripts
./platform/backup_restore.sh backup

# Restore last backup
./platform/backup_restore.sh restore

