#!/bin/sh
# Install OpenCode agents globally
# Runs generate.sh first, then copies to ~/.config/opencode/agents/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.config/opencode/agents"

echo "Running generator..."
"$SCRIPT_DIR/generate.sh"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

echo "Installing agents to $TARGET_DIR..."
for f in "$SCRIPT_DIR/../.opencode/agents"/*.md; do
    cp "$f" "$TARGET_DIR/"
    echo "  Installed: $(basename "$f")"
done

echo "Done. Installed $(ls "$TARGET_DIR"/*.md 2>/dev/null | wc -l) agents globally."
