@echo off

echo.
echo ==============================================
echo   AI Development Environment Installer
echo   Git + Gemini CLI + Codex CLI + Claude Code
echo ==============================================
echo.
echo   Prerequisites (install manually first):
echo     - Python  : https://www.python.org/downloads/
echo     - VS Code : https://code.visualstudio.com/download
echo     - Node.js : https://nodejs.org/en/download
echo.

REM ==================================================
REM  STEP 0: Ensure npm global bin is in PATH
REM ==================================================
echo [Step 0] Checking npm global path...
echo ----------------------------------------------

REM Add npm global path to current session PATH
IF EXIST "%APPDATA%\npm" (
    echo "%PATH%" | findstr /I /C:"%APPDATA%\npm" >nul 2>&1
    IF ERRORLEVEL 1 (
        set "PATH=%APPDATA%\npm;%PATH%"
        echo   [FIX] Added %APPDATA%\npm to session PATH.
    ) ELSE (
        echo   [OK] npm global path already in PATH.
    )
) ELSE (
    echo   [INFO] %APPDATA%\npm does not exist yet. Will be created after first npm -g install.
)

REM Add Git paths to current session PATH (in case Git was just installed)
IF EXIST "%ProgramFiles%\Git\cmd" (
    echo "%PATH%" | findstr /I /C:"Git\cmd" >nul 2>&1
    IF ERRORLEVEL 1 (
        set "PATH=%ProgramFiles%\Git\cmd;%ProgramFiles%\Git\bin;%PATH%"
        echo   [FIX] Added Git to session PATH.
    )
)
echo.

REM ==================================================
REM  Pre-flight: Check Python
REM ==================================================
echo [Pre-check] Python
echo ----------------------------------------------
where python >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [X] Python not found in PATH.
    echo       Download: https://www.python.org/downloads/
    echo       *** "Add python.exe to PATH" must be checked during install! ***
    echo       Install, then close and reopen this terminal.
    echo.
    GOTO PREREQ_FAIL
)
echo   [OK] Python found.
call python --version
echo.

:CHECK_VSCODE
REM ==================================================
REM  Pre-flight: Check VS Code
REM ==================================================
echo [Pre-check] VS Code
echo ----------------------------------------------
where code >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [X] VS Code not found in PATH.
    echo       Download: https://code.visualstudio.com/download
    echo       Install, then close and reopen this terminal.
    echo.
    GOTO PREREQ_FAIL
)
echo   [OK] VS Code found.
echo.

:CHECK_NODE
echo [Pre-check] Node.js + npm
echo ----------------------------------------------
where node >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [X] Node.js not found in PATH.
    echo       Download LTS: https://nodejs.org/en/download
    echo       Install, then close and reopen this terminal.
    echo.
    GOTO PREREQ_FAIL
)
echo   [OK] Node.js found.
call node --version
call npm --version
echo.

:PREREQ_PASS
echo   All prerequisites OK. Installing tools...
echo.

CALL :STEP1
CALL :STEP2
CALL :STEP3
CALL :STEP4
CALL :STEP5
CALL :STEP6
CALL :SUMMARY

echo.
echo Done. Press any key to close.
pause >nul
exit /b 0

:PREREQ_FAIL
echo ==============================================
echo   Please install the missing prerequisites,
echo   then close this terminal and re-run.
echo ==============================================
echo.
pause
exit /b 0

REM ==================================================
:STEP1
echo [Step 1/6] Git
echo ----------------------------------------------
where git >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [INSTALLING] Git not found. Installing via winget...
    winget install Git.Git --silent --accept-source-agreements --accept-package-agreements
    REM Add Git to PATH for this session immediately
    set "PATH=%ProgramFiles%\Git\cmd;%ProgramFiles%\Git\bin;%PATH%"
    echo   [DONE] Git install attempted.
    echo.
    echo   If failed, run manually:
    echo     winget install Git.Git
    echo   Or download: https://git-scm.com/downloads/win
) ELSE (
    echo   [OK] Git already installed.
    call git --version
)
echo.
exit /b 0

REM ==================================================
:STEP2
echo [Step 2/6] Gemini CLI
echo ----------------------------------------------
where gemini >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [INSTALLING] Gemini CLI...
    call npm install -g @google/gemini-cli
    REM Refresh PATH to pick up newly installed command
    set "PATH=%APPDATA%\npm;%PATH%"
    echo   [DONE] Gemini CLI install attempted.
    echo.
    echo   If failed, run manually:
    echo     npm install -g @google/gemini-cli
) ELSE (
    echo   [OK] Gemini CLI already installed.
)
echo.
exit /b 0

