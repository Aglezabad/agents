#!/bin/sh
# Verify that generated files match agents/ source of truth.
# Exits 0 if in sync, 1 if any file differs.
#
# Usage: ./check-sync.sh --provider <github|opencode|cursor|codex|claude>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d)"

PROVIDER=""
TIER="performance"

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        --tier)
            TIER="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude> [--tier <economy|balanced|performance>]"
            echo ""
            echo "Options:"
            echo "  --tier  Model tier to check: economy, balanced, or performance (default: performance)"
            echo ""
            echo "Providers:"
            echo "  github   Check GitHub Copilot agent files"
            echo "  opencode Check OpenCode agent files"
            echo "  cursor   Check Cursor agent files"
            echo "  codex    Check GitHub Codex agent files"
            echo "  claude   Check Claude Code agent files"
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude> [--tier <economy|balanced|performance>]" >&2
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

case "$TIER" in
    economy|balanced|performance)
        ;;
    *)
        echo "Error: unknown tier '$TIER'" >&2
        echo "Supported tiers: economy, balanced, performance" >&2
        exit 1
        ;;
esac

trap 'rm -rf "$TEMP_DIR"' EXIT

# Step 1: Save current generated files to temp BEFORE regenerating
mkdir -p "$TEMP_DIR/.github/agents" "$TEMP_DIR/.opencode/agents" "$TEMP_DIR/.cursor/agents" "$TEMP_DIR/.codex/agents" "$TEMP_DIR/.claude/agents"

