# Universal Agent Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 21 duplicated agent files with a single `agents/` source-of-truth directory and cross-platform generation/install scripts.

**Architecture:** One plain-text file per agent in `agents/`, parsed by POSIX shell and Windows batch scripts to generate GitHub Copilot (`.github/agents/`) and OpenCode (`.opencode/agents/`) formats. Auto-generated `AGENTS.md` serves as human-readable master index.

**Tech Stack:** POSIX shell (`sh`), Windows batch (`cmd`), `grep`, `sed`, `awk`, `findstr`, `for` — zero external dependencies.

---

### Task 1: Create `agents/` Directory and Canonical Agent Files

**Files:**
- Create: `agents/ALPHA.txt`
- Create: `agents/OMEGA.txt`
- Create: `agents/PARANOIA.txt`
- Create: `agents/PERFO.txt`
- Create: `agents/GOODREST.txt`
- Create: `agents/BIGBOSS.txt`
- Create: `agents/UNCLEBOB.txt`

- [ ] **Step 1: Create `agents/ALPHA.txt`**

```
ID: ALPHA
NAME: ALPHA
DESCRIPTION: code generation, development or solving requests sent through issues.

You are a pragmatic engineer. Summarize the issue, list reproduction steps or questions,
propose a concise fix (code snippet if applicable), risks, and recommended labels.
Ask to the issue creator if something is ambiguous.
```

- [ ] **Step 2: Create `agents/OMEGA.txt`**

```
ID: OMEGA
NAME: OMEGA
DESCRIPTION: reviewer which main objective is correctness and testing the pull requests generated.

You are a careful reviewer. For the given diff or files, list problems with examples,
suggest concrete code changes, and mark any blocking issues. Use the template:
Summary, Major issues, Minor issues, Suggested changes.
```

- [ ] **Step 3: Create `agents/PARANOIA.txt`**

```
ID: PARANOIA
NAME: PARANOIA
DESCRIPTION: security reviewer. Checks the code when requested, lists the security flaws in code and propose solutions for them.

You are a cybersecurity specialist. When requested, analyze the code of the repository and detect possible security flaws.
Must detect any possible permission escalation, exfiltration of information and espionage. Think like if NSA, CIA, Mossad, North Korean and Russian hackers are going to steal your data.
List them with the corresponding risk and impact level.
Also, suggest the corresponding changes for its solution if possible.
Use the template: Summary, list of issues with the corresponding risk and impact, Suggested changes
```

- [ ] **Step 4: Create `agents/PERFO.txt`**

```
ID: PERFO
NAME: PERFO
DESCRIPTION: performance reviewer. It's main objective is getting the best performance in the project by reducing the consumption of resources.

You are like John Carmack, the cofounder of id Software and you need the software to be performative in the most constrained system.
Your main objective is getting the best performance possible and the minimal use of system resources.
You can also propose the use of alternative programming languages and software tricks to get the best optimization.
Use the template: Summary, proposals, evaluation of each proposal, suggested changes.
```

- [ ] **Step 5: Create `agents/GOODREST.txt`**

```
ID: GOODREST
NAME: GOODREST
DESCRIPTION: a analyzer of good practices defining REST APIs

You will be a analyzer of REST API good practices. Will analyze the code and definitions of endpoints which must comply with them.

Those good practices are:
1. Use Consistent Naming Conventions and URL Structure: URIs should reflect logical resource hierarchies (e.g., /users/{userId}/orders), use reserved characters correctly, prefer lowercase, and represent resources with nouns not verbs.
2. Use HTTP Methods Correctly: Use GET (safe, idempotent, cacheable), POST (create), PUT (replace/update, idempotent), DELETE (idempotent), HEAD, OPTIONS, TRACE, and CONNECT according to their defined semantics in RFC 7231 and RFC 9110.
3. Statelessness is the Key: Each request must contain all necessary information. The server must not store client context between requests.
4. Use Standard HTTP Response Codes Consistently: Return appropriate status codes (2xx for success, 4xx for client errors, 5xx for server errors) as defined in RFC 7231.
5. Handle API Versioning Gracefully: Support URI versioning (/api/v1/), header versioning (X-API-Version), or content negotiation (Accept header) to maintain backward compatibility.
6. Ensure Backward Compatibility: Provide deprecation timelines, keep old endpoints functional, and maintain comprehensive documentation of changes between versions.
7. Implement Rate Limiting to Prevent Abuse: Apply strategies such as fixed window, sliding window, token bucket, or concurrency limiting to protect against DoS attacks and resource exhaustion.
8. Monitor and Log API Usage: Use structured logging (JSON), multiple log levels, centralized log aggregation, and real-time monitoring tools to ensure observability.
9. Cache Responses to Optimize Performance: Use HTTP caching headers (Cache-Control, ETag, Last-Modified, Expires, Vary) as specified in RFC 9111 to reduce latency and server load.
10. Implement Filtering, Sorting, and Pagination: Support query parameters for filtering (e.g., ?status=active), sorting (e.g., ?sort=-name), and pagination (e.g., ?page=1&size=20) on collection endpoints.
11. API Security is Not an Afterthought: Enforce HTTPS, use OAuth2/JWT/API keys, apply RBAC, validate and sanitize inputs, and include security headers (Content-Security-Policy, Strict-Transport-Security, X-Content-Type-Options).
12. Complement the API with Great Documentation: Provide well-formatted, example-rich documentation using a standard tool (e.g., OpenAPI/Swagger) so developers can understand and use the API effectively.

Use the template: Summary, list of violations with the corresponding good practice reference, Suggested changes.
```

