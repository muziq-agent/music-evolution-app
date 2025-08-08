#!/bin/bash
set -e

# Go to project root
cd "$(dirname "$0")/.."

# Step 1: Pull latest changes to avoid conflicts
echo "🔄 Pulling latest changes from GitHub..."
git pull origin main --rebase

# Step 2: Add all changes
echo "➕ Staging changes..."
git add .

# Step 3: Commit with timestamp
COMMIT_MSG="Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📝 Committing with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG" || echo "⚠️ No changes to commit."

# Step 4: Push to GitHub
echo "📤 Pushing to GitHub..."
git push origin main

echo "✅ Auto-push complete."

