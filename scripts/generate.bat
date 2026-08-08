@echo off
setlocal enabledelayedexpansion

set "AGENTS_DIR=agents"
set "GITHUB_DIR=.github\agents"
set "OPENCODE_DIR=.opencode\agents"
set "CURSOR_DIR=.cursor\agents"
set "CODEX_DIR=.codex\agents"
set "CLAUDE_DIR=.claude\agents"
set "MASTER_FILE=AGENTS.md"
set "PROVIDER="
set "TIER=performance"
set "NO_PREAMBLE="

rem Parse arguments
:parse_args
if "%~1"=="" goto :done_parsing
if "%~1"=="--provider" (
    set "PROVIDER=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--tier" (
    set "TIER=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--no-preamble" (
    set "NO_PREAMBLE=all"
    shift
    if not "%~1"=="" (
        set "arg=%~1"
        if not "!arg:~0,2!"=="--" (
            set "NO_PREAMBLE=%~1"
            shift
        )
    )
    goto :parse_args
)
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
echo Unknown option: %~1 >&2
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--tier ^<economy^|balanced^|performance^>] >&2
exit /b 1

:show_help
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--tier ^<economy^|balanced^|performance^>] [--no-preamble [^<names^>^|all]]
echo.
echo Options:
echo   --tier          Model tier to generate: economy, balanced, or performance (default: performance)
echo   --no-preamble   Skip injecting preambles. Accepts a comma-separated list of preamble names, or 'all' to skip every preamble (default: inject all)
echo.
echo Providers:
echo   github   Generate GitHub Copilot agent files (.github\agents\)
echo   opencode Generate OpenCode agent files (.opencode\agents\)
echo   cursor   Generate Cursor agent files (.cursor\agents\)
echo   codex    Generate GitHub Codex agent files (.codex\agents\)
echo   claude   Generate Claude Code agent files (.claude\agents\)
exit /b 0

:done_parsing

rem Validate provider
if "%PROVIDER%"=="" (
    echo Error: --provider is required >&2
    echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> >&2
    exit /b 1
)

if not "%PROVIDER%"=="github" if not "%PROVIDER%"=="opencode" if not "%PROVIDER%"=="cursor" if not "%PROVIDER%"=="codex" if not "%PROVIDER%"=="claude" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode, cursor, codex, claude >&2
    exit /b 1
)

if not "%TIER%"=="economy" if not "%TIER%"=="balanced" if not "%TIER%"=="performance" (
    echo Error: unknown tier '%TIER%' >&2
    echo Supported tiers: economy, balanced, performance >&2
    exit /b 1
)

if not exist "%AGENTS_DIR%" (
    echo Error: %AGENTS_DIR% directory not found. >&2
    exit /b 1
)

