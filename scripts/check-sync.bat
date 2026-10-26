@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
for %%I in ("%SCRIPT_DIR%..") do set "REPO_DIR=%%~fI"
set "TEMP_DIR=%TEMP%\agent-sync-check-%RANDOM%"
set "PROVIDER="
set "OUT_DIR="
set "EXT="

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
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> >&2
exit /b 1

:show_help
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^>
echo.
echo Providers:
echo   github   Check GitHub Copilot agent files
echo   opencode Check OpenCode agent files
echo   cursor   Check Cursor agent files
echo   codex    Check GitHub Codex agent files
echo   claude   Check Claude Code agent files
exit /b 0

:done_parsing

rem Validate provider and resolve output dir and file extension
if "%PROVIDER%"=="" (
    echo Error: --provider is required >&2
    echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> >&2
    exit /b 1
)

if "%PROVIDER%"=="github" (
    set "OUT_DIR=.github\agents"
    set "EXT=agent.md"
)
if "%PROVIDER%"=="opencode" (
    set "OUT_DIR=.opencode\agents"
    set "EXT=md"
)
if "%PROVIDER%"=="cursor" (
    set "OUT_DIR=.cursor\agents"
    set "EXT=md"
)
if "%PROVIDER%"=="codex" (
    set "OUT_DIR=.codex\agents"
    set "EXT=md"
)
if "%PROVIDER%"=="claude" (
    set "OUT_DIR=.claude\agents"
    set "EXT=md"
)
if "%OUT_DIR%"=="" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode, cursor, codex, claude >&2
    exit /b 1
)

mkdir "%TEMP_DIR%\%OUT_DIR%"

echo Saving current generated files to temp...
if exist "%REPO_DIR%\%OUT_DIR%\*.%EXT%" (
    xcopy /y /q "%REPO_DIR%\%OUT_DIR%\*.%EXT%" "%TEMP_DIR%\%OUT_DIR%\" >nul
)
if exist "%REPO_DIR%\AGENTS.md" (
    copy /y "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\" >nul
)

echo Regenerating fresh copies...
pushd "%REPO_DIR%"
call "%SCRIPT_DIR%generate.bat" --provider %PROVIDER% >nul
popd

set DIFF_FOUND=0

rem Compare provider-specific directory
for %%f in ("%REPO_DIR%\%OUT_DIR%\*.%EXT%") do (
    if not exist "%TEMP_DIR%\%OUT_DIR%\%%~nxf" (
        echo MISMATCH: %OUT_DIR%\%%~nxf ^(new file, not in previous generation^)
        set DIFF_FOUND=1
    ) else (
        fc /b "%%f" "%TEMP_DIR%\%OUT_DIR%\%%~nxf" >nul
        if errorlevel 1 (
            echo MISMATCH: %OUT_DIR%\%%~nxf
            set DIFF_FOUND=1
        )
    )
)
for %%f in ("%TEMP_DIR%\%OUT_DIR%\*.%EXT%") do (
    if not exist "%REPO_DIR%\%OUT_DIR%\%%~nxf" (
        echo MISMATCH: %OUT_DIR%\%%~nxf ^(file removed^)
        set DIFF_FOUND=1
    )
)

rem Compare AGENTS.md
if exist "%REPO_DIR%\AGENTS.md" (
    if not exist "%TEMP_DIR%\AGENTS.md" (
        echo MISMATCH: AGENTS.md ^(new file, not in previous generation^)
        set DIFF_FOUND=1
    ) else (
        fc /b "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\AGENTS.md" >nul
        if errorlevel 1 (
            echo MISMATCH: AGENTS.md
            set DIFF_FOUND=1
        )
    )
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
