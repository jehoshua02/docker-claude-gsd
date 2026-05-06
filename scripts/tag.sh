#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE="jehoshua02/claude-gsd"
PART="$1"

if [ -z "$PART" ]; then
  echo "Usage: ./scripts/tag.sh <major|minor|patch>"
  exit 1
fi

VERSION=$(bash "$SCRIPT_DIR/next-version.sh" "$PART")

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: version must be semver (e.g. 0.0.4), got: $VERSION"
  exit 1
fi

echo "Tagging $IMAGE:build as $VERSION and latest ..."
docker tag "$IMAGE:build" "$IMAGE:$VERSION"
docker tag "$IMAGE:build" "$IMAGE:latest"

git tag "v$VERSION"

echo ""
echo "Tagged:"
echo "  $IMAGE:$VERSION"
echo "  $IMAGE:latest"
echo "  git: v$VERSION"
