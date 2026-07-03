@echo off
setlocal enabledelayedexpansion

set "AGENTS_DIR=agents"
set "GITHUB_DIR=.github\agents"
set "OPENCODE_DIR=.opencode\agents"
set "MASTER_FILE=AGENTS.md"
set "PROVIDER=all"

rem Parse arguments
:parse_args
if "%~1"=="" goto :done_parsing
if "%~1"=="--provider" (
    set "PROVIDER=%~2"
    shift
    shift
    goto :parse_args
)
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
echo Unknown option: %~1 >&2
echo Usage: %~nx0 [--provider ^<github^|opencode^|all^>] >&2
exit /b 1

:show_help
echo Usage: %~nx0 [--provider ^<github^|opencode^|all^>]
echo.
echo Providers:
echo   github    Generate GitHub Copilot agent files (.github\agents\)
echo   opencode  Generate OpenCode agent files (.opencode\agents\)
echo   all       Generate all provider files (default)
exit /b 0

:done_parsing

rem Validate provider
if not "%PROVIDER%"=="github" if not "%PROVIDER%"=="opencode" if not "%PROVIDER%"=="all" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode, all >&2
    exit /b 1
)

if not exist "%AGENTS_DIR%" (
    echo Error: %AGENTS_DIR% directory not found. >&2
    exit /b 1
)

rem Create and clean only the directories we need
if "%PROVIDER%"=="github" (
    if not exist "%GITHUB_DIR%" mkdir "%GITHUB_DIR%"
    del /q "%GITHUB_DIR%\*.agent.md" 2>nul
)
if "%PROVIDER%"=="opencode" (
    if not exist "%OPENCODE_DIR%" mkdir "%OPENCODE_DIR%"
    del /q "%OPENCODE_DIR%\*.md" 2>nul
)
if "%PROVIDER%"=="all" (
    if not exist "%GITHUB_DIR%" mkdir "%GITHUB_DIR%"
    if not exist "%OPENCODE_DIR%" mkdir "%OPENCODE_DIR%"
    del /q "%GITHUB_DIR%\*.agent.md" 2>nul
    del /q "%OPENCODE_DIR%\*.md" 2>nul
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

    if "%PROVIDER%"=="github" (
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
    )
    if "%PROVIDER%"=="opencode" (
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
    )
    if "%PROVIDER%"=="all" (
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
    )

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

if "%PROVIDER%"=="github" (
    echo Generated %count% agents for GitHub Copilot (%GITHUB_DIR%)
)
if "%PROVIDER%"=="opencode" (
    echo Generated %count% agents for OpenCode (%OPENCODE_DIR%)
)
if "%PROVIDER%"=="all" (
    echo Generated %count% agents for GitHub Copilot (%GITHUB_DIR%)
    echo Generated %count% agents for OpenCode (%OPENCODE_DIR%)
)
echo Generated master index (%MASTER_FILE%)
endlocal
