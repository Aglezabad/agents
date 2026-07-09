@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROVIDER="
set "TIER=performance"
set "TARGET_DIR="

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
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
echo Unknown option: %~1 >&2
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--tier ^<economy^|balanced^|performance^>] >&2
exit /b 1

:show_help
echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> [--tier ^<economy^|balanced^|performance^>]
echo.
echo Options:
echo   --tier  Model tier to install: economy, balanced, or performance (default: performance)
echo.
echo Providers:
echo   github   Install GitHub Copilot agent files to %%USERPROFILE%%\.config\github-copilot\agents\
echo   opencode Install OpenCode agent files to %%USERPROFILE%%\.config\opencode\agents\
echo   cursor   Install Cursor agent files to %%USERPROFILE%%\.config\cursor\agents\
echo   codex    Install GitHub Codex agent files to %%USERPROFILE%%\.config\codex\agents\
echo   claude   Install Claude Code agent files to %%USERPROFILE%%\.config\claude\agents\
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

rem Set target directory based on provider
if "%PROVIDER%"=="github" set "TARGET_DIR=%USERPROFILE%\.config\github-copilot\agents"
if "%PROVIDER%"=="opencode" set "TARGET_DIR=%USERPROFILE%\.config\opencode\agents"
if "%PROVIDER%"=="cursor" set "TARGET_DIR=%USERPROFILE%\.config\cursor\agents"
if "%PROVIDER%"=="codex" set "TARGET_DIR=%USERPROFILE%\.config\codex\agents"
if "%PROVIDER%"=="claude" set "TARGET_DIR=%USERPROFILE%\.config\claude\agents"

echo Running generator for provider: %PROVIDER%, tier: %TIER%...
call "%SCRIPT_DIR%generate.bat" --provider %PROVIDER% --tier %TIER%

if not exist "%TARGET_DIR%" (
    echo Creating target directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

echo Installing agents to %TARGET_DIR%...

if "%PROVIDER%"=="github" (
    for %%f in ("%SCRIPT_DIR%..\.github\agents\*.agent.md") do (
        copy "%%f" "%TARGET_DIR%\" >nul
        echo   Installed: %%~nxf
    )
)
if "%PROVIDER%"=="opencode" (
    for %%f in ("%SCRIPT_DIR%..\.opencode\agents\*.md") do (
        copy "%%f" "%TARGET_DIR%\" >nul
        echo   Installed: %%~nxf
    )
)
if "%PROVIDER%"=="cursor" (
    for %%f in ("%SCRIPT_DIR%..\.cursor\agents\*.md") do (
        copy "%%f" "%TARGET_DIR%\" >nul
        echo   Installed: %%~nxf
    )
)
if "%PROVIDER%"=="codex" (
    for %%f in ("%SCRIPT_DIR%..\.codex\agents\*.md") do (
        copy "%%f" "%TARGET_DIR%\" >nul
        echo   Installed: %%~nxf
    )
)
if "%PROVIDER%"=="claude" (
    for %%f in ("%SCRIPT_DIR%..\.claude\agents\*.md") do (
        copy "%%f" "%TARGET_DIR%\" >nul
        echo   Installed: %%~nxf
    )
)

set count=0
for %%f in ("%TARGET_DIR%\*") do set /a count+=1
echo Done. Installed %count% agents globally.
endlocal
