#!/bin/sh
# Universal Agent Registry Generator (POSIX Shell)
# Reads agents/*.txt and generates provider-specific agent files.
#
# Usage: ./generate.sh --provider <github|opencode|cursor|codex|claude>

set -e

AGENTS_DIR="agents"
PREAMBLES_DIR="preambles"
MASTER_FILE="AGENTS.md"
PREAMBLE_TAG='[**PREAMBLES**]'

PROVIDER=""
NO_PREAMBLE=""
OUT_DIR=""
EXT=""
LABEL=""

# Parse arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --provider)
            PROVIDER="$2"
            shift 2
            ;;
        --no-preamble)
            NO_PREAMBLE="all"
            case "$2" in
                ""|-*)
                    ;;
                *)
                    NO_PREAMBLE="$2"
                    shift
                    ;;
            esac
            shift
            ;;
        -h|--help)
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude> [--no-preamble [<names>|all]]"
            echo ""
            echo "Options:"
            echo "  --no-preamble   Skip injecting preambles. Accepts a comma-separated list of preamble names, or 'all' to skip every preamble (default: inject all)"
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

# Validate provider and resolve output dir, file extension, and display label
if [ -z "$PROVIDER" ]; then
    echo "Error: --provider is required" >&2
    echo "Usage: $0 --provider <github|opencode|cursor|codex|claude>" >&2
    exit 1
fi

case "$PROVIDER" in
    github)
        OUT_DIR=".github/agents"
        EXT="agent.md"
        LABEL="GitHub Copilot"
        ;;
    opencode)
        OUT_DIR=".opencode/agents"
        EXT="md"
        LABEL="OpenCode"
        ;;
    cursor)
        OUT_DIR=".cursor/agents"
        EXT="md"
        LABEL="Cursor"
        ;;
    codex)
        OUT_DIR=".codex/agents"
        EXT="md"
        LABEL="GitHub Codex"
        ;;
    claude)
        OUT_DIR=".claude/agents"
        EXT="md"
        LABEL="Claude Code"
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
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*."$EXT"

# Build the preamble block once (sorted order, minus any excluded via --no-preamble)
PREAMBLE_BLOCK=""
if [ "$NO_PREAMBLE" != "all" ]; then
    for preamble_file in "$PREAMBLES_DIR"/*.txt; do
        [ -e "$preamble_file" ] || continue
        preamble_name=$(basename "$preamble_file" .txt)
        if [ -n "$NO_PREAMBLE" ]; then
            case ",$NO_PREAMBLE," in
                *",$preamble_name,"*)
                    continue
                    ;;
            esac
        fi
        if [ -s "$preamble_file" ]; then
            preamble=$(cat "$preamble_file")
            if [ -z "$PREAMBLE_BLOCK" ]; then
                PREAMBLE_BLOCK="$preamble"
            else
                PREAMBLE_BLOCK="$PREAMBLE_BLOCK

$preamble"
            fi
        else
            echo "Warning: $preamble_file is empty; skipping" >&2
        fi
    done
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

    # Inject preambles at the [**PREAMBLES**] tag; when no preambles are
    # selected, the tag line is dropped. Agents without the tag get no
    # preambles.
    if printf '%s\n' "$body" | grep -qF -- "$PREAMBLE_TAG"; then
        body=$(printf '%s\n' "$body" | awk -v tag="$PREAMBLE_TAG" -v block="$PREAMBLE_BLOCK" '
            index($0, tag) { if (block != "") print block; next }
            { print }
        ')
    elif [ -n "$PREAMBLE_BLOCK" ]; then
        echo "Warning: $agent_file has no $PREAMBLE_TAG tag; skipping preambles" >&2
    fi

    # Generate file for the selected provider
    {
        echo "---"
        echo "name: $agent_name"
        echo "description: $agent_desc"
        echo "---"
        echo ""
        echo "# $agent_name"
        echo ""
        printf '%s\n' "$body"
    } > "$OUT_DIR/${agent_id}.$EXT"

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

echo "Generated $count agents for $LABEL ($OUT_DIR)"
echo "Generated master index ($MASTER_FILE)"