REM ==================================================
:STEP3
echo [Step 3/6] OpenAI Codex CLI
echo ----------------------------------------------
where codex >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [INSTALLING] Codex CLI...
    call npm install -g @openai/codex
    set "PATH=%APPDATA%\npm;%PATH%"
    echo   [DONE] Codex CLI install attempted.
    echo.
    echo   If failed, run manually:
    echo     npm install -g @openai/codex
) ELSE (
    echo   [OK] Codex CLI already installed.
)
echo.
exit /b 0

REM ==================================================
:STEP4
echo [Step 4/6] Claude Code
echo ----------------------------------------------
where claude >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [INSTALLING] Claude Code...
    call npm install -g @anthropic-ai/claude-code
    set "PATH=%APPDATA%\npm;%PATH%"
    echo   [DONE] Claude Code install attempted.
    echo.
    echo   If failed, run manually:
    echo     npm install -g @anthropic-ai/claude-code
) ELSE (
    echo   [OK] Claude Code already installed.
)
echo.
exit /b 0

REM ==================================================
:STEP5
echo [Step 5/6] Set CLAUDE_CODE_GIT_BASH_PATH
echo ----------------------------------------------
IF EXIST "%ProgramFiles%\Git\bin\bash.exe" (
    echo   [OK] Git Bash found: %ProgramFiles%\Git\bin\bash.exe
    set "CLAUDE_CODE_GIT_BASH_PATH=%ProgramFiles%\Git\bin\bash.exe"
    setx CLAUDE_CODE_GIT_BASH_PATH "%ProgramFiles%\Git\bin\bash.exe" >nul 2>&1
    echo   [DONE] Environment variable set permanently.
    echo.
    echo   If failed, run manually:
    echo     setx CLAUDE_CODE_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
) ELSE (
    echo   [WARN] Git Bash not found. Claude Code may not work.
    echo.
    echo   Fix manually:
    echo     1. Install Git: winget install Git.Git
    echo     2. Then run: setx CLAUDE_CODE_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
    echo     3. Close and reopen terminal.
)
echo.
exit /b 0

REM ==================================================
:STEP6
echo [Step 6/6] Register npm global path permanently
echo ----------------------------------------------
REM Check if npm global path is already in user PATH
reg query "HKCU\Environment" /v Path 2>nul | findstr /I /C:"%APPDATA%\npm" >nul 2>&1
IF ERRORLEVEL 1 (
    echo   [FIX] Adding npm global path to user PATH permanently...
    for /f "tokens=2,*" %%a in ('reg query "HKCU\Environment" /v Path 2^>nul ^| findstr /I "Path"') do set "CURRENT_USER_PATH=%%b"
    IF DEFINED CURRENT_USER_PATH (
        setx PATH "%CURRENT_USER_PATH%;%APPDATA%\npm" >nul 2>&1
    ) ELSE (
        setx PATH "%APPDATA%\npm" >nul 2>&1
    )
    echo   [DONE] npm global path added. New terminals will find gemini, codex, claude.
) ELSE (
    echo   [OK] npm global path already in user PATH.
)
echo.
exit /b 0

REM ==================================================
:SUMMARY
echo ==============================================
echo   INSTALLATION SUMMARY
echo ==============================================
echo.

where python >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Python) ELSE (echo   [OK] Python)

where code >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  VS Code) ELSE (echo   [OK] VS Code)

where node >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Node.js) ELSE (echo   [OK] Node.js)

where git >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Git) ELSE (echo   [OK] Git)

where gemini >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Gemini CLI) ELSE (echo   [OK] Gemini CLI)

where codex >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Codex CLI) ELSE (echo   [OK] Codex CLI)

where claude >nul 2>&1
IF ERRORLEVEL 1 (echo   [X]  Claude Code) ELSE (echo   [OK] Claude Code)

echo.
echo ----------------------------------------------
echo   Manual install commands (if needed):
echo     winget install Git.Git
echo     npm install -g @google/gemini-cli
echo     npm install -g @openai/codex
echo     npm install -g @anthropic-ai/claude-code
echo     setx CLAUDE_CODE_GIT_BASH_PATH "C:\Program Files\Git\bin\bash.exe"
echo ----------------------------------------------
echo.
echo   ** Close and reopen terminal for all PATH
echo      changes to take full effect. **
echo.
exit /b 0
