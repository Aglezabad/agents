# agents

A universal agent prompt repository for GitHub Copilot and OpenCode.

## Available Agents

- **ALPHA** — code generator (implement features, produce code + tests)
- **OMEGA** — code reviewer (review diffs/PRs for correctness and tests)
- **PARANOIA** — security reviewer (security-focused audits and remediation)
- **PERFO** — performance reviewer (optimizations for constrained systems)
- **BIGBOSS** — SOLID principle checker and fixer (detects violations and proposes refactors)
- **GOODREST** — REST API good practices analyzer
- **UNCLEBOB** — clean code reviewer (readability, maintainability, and code quality principles)

## How It Works

Agent definitions are stored as plain text in `agents/`. Provider-specific files are generated from this single source of truth.

### Generate Provider Files

By default, all provider files are generated. You can also target a specific provider.

**Linux / macOS / WSL:**
```bash
# Generate all providers (default)
./scripts/generate.sh

# Generate only GitHub Copilot
./scripts/generate.sh --provider github

# Generate only OpenCode
./scripts/generate.sh --provider opencode
```

**Windows:**
```batch
:: Generate all providers (default)
scripts\generate.bat

:: Generate only GitHub Copilot
scripts\generate.bat --provider github

:: Generate only OpenCode
scripts\generate.bat --provider opencode
```

This generates:
- `.github/agents/*.agent.md` — GitHub Copilot custom agents
- `.opencode/agents/*.md` — OpenCode custom agents
- `AGENTS.md` — human-readable master index

### Install Agents Globally

**Linux / macOS / WSL:**
```bash
# Install OpenCode agents globally (default)
./scripts/install.sh

# Install GitHub Copilot agents globally
./scripts/install.sh --provider github
```

**Windows:**
```batch
:: Install OpenCode agents globally (default)
scripts\install.bat

:: Install GitHub Copilot agents globally
scripts\install.bat --provider github
```

### Verify Synchronization

**Linux / macOS / WSL:**
```bash
# Check all providers (default)
./scripts/check-sync.sh

# Check only GitHub Copilot
./scripts/check-sync.sh --provider github

# Check only OpenCode
./scripts/check-sync.sh --provider opencode
```

**Windows:**
```batch
:: Check all providers (default)
scripts\check-sync.bat

:: Check only GitHub Copilot
scripts\check-sync.bat --provider github

:: Check only OpenCode
scripts\check-sync.bat --provider opencode
```

Exits with code 0 if all generated files match `agents/`, or 1 if any file is out of sync.

## Adding or Editing Agents

1. Edit the corresponding file in `agents/`
2. Run `scripts/generate.sh` (or `.bat`)
3. Commit both `agents/` and the generated files

## Usage

- With GitHub Copilot: prefix requests with `AGENT: <NAME> — <task>`
- With OpenCode: agents are available after installation

See `AGENTS.md` for full agent prompts and recommended workflows.
