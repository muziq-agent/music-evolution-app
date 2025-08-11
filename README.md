> **MuzIQ Public Demo Edition** — Licensed under **AGPL-3.0**. Commercial use requires explicit written permission from the MuzIQ team. This repo is for demos and community contributions; core production code remains private.

# MuzIQ (Private Repo)

🚧 **This is a private early-stage prototype** for the MuzIQ platform.  
Please do not share, fork, or publish without permission from the core development team.

## What is MuzIQ?
MuzIQ is a fully AI-operated platform for mapping the evolution of music.  
It uses graph-based knowledge representation and interactive UI to educate users on genre development, musical influences, and cultural impact.

## Current Status
- AI-powered React front-end (MuzIQApp)
- Interactive music ontology with AI-generated and unrestricted sources tracks
- Early discussions on integrating blockchain and tokenization
- Vision and roadmap are private for now

## License
AGPL-3.0 – see `LICENSE` file.

## Important
This repository is **private and confidential**. Unauthorized distribution or duplication is not allowed.
## Project To-Do List
[View the live To-Do list on GitHub](https://github.com/muziq-agent/music-evolution-app/blob/main/TODO.md)

## Operations Manual
See [docs/OPERATIONS.md](docs/OPERATIONS.md) for environments, branching, and deploys.

---

## 🚀 Releasing

We use a one-command release script that tags and publishes directly from the terminal.

Example:
\`\`\`bash
./_release.sh v0.3 "Next Demo" "Optional description"
\`\`\`

This will:
1. Create the git tag (e.g., v0.3).
2. Push it to GitHub.
3. Create/update the GitHub Release with notes.


## Developer Safe Start Script
Use this helper to start API + frontend safely (no zombie processes):

- `./scripts/dev_safe.sh restart`  — stop old, start fresh
- `./scripts/dev_safe.sh status`   — show running state
- `./scripts/dev_safe.sh logs`     — tail API & web logs