rem Create and clean only the target directory
if "%PROVIDER%"=="github" (
    if not exist "%GITHUB_DIR%" mkdir "%GITHUB_DIR%"
    del /q "%GITHUB_DIR%\*.agent.md" 2>nul
)
if "%PROVIDER%"=="opencode" (
    if not exist "%OPENCODE_DIR%" mkdir "%OPENCODE_DIR%"
    del /q "%OPENCODE_DIR%\*.md" 2>nul
)
if "%PROVIDER%"=="cursor" (
    if not exist "%CURSOR_DIR%" mkdir "%CURSOR_DIR%"
    del /q "%CURSOR_DIR%\*.md" 2>nul
)
if "%PROVIDER%"=="codex" (
    if not exist "%CODEX_DIR%" mkdir "%CODEX_DIR%"
    del /q "%CODEX_DIR%\*.md" 2>nul
)
if "%PROVIDER%"=="claude" (
    if not exist "%CLAUDE_DIR%" mkdir "%CLAUDE_DIR%"
    del /q "%CLAUDE_DIR%\*.md" 2>nul
)

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
    set "agent_model="
    set "agent_model_balanced="
    set "agent_model_economy="
    set "agent_opencode_model="
    set "agent_opencode_model_balanced="
    set "agent_opencode_model_economy="
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
                echo !line! | findstr /b "MODEL:" >nul && set "agent_model=!line:~6!"
                echo !line! | findstr /b "MODEL_BALANCED:" >nul && set "agent_model_balanced=!line:~16!"
                echo !line! | findstr /b "MODEL_ECONOMY:" >nul && set "agent_model_economy=!line:~14!"
                echo !line! | findstr /b "OPENCODE_MODEL:" >nul && set "agent_opencode_model=!line:~16!"
                echo !line! | findstr /b "OPENCODE_MODEL_BALANCED:" >nul && set "agent_opencode_model_balanced=!line:~26!"
                echo !line! | findstr /b "OPENCODE_MODEL_ECONOMY:" >nul && set "agent_opencode_model_economy=!line:~24!"
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

    rem Determine the model ID to emit for the target provider and tier
    if "%PROVIDER%"=="opencode" (
        if "%TIER%"=="economy" (
            if not "!agent_opencode_model_economy!"=="" (
                set "emit_model=!agent_opencode_model_economy!"
            ) else if not "!agent_opencode_model_balanced!"=="" (
                set "emit_model=!agent_opencode_model_balanced!"
            ) else (
                set "emit_model=!agent_opencode_model!"
            )
        ) else if "%TIER%"=="balanced" (
            if not "!agent_opencode_model_balanced!"=="" (
                set "emit_model=!agent_opencode_model_balanced!"
            ) else (
                set "emit_model=!agent_opencode_model!"
            )
        ) else (
            set "emit_model=!agent_opencode_model!"
        )
    ) else (
        if "%TIER%"=="economy" (
            if not "!agent_model_economy!"=="" (
                set "emit_model=!agent_model_economy!"
            ) else if not "!agent_model_balanced!"=="" (
                set "emit_model=!agent_model_balanced!"
            ) else (
                set "emit_model=!agent_model!"
            )
        ) else if "%TIER%"=="balanced" (
            if not "!agent_model_balanced!"=="" (
                set "emit_model=!agent_model_balanced!"
            ) else (
                set "emit_model=!agent_model!"
            )
        ) else (
            set "emit_model=!agent_model!"
        )
    )

    rem Prepend all preambles in sorted order, skipping any excluded via --no-preamble
    if not "%NO_PREAMBLE%"=="all" (
        set "preamble_block="
        for %%f in (preambles\*.txt) do (
            set "excluded=0"
            if not "%NO_PREAMBLE%"=="" (
                set "np=%NO_PREAMBLE:,= %"
                for %%n in (!np!) do (
                    if "%%n"=="%%~nf" set "excluded=1"
                )
            )
            if "!excluded!"=="0" (
                for %%p in ("%%f") do if %%~zp gtr 0 (
                    set "preamble="
                    for /f "usebackq delims=" %%l in ("%%f") do (
                        if "!preamble!"=="" (
                            set "preamble=%%l"
                        ) else (
                            set "preamble=!preamble!
%%l"
                        )
                    )
                    if "!preamble_block!"=="" (
                        set "preamble_block=!preamble!"
                    ) else (
                        set "preamble_block=!preamble_block!

!preamble!"
                    )
                ) else (
                    echo Warning: %%f is empty; skipping >&2
                )
            )
        )
        if not "!preamble_block!"=="" (
            set "body=!preamble_block!

!body!"
        )
    )

    if "%PROVIDER%"=="github" (
        (
            echo ---
            echo name: !agent_name!
            echo description: !agent_desc!
            if not "!emit_model!"=="" echo model: !emit_model!
            echo ---
            echo.
            echo # !agent_name!
            echo.
            echo !body!
        ) > "%GITHUB_DIR%\!agent_id!.agent.md"
    )
    if "%PROVIDER%"=="opencode" (
        (
            echo ---
            echo name: !agent_name!
            echo description: !agent_desc!
            if not "!emit_model!"=="" echo model: !emit_model!
            echo ---
            echo.
            echo # !agent_name!
            echo.
            echo !body!
        ) > "%OPENCODE_DIR%\!agent_id!.md"
    )
    if "%PROVIDER%"=="cursor" (
        (
            echo ---
            echo name: !agent_name!
            echo description: !agent_desc!
            if not "!emit_model!"=="" echo model: !emit_model!
            echo ---
            echo.
            echo # !agent_name!
            echo.
            echo !body!
        ) > "%CURSOR_DIR%\!agent_id!.md"
    )
    if "%PROVIDER%"=="codex" (
        (
            echo ---
            echo name: !agent_name!
            echo description: !agent_desc!
            if not "!emit_model!"=="" echo model: !emit_model!
            echo ---
            echo.
            echo # !agent_name!
            echo.
            echo !body!
        ) > "%CODEX_DIR%\!agent_id!.md"
    )
    if "%PROVIDER%"=="claude" (
        (
            echo ---
            echo name: !agent_name!
            echo description: !agent_desc!
            if not "!emit_model!"=="" echo model: !emit_model!
            echo ---
            echo.
            echo # !agent_name!
            echo.
            echo !body!
        ) > "%CLAUDE_DIR%\!agent_id!.md"
    )

    rem Build recommended model lines for AGENTS.md
    set "perf_line="
    set "balanced_line="
    set "economy_line="
    if not "!agent_model!"=="" (
        set "perf_line=- Performance: `!agent_model!`"
        if not "!agent_opencode_model!"=="" set "perf_line=!perf_line! (`!agent_opencode_model!` on OpenCode)"
    )
    if not "!agent_model_balanced!"=="" (
        set "balanced_line=- Balanced: `!agent_model_balanced!`"
        if not "!agent_opencode_model_balanced!"=="" set "balanced_line=!balanced_line! (`!agent_opencode_model_balanced!` on OpenCode)"
    )
    if not "!agent_model_economy!"=="" (
        set "economy_line=- Economy: `!agent_model_economy!`"
        if not "!agent_opencode_model_economy!"=="" set "economy_line=!economy_line! (`!agent_opencode_model_economy!` on OpenCode)"
    )

    (
        echo ### !agent_name! — !agent_desc!
        echo !agent_desc!
        if not "!perf_line!"=="" (
            echo.
            echo **Recommended models:**
            echo !perf_line!
            if not "!balanced_line!"=="" echo !balanced_line!
            if not "!economy_line!"=="" echo !economy_line!
        )
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

if "%PROVIDER%"=="github" echo Generated %count% agents for GitHub Copilot (%GITHUB_DIR%) using %TIER% tier
if "%PROVIDER%"=="opencode" echo Generated %count% agents for OpenCode (%OPENCODE_DIR%) using %TIER% tier
if "%PROVIDER%"=="cursor" echo Generated %count% agents for Cursor (%CURSOR_DIR%) using %TIER% tier
if "%PROVIDER%"=="codex" echo Generated %count% agents for Codex (%CODEX_DIR%) using %TIER% tier
if "%PROVIDER%"=="claude" echo Generated %count% agents for Claude Code (%CLAUDE_DIR%) using %TIER% tier
echo Generated master index (%MASTER_FILE%)
endlocal
