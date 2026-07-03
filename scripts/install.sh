#!/bin/sh
# Install agents globally
# Runs generate.sh first, then copies to the user's config directory.
#
# Usage: ./install.sh --provider <github|opencode|cursor|codex|claude>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROVIDER=""
TARGET_DIR=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude>"
            echo ""
            echo "Providers:"
            echo "  github   Install GitHub Copilot agent files to ~/.config/github-copilot/agents/"
            echo "  opencode Install OpenCode agent files to ~/.config/opencode/agents/"
            echo "  cursor   Install Cursor agent files to ~/.config/cursor/agents/"
            echo "  codex    Install GitHub Codex agent files to ~/.config/codex/agents/"
            echo "  claude   Install Claude Code agent files to ~/.config/claude/agents/"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude>" >&2
            exit 1
            ;;
    esac
done

# Validate provider
if [ -z "$PROVIDER" ]; then
    echo "Error: --provider is required" >&2
    echo "Usage: $0 --provider <github|opencode|cursor|codex|claude>" >&2
    exit 1
fi

case "$PROVIDER" in
    github|opencode|cursor|codex|claude)
        ;;
    *)
        echo "Error: unknown provider '$PROVIDER'" >&2
        echo "Supported providers: github, opencode, cursor, codex, claude" >&2
        exit 1
        ;;
esac

# Set target directory based on provider
case "$PROVIDER" in
    github)
        TARGET_DIR="$HOME/.config/github-copilot/agents"
        ;;
    opencode)
        TARGET_DIR="$HOME/.config/opencode/agents"
        ;;
    cursor)
        TARGET_DIR="$HOME/.config/cursor/agents"
        ;;
    codex)
        TARGET_DIR="$HOME/.config/codex/agents"
        ;;
    claude)
        TARGET_DIR="$HOME/.config/claude/agents"
        ;;
esac

echo "Running generator for provider: $PROVIDER..."
"$SCRIPT_DIR/generate.sh" --provider "$PROVIDER"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

echo "Installing agents to $TARGET_DIR..."

if [ "$PROVIDER" = "github" ]; then
    for f in "$SCRIPT_DIR/../.github/agents"/*.agent.md; do
        cp "$f" "$TARGET_DIR/"
        echo "  Installed: $(basename "$f")"
    done
elif [ "$PROVIDER" = "opencode" ]; then
    for f in "$SCRIPT_DIR/../.opencode/agents"/*.md; do
        cp "$f" "$TARGET_DIR/"
        echo "  Installed: $(basename "$f")"
    done
elif [ "$PROVIDER" = "cursor" ]; then
    for f in "$SCRIPT_DIR/../.cursor/agents"/*.md; do
        cp "$f" "$TARGET_DIR/"
        echo "  Installed: $(basename "$f")"
    done
elif [ "$PROVIDER" = "codex" ]; then
    for f in "$SCRIPT_DIR/../.codex/agents"/*.md; do
        cp "$f" "$TARGET_DIR/"
        echo "  Installed: $(basename "$f")"
    done
elif [ "$PROVIDER" = "claude" ]; then
    for f in "$SCRIPT_DIR/../.claude/agents"/*.md; do
        cp "$f" "$TARGET_DIR/"
        echo "  Installed: $(basename "$f")"
    done
fi

echo "Done. Installed $(ls "$TARGET_DIR"/* 2>/dev/null | wc -l) agents globally."
