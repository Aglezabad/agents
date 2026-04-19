# copilot-agents

A list of GitHub Copilot agent prompts I'm using for development.

This repository stores short agent definitions and prompts for the following agents:
- ALPHA — code generator (implement features, produce code + tests)
- OMEGA — code reviewer (review diffs/PRs for correctness and tests)
- PARANOIA — security reviewer (security-focused audits and remediation)
- PERFO — performance reviewer (optimizations for constrained systems)
- BIGBOSS — SOLID principle checker and fixer (detects violations and proposes refactors)
- GOODREST — REST API good practices analyzer

See AGENTS.md in the repository root for full agent prompts, usage rules, and recommended workflows.

Usage note:
- When requesting Copilot generate or review code, prefix the request with the agent you want to use, e.g.:
  - `AGENT: ALPHA — Implement X`
  - `AGENT: OMEGA — Review PR #42`
