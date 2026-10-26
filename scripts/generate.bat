@echo off
setlocal enabledelayedexpansion

set "AGENTS_DIR=agents"
set "PREAMBLES_DIR=preambles"
set "MASTER_FILE=AGENTS.md"
set "PREAMBLE_TAG=[**PREAMBLES**]"
set "PROVIDER="
set "NO_PREAMBLE="
set "OUT_DIR="
set "EXT="
set "LABEL="

rem Parse arguments
:parse_args
if "%~1"=="" goto :done_parsing
if "%~1"=="--provider" (
    set "PROVIDER=%~2"
    shift
    shift
    goto :parse_args
)
if not "%~1"=="--no-preamble" goto :no_preamble_done
set "NO_PREAMBLE=all"
shift
if "%~1"=="" goto :parse_args
set "arg=%~1"
if "!arg:~0,1!"=="-" goto :parse_args
set "NO_PREAMBLE=%~1"
shift
goto :parse_args
:no_preamble_done
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
echo Unknown option: %~1 >&2
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--no-preamble [^<names^>^|all]] >&2
exit /b 1

:show_help
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--no-preamble [^<names^>^|all]]
echo.
echo Options:
echo   --no-preamble   Skip injecting preambles. Accepts a comma-separated list of preamble names, or 'all' to skip every preamble (default: inject all)
echo.
echo Providers:
echo   github   Generate GitHub Copilot agent files (.github\agents\^)
echo   opencode Generate OpenCode agent files (.opencode\agents\^)
echo   cursor   Generate Cursor agent files (.cursor\agents\^)
echo   codex    Generate GitHub Codex agent files (.codex\agents\^)
echo   claude   Generate Claude Code agent files (.claude\agents\^)
exit /b 0

:done_parsing

rem Validate provider and resolve output dir, file extension, and display label
if "%PROVIDER%"=="" (
    echo Error: --provider is required >&2
    echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> >&2
    exit /b 1
)

if "%PROVIDER%"=="github" (
    set "OUT_DIR=.github\agents"
    set "EXT=agent.md"
    set "LABEL=GitHub Copilot"
)
if "%PROVIDER%"=="opencode" (
    set "OUT_DIR=.opencode\agents"
    set "EXT=md"
    set "LABEL=OpenCode"
)
if "%PROVIDER%"=="cursor" (
    set "OUT_DIR=.cursor\agents"
    set "EXT=md"
    set "LABEL=Cursor"
)
if "%PROVIDER%"=="codex" (
    set "OUT_DIR=.codex\agents"
    set "EXT=md"
    set "LABEL=GitHub Codex"
)
if "%PROVIDER%"=="claude" (
    set "OUT_DIR=.claude\agents"
    set "EXT=md"
    set "LABEL=Claude Code"
)
if "%LABEL%"=="" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode, cursor, codex, claude >&2
    exit /b 1
)

if not exist "%AGENTS_DIR%" (
    echo Error: %AGENTS_DIR% directory not found. >&2
    exit /b 1
)

rem Create and clean only the target directory
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"
del /q "%OUT_DIR%\*.%EXT%" 2>nul

rem Build the preamble block once into a temp file (sorted order, minus any
rem excluded via --no-preamble). Lines are streamed with echo instead of being
rem accumulated in a multi-line variable, which cmd cannot parse reliably.
set "PREAMBLE_TMP="
set "PREAMBLE_TMPFILE=%TEMP%\preambles-%RANDOM%.tmp"
if not "%NO_PREAMBLE%"=="all" (
    set "pfirst=1"
    for %%f in (%PREAMBLES_DIR%\*.txt) do (
        set "excluded=0"
        if not "%NO_PREAMBLE%"=="" (
            set "np=%NO_PREAMBLE:,= %"
            for %%n in (!np!) do (
                if "%%n"=="%%~nf" set "excluded=1"
            )
        )
        if "!excluded!"=="0" (
            set "plines=0"
            for /f "usebackq delims=" %%l in ("%%f") do set "plines=1"
            if "!plines!"=="1" (
                if "!pfirst!"=="1" (
                    set "pfirst=0"
                ) else (
                    >> "%PREAMBLE_TMPFILE%" echo.
                )
                for /f "usebackq delims=" %%l in ("%%f") do >> "%PREAMBLE_TMPFILE%" echo:%%l
            ) else (
                echo Warning: %%f is empty; skipping >&2
            )
        )
    )
    if exist "%PREAMBLE_TMPFILE%" set "PREAMBLE_TMP=%PREAMBLE_TMPFILE%"
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
    set "agent_id="
    set "agent_name="
    set "agent_desc="
    set "in_body=0"

    rem Pass 1: parse metadata (lines before the first blank line). findstr /n
    rem prefixes line numbers so blank lines survive the for /f loop.
    for /f "usebackq delims=" %%a in (`findstr /n "^" "%%f"`) do (
        if "!in_body!"=="0" (
            set "line=%%a"
            set "line=!line:*:=!"
            if "!line!"=="" (
                set "in_body=1"
            ) else (
                echo !line! | findstr /b "ID:" >nul && set "agent_id=!line:~4!"
                echo !line! | findstr /b "NAME:" >nul && set "agent_name=!line:~6!"
                echo !line! | findstr /b "DESCRIPTION:" >nul && set "agent_desc=!line:~13!"
            )
        )
    )

    if "!agent_id!"=="" (
        echo Warning: skipping %%f ^(missing ID or DESCRIPTION^) >&2
    ) else (
        if "!agent_desc!"=="" (
            echo Warning: skipping %%f ^(missing ID or DESCRIPTION^) >&2
        ) else (
            if "!agent_name!"=="" set "agent_name=!agent_id!"

            rem Pass 2a: write frontmatter
            > "%OUT_DIR%\!agent_id!.%EXT%" (
                echo ---
                echo name: !agent_name!
                echo description: !agent_desc!
                echo ---
                echo.
                echo # !agent_name!
                echo.
            )

            rem Pass 2b: stream the body, injecting the preamble block at the
            rem tag; the tag line is dropped when no preambles are selected
            set "has_tag=0"
            set "in_body=0"
            for /f "usebackq delims=" %%a in (`findstr /n "^" "%%f"`) do (
                set "line=%%a"
                set "line=!line:*:=!"
                if "!in_body!"=="0" (
                    if "!line!"=="" set "in_body=1"
                ) else (
                    if "!line!"=="%PREAMBLE_TAG%" (
                        set "has_tag=1"
                        if defined PREAMBLE_TMP type "%PREAMBLE_TMP%" >> "%OUT_DIR%\!agent_id!.%EXT%"
                    ) else (
                        if "!line!"=="" (
                            >> "%OUT_DIR%\!agent_id!.%EXT%" echo.
                        ) else (
                            >> "%OUT_DIR%\!agent_id!.%EXT%" echo:!line!
                        )
                    )
                )
            )
            if "!has_tag!"=="0" if defined PREAMBLE_TMP echo Warning: %%f has no %PREAMBLE_TAG% tag; skipping preambles >&2

            (
                echo ### !agent_name! — !agent_desc!
                echo !agent_desc!
                echo.
            ) >> "%MASTER_FILE%"

            set /a count+=1
        )
    )
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

if defined PREAMBLE_TMP del "%PREAMBLE_TMP%" 2>nul

echo Generated %count% agents for %LABEL% (%OUT_DIR%^)
echo Generated master index (%MASTER_FILE%^)
endlocal
