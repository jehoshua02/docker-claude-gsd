#!/usr/bin/env bash
set -e

IMAGE="jehoshua02/claude-gsd"
VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "Error: version required. Run ./scripts/tag.sh first, then pass the version."
  exit 1
fi

if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: version must be semver (e.g. 0.0.4), got: $VERSION"
  exit 1
fi

echo "Pushing $IMAGE:$VERSION and latest ..."
docker push "$IMAGE:$VERSION"
docker push "$IMAGE:latest"

git push origin "v$VERSION"

echo ""
echo "Pushed:"
echo "  $IMAGE:$VERSION"
echo "  $IMAGE:latest"
echo "  git: v$VERSION"