if [ "$PROVIDER" = "github" ]; then
    if [ -d "$REPO_DIR/.github/agents" ]; then
        cp "$REPO_DIR/.github/agents"/*.agent.md "$TEMP_DIR/.github/agents/" 2>/dev/null || true
    fi
elif [ "$PROVIDER" = "opencode" ]; then
    if [ -d "$REPO_DIR/.opencode/agents" ]; then
        cp "$REPO_DIR/.opencode/agents"/*.md "$TEMP_DIR/.opencode/agents/" 2>/dev/null || true
    fi
elif [ "$PROVIDER" = "cursor" ]; then
    if [ -d "$REPO_DIR/.cursor/agents" ]; then
        cp "$REPO_DIR/.cursor/agents"/*.md "$TEMP_DIR/.cursor/agents/" 2>/dev/null || true
    fi
elif [ "$PROVIDER" = "codex" ]; then
    if [ -d "$REPO_DIR/.codex/agents" ]; then
        cp "$REPO_DIR/.codex/agents"/*.md "$TEMP_DIR/.codex/agents/" 2>/dev/null || true
    fi
elif [ "$PROVIDER" = "claude" ]; then
    if [ -d "$REPO_DIR/.claude/agents" ]; then
        cp "$REPO_DIR/.claude/agents"/*.md "$TEMP_DIR/.claude/agents/" 2>/dev/null || true
    fi
fi

if [ -f "$REPO_DIR/AGENTS.md" ]; then
    cp "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" 2>/dev/null || true
fi

# Step 2: Regenerate fresh copies in repo
echo "Regenerating fresh copies..."
cd "$REPO_DIR"
"$SCRIPT_DIR/generate.sh" --provider "$PROVIDER" --tier "$TIER" >/dev/null

# Step 3: Compare
DIFF_FOUND=0

# Compare provider-specific directory
if [ "$PROVIDER" = "github" ]; then
    for f in "$REPO_DIR/.github/agents"/*.agent.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$TEMP_DIR/.github/agents/$fname" ]; then
            echo "MISMATCH: .github/agents/$fname (new file, not in previous generation)"
            DIFF_FOUND=1
        elif ! diff -q "$f" "$TEMP_DIR/.github/agents/$fname" >/dev/null 2>&1; then
            echo "MISMATCH: .github/agents/$fname"
            DIFF_FOUND=1
        fi
    done
    for f in "$TEMP_DIR/.github/agents"/*.agent.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$REPO_DIR/.github/agents/$fname" ]; then
            echo "MISMATCH: .github/agents/$fname (file removed)"
            DIFF_FOUND=1
        fi
    done
elif [ "$PROVIDER" = "opencode" ]; then
    for f in "$REPO_DIR/.opencode/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$TEMP_DIR/.opencode/agents/$fname" ]; then
            echo "MISMATCH: .opencode/agents/$fname (new file, not in previous generation)"
            DIFF_FOUND=1
        elif ! diff -q "$f" "$TEMP_DIR/.opencode/agents/$fname" >/dev/null 2>&1; then
            echo "MISMATCH: .opencode/agents/$fname"
            DIFF_FOUND=1
        fi
    done
    for f in "$TEMP_DIR/.opencode/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$REPO_DIR/.opencode/agents/$fname" ]; then
            echo "MISMATCH: .opencode/agents/$fname (file removed)"
            DIFF_FOUND=1
        fi
    done
elif [ "$PROVIDER" = "cursor" ]; then
    for f in "$REPO_DIR/.cursor/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$TEMP_DIR/.cursor/agents/$fname" ]; then
            echo "MISMATCH: .cursor/agents/$fname (new file, not in previous generation)"
            DIFF_FOUND=1
        elif ! diff -q "$f" "$TEMP_DIR/.cursor/agents/$fname" >/dev/null 2>&1; then
            echo "MISMATCH: .cursor/agents/$fname"
            DIFF_FOUND=1
        fi
    done
    for f in "$TEMP_DIR/.cursor/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$REPO_DIR/.cursor/agents/$fname" ]; then
            echo "MISMATCH: .cursor/agents/$fname (file removed)"
            DIFF_FOUND=1
        fi
    done
elif [ "$PROVIDER" = "codex" ]; then
    for f in "$REPO_DIR/.codex/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$TEMP_DIR/.codex/agents/$fname" ]; then
            echo "MISMATCH: .codex/agents/$fname (new file, not in previous generation)"
            DIFF_FOUND=1
        elif ! diff -q "$f" "$TEMP_DIR/.codex/agents/$fname" >/dev/null 2>&1; then
            echo "MISMATCH: .codex/agents/$fname"
            DIFF_FOUND=1
        fi
    done
    for f in "$TEMP_DIR/.codex/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$REPO_DIR/.codex/agents/$fname" ]; then
            echo "MISMATCH: .codex/agents/$fname (file removed)"
            DIFF_FOUND=1
        fi
    done
elif [ "$PROVIDER" = "claude" ]; then
    for f in "$REPO_DIR/.claude/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$TEMP_DIR/.claude/agents/$fname" ]; then
            echo "MISMATCH: .claude/agents/$fname (new file, not in previous generation)"
            DIFF_FOUND=1
        elif ! diff -q "$f" "$TEMP_DIR/.claude/agents/$fname" >/dev/null 2>&1; then
            echo "MISMATCH: .claude/agents/$fname"
            DIFF_FOUND=1
        fi
    done
    for f in "$TEMP_DIR/.claude/agents"/*.md; do
        [ -e "$f" ] || continue
        fname=$(basename "$f")
        if [ ! -f "$REPO_DIR/.claude/agents/$fname" ]; then
            echo "MISMATCH: .claude/agents/$fname (file removed)"
            DIFF_FOUND=1
        fi
    done
fi

# Compare AGENTS.md
if [ ! -f "$TEMP_DIR/AGENTS.md" ]; then
    if [ -f "$REPO_DIR/AGENTS.md" ]; then
        echo "MISMATCH: AGENTS.md (new file, not in previous generation)"
        DIFF_FOUND=1
    fi
elif ! diff -q "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" >/dev/null 2>&1; then
    echo "MISMATCH: AGENTS.md"
    DIFF_FOUND=1
fi

if [ "$DIFF_FOUND" -eq 1 ]; then
    echo ""
    echo "Error: generated files are out of sync with agents/. Run scripts/generate.sh to fix." >&2
    exit 1
else
    echo "All generated files are in sync with agents/."
    exit 0
fi
