# Multilingual Chain-of-Thought (Compact Thinking) Design

## Overview

Add a global preamble to all agent prompts that instructs models to perform internal reasoning in their most token-efficient language, while always emitting the final response in the user's input language. This reduces token consumption during the thinking phase without affecting user-facing output.

## Goals

1. Reduce token usage during agent chain-of-thought by leveraging language-specific tokenization efficiency
2. Maintain user experience: responses always match the input language
3. Allow runtime user override without requiring agent regeneration
4. Keep the system provider-agnostic and backward-compatible

## Non-Goals

1. Automatic language detection or translation of user input
2. Per-agent granularity for thinking-language mode (initial version)
3. Hardcoded model-to-language mappings or tokenizer-specific logic
4. Measuring actual token savings (out of scope for this spec)

## Architecture

### Components

| Component | Description |
|-----------|-------------|
| `preambles/compact-thinking.txt` | The shared preamble file containing the thinking-language directive |
| `scripts/generate.sh` | Modified to prepend the preamble to each agent's body |
| `scripts/generate.bat` | Windows equivalent, modified identically |
| `scripts/check-sync.sh` | Modified to verify preamble inclusion in generated files |
| `scripts/check-sync.bat` | Windows equivalent |

### Data Flow

```
agents/*.txt ──┐
               ├──► generate.sh ──► provider-specific agent files
preambles/     │         │
compact-       │         └─ prepend compact-thinking.txt
thinking.txt ──┘            to agent body
```

## Detailed Design

### Preamble File (`preambles/compact-thinking.txt`)

The preamble contains three sections:

1. **Internal Reasoning Directive**: Instructs the model to reason in its most token-efficient language
2. **Response Language Rule**: Mandates that the final output match the user's input language
3. **User Override Clause**: Allows the user to force a specific thinking language at runtime

The preamble is written in plain English that all major LLMs understand. No XML tags, no structured formats, no provider-specific syntax.

**Exact preamble text:**

```markdown
## Internal Reasoning Directive

To minimize token usage during analysis, perform all internal reasoning, scratchwork, and intermediate steps in the language that yields the most compact token representation for your tokenizer (typically Chinese, Japanese, or another high-density language depending on your training).

Your final response to the user MUST always be in the same language the user used for their request.

## User Override

If the user explicitly requests "THINK IN MY LANGUAGE" or names a specific language (e.g., "THINK IN ENGLISH", "THINK IN SPANISH"), disregard the efficiency directive above and perform all reasoning in the requested language.
```

### Generator Script Changes

**New behavior in `generate.sh`:**

1. After extracting the agent body (everything after the first blank line), check if `preambles/compact-thinking.txt` exists
2. If it exists and is non-empty, prepend its contents to the body with a blank line separator
3. If it is missing or empty, log a warning to stderr and generate the agent without the preamble (graceful degradation)
4. Add a `--no-preamble` CLI flag. When present, skip preamble injection entirely

**Argument parsing update:**

The existing argument parser uses a `while/case` loop. The new `--no-preamble` flag is a boolean switch (no value required). It must be handled before the provider validation so that `--no-preamble` can be combined with `--provider` in any order.

**Preamble injection logic:**

```text
if [ -f "preambles/compact-thinking.txt" ] && [ -s "preambles/compact-thinking.txt" ] && [ "$NO_PREAMBLE" != "1" ]; then
    body="$(cat preambles/compact-thinking.txt)\n\n$body"
fi
```

**Windows batch script (`generate.bat`)** gets equivalent modifications using `if exist` and `findstr` for non-empty checks.

### Check-Sync Script Changes

`check-sync.sh` compares generated files against what `generate.sh` would produce. With the preamble addition, the sync check must:

1. Read the expected preamble content from `preambles/compact-thinking.txt`
2. Verify that each generated file starts with the expected preamble (if the preamble file exists and is non-empty)
3. Report mismatches correctly, indicating whether the issue is missing preamble or stale content

### User Override at Runtime

The override is prompt-based. The user includes one of these phrases in their request:

- `"THINK IN MY LANGUAGE"` — forces reasoning to match the input language
- `"THINK IN ENGLISH"`, `"THINK IN SPANISH"`, etc. — forces reasoning in the named language

Because this instruction is baked into every agent prompt, it works across all supported providers without any provider-specific implementation. The model itself interprets and honors (or ignores) the override.

## File Structure

```
agents/
  ALPHA.txt
  BIGBOSS.txt
  GOODREST.txt
  OMEGA.txt
  PARANOIA.txt
  PERFO.txt
  UNCLEBOB.txt
preambles/
  compact-thinking.txt        ← NEW
scripts/
  generate.sh                 ← MODIFIED
  generate.bat                ← MODIFIED
  check-sync.sh               ← MODIFIED
  check-sync.bat              ← MODIFIED
  install.sh                  ← UNCHANGED
  install.bat                 ← UNCHANGED
docs/superpowers/specs/
  2026-07-04-multilingual-chain-of-thought-design.md  ← THIS FILE
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Missing `preambles/compact-thinking.txt` | Warning to stderr; generate agents without preamble |
| Empty `preambles/compact-thinking.txt` | Treated as missing; warning and skip |
| `--no-preamble` flag used | Skip preamble injection entirely; no warning |
| Provider file already exists with old content | Regenerated normally; old content overwritten |
| Model ignores the thinking-language directive | Soft failure; agent behaves as before (normal reasoning) |

## Backward Compatibility

1. Existing `agents/*.txt` files require **no changes**
2. Existing generated provider files will be updated on next `generate.sh` run
3. The `--provider` flag remains required
4. No new dependencies or external tools needed
5. POSIX shell and Windows batch scripts both supported

## Testing

1. **Unit test for generate.sh**: Run `./scripts/generate.sh --provider opencode`, inspect `.opencode/agents/ALPHA.md`, verify it starts with the preamble content followed by the original agent body
2. **Sync check**: After generation, run `./scripts/check-sync.sh --provider opencode` and confirm exit code 0
3. **No-preamble flag**: Run `./scripts/generate.sh --provider opencode --no-preamble`, verify generated files do NOT contain the preamble
4. **Missing preamble**: Temporarily rename `preambles/compact-thinking.txt`, run generator, verify warning appears and files generate without preamble

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Models may not reliably follow the thinking-language directive | This is a soft optimization; failure degrades gracefully to normal behavior |
| Preamble may confuse models about whether to respond in the "thinking" language | The response-language rule is stated explicitly and redundantly |
| Token savings may be negligible for some languages/models | No hardcoded assumptions; the model decides what is efficient for its tokenizer |
| Adding `--no-preamble` increases CLI complexity | It is an optional flag; the default behavior is simple and global |

## Future Work

1. **Per-agent opt-out**: Add an `OPT_OUT:` metadata field to individual agent `.txt` files for agents where compact thinking is inappropriate
2. **Metrics**: Add a benchmarking mechanism to measure token savings per agent/provider
3. **Structured reasoning blocks**: If models consistently support XML reasoning tags, consider wrapping thinking in `<thinking>` blocks for better observability

## Decision Log

- **Global default vs. optional wrapper**: Chose global default because the user specified "global default for all agents" and the feature is a transparent optimization
- **Let model decide vs. hardcoded mapping**: Chose "let the model decide" because tokenizer efficiency varies by model and training data; hardcoding would be brittle and outdated quickly
- **Runtime override vs. generation-time flag**: Chose runtime prompt-based override because it requires no regeneration and works across all providers instantly
