#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$SCRIPT_DIR/build.sh"
bash "$SCRIPT_DIR/test.sh"
