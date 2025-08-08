#!/bin/bash
# Auto Push Script - keeps local changes, commits, and pushes to GitHub

PROJECT_DIR="/Users/APM/Library/CloudStorage/OneDrive-Personal/Projects/MuzIQ/music-evolution-app"
LOG_FILE="$PROJECT_DIR/platform/push_log.txt"

cd "$PROJECT_DIR" || { echo "❌ Project folder not found."; exit 1; }

echo "🕒 Starting auto push at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"

# Pull latest changes but keep local work
echo "🔄 Pulling latest changes from GitHub..."
git stash push -m "Auto stash before pull" --include-untracked >> "$LOG_FILE" 2>&1
git pull --rebase >> "$LOG_FILE" 2>&1
git stash pop >> "$LOG_FILE" 2>&1

# Stage, commit, and push
git add .
COMMIT_MSG="Auto commit on $(date '+%Y-%m-%d %H:%M:%S')"
git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1
git push origin main >> "$LOG_FILE" 2>&1

echo "✅ Push complete at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

