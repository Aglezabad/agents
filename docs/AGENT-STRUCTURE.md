# How to structure a new agent

Every agent lives in `agents/` as a single plain-text file. That file is the only
source of truth: the provider files (`.github/agents/`, `.opencode/agents/`,
`.cursor/agents/`, `.codex/agents/`, `.claude/agents/`) are generated from it.

## 1. File location and name

```
agents/<ID>.txt
```

- One agent per file.
- Use the agent ID as the file name, uppercase, e.g. `agents/ALPHA.txt`.
- Keep the ID to `A-Z`, `a-z`, `0-9`, `_` and `-`. Any other character is stripped
  by the generator, which can silently change the output file name.

## 2. Metadata header

The lines **before the first blank line** are metadata, not prompt content:

```
ID: ALPHA
NAME: ALPHA
DESCRIPTION: code generation and development.
```

| Field | Required | Notes |
|-------|----------|-------|
| `ID` | Yes | Used for the output file name (`ALPHA.agent.md`, `ALPHA.md`, ...). The generator skips the file if it is missing. |
| `NAME` | No | Falls back to `ID` when empty. Becomes the `name:` frontmatter field and the `# NAME` heading of the generated file. |
| `DESCRIPTION` | Yes | One sentence, no trailing period needed. Becomes the `description:` frontmatter field and the entry in `AGENTS.md`. The generator skips the file if it is missing. |

Only the first match of each key is read, so do not repeat them.

## 3. Body

Everything **after the first blank line** is the prompt body. It is copied
verbatim into the generated file, under a `# <NAME>` heading.

The body of the existing agents follows the same skeleton:

```markdown
# AGENT DEFINITION
## PREAMBLES
[**PREAMBLES**]

## ROLE
You are a <role>.

## INPUT PRECONDITION
What the agent must do when no action is needed.

## WORKFLOW
The steps or flows the agent follows.

## RULES
Hard constraints (what it must never do, what it must ask).

## FINALLY
How the agent closes its answer.
```

This is a convention, not a requirement — any Markdown is accepted. Keep the
skeleton unless the agent genuinely does not fit it.

## 4. Preamble injection

`[**PREAMBLES**]` is a marker, not content. During generation the whole line is
replaced by the concatenated contents of `preambles/*.txt` (sorted by file name),
so:

- Put the marker on its own line, under `## PREAMBLES`.
- Leave `## PREAMBLES` with no content besides the marker; anything else on the
  marker line is discarded.
- Without the marker the agent is generated with **no** preambles and the script
  emits a warning.
- With `--no-preamble all` the marker line is dropped and the section stays empty.

Current preambles:

| Preamble | Purpose |
|----------|---------|
| `compact-thinking` | Compact internal reasoning, output in the user's language |
| `tokenomics` | No filler, no rewritten code, explain "why" only |

## 5. Tests (optional but recommended)

Reviewer agents are validated against input files in `tests/`, named
`<agent>_<case>.<ext>` with a `*_clean.*` counterpart when it applies:

```
tests/omega_clean.patch   tests/omega_diff.patch
tests/perfo_clean.py      tests/perfo_code.py
```

Both a compliant and a non-compliant input let a reviewer be judged on whether it
flags the right thing — and stays quiet on clean code.

## 6. Generate and commit

```bash
# Linux / macOS / WSL
./scripts/generate.sh --provider github
./scripts/generate.sh --provider opencode
./scripts/generate.sh --provider cursor
./scripts/generate.sh --provider codex
./scripts/generate.sh --provider claude
```

```batch
:: Windows
scripts\generate.bat --provider github
scripts\generate.bat --provider opencode
scripts\generate.bat --provider cursor
scripts\generate.bat --provider codex
scripts\generate.bat --provider claude
```

Generation regenerates `AGENTS.md` (the master index) automatically and rewrites
only the target provider directory, so every provider must be generated and
committed for the entry to exist everywhere. Run
`./scripts/check-sync.sh --provider <name>` to verify that generated files match
`agents/`.

## 7. Checklist

- [ ] `agents/<ID>.txt` created, `ID` / `NAME` / `DESCRIPTION` filled in
- [ ] First blank line separates metadata from the body
- [ ] `[**PREAMBLES**]` present on its own line if preambles are wanted
- [ ] Test inputs added in `tests/` (reviewer agents)
- [ ] All five providers generated
- [ ] `AGENTS.md`, `README.md` and generated files committed together

## Example: minimal agent

```
ID: DOCS
NAME: DOCS
DESCRIPTION: documentation reviewer.

# AGENT DEFINITION
## PREAMBLES
[**PREAMBLES**]

## ROLE
You are a documentation reviewer.

## INPUT PRECONDITION
If there is no documentation to review, say so and stop.

## WORKFLOW
- Check that every public symbol is documented.
- Report gaps as a list, most severe first.

## FINALLY
State the number of gaps found.
```
