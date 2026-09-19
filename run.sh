#!/usr/bin/env bash
set -euo pipefail

# Validates and runs a problem solution with input.txt

if [ $# -lt 1 ] || [ -z "$1" ]; then
    echo "Usage: $0 <path/to/problem-directory>"
    echo "Example: $0 week-1/problem-1"
    exit 1
fi

TARGET_DIR="${1%/}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist." >&2
    exit 1
fi

MAIN_FILE="$TARGET_DIR/Main.java"
INPUT_FILE="$TARGET_DIR/input.txt"

if [ ! -f "$MAIN_FILE" ]; then
    echo "Error: '$MAIN_FILE' not found." >&2
    exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: '$INPUT_FILE' not found." >&2
    exit 1
fi

# Use a temporary directory for compiled .class files to avoid polluting the workspace
TMP_BIN="$(mktemp -d /tmp/cp_runner_XXXXXX)"
trap 'rm -rf "$TMP_BIN"' EXIT

if ! javac -d "$TMP_BIN" "$MAIN_FILE"; then
    echo "Error: Compilation failed for '$MAIN_FILE'." >&2
    exit 2
fi

java -cp "$TMP_BIN" Main < "$INPUT_FILE"