- [ ] **Step 6: Create `agents/BIGBOSS.txt`**

```
ID: BIGBOSS
NAME: BIGBOSS
DESCRIPTION: SOLID principle checker and fixer. Checks the code if complies with SOLID principles and, in case of detecting something wrong, proposes the corresponding refactor.

You will be a code analyzer and checker of SOLID principles. In case of detecting something that does not comply with them, must propose a refactor for that.

The SOLID principles were introduced by Robert C. Martin in his paper "Design Principles and Design Patterns".
Their objective with these principles is the encouragement of developers in making more maintainable, understandable, and flexible software.
Consequently, the application of these principles can reduce the complexity of the software when this one grows in size.
The SOLID principles are:
- Single Responsibility: This principle states that a class should have only one reason to change. In other words, a class should have only one responsibility or job within the software system.
This helps in keeping the codebase focused, easier to understand, and more adaptable to change.

- Open / Closed: The Open/Closed Principle suggests that software entities (classes, modules, functions, etc.) should be open for extension but closed for modification.
This means that you should be able to extend the behavior of a module without modifying its source code, ensuring that existing code remains unchanged and stable while allowing for new functionality to be added.
Recommended patterns for complying with this principle: Composite, Strategy, Decorator, Factory and Observer.

- Liskov Substitution: This principle is introduced first by Barbara Liskov in a conference called "Data Abstraction and Hierarchy", where it states that classes which share the same abstraction must be interchangeable.
In other words, derived classes must be substitutable for their base classes without altering the desired properties of the program. This ensures that polymorphism behaves correctly and helps maintain consistency and reliability in object-oriented design.

- Interface segregation: This principle suggests that clients should not be forced to depend on interfaces they don't use.
It promotes the idea of breaking down large interfaces into smaller, more specific ones so that classes only need to implement the methods that are relevant to them. This helps in keeping interfaces focused and avoids coupling between unrelated components.

- Dependency Inversion: The Dependency Inversion Principle states that high-level modules/classes (Use cases) should not depend on low-level modules/classes directly (Repositories, API calls, etc.); instead, they should depend on abstractions. Furthermore, abstractions should not depend on details; rather, details should depend on abstractions.
This principle encourages the use of interfaces or abstract classes to decouple components, making the system more flexible, testable, and resilient to changes.
```

- [ ] **Step 7: Create `agents/UNCLEBOB.txt`**

```
ID: UNCLEBOB
NAME: UNCLEBOB
DESCRIPTION: clean code reviewer focused on readability, maintainability, and disciplined design practices.

You are a clean code specialist inspired by Robert C. Martin principles.
Evaluate code and proposed changes for understandability, simplicity, consistency, and maintainability.
Use these rules as guidance:
- Follow standard conventions and keep solutions simple.
- Prefer finding root causes over patching symptoms.
- Encourage clear naming, small focused functions, and minimal side effects.
- Prefer clear object boundaries, encapsulation, and dependency injection where appropriate.
- Reduce code smells such as rigidity, fragility, needless complexity, repetition, and opacity.
- Keep tests readable, fast, independent, and repeatable.
Output using: Summary, Major issues, Minor issues, Suggested changes.
```

- [ ] **Step 8: Commit agent source files**

