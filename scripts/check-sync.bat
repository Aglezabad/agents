@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR%.."
set "TEMP_DIR=%TEMP%\agent-sync-check-%RANDOM%"
set "PROVIDER="

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

mkdir "%TEMP_DIR%"
mkdir "%TEMP_DIR%\.github\agents"
mkdir "%TEMP_DIR%\.opencode\agents"
mkdir "%TEMP_DIR%\.cursor\agents"
mkdir "%TEMP_DIR%\.codex\agents"
mkdir "%TEMP_DIR%\.claude\agents"

echo Saving current generated files to temp...
if "%PROVIDER%"=="github" (
    if exist "%REPO_DIR%\.github\agents\*.agent.md" (
        xcopy /y /q "%REPO_DIR%\.github\agents\*.agent.md" "%TEMP_DIR%\.github\agents\" >nul
    )
)
if "%PROVIDER%"=="opencode" (
    if exist "%REPO_DIR%\.opencode\agents\*.md" (
        xcopy /y /q "%REPO_DIR%\.opencode\agents\*.md" "%TEMP_DIR%\.opencode\agents\" >nul
    )
)
if "%PROVIDER%"=="cursor" (
    if exist "%REPO_DIR%\.cursor\agents\*.md" (
        xcopy /y /q "%REPO_DIR%\.cursor\agents\*.md" "%TEMP_DIR%\.cursor\agents\" >nul
    )
)
if "%PROVIDER%"=="codex" (
    if exist "%REPO_DIR%\.codex\agents\*.md" (
        xcopy /y /q "%REPO_DIR%\.codex\agents\*.md" "%TEMP_DIR%\.codex\agents\" >nul
    )
)
if "%PROVIDER%"=="claude" (
    if exist "%REPO_DIR%\.claude\agents\*.md" (
        xcopy /y /q "%REPO_DIR%\.claude\agents\*.md" "%TEMP_DIR%\.claude\agents\" >nul
    )
)
if exist "%REPO_DIR%\AGENTS.md" (
    copy /y "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\" >nul
)

echo Regenerating fresh copies...
pushd "%REPO_DIR%"
call "%SCRIPT_DIR%generate.bat" --provider %PROVIDER% >nul
popd

set DIFF_FOUND=0

if "%PROVIDER%"=="github" (
    for %%f in ("%REPO_DIR%\.github\agents\*.agent.md") do (
        set "fname=%%~nxf"
        if not exist "%TEMP_DIR%\.github\agents\%%~nxf" (
            echo MISMATCH: .github\agents\%%~nxf ^(new file, not in previous generation^)
            set DIFF_FOUND=1
        ) else (
            fc /b "%%f" "%TEMP_DIR%\.github\agents\%%~nxf" >nul
            if errorlevel 1 (
                echo MISMATCH: .github\agents\%%~nxf
                set DIFF_FOUND=1
            )
        )
    )
    for %%f in ("%TEMP_DIR%\.github\agents\*.agent.md") do (
        if not exist "%REPO_DIR%\.github\agents\%%~nxf" (
            echo MISMATCH: .github\agents\%%~nxf ^(file removed^)
            set DIFF_FOUND=1
        )
    )
)

if "%PROVIDER%"=="opencode" (
    for %%f in ("%REPO_DIR%\.opencode\agents\*.md") do (
        set "fname=%%~nxf"
        if not exist "%TEMP_DIR%\.opencode\agents\%%~nxf" (
            echo MISMATCH: .opencode\agents\%%~nxf ^(new file, not in previous generation^)
            set DIFF_FOUND=1
        ) else (
            fc /b "%%f" "%TEMP_DIR%\.opencode\agents\%%~nxf" >nul
            if errorlevel 1 (
                echo MISMATCH: .opencode\agents\%%~nxf
                set DIFF_FOUND=1
            )
        )
    )
    for %%f in ("%TEMP_DIR%\.opencode\agents\*.md") do (
        if not exist "%REPO_DIR%\.opencode\agents\%%~nxf" (
            echo MISMATCH: .opencode\agents\%%~nxf ^(file removed^)
            set DIFF_FOUND=1
        )
    )
)

if "%PROVIDER%"=="cursor" (
    for %%f in ("%REPO_DIR%\.cursor\agents\*.md") do (
        set "fname=%%~nxf"
        if not exist "%TEMP_DIR%\.cursor\agents\%%~nxf" (
            echo MISMATCH: .cursor\agents\%%~nxf ^(new file, not in previous generation^)
            set DIFF_FOUND=1
        ) else (
            fc /b "%%f" "%TEMP_DIR%\.cursor\agents\%%~nxf" >nul
            if errorlevel 1 (
                echo MISMATCH: .cursor\agents\%%~nxf
                set DIFF_FOUND=1
            )
        )
    )
    for %%f in ("%TEMP_DIR%\.cursor\agents\*.md") do (
        if not exist "%REPO_DIR%\.cursor\agents\%%~nxf" (
            echo MISMATCH: .cursor\agents\%%~nxf ^(file removed^)
            set DIFF_FOUND=1
        )
    )
)

if "%PROVIDER%"=="codex" (
    for %%f in ("%REPO_DIR%\.codex\agents\*.md") do (
        set "fname=%%~nxf"
        if not exist "%TEMP_DIR%\.codex\agents\%%~nxf" (
            echo MISMATCH: .codex\agents\%%~nxf ^(new file, not in previous generation^)
            set DIFF_FOUND=1
        ) else (
            fc /b "%%f" "%TEMP_DIR%\.codex\agents\%%~nxf" >nul
            if errorlevel 1 (
                echo MISMATCH: .codex\agents\%%~nxf
                set DIFF_FOUND=1
            )
        )
    )
    for %%f in ("%TEMP_DIR%\.codex\agents\*.md") do (
        if not exist "%REPO_DIR%\.codex\agents\%%~nxf" (
            echo MISMATCH: .codex\agents\%%~nxf ^(file removed^)
            set DIFF_FOUND=1
        )
    )
)

if "%PROVIDER%"=="claude" (
    for %%f in ("%REPO_DIR%\.claude\agents\*.md") do (
        set "fname=%%~nxf"
        if not exist "%TEMP_DIR%\.claude\agents\%%~nxf" (
            echo MISMATCH: .claude\agents\%%~nxf ^(new file, not in previous generation^)
            set DIFF_FOUND=1
        ) else (
            fc /b "%%f" "%TEMP_DIR%\.claude\agents\%%~nxf" >nul
            if errorlevel 1 (
                echo MISMATCH: .claude\agents\%%~nxf
                set DIFF_FOUND=1
            )
        )
    )
    for %%f in ("%TEMP_DIR%\.claude\agents\*.md") do (
        if not exist "%REPO_DIR%\.claude\agents\%%~nxf" (
            echo MISMATCH: .claude\agents\%%~nxf ^(file removed^)
            set DIFF_FOUND=1
        )
    )
)

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
