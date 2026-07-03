#!/bin/sh
# Verify that generated files match agents/ source of truth.
# Exits 0 if in sync, 1 if any file differs.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Generating fresh copies to temp directory..."
(cd "$REPO_DIR" && "$SCRIPT_DIR/generate.sh" >/dev/null)

# Move generated files to temp for comparison
mkdir -p "$TEMP_DIR/.github/agents" "$TEMP_DIR/.opencode/agents"
cp "$REPO_DIR/.github/agents"/*.agent.md "$TEMP_DIR/.github/agents/" 2>/dev/null || true
cp "$REPO_DIR/.opencode/agents"/*.md "$TEMP_DIR/.opencode/agents/" 2>/dev/null || true
cp "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" 2>/dev/null || true

# Regenerate fresh in temp
cd "$REPO_DIR"
"$SCRIPT_DIR/generate.sh" >/dev/null

DIFF_FOUND=0

# Compare .github/agents/
for f in "$REPO_DIR/.github/agents"/*.agent.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if ! diff -q "$f" "$TEMP_DIR/.github/agents/$fname" >/dev/null 2>&1; then
        echo "MISMATCH: .github/agents/$fname"
        DIFF_FOUND=1
    fi
done

# Compare .opencode/agents/
for f in "$REPO_DIR/.opencode/agents"/*.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if ! diff -q "$f" "$TEMP_DIR/.opencode/agents/$fname" >/dev/null 2>&1; then
        echo "MISMATCH: .opencode/agents/$fname"
        DIFF_FOUND=1
    fi
done

# Compare AGENTS.md
if ! diff -q "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" >/dev/null 2>&1; then
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
