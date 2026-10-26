@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROVIDER="
set "TARGET_DIR="
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
echo   github   Install GitHub Copilot agent files to %%USERPROFILE%%\.config\github-copilot\agents\
echo   opencode Install OpenCode agent files to %%USERPROFILE%%\.config\opencode\agents\
echo   cursor   Install Cursor agent files to %%USERPROFILE%%\.config\cursor\agents\
echo   codex    Install GitHub Codex agent files to %%USERPROFILE%%\.config\codex\agents\
echo   claude   Install Claude Code agent files to %%USERPROFILE%%\.config\claude\agents\
exit /b 0

:done_parsing

rem Validate provider and resolve source dir, file extension, and target directory
if "%PROVIDER%"=="" (
    echo Error: --provider is required >&2
    echo Usage: %~nx0 --provider ^<github^|opencode^|cursor^|codex^|claude^> >&2
    exit /b 1
)

if "%PROVIDER%"=="github" (
    set "OUT_DIR=.github\agents"
    set "EXT=agent.md"
    set "TARGET_DIR=%USERPROFILE%\.config\github-copilot\agents"
)
if "%PROVIDER%"=="opencode" (
    set "OUT_DIR=.opencode\agents"
    set "EXT=md"
    set "TARGET_DIR=%USERPROFILE%\.config\opencode\agents"
)
if "%PROVIDER%"=="cursor" (
    set "OUT_DIR=.cursor\agents"
    set "EXT=md"
    set "TARGET_DIR=%USERPROFILE%\.config\cursor\agents"
)
if "%PROVIDER%"=="codex" (
    set "OUT_DIR=.codex\agents"
    set "EXT=md"
    set "TARGET_DIR=%USERPROFILE%\.config\codex\agents"
)
if "%PROVIDER%"=="claude" (
    set "OUT_DIR=.claude\agents"
    set "EXT=md"
    set "TARGET_DIR=%USERPROFILE%\.config\claude\agents"
)
if "%OUT_DIR%"=="" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode, cursor, codex, claude >&2
    exit /b 1
)

echo Running generator for provider: %PROVIDER%...
call "%SCRIPT_DIR%generate.bat" --provider %PROVIDER%

if not exist "%TARGET_DIR%" (
    echo Creating target directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

echo Installing agents to %TARGET_DIR%...

for %%f in ("%SCRIPT_DIR%..\%OUT_DIR%\*.%EXT%") do (
    copy "%%f" "%TARGET_DIR%\" >nul
    echo   Installed: %%~nxf
)

set count=0
for %%f in ("%TARGET_DIR%\*") do set /a count+=1
echo Done. Installed %count% agents globally.
endlocal
