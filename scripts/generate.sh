#!/bin/sh
# Universal Agent Registry Generator (POSIX Shell)
# Reads agents/*.txt and generates provider-specific agent files.

set -e

AGENTS_DIR="agents"
GITHUB_DIR=".github/agents"
OPENCODE_DIR=".opencode/agents"
MASTER_FILE="AGENTS.md"

if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: $AGENTS_DIR directory not found." >&2
    exit 1
fi

mkdir -p "$GITHUB_DIR" "$OPENCODE_DIR"

# Clear old generated files
rm -f "$GITHUB_DIR"/*.agent.md
rm -f "$OPENCODE_DIR"/*.md

# Start AGENTS.md
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

    # Generate .github/agents/<id>.agent.md
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

    # Generate .opencode/agents/<id>.md
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

echo "Generated $count agents for GitHub Copilot ($GITHUB_DIR)"
echo "Generated $count agents for OpenCode ($OPENCODE_DIR)"
echo "Generated master index ($MASTER_FILE)"