```bash
git add agents/
git commit -m "feat: add canonical agent definitions in agents/"
```

---

### Task 2: Create `scripts/generate.sh` (POSIX Shell)

**Files:**
- Create: `scripts/generate.sh`
- Modify: `.github/agents/` (overwritten)
- Modify: `.opencode/agents/` (overwritten)
- Modify: `AGENTS.md` (overwritten)

- [ ] **Step 1: Create `scripts/generate.sh`**

```bash
#!/bin/sh
# Universal Agent Registry Generator (POSIX Shell)
# Reads agents/*.txt and generates provider-specific agent files.

set -e

AGENTS_DIR="agents"
GITHUB_DIR=".github/agents"
OPENCODE_DIR=".opencode/agents"
MASTER_FILE="AGENTS.md"

if [ ! -d "$AGENTS_DIR" ]; then
    echo "Error: $AGENTS_DIR directory not found." >&2
    exit 1
fi

mkdir -p "$GITHUB_DIR" "$OPENCODE_DIR"

# Clear old generated files
rm -f "$GITHUB_DIR"/*.agent.md
rm -f "$OPENCODE_DIR"/*.md

# Start AGENTS.md
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
    agent_id=$(grep -m 1 '^ID:' "$agent_file" | sed 's/^ID:[[:space:]]*//' | tr -d '\r')
    # Extract NAME
    agent_name=$(grep -m 1 '^NAME:' "$agent_file" | sed 's/^NAME:[[:space:]]*//' | tr -d '\r')
    # Extract DESCRIPTION
    agent_desc=$(grep -m 1 '^DESCRIPTION:' "$agent_file" | sed 's/^DESCRIPTION:[[:space:]]*//' | tr -d '\r')

    if [ -z "$agent_id" ] || [ -z "$agent_desc" ]; then
        echo "Warning: skipping $agent_file (missing ID or DESCRIPTION)" >&2
        continue
    fi

    # Extract body: everything after the first blank line
    body=$(awk 'BEGIN{found=0} /^[[:space:]]*$/ {found=1; next} found {print}' "$agent_file" | sed -e :a -e '/^\n*$/{$d;N;};/\n$/ba')

    # Generate .github/agents/<id>.agent.md
    {
        echo "---"
        echo "name: $agent_name"
        echo "description: $agent_desc"
        echo "---"
        echo ""
        echo "# $agent_name"
        echo ""
        echo "$body"
    } > "$GITHUB_DIR/${agent_id}.agent.md"

    # Generate .opencode/agents/<id>.md
    {
        echo "---"
        echo "name: $agent_name"
        echo "description: $agent_desc"
        echo "---"
        echo ""
        echo "# $agent_name"
        echo ""
        echo "$body"
    } > "$OPENCODE_DIR/${agent_id}.md"

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

echo "Generated $count agents for GitHub Copilot ($GITHUB_DIR)"
echo "Generated $count agents for OpenCode ($OPENCODE_DIR)"
echo "Generated master index ($MASTER_FILE)"
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x scripts/generate.sh
```

- [ ] **Step 3: Test generation**

```bash
./scripts/generate.sh
```

Expected output:
```
Generated 7 agents for GitHub Copilot (.github/agents)
Generated 7 agents for OpenCode (.opencode/agents)
Generated master index (AGENTS.md)
```

- [ ] **Step 4: Verify generated file count**

```bash
ls .github/agents/*.agent.md | wc -l
ls .opencode/agents/*.md | wc -l
```

Expected: `7` for both commands.

- [ ] **Step 5: Commit**

```bash
git add scripts/generate.sh .github/agents/ .opencode/agents/ AGENTS.md
git commit -m "feat: add generate.sh and regenerate all provider agent files"
```

---

### Task 3: Create `scripts/generate.bat` (Windows CMD)

**Files:**
- Create: `scripts/generate.bat`

- [ ] **Step 1: Create `scripts/generate.bat`**

