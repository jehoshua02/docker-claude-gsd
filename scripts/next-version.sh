#!/usr/bin/env bash
set -e

PART="${1:-patch}"

LATEST=$(git tag -l 'v*' --sort=-v:refname | head -1 | sed 's/^v//')

if [ -z "$LATEST" ]; then
  echo "0.0.0"
  exit 0
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$LATEST"

case "$PART" in
  major) echo "$((MAJOR + 1)).0.0" ;;
  minor) echo "$MAJOR.$((MINOR + 1)).0" ;;
  patch) echo "$MAJOR.$MINOR.$((PATCH + 1))" ;;
  *) echo "Usage: ./scripts/next-version.sh [major|minor|patch]"; exit 1 ;;
esac
