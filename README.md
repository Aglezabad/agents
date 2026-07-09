# agents

A universal agent prompt repository for GitHub Copilot, OpenCode, Cursor, Codex, and Claude Code.

## Available Agents

- **ALPHA** — code generator (implement features, produce code + tests)
- **OMEGA** — code reviewer (review diffs/PRs for correctness and tests)
- **PARANOIA** — security reviewer (security-focused audits and remediation)
- **PERFO** — performance reviewer (optimizations for constrained systems)
- **BIGBOSS** — SOLID principle checker and fixer (detects violations and proposes refactors)
- **GOODREST** — REST API good practices analyzer
- **UNCLEBOB** — clean code reviewer (readability, maintainability, and code quality principles)

## Supported Providers

- [GitHub Copilot](https://github.com/features/copilot)
- [OpenCode](https://opencode.ai)
- [Cursor](https://cursor.com)
- [OpenAI Codex](https://github.com/openai/codex)
- [Claude Code](https://claude.ai/code)

## How It Works

Agent definitions are stored as plain text in `agents/`. Provider-specific files are generated from this single source of truth using shell/batch scripts.

### Generate Provider Files

**You must specify a provider.** No default is assumed.

**Linux / macOS / WSL:**
```bash
# GitHub Copilot
./scripts/generate.sh --provider github

# OpenCode
./scripts/generate.sh --provider opencode

# Cursor
./scripts/generate.sh --provider cursor

# GitHub Codex
./scripts/generate.sh --provider codex

# Claude Code
./scripts/generate.sh --provider claude
```

**Windows:**
```batch
:: GitHub Copilot
scripts\generate.bat --provider github

:: OpenCode
scripts\generate.bat --provider opencode

:: Cursor
scripts\generate.bat --provider cursor

:: GitHub Codex
scripts\generate.bat --provider codex

:: Claude Code
scripts\generate.bat --provider claude
```

This generates files in the provider's expected directory:
- `.github/agents/*.agent.md` — GitHub Copilot
- `.opencode/agents/*.md` — OpenCode
- `.cursor/agents/*.md` — Cursor
- `.codex/agents/*.md` — GitHub Codex
- `.claude/agents/*.md` — Claude Code
- `AGENTS.md` — human-readable master index (always generated)

### Install Agents Globally

**You must specify a provider.**

**Linux / macOS / WSL:**
```bash
# OpenCode
./scripts/install.sh --provider opencode

# Cursor
./scripts/install.sh --provider cursor

# Claude Code
./scripts/install.sh --provider claude

# GitHub Copilot
./scripts/install.sh --provider github

# GitHub Codex
./scripts/install.sh --provider codex
```

**Windows:**
```batch
:: OpenCode
scripts\install.bat --provider opencode

:: Cursor
scripts\install.bat --provider cursor

:: Claude Code
scripts\install.bat --provider claude

:: GitHub Copilot
scripts\install.bat --provider github

:: GitHub Codex
scripts\install.bat --provider codex
```

### Verify Synchronization

**You must specify a provider.**

**Linux / macOS / WSL:**
```bash
./scripts/check-sync.sh --provider github
./scripts/check-sync.sh --provider opencode
./scripts/check-sync.sh --provider cursor
./scripts/check-sync.sh --provider codex
./scripts/check-sync.sh --provider claude
```

**Windows:**
```batch
scripts\check-sync.bat --provider github
scripts\check-sync.bat --provider opencode
scripts\check-sync.bat --provider cursor
scripts\check-sync.bat --provider codex
scripts\check-sync.bat --provider claude
```

Exits with code 0 if generated files match `agents/`, or 1 if any file is out of sync.

## Adding or Editing Agents

1. Edit the corresponding file in `agents/`
2. Optional: set recommended models per tier:
   - `MODEL:` — performance tier (default)
   - `MODEL_BALANCED:` — balanced tier
   - `MODEL_ECONOMY:` — economy tier
   - `OPENCODE_MODEL:`, `OPENCODE_MODEL_BALANCED:`, `OPENCODE_MODEL_ECONOMY:` — OpenCode-specific overrides
3. Run `scripts/generate.sh --provider <name> [--tier <economy|balanced|performance>]` (or `.bat`)
4. Commit both `agents/` and the generated files

## Recommended Models

Each agent defines three model tiers using provider-agnostic family names:

| Tier | Description |
|------|-------------|
| **Performance** | Best quality regardless of cost |
| **Balanced** | Good quality at moderate cost |
| **Economy** | Cheapest viable option |

| Agent | Performance | Balanced | Economy |
|-------|-------------|----------|---------|
| ALPHA, PERFO, UNCLEBOB | `kimi-k2.7-code` | `kimi-k2.5` | `qwen3.5-plus` |
| OMEGA, PARANOIA, BIGBOSS, GOODREST | `claude-sonnet-4-6` | `claude-sonnet-4-5` | `qwen3.5-plus` |

OpenCode requires `provider/model-id` format, so each tier also has an `OPENCODE_MODEL_*` override. Generate or install with `--tier economy` or `--tier balanced` to use cheaper models, or omit the flag for the performance tier.

## Usage

- **GitHub Copilot / Codex:** prefix requests with `AGENT: <NAME> — <task>`
- **OpenCode:** agents are available after installation
- **Cursor / Claude Code:** refer to the provider's documentation for invoking custom agents

See `AGENTS.md` for full agent prompts and recommended workflows.
