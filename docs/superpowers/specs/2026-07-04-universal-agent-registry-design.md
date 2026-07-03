# Universal Agent Registry — Design Spec

> Date: 2025-01-11
> Status: Approved

---

## Problem Statement

The repository currently stores 7 agent definitions (ALPHA, OMEGA, PARANOIA, PERFO, GOODREST, BIGBOSS, UNCLEBOB) in three locations:

1. **Root directory**: `ALPHA.md`, `OMEGA.md`, etc. (simple YAML-like format)
2. **`.opencode/agents/`**: Same content, YAML frontmatter + markdown body format
3. **`.github/agents/`**: Same content, `.agent.md` extension, YAML frontmatter + markdown body

Total: 21 files. Any prompt change requires editing 3 files, creating high risk of drift and maintenance burden.

## Goal

Create a single source of truth for agent definitions that:
- Eliminates duplication
- Supports generating provider-specific formats (GitHub Copilot, OpenCode)
- Supports global/local installation
- Has zero external dependencies (no Python, no Node.js, no YAML/JSON parsers)
- Can be verified/synchronized automatically

## Architecture

### Data Format: `agents/` Directory (One File Per Agent)

Each agent is stored as a plain text file in `agents/<ID>.txt` with a simple key-value structure:

```
ID: ALPHA
NAME: ALPHA
DESCRIPTION: code generation, development or solving requests sent through issues.

You are a pragmatic engineer. Summarize the issue, list reproduction steps or questions,
propose a concise fix (code snippet if applicable), risks, and recommended labels.
Ask to the issue creator if something is ambiguous.
```

**Parsing rules:**
- Lines before the first blank line are metadata (key: value)
- Everything after the first blank line is the multi-line system prompt
- Keys: `ID`, `NAME`, `DESCRIPTION` (case-insensitive)
- Values for `ID` and `NAME` must be single-line
- `DESCRIPTION` must be single-line
- System prompt is verbatim until EOF, preserved with line breaks
- Trailing blank lines at EOF are trimmed (but internal blank lines are preserved)

**Why this format?**
- Trivial to parse with POSIX `grep`, `sed`, `awk`, or Windows `findstr`/`for`
- No dependency on YAML/JSON parsers
- Human-readable and editable in any text editor
- Extensible: new metadata keys can be added later without breaking existing scripts

### Generated Artifacts

The generation scripts read `agents/` and produce:

1. **`.github/agents/<id>.agent.md`** — GitHub Copilot custom agent format:
   ```markdown
   ---
   name: ALPHA
   description: code generation, development or solving requests sent through issues.
   ---

   # ALPHA

   You are a pragmatic engineer...
   ```

2. **`.opencode/agents/<id>.md`** — OpenCode custom agent format:
   ```markdown
   ---
   name: ALPHA
   description: code generation, development or solving requests sent through issues.
   ---

   # ALPHA

   You are a pragmatic engineer...
   ```

3. **`AGENTS.md`** — Auto-generated master index for human reference:
   ```markdown
   # AGENTS

   This file centralizes the agent definitions available in this repository.

   ### ALPHA — Code Generator
   code generation, development or solving requests sent through issues.

   ### OMEGA — Code Reviewer
   reviewer which main objective is correctness and testing the pull requests generated.

   ### PARANOIA — Security Reviewer
   security reviewer. Checks the code when requested, lists the security flaws in code and propose solutions for them.

   ### PERFO — Performance Reviewer / Optimizer
   performance reviewer. It's main objective is getting the best performance in the project by reducing the consumption of resources.

   ### GOODREST — REST API Good Practices Analyzer
   a analyzer of good practices defining REST APIs

   ### BIGBOSS — SOLID Principle Checker / Fixer
   SOLID principle checker and fixer. Checks the code if complies with SOLID principles and, in case of detecting something wrong, proposes the corresponding refactor.

   ### UNCLEBOB — Clean Code Reviewer
   clean code reviewer focused on readability, maintainability, and disciplined design practices.

   ### Usage rules (with GitHub Copilot)
   - When requesting Copilot to run or create code, include a clear top-line instruction naming the agent, e.g.:
     - `AGENT: ALPHA — <task description>`
     - `AGENT: OMEGA — review branch X and propose fixes`
   - If you want a pipeline, specify the sequence:
     - `AGENT: ALPHA -> OMEGA -> PARANOIA -> PERFO — Implement feature X and run full pipeline.`
   ```

### Generation Scripts

#### `scripts/generate.sh` (POSIX Shell)

- **Target**: Linux, macOS, WSL
- **Dependencies**: POSIX shell (`sh`), `grep`, `sed`, `awk`, `cat`
- **Behavior**:
  - Reads all `agents/*.txt` files
  - Generates `.github/agents/`, `.opencode/agents/`, and `AGENTS.md`
  - Creates directories if missing
  - Overwrites existing generated files
  - Prints summary: "Generated N agents for GitHub Copilot, N agents for OpenCode"

#### `scripts/generate.bat` (Windows CMD)

- **Target**: Windows `cmd.exe`
- **Dependencies**: None (pure Windows batch)
- **Behavior**: Same as `generate.sh`

