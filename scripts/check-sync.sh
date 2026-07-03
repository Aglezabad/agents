#!/bin/sh
# Verify that generated files match agents/ source of truth.
# Exits 0 if in sync, 1 if any file differs.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TEMP_DIR"' EXIT

# Step 1: Save current generated files to temp BEFORE regenerating
mkdir -p "$TEMP_DIR/.github/agents" "$TEMP_DIR/.opencode/agents"
if [ -d "$REPO_DIR/.github/agents" ]; then
    cp "$REPO_DIR/.github/agents"/*.agent.md "$TEMP_DIR/.github/agents/" 2>/dev/null || true
fi
if [ -d "$REPO_DIR/.opencode/agents" ]; then
    cp "$REPO_DIR/.opencode/agents"/*.md "$TEMP_DIR/.opencode/agents/" 2>/dev/null || true
fi
if [ -f "$REPO_DIR/AGENTS.md" ]; then
    cp "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" 2>/dev/null || true
fi

# Step 2: Regenerate fresh copies in repo
echo "Regenerating fresh copies..."
cd "$REPO_DIR"
"$SCRIPT_DIR/generate.sh" >/dev/null

# Step 3: Compare
DIFF_FOUND=0

# Compare .github/agents/
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

# Check for removed files in .github/agents/
for f in "$TEMP_DIR/.github/agents"/*.agent.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if [ ! -f "$REPO_DIR/.github/agents/$fname" ]; then
        echo "MISMATCH: .github/agents/$fname (file removed)"
        DIFF_FOUND=1
    fi
done

# Compare .opencode/agents/
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

# Check for removed files in .opencode/agents/
for f in "$TEMP_DIR/.opencode/agents"/*.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if [ ! -f "$REPO_DIR/.opencode/agents/$fname" ]; then
        echo "MISMATCH: .opencode/agents/$fname (file removed)"
        DIFF_FOUND=1
    fi
done

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