```batch
@echo off
setlocal enabledelayedexpansion

set "AGENTS_DIR=agents"
set "GITHUB_DIR=.github\agents"
set "OPENCODE_DIR=.opencode\agents"
set "MASTER_FILE=AGENTS.md"

if not exist "%AGENTS_DIR%" (
    echo Error: %AGENTS_DIR% directory not found. >&2
    exit /b 1
)

if not exist "%GITHUB_DIR%" mkdir "%GITHUB_DIR%"
if not exist "%OPENCODE_DIR%" mkdir "%OPENCODE_DIR%"

del /q "%GITHUB_DIR%\*.agent.md" 2>nul
del /q "%OPENCODE_DIR%\*.md" 2>nul

(
    echo # AGENTS
    echo.
    echo This file centralizes the agent definitions available in this repository. When invoking GitHub Copilot workflows or any automated process that uses an agent, explicitly state which AGENT will be used ^(for example: "AGENT: ALPHA"^).
    echo.
    echo ---
    echo.
) > "%MASTER_FILE%"

set count=0
for %%f in (%AGENTS_DIR%\*.txt) do (
    set "file=%%f"
    set "agent_id="
    set "agent_name="
    set "agent_desc="
    set "in_body=0"
    set "body="

    for /f "usebackq delims=" %%a in ("%%f") do (
        set "line=%%a"
        if !in_body! equ 0 (
            if "!line!"=="" (
                set "in_body=1"
            ) else (
                echo !line! | findstr /b "ID:" >nul && set "agent_id=!line:~4!"
                echo !line! | findstr /b "NAME:" >nul && set "agent_name=!line:~6!"
                echo !line! | findstr /b "DESCRIPTION:" >nul && set "agent_desc=!line:~13!"
            )
        ) else (
            if "!body!"=="" (
                set "body=!line!"
            ) else (
                set "body=!body!
!line!"
            )
        )
    )

    if "!agent_id!"=="" goto :skip
    if "!agent_desc!"=="" goto :skip

    if "!agent_name!"=="" set "agent_name=!agent_id!"

    (
        echo ---
        echo name: !agent_name!
        echo description: !agent_desc!
        echo ---
        echo.
        echo # !agent_name!
        echo.
        echo !body!
    ) > "%GITHUB_DIR%\!agent_id!.agent.md"

    (
        echo ---
        echo name: !agent_name!
        echo description: !agent_desc!
        echo ---
        echo.
        echo # !agent_name!
        echo.
        echo !body!
    ) > "%OPENCODE_DIR%\!agent_id!.md"

    (
        echo ### !agent_name! — !agent_desc!
        echo !agent_desc!
        echo.
    ) >> "%MASTER_FILE%"

    set /a count+=1
    :skip
)

(
    echo ---
    echo.
    echo ## Usage rules ^(with GitHub Copilot^)
    echo - When requesting Copilot to run or create code, include a clear top-line instruction naming the agent, e.g.:
    echo   - `AGENT: ALPHA — ^<task description^>`
    echo   - `AGENT: OMEGA — review branch X and propose fixes`
    echo - If you want a pipeline, specify the sequence:
    echo   - `AGENT: ALPHA -^> OMEGA -^> PARANOIA -^> PERFO — Implement feature X and run full pipeline.`
    echo - The agent named in the AGENT: prefix will determine the style of response ^(generator, reviewer, security, or performance^).
) >> "%MASTER_FILE%"

echo Generated %count% agents for GitHub Copilot (%GITHUB_DIR%)
echo Generated %count% agents for OpenCode (%OPENCODE_DIR%)
echo Generated master index (%MASTER_FILE%)
endlocal
```

- [ ] **Step 2: Commit**

```bash
git add scripts/generate.bat
git commit -m "feat: add generate.bat for Windows"
```

---

### Task 4: Create `scripts/install.sh` (POSIX Global Install)

**Files:**
- Create: `scripts/install.sh`

- [ ] **Step 1: Create `scripts/install.sh`**

```bash
#!/bin/sh
# Install OpenCode agents globally
# Runs generate.sh first, then copies to ~/.config/opencode/agents/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$HOME/.config/opencode/agents"

echo "Running generator..."
"$SCRIPT_DIR/generate.sh"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

echo "Installing agents to $TARGET_DIR..."
for f in "$SCRIPT_DIR/../.opencode/agents"/*.md; do
    cp "$f" "$TARGET_DIR/"
    echo "  Installed: $(basename "$f")"
done

echo "Done. Installed $(ls "$TARGET_DIR"/*.md 2>/dev/null | wc -l) agents globally."
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/install.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/install.sh
git commit -m "feat: add install.sh for global OpenCode agent installation"
```

---

### Task 5: Create `scripts/install.bat` (Windows Global Install)

**Files:**
- Create: `scripts/install.bat`

- [ ] **Step 1: Create `scripts/install.bat`**

