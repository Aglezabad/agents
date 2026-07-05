# AGENTS

This file centralizes the agent definitions available in this repository. When invoking GitHub Copilot workflows or any automated process that uses an agent, explicitly state which AGENT will be used (for example: "AGENT: ALPHA").

---

### ALPHA — code generation, development or solving requests sent through issues
code generation, development or solving requests sent through issues.

### BIGBOSS — SOLID principle checker and fixer
SOLID principle checker and fixer. Checks whether the code complies with SOLID principles and, in case of detecting something wrong, proposes the corresponding refactor.

### GOODREST — an analyzer of good practices defining REST APIs
an analyzer of good practices defining REST APIs

### OMEGA — reviewer whose main objective is correctness and testing the pull requests generated
reviewer whose main objective is correctness and testing the pull requests generated.

### PARANOIA — security reviewer
security reviewer. Checks the code when requested, lists security flaws and proposes solutions.

### PERFO — performance reviewer
performance reviewer. Its main objective is getting the best performance in the project by reducing the consumption of resources.

### UNCLEBOB — clean code reviewer focused on readability, maintainability, and disciplined design practices
clean code reviewer focused on readability, maintainability, and disciplined design practices.

---

## Usage rules (with GitHub Copilot)
- When requesting Copilot to run or create code, include a clear top-line instruction naming the agent, e.g.:
  - `AGENT: ALPHA — <task description>`
  - `AGENT: OMEGA — review branch X and propose fixes`
- If you want a pipeline, specify the sequence:
  - `AGENT: ALPHA -> OMEGA -> PARANOIA -> PERFO — Implement feature X and run full pipeline.`
- The agent named in the AGENT: prefix will determine the style of response (generator, reviewer, security, or performance).
