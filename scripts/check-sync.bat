@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR%.."
set "TEMP_DIR=%TEMP%\agent-sync-check-%RANDOM%"

mkdir "%TEMP_DIR%"
mkdir "%TEMP_DIR%\.github\agents"
mkdir "%TEMP_DIR%\.opencode\agents"

echo Saving current generated files to temp...
if exist "%REPO_DIR%\.github\agents\*.agent.md" (
    xcopy /y /q "%REPO_DIR%\.github\agents\*.agent.md" "%TEMP_DIR%\.github\agents\" >nul
)
if exist "%REPO_DIR%\.opencode\agents\*.md" (
    xcopy /y /q "%REPO_DIR%\.opencode\agents\*.md" "%TEMP_DIR%\.opencode\agents\" >nul
)
if exist "%REPO_DIR%\AGENTS.md" (
    copy /y "%REPO_DIR%\AGENTS.md" "%TEMP_DIR%\" >nul
)

echo Regenerating fresh copies...
pushd "%REPO_DIR%"
call "%SCRIPT_DIR%generate.bat" >nul
popd

set DIFF_FOUND=0

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