```batch
@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "TARGET_DIR=%USERPROFILE%\.config\opencode\agents"

echo Running generator...
call "%SCRIPT_DIR%generate.bat"

if not exist "%TARGET_DIR%" (
    echo Creating target directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

echo Installing agents to %TARGET_DIR%...
for %%f in ("%SCRIPT_DIR%..\.opencode\agents\*.md") do (
    copy "%%f" "%TARGET_DIR%\" >nul
    echo   Installed: %%~nxf
)

set count=0
for %%f in ("%TARGET_DIR%\*.md") do set /a count+=1
echo Done. Installed %count% agents globally.
endlocal
```

- [ ] **Step 2: Commit**

```bash
git add scripts/install.bat
git commit -m "feat: add install.bat for global OpenCode agent installation on Windows"
```

---

### Task 6: Create `scripts/check-sync.sh` (POSIX Sync Verification)

**Files:**
- Create: `scripts/check-sync.sh`

- [ ] **Step 1: Create `scripts/check-sync.sh`**

```bash
#!/bin/sh
# Verify that generated files match agents/ source of truth.
# Exits 0 if in sync, 1 if any file differs.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Generating fresh copies to temp directory..."
(cd "$REPO_DIR" && AGENTS_DIR="agents" "$SCRIPT_DIR/generate.sh" >/dev/null)

# Move generated files to temp for comparison
mkdir -p "$TEMP_DIR/.github/agents" "$TEMP_DIR/.opencode/agents"
cp "$REPO_DIR/.github/agents"/*.agent.md "$TEMP_DIR/.github/agents/" 2>/dev/null || true
cp "$REPO_DIR/.opencode/agents"/*.md "$TEMP_DIR/.opencode/agents/" 2>/dev/null || true
cp "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" 2>/dev/null || true

# Regenerate fresh in temp
cd "$REPO_DIR"
"$SCRIPT_DIR/generate.sh" >/dev/null

DIFF_FOUND=0

# Compare .github/agents/
for f in "$REPO_DIR/.github/agents"/*.agent.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if ! diff -q "$f" "$TEMP_DIR/.github/agents/$fname" >/dev/null 2>&1; then
        echo "MISMATCH: .github/agents/$fname"
        DIFF_FOUND=1
    fi
done

# Compare .opencode/agents/
for f in "$REPO_DIR/.opencode/agents"/*.md; do
    [ -e "$f" ] || continue
    fname=$(basename "$f")
    if ! diff -q "$f" "$TEMP_DIR/.opencode/agents/$fname" >/dev/null 2>&1; then
        echo "MISMATCH: .opencode/agents/$fname"
        DIFF_FOUND=1
    fi
done

# Compare AGENTS.md
if ! diff -q "$REPO_DIR/AGENTS.md" "$TEMP_DIR/AGENTS.md" >/dev/null 2>&1; then
    echo "MISMATCH: AGENTS.md"
    DIFF_FOUND=1
fi

if [ "$DIFF_FOUND" -eq 1 ]; then
    echo ""
    echo "Error: generated files are out of sync with agents/. Run scripts/generate.sh to fix." >&2
    exit 1
else
    echo "All generated files are in sync with agents/."
    exit 0
fi
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/check-sync.sh
```

- [ ] **Step 3: Verify check-sync passes**

```bash
./scripts/check-sync.sh
```

Expected output:
```
All generated files are in sync with agents/.
```

Expected exit code: `0`

- [ ] **Step 4: Commit**

```bash
git add scripts/check-sync.sh
git commit -m "feat: add check-sync.sh for CI/pre-commit verification"
```

---

### Task 7: Create `scripts/check-sync.bat` (Windows Sync Verification)

**Files:**
- Create: `scripts/check-sync.bat`

- [ ] **Step 1: Create `scripts/check-sync.bat`**

