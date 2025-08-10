#!/usr/bin/env bash
set -euo pipefail

VER="${1:-}"
TITLE="${2:-}"
BODY="${3:-}"

if [[ -z "$VER" ]]; then
  echo "Usage: ./_release.sh vX.Y[.Z] [\"Title\"] [\"Body (optional; auto if empty)\"]"
  exit 1
fi

# Make sure we’re up to date locally
git fetch --tags origin

# Refuse to release with dirty working tree
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "❌ You have uncommitted changes. Commit/stash before releasing."
  exit 1
fi

# Last tag (for changelog)
LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"

# Make tag if it doesn't exist yet
if git rev-parse "$VER" >/dev/null 2>&1; then
  echo "ℹ️  Tag $VER already exists."
else
  git tag -a "$VER" -m "${TITLE:-Release $VER}"
  git push origin "$VER"
fi

# Build release notes if not provided
if [[ -z "$BODY" ]]; then
  if [[ -n "$LAST_TAG" ]]; then
    RANGE="$LAST_TAG..HEAD"
  else
    RANGE=""
  fi
  BODY="$(git log --pretty=format:'- %s (%h)' ${RANGE})"
  if [[ -z "$BODY" ]]; then
    BODY="Initial release."
  fi
fi

# Create or update the release via GitHub CLI
if gh release view "$VER" >/dev/null 2>&1; then
  echo "✏️  Updating existing release $VER…"
  gh release edit "$VER" -t "${TITLE:-$VER}" -n "$BODY"
else
  echo "🚀 Creating release $VER…"
  gh release create "$VER" -t "${TITLE:-$VER}" -n "$BODY"
fi

echo "✅ Release $VER published/updated."
