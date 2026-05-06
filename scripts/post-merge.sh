#!/usr/bin/env bash
set -e

PART="${1:-patch}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION=$(bash "$SCRIPT_DIR/next-version.sh" "$PART")

bash "$SCRIPT_DIR/tag.sh" "$PART"
bash "$SCRIPT_DIR/push.sh" "$VERSION"