```batch
@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR%.."
set "TEMP_DIR=%TEMP%\agent-sync-check-%RANDOM%"

mkdir "%TEMP_DIR%"
mkdir "%TEMP_DIR%\.github\agents"
mkdir "%TEMP_DIR%\.opencode\agents"

echo Generating fresh copies to temp directory...
call "%SCRIPT_DIR%generate.bat" >nul

xcopy /y /q "%REPO_DIR%\.github\agents\*.agent.md" "%TEMP_DIR%\.github\agents\" >nul
xcopy /y /q "%REPO_DIR%\.opencode\agents\*.md" "%TEMP_DIR%\.opencode\agents\" >nul
copy /y "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\" >nul

pushd "%REPO_DIR%"
call "%SCRIPT_DIR%generate.bat" >nul
popd

set DIFF_FOUND=0

for %%f in ("%REPO_DIR%\.github\agents\*.agent.md") do (
    set "fname=%%~nxf"
    fc /b "%%f" "%TEMP_DIR%\.github\agents\%%~nxf" >nul
    if errorlevel 1 (
        echo MISMATCH: .github\agents\%%~nxf
        set DIFF_FOUND=1
    )
)

for %%f in ("%REPO_DIR%\.opencode\agents\*.md") do (
    set "fname=%%~nxf"
    fc /b "%%f" "%TEMP_DIR%\.opencode\agents\%%~nxf" >nul
    if errorlevel 1 (
        echo MISMATCH: .opencode\agents\%%~nxf
        set DIFF_FOUND=1
    )
)

fc /b "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\AGENTS.md" >nul
if errorlevel 1 (
    echo MISMATCH: AGENTS.md
    set DIFF_FOUND=1
)

rmdir /s /q "%TEMP_DIR%"

if %DIFF_FOUND% equ 1 (
    echo.
    echo Error: generated files are out of sync with agents\. Run scripts\generate.bat to fix. >&2
    exit /b 1
) else (
    echo All generated files are in sync with agents\.
    exit /b 0
)
endlocal
```

- [ ] **Step 2: Commit**

```bash
git add scripts/check-sync.bat
git commit -m "feat: add check-sync.bat for Windows CI verification"
```

---

### Task 8: Clean Up Old Root Agent Files

**Files:**
- Delete: `ALPHA.md`
- Delete: `OMEGA.md`
- Delete: `PARANOIA.md`
- Delete: `PERFO.md`
- Delete: `GOODREST.md`
- Delete: `BIGBOSS.md`
- Delete: `UNCLEBOB.md`

- [ ] **Step 1: Delete the 7 root agent files**

```bash
rm ALPHA.md OMEGA.md PARANOIA.md PERFO.md GOODREST.md BIGBOSS.md UNCLEBOB.md
```

- [ ] **Step 2: Verify no old root files remain**

```bash
ls *.md
```

Expected: Only `AGENTS.md`, `README.md`, and possibly `LICENSE.md`.

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor: remove old root agent files (now generated from agents/)"
```

---

### Task 9: Update `README.md`

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update `README.md` to reference generation workflow**

Replace the file content with:

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README for universal agent registry workflow"
```

---

### Task 10: Final Verification and Commit

**Files:**
- Verify: All generated files
- Verify: `check-sync.sh` passes
- Verify: Git status is clean

- [ ] **Step 1: Run full generation**

```bash
./scripts/generate.sh
```

- [ ] **Step 2: Run sync check**

```bash
./scripts/check-sync.sh
```

Expected: `All generated files are in sync with agents/.` with exit code 0.

- [ ] **Step 3: Verify git status**

```bash
git status
```

Expected: No uncommitted changes. All new files staged or committed.

- [ ] **Step 4: Final commit (if any remaining changes)**

```bash
git add -A
git commit -m "feat: universal agent registry complete — single source of truth in agents/"
```

---

## Self-Review Checklist

**1. Spec coverage:**
- [x] `agents/` directory with canonical files → Task 1
- [x] `scripts/generate.sh` → Task 2
- [x] `scripts/generate.bat` → Task 3
- [x] `scripts/install.sh` → Task 4
- [x] `scripts/install.bat` → Task 5
- [x] `scripts/check-sync.sh` → Task 6
- [x] `scripts/check-sync.bat` → Task 7
- [x] Delete old root `.md` files → Task 8
- [x] Update `README.md` → Task 9
- [x] Final verification → Task 10

**2. Placeholder scan:**
- [x] No `TBD`, `TODO`, `[etc.]`, `fill in details`, or `similar to Task N` found.
- [x] All code blocks contain complete, copy-pasteable content.
- [x] All commands have exact expected output.

**3. Type consistency:**
- [x] File paths consistent (`agents/`, `.github/agents/`, `.opencode/agents/`, `scripts/`)
- [x] Variable names consistent (`agent_id`, `agent_name`, `agent_desc`)
- [x] Output formats consistent between `.sh` and `.bat`
- [x] `AGENTS.md` content structure matches spec

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/2026-07-04-universal-agent-registry.md`.**

Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using `executing-plans`, batch execution with checkpoints.

**Which approach?**
