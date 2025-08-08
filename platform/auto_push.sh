#!/bin/bash
# Auto push changes to GitHub with automatic backups

set -e

# Variables
PROJECT_ROOT="/Users/APM/Library/CloudStorage/OneDrive-Personal/Projects/MuzIQ/music-evolution-app"
PLATFORM_DIR="$PROJECT_ROOT/platform"
BACKUP_DIR="$PLATFORM_DIR/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Step 1: Backup important files
echo "📦 Creating backup before push..."
mkdir -p "$BACKUP_DIR"

cp "$PLATFORM_DIR/generate_track.sh" "$BACKUP_DIR/generate_track.sh_$TIMESTAMP.bak"
cp "$PLATFORM_DIR/apps/api/main.py" "$BACKUP_DIR/main.py_$TIMESTAMP.bak"

echo "✅ Backup complete at $TIMESTAMP"
echo "   - $BACKUP_DIR/generate_track.sh_$TIMESTAMP.bak"
echo "   - $BACKUP_DIR/main.py_$TIMESTAMP.bak"

# Step 2: Pull latest changes
echo "🔄 Pulling latest changes from GitHub..."
cd "$PROJECT_ROOT"
git pull --rebase || { echo "❌ Git pull failed! Resolve conflicts before retrying."; exit 1; }

# Step 3: Stage and commit changes
echo "📝 Staging and committing changes..."
git add .
git commit -m "Auto backup + push on $TIMESTAMP" || echo "ℹ️ No changes to commit."

# Step 4: Push to GitHub
echo "🚀 Pushing to GitHub..."
git push origin main

echo "✅ Auto push completed successfully!"

