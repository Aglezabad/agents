@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROVIDER=opencode"
set "TARGET_DIR=%USERPROFILE%\.config\opencode\agents"

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
echo Usage: %~nx0 [--provider ^<github^|opencode^>] >&2
exit /b 1

:show_help
echo Usage: %~nx0 [--provider ^<github^|opencode^>]
echo.
echo Providers:
echo   github    Install GitHub Copilot agent files
echo   opencode  Install OpenCode agent files (default)
exit /b 0

:done_parsing

rem Validate provider
if not "%PROVIDER%"=="github" if not "%PROVIDER%"=="opencode" (
    echo Error: unknown provider '%PROVIDER%' >&2
    echo Supported providers: github, opencode >&2
    exit /b 1
)

echo Running generator for provider: %PROVIDER%...
call "%SCRIPT_DIR%generate.bat" --provider %PROVIDER%

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

set count=0
for %%f in ("%TARGET_DIR%\*") do set /a count+=1
echo Done. Installed %count% agents globally.
endlocal
