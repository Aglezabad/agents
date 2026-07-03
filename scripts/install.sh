#!/bin/sh
# Install agents globally
# Runs generate.sh first, then copies to the user's config directory.
#
# Usage: ./install.sh [--provider <github|opencode>]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROVIDER="opencode"
TARGET_DIR="$HOME/.config/opencode/agents"

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [--provider <github|opencode> ]"
            echo ""
            echo "Providers:"
            echo "  github    Install GitHub Copilot agent files"
            echo "  opencode  Install OpenCode agent files (default)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 [--provider <github|opencode> ]" >&2
            exit 1
            ;;
    esac
done

# Validate provider
case "$PROVIDER" in
    github|opencode)
        ;;
    *)
        echo "Error: unknown provider '$PROVIDER'" >&2
        echo "Supported providers: github, opencode" >&2
        exit 1
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
fi

echo "Done. Installed $(ls "$TARGET_DIR"/* 2>/dev/null | wc -l) agents globally."