#### `scripts/install.sh` (POSIX Shell)

- **Target**: `~/.config/opencode/agents/`
- **Dependencies**: POSIX shell
- **Behavior**:
  - Runs `generate.sh` first
  - Copies `.opencode/agents/*.md` to `~/.config/opencode/agents/`
  - Creates target directory if missing
  - Prints installed files list

#### `scripts/install.bat` (Windows CMD)

- **Target**: `%USERPROFILE%\.config\opencode\agents\`
- **Dependencies**: None
- **Behavior**: Same as `install.sh`

#### `scripts/check-sync.sh` (POSIX Shell)

- **Dependencies**: POSIX shell
- **Behavior**:
  - Runs `generate.sh` to a temporary directory
  - Compares generated files against existing `.github/agents/` and `.opencode/agents/`
  - Exits with code 0 if identical, code 1 if any file differs
  - Prints diff summary for any mismatches
  - Intended for CI or pre-commit hooks

#### `scripts/check-sync.bat` (Windows CMD)

- **Dependencies**: None
- **Behavior**: Same as `check-sync.sh`

### Cleanup

After the scripts are in place:

- **Delete**: The 7 root `<AGENT>.md` files (`ALPHA.md`, `OMEGA.md`, `PARANOIA.md`, `PERFO.md`, `GOODREST.md`, `BIGBOSS.md`, `UNCLEBOB.md`)
- **Delete**: Old `.github/agents/*.agent.md` and `.opencode/agents/*.md` (they are regenerated)
- **Keep**: `README.md` updated to reference the generation script
- **Keep**: `AGENTS.md` as an auto-generated artifact (committed to git)

### Repository Structure After Refactor

```
agents/
├── ALPHA.txt
├── OMEGA.txt
├── PARANOIA.txt
├── PERFO.txt
├── GOODREST.txt
├── BIGBOSS.txt
└── UNCLEBOB.txt

scripts/
├── generate.sh
├── generate.bat
├── install.sh
├── install.bat
├── check-sync.sh
└── check-sync.bat

.github/
└── agents/
    ├── ALPHA.agent.md       (generated)
    ├── OMEGA.agent.md       (generated)
    ├── PARANOIA.agent.md    (generated)
    ├── PERFO.agent.md       (generated)
    ├── GOODREST.agent.md    (generated)
    ├── BIGBOSS.agent.md     (generated)
    └── UNCLEBOB.agent.md    (generated)

.opencode/
└── agents/
    ├── ALPHA.md             (generated)
    ├── OMEGA.md             (generated)
    ├── PARANOIA.md          (generated)
    ├── PERFO.md             (generated)
    ├── GOODREST.md          (generated)
    ├── BIGBOSS.md           (generated)
    └── UNCLEBOB.md          (generated)

AGENTS.md                    (generated)
README.md                    (updated)
```

## Error Handling

- If `agents/` directory is missing: print error and exit 1
- If an agent file is missing required `ID` or `DESCRIPTION`: print warning and skip it
- If target directories cannot be created: print error and exit 1
- If `check-sync` detects mismatches: print which files differ and exit 1

## Testing Strategy

1. **Manual verification**: After running `generate.sh`, inspect the generated files to ensure YAML frontmatter, formatting, and line breaks are correct
2. **Comparison check**: Run `check-sync.sh` immediately after `generate.sh` — it must exit 0
3. **Round-trip test**: Copy the generated `.github/agents/ALPHA.agent.md`, delete `agents/ALPHA.txt`, and attempt to recreate it — this is out of scope for the generator (one-way only), but useful to verify completeness

## Future Extensibility

- New agents: add `agents/NEWAGENT.txt` and re-run `generate.sh`
- New providers: add a new output directory and template in `generate.sh`
- New metadata: add new key to the parsing logic (e.g., `CATEGORY`, `TAGS`)
- Git hook: add `scripts/check-sync.sh` as a pre-commit hook to prevent manual edits to generated files

## Risks and Mitigations

| Risk | Mitigation |
|------|-----------|
| Shell scripts fail on edge-case prompts (e.g., lines starting with `---`) | Prompt body is everything after first blank line; no parsing of body content |
| Windows batch has limited string manipulation | Use `for /f` with delimiters to read metadata; preserve body with `type` |
| Generated files accidentally edited by hand | `check-sync.sh` detects this; can be wired into CI |
| Users miss the new `agents/` directory and still edit old files | Remove old files; update README to point to `agents/` |

## Decision Log

- **Data format**: Chose plain text over YAML/JSON to avoid dependencies. This is the key trade-off: slightly less structured data for zero dependency overhead.
- **One file per agent** over single registry file: Easier to edit, review, and diff in git. No risk of merge conflicts in a single monolithic file.
- **Shell + Batch over Node/Python**: Aligns with user preference for minimal dependencies.
- **Keep `AGENTS.md` as generated artifact**: Provides human-readable reference without manual maintenance. Committed to git so it works offline.
- **Generate into `.github/agents/` and `.opencode/agents/`**: These directories are expected by the respective tools; generating them preserves compatibility.
