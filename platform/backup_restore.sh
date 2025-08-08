#!/bin/bash
# backup_restore.sh — Safe Backup & Restore for generate_track.sh and main.py

BACKUP_DIR="platform/backups"
GEN_SCRIPT="platform/generate_track.sh"
MAIN_PY="platform/apps/api/main.py"

# Create backups folder if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to create a timestamp
timestamp() {
    date +"%Y%m%d_%H%M%S"
}

# Backup files
backup_files() {
    TS=$(timestamp)
    cp "$GEN_SCRIPT" "$BACKUP_DIR/generate_track.sh_${TS}.bak"
    cp "$MAIN_PY" "$BACKUP_DIR/main.py_${TS}.bak"
    echo "✅ Backup complete at $TS"
}

# Restore latest backup (with auto-backup first)
restore_files() {
    echo "📦 Creating backup of current files before restoring..."
    backup_files

    LATEST_GEN=$(ls -t "$BACKUP_DIR"/generate_track.sh_*.bak 2>/dev/null | head -n 1)
    LATEST_MAIN=$(ls -t "$BACKUP_DIR"/main.py_*.bak 2>/dev/null | head -n 1)

    if [[ -z "$LATEST_GEN" || -z "$LATEST_MAIN" ]]; then
        echo "❌ No backups found to restore."
        exit 1
    fi

    cp "$LATEST_GEN" "$GEN_SCRIPT"
    cp "$LATEST_MAIN" "$MAIN_PY"
    echo "♻️ Restored backups from:"
    echo "  - $LATEST_GEN"
    echo "  - $LATEST_MAIN"
}

case "$1" in
    backup)
        backup_files
        ;;
    restore)
        restore_files
        ;;
    *)
        echo "Usage: $0 {backup|restore}"
        exit 1
        ;;
esac

