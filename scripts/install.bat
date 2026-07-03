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
