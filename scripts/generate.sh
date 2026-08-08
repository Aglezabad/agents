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
TIER="performance"
NO_PREAMBLE=""

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
            echo "Usage: $0 --provider <github|opencode|cursor|codex|claude> [--tier <economy|balanced|performance>] [--no-preamble [<names>|all]]"
            echo ""
            echo "Options:"
            echo "  --tier          Model tier to generate: economy, balanced, or performance (default: performance)"
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
    # Extract MODEL tiers (optional, provider-agnostic)
    agent_model=$(awk '/^MODEL:/ {print; exit}' "$agent_file" | sed 's/^MODEL:[[:space:]]*//' | tr -d '\r')
    agent_model_balanced=$(awk '/^MODEL_BALANCED:/ {print; exit}' "$agent_file" | sed 's/^MODEL_BALANCED:[[:space:]]*//' | tr -d '\r')
    agent_model_economy=$(awk '/^MODEL_ECONOMY:/ {print; exit}' "$agent_file" | sed 's/^MODEL_ECONOMY:[[:space:]]*//' | tr -d '\r')
    # Extract OpenCode-specific model tier overrides (optional)
    agent_opencode_model=$(awk '/^OPENCODE_MODEL:/ {print; exit}' "$agent_file" | sed 's/^OPENCODE_MODEL:[[:space:]]*//' | tr -d '\r')
    agent_opencode_model_balanced=$(awk '/^OPENCODE_MODEL_BALANCED:/ {print; exit}' "$agent_file" | sed 's/^OPENCODE_MODEL_BALANCED:[[:space:]]*//' | tr -d '\r')
    agent_opencode_model_economy=$(awk '/^OPENCODE_MODEL_ECONOMY:/ {print; exit}' "$agent_file" | sed 's/^OPENCODE_MODEL_ECONOMY:[[:space:]]*//' | tr -d '\r')

    if [ -z "$agent_id" ] || [ -z "$agent_desc" ]; then
        echo "Warning: skipping $agent_file (missing ID or DESCRIPTION)" >&2
        continue
    fi

    # Fallback for empty agent_name
    if [ -z "$agent_name" ]; then
        agent_name="$agent_id"
    fi

    # Determine the model ID to emit for the target provider and tier
    if [ "$PROVIDER" = "opencode" ]; then
        case "$TIER" in
            economy)
                emit_model="${agent_opencode_model_economy:-${agent_opencode_model_balanced:-$agent_opencode_model}}"
                ;;
            balanced)
                emit_model="${agent_opencode_model_balanced:-$agent_opencode_model}"
                ;;
            performance|*)
                emit_model="$agent_opencode_model"
                ;;
        esac
    else
        case "$TIER" in
            economy)
                emit_model="${agent_model_economy:-${agent_model_balanced:-$agent_model}}"
                ;;
            balanced)
                emit_model="${agent_model_balanced:-$agent_model}"
                ;;
            performance|*)
                emit_model="$agent_model"
                ;;
        esac
    fi

    # Extract body: everything after the first blank line
    body=$(awk 'BEGIN{found=0} !found && /^[[:space:]]*$/ {found=1; next} found {print}' "$agent_file")

    # Prepend all preambles in sorted order, skipping any excluded via --no-preamble
    if [ "$NO_PREAMBLE" != "all" ]; then
        preamble_block=""
        for preamble_file in preambles/*.txt; do
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
                if [ -z "$preamble_block" ]; then
                    preamble_block="$preamble"
                else
                    preamble_block="$preamble_block

$preamble"
                fi
            else
                echo "Warning: $preamble_file is empty; skipping" >&2
            fi
        done
        if [ -n "$preamble_block" ]; then
            body="$preamble_block

$body"
        fi
    fi

    # Generate files for the selected provider
    if [ "$PROVIDER" = "github" ]; then
        {
            echo "---"
            echo "name: $agent_name"
            echo "description: $agent_desc"
            if [ -n "$emit_model" ]; then
                echo "model: $emit_model"
            fi
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
            if [ -n "$emit_model" ]; then
                echo "model: $emit_model"
            fi
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
            if [ -n "$emit_model" ]; then
                echo "model: $emit_model"
            fi
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
            if [ -n "$emit_model" ]; then
                echo "model: $emit_model"
            fi
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
            if [ -n "$emit_model" ]; then
                echo "model: $emit_model"
            fi
            echo "---"
            echo ""
            echo "# $agent_name"
            echo ""
            printf '%s\n' "$body"
        } > "$CLAUDE_DIR/${agent_id}.md"
    fi

    # Build recommended model lines for AGENTS.md
    if [ -n "$agent_model" ]; then
        perf_line="- Performance: \`$agent_model\`"
        if [ -n "$agent_opencode_model" ]; then
            perf_line="$perf_line (\`$agent_opencode_model\` on OpenCode)"
        fi
        balanced_line=""
        if [ -n "$agent_model_balanced" ]; then
            balanced_line="- Balanced: \`$agent_model_balanced\`"
            if [ -n "$agent_opencode_model_balanced" ]; then
                balanced_line="$balanced_line (\`$agent_opencode_model_balanced\` on OpenCode)"
            fi
        fi
        economy_line=""
        if [ -n "$agent_model_economy" ]; then
            economy_line="- Economy: \`$agent_model_economy\`"
            if [ -n "$agent_opencode_model_economy" ]; then
                economy_line="$economy_line (\`$agent_opencode_model_economy\` on OpenCode)"
            fi
        fi
    fi

    # Append to AGENTS.md
    {
        echo "### $agent_name — ${agent_desc%%.*}"
        echo "$agent_desc"
        if [ -n "$agent_model" ]; then
            echo ""
            echo "**Recommended models:**"
            echo "$perf_line"
            if [ -n "$balanced_line" ]; then
                echo "$balanced_line"
            fi
            if [ -n "$economy_line" ]; then
                echo "$economy_line"
            fi
        fi
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
        echo "Generated $count agents for GitHub Copilot ($GITHUB_DIR) using $TIER tier"
        ;;
    opencode)
        echo "Generated $count agents for OpenCode ($OPENCODE_DIR) using $TIER tier"
        ;;
    cursor)
        echo "Generated $count agents for Cursor ($CURSOR_DIR) using $TIER tier"
        ;;
    codex)
        echo "Generated $count agents for Codex ($CODEX_DIR) using $TIER tier"
        ;;
    claude)
        echo "Generated $count agents for Claude Code ($CLAUDE_DIR) using $TIER tier"
        ;;
esac
echo "Generated master index ($MASTER_FILE)"
