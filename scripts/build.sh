#!/usr/bin/env bash
set -e

IMAGE="jehoshua02/claude-gsd"

echo "Building $IMAGE ..."
docker build --tag "$IMAGE:build" .

echo ""
echo "Built: $IMAGE:build"
