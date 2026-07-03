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

**Linux / macOS / WSL:**
```bash
./scripts/generate.sh
```

**Windows:**
```batch
scripts\generate.bat
```

This generates:
- `.github/agents/*.agent.md` — GitHub Copilot custom agents
- `.opencode/agents/*.md` — OpenCode custom agents
- `AGENTS.md` — human-readable master index

### Install Agents Globally (OpenCode)

**Linux / macOS / WSL:**
```bash
./scripts/install.sh
```

**Windows:**
```batch
scripts\install.bat
```

### Verify Synchronization

**Linux / macOS / WSL:**
```bash
./scripts/check-sync.sh
```

**Windows:**
```batch
scripts\check-sync.bat
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
