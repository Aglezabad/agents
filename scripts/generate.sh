#!/bin/sh
# Universal Agent Registry Generator (POSIX Shell)
# Reads agents/*.txt and generates provider-specific agent files.
#
# Usage: ./generate.sh --provider <github|opencode|cursor|codex|claude>

set -e

AGENTS_DIR="agents"
GITHUB_DIR=".github/agents"
OPENCODE_DIR=".opencode/agents"
CURSOR_DIR=".cursor/agents"
CODEX_DIR=".codex/agents"
CLAUDE_DIR=".claude/agents"
MASTER_FILE="AGENTS.md"

PROVIDER=""

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
            echo "  github   Generate GitHub Copilot agent files (.github/agents/)"
            echo "  opencode Generate OpenCode agent files (.opencode/agents/)"
            echo "  cursor   Generate Cursor agent files (.cursor/agents/)"
            echo "  codex    Generate GitHub Codex agent files (.codex/agents/)"
            echo "  claude   Generate Claude Code agent files (.claude/agents/)"
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

if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: $AGENTS_DIR directory not found." >&2
    exit 1
fi

# Create and clean only the target directory
if [ "$PROVIDER" = "github" ]; then
    mkdir -p "$GITHUB_DIR"
    rm -f "$GITHUB_DIR"/*.agent.md
elif [ "$PROVIDER" = "opencode" ]; then
    mkdir -p "$OPENCODE_DIR"
    rm -f "$OPENCODE_DIR"/*.md
elif [ "$PROVIDER" = "cursor" ]; then
    mkdir -p "$CURSOR_DIR"
    rm -f "$CURSOR_DIR"/*.md
elif [ "$PROVIDER" = "codex" ]; then
    mkdir -p "$CODEX_DIR"
    rm -f "$CODEX_DIR"/*.md
elif [ "$PROVIDER" = "claude" ]; then
    mkdir -p "$CLAUDE_DIR"
    rm -f "$CLAUDE_DIR"/*.md
fi

# Start AGENTS.md (always generated)
{
    echo "# AGENTS"
    echo ""
    echo "This file centralizes the agent definitions available in this repository. When invoking GitHub Copilot workflows or any automated process that uses an agent, explicitly state which AGENT will be used (for example: \"AGENT: ALPHA\")."
    echo ""
    echo "---"
    echo ""
} > "$MASTER_FILE"

count=0
for agent_file in "$AGENTS_DIR"/*.txt; do
    [ -e "$agent_file" ] || continue

    # Parse metadata: lines before first blank line
    # Extract ID
    agent_id=$(awk '/^ID:/ {print; exit}' "$agent_file" | sed 's/^ID:[[:space:]]*//' | tr -d '\r')
    # Sanitize agent_id to prevent path traversal
    agent_id=$(printf '%s' "$agent_id" | tr -cd 'A-Za-z0-9_-')
    # Extract NAME
    agent_name=$(awk '/^NAME:/ {print; exit}' "$agent_file" | sed 's/^NAME:[[:space:]]*//' | tr -d '\r')
    # Extract DESCRIPTION
    agent_desc=$(awk '/^DESCRIPTION:/ {print; exit}' "$agent_file" | sed 's/^DESCRIPTION:[[:space:]]*//' | tr -d '\r')

    if [ -z "$agent_id" ] || [ -z "$agent_desc" ]; then
        echo "Warning: skipping $agent_file (missing ID or DESCRIPTION)" >&2
        continue
    fi

    # Fallback for empty agent_name
    if [ -z "$agent_name" ]; then
        agent_name="$agent_id"
    fi

    # Extract body: everything after the first blank line
    body=$(awk 'BEGIN{found=0} !found && /^[[:space:]]*$/ {found=1; next} found {print}' "$agent_file")

    # Generate files for the selected provider
    if [ "$PROVIDER" = "github" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$GITHUB_DIR/${agent_id}.agent.md"
    elif [ "$PROVIDER" = "opencode" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$OPENCODE_DIR/${agent_id}.md"
    elif [ "$PROVIDER" = "cursor" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$CURSOR_DIR/${agent_id}.md"
    elif [ "$PROVIDER" = "codex" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$CODEX_DIR/${agent_id}.md"
    elif [ "$PROVIDER" = "claude" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$CLAUDE_DIR/${agent_id}.md"
    fi

    # Append to AGENTS.md
    {
        echo "### $agent_name — ${agent_desc%%.*}"
        echo "$agent_desc"
        echo ""
    } >> "$MASTER_FILE"

    count=$((count + 1))
done

# Append usage rules to AGENTS.md
{
    echo "---"
    echo ""
    echo "## Usage rules (with GitHub Copilot)"
    echo "- When requesting Copilot to run or create code, include a clear top-line instruction naming the agent, e.g.:"
    echo "  - \`AGENT: ALPHA — <task description>\`"
    echo "  - \`AGENT: OMEGA — review branch X and propose fixes\`"
    echo "- If you want a pipeline, specify the sequence:"
    echo "  - \`AGENT: ALPHA -> OMEGA -> PARANOIA -> PERFO — Implement feature X and run full pipeline.\`"
    echo "- The agent named in the AGENT: prefix will determine the style of response (generator, reviewer, security, or performance)."
} >> "$MASTER_FILE"

# Print summary
case "$PROVIDER" in
    github)
        echo "Generated $count agents for GitHub Copilot ($GITHUB_DIR)"
        ;;
    opencode)
        echo "Generated $count agents for OpenCode ($OPENCODE_DIR)"
        ;;
    cursor)
        echo "Generated $count agents for Cursor ($CURSOR_DIR)"
        ;;
    codex)
        echo "Generated $count agents for Codex ($CODEX_DIR)"
        ;;
    claude)
        echo "Generated $count agents for Claude Code ($CLAUDE_DIR)"
        ;;
esac
echo "Generated master index ($MASTER_FILE)"
