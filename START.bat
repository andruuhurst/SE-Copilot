@echo off
setlocal EnableDelayedExpansion
:: =============================================================================
:: SE Copilot — Universal Launcher (Windows CMD)
:: Fixed: loops back to menu after every action instead of exiting
:: =============================================================================

:MAIN_LOOP
cls
echo.
echo   ============================================================
echo        SE Copilot  --  Welcome
echo        AI-powered Sales Engineering Assistant
echo   ============================================================
echo.

:: ── System checks ─────────────────────────────────────────────────────────────
for /f "tokens=4-5 delims=. " %%i in ('ver') do set WIN_VER=%%i.%%j
echo   OS: Windows %WIN_VER%

:: Python
where python >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%v in ('python --version 2^>^&1') do set PYVER=%%v
    set HAS_PYTHON=true
    echo   Python: !PYVER!
) else (
    set HAS_PYTHON=false
    set PYVER=NOT FOUND
    echo   Python: NOT FOUND  ^(run option 1 to fix^)
)

:: Context file status
findstr /c:"[YOUR COMPANY NAME]" "context\PRODUCT_CONTEXT.md" >nul 2>&1
if %errorlevel% equ 0 (
    echo   Context: NOT filled in yet
) else (
    echo   Context: Ready
)

:: Read saved mode and conditionally show intake status
set SAVED_MODE=
if exist "scripts\.last_mode.json" (
    for /f "usebackq tokens=*" %%m in (`python -c "import json; print(json.load(open('scripts/.last_mode.json')).get('mode',''))" 2^>nul`) do set SAVED_MODE=%%m
)

if "!SAVED_MODE!"=="2" (
    set PDOC_COUNT=0
    set CDOC_COUNT=0
    for %%f in (intake\product\*) do (
        if not "%%~nxf"=="README.md" set /a PDOC_COUNT+=1
    )
    for %%f in (intake\client\*) do (
        if not "%%~nxf"=="README.md" set /a CDOC_COUNT+=1
    )
    echo   Intake:  Product docs: !PDOC_COUNT! file^(s^)  /  Client docs: !CDOC_COUNT! file^(s^)
) else if "!SAVED_MODE!"=="3" (
    set PDOC_COUNT=0
    set CDOC_COUNT=0
    for %%f in (intake\product\*) do (
        if not "%%~nxf"=="README.md" set /a PDOC_COUNT+=1
    )
    for %%f in (intake\client\*) do (
        if not "%%~nxf"=="README.md" set /a CDOC_COUNT+=1
    )
    echo   Intake:  Product docs: !PDOC_COUNT! file^(s^)  /  Client docs: !CDOC_COUNT! file^(s^)
) else if "!SAVED_MODE!"=="" (
    echo   Mode:    Not set yet -- will be chosen when you build a prompt
) else (
    echo   Mode:    Claude UI ^(files uploaded directly in Claude^)
)

echo.
echo   ============================================================
echo   What would you like to do?
echo.
echo     1.  First time setup         ^(check Python, verify everything^)
echo     2.  Build a prompt           ^(use cases, integration plan, demo^)
echo     3.  Manage intake files      ^(add docs ^& URLs for product/client^)
echo     4.  Check context file       ^(see what's filled in^)
echo     5.  Claude.ai Project setup  ^(step-by-step guide^)
echo     Q.  Quit
echo.
set /p CHOICE="  Enter a choice: "

if /i "%CHOICE%"=="1" goto :SETUP
if /i "%CHOICE%"=="2" goto :RUN
if /i "%CHOICE%"=="3" goto :INTAKE
if /i "%CHOICE%"=="4" goto :CHECK
if /i "%CHOICE%"=="5" goto :CLAUDE_GUIDE
if /i "%CHOICE%"=="Q" goto :EXIT
echo.
echo   Invalid choice. Please enter 1-5 or Q.
timeout /t 1 /nobreak >nul
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:SETUP
cls
echo.
echo   ============================================================
echo        First Time Setup
echo   ============================================================
echo.
if "%HAS_PYTHON%"=="false" (
    echo   [ERROR] Python 3 is not installed or not in PATH.
    echo.
    echo   To install Python:
    echo     1. Open browser: https://python.org/downloads
    echo     2. Click "Download Python 3.x.x"
    echo     3. Run installer
    echo     4. CHECK THE BOX: "Add Python to PATH"  ^<-- IMPORTANT
    echo     5. Click Install Now
    echo     6. Restart this script
    echo.
    pause
    goto :MAIN_LOOP
)
echo   [OK] !PYVER! found
echo.
findstr /c:"[YOUR COMPANY NAME]" "context\PRODUCT_CONTEXT.md" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [WARNING] context\PRODUCT_CONTEXT.md has not been filled in.
    echo.
    echo   Open it in Notepad and replace every [BRACKET] with real info.
    echo   Reference: examples\EXAMPLE_FILLED_CONTEXT.md
    echo              context\CONTEXT_GUIDE.md
) else (
    echo   [OK] Context file looks filled in
)
echo.
echo   [OK] Setup check complete. You're ready to use SE Copilot.
echo.
pause
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:RUN
echo.
if "%HAS_PYTHON%"=="false" (
    echo   [ERROR] Python required. Run option 1 first.
    pause
    goto :MAIN_LOOP
)
python scripts\build_prompt.py
pause
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:INTAKE
cls
echo.
echo   ============================================================
echo        Manage Intake Files
echo   ============================================================
echo.
echo   Drop documents into these folders, then run option 2.
echo   The tool will automatically read them when building prompts.
echo.
echo   PRODUCT documents (your product's docs, decks, guides):
echo     %CD%\intake\product\
echo.
echo   CLIENT documents (prospect notes, RFPs, job postings):
echo     %CD%\intake\client\
echo.
echo   PRODUCT URLs (edit to add your product's web pages):
echo     %CD%\intake\urls\product_urls.txt
echo.
echo   CLIENT URLs (edit to add prospect's website, LinkedIn, etc):
echo     %CD%\intake\urls\client_urls.txt
echo.
echo   Supported file types: .pdf  .docx  .txt  .md  .csv  .json
echo.
echo   REMINDER: Clear intake\client\ between prospects.
echo.
set /p OPEN_FOLDERS="  Open intake folders in Explorer? (y/n): "
if /i "%OPEN_FOLDERS%"=="y" (
    explorer "%CD%\intake\product"
    explorer "%CD%\intake\client"
    explorer "%CD%\intake\urls"
)
echo.
set /p EDIT_PURLS="  Open product_urls.txt to edit? (y/n): "
if /i "%EDIT_PURLS%"=="y" notepad "%CD%\intake\urls\product_urls.txt"
echo.
set /p EDIT_CURLS="  Open client_urls.txt to edit? (y/n): "
if /i "%EDIT_CURLS%"=="y" notepad "%CD%\intake\urls\client_urls.txt"
echo.
pause
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:CHECK
cls
echo.
echo   ============================================================
echo        Context File Status
echo   ============================================================
echo.
if not exist "context\PRODUCT_CONTEXT.md" (
    echo   [ERROR] context\PRODUCT_CONTEXT.md not found.
    echo   Make sure you're running START.bat from inside se-copilot folder.
    echo.
    pause
    goto :MAIN_LOOP
)
findstr /c:"[YOUR" "context\PRODUCT_CONTEXT.md" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [WARNING] Unfilled placeholders found.
    echo   Open context\PRODUCT_CONTEXT.md and search for [ to find them.
    echo.
    echo   Reference files:
    echo     examples\EXAMPLE_FILLED_CONTEXT.md  -- completed example
    echo     context\CONTEXT_GUIDE.md            -- field-by-field guide
) else (
    echo   [OK] No unfilled placeholders found. Context looks complete!
    echo.
    echo   Update this file when:
    echo     - Product ships new features
    echo     - You win a deal with a new use case
    echo     - Pricing or integrations change
)
echo.
echo   Section presence check:
for %%s in (
    "COMPANY OVERVIEW"
    "PRODUCT MODULES"
    "INTEGRATIONS"
    "PAIN POINT"
    "PRICING"
    "COMPETITIVE"
    "REFERENCE ARCH"
    "OBJECTION"
    "PROOF POINTS"
    "DEMO GUIDANCE"
) do (
    findstr /i %%s "context\PRODUCT_CONTEXT.md" >nul 2>&1
    if !errorlevel! equ 0 (
        echo     [FOUND]   %%~s
    ) else (
        echo     [MISSING] %%~s
    )
)
echo.
pause
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:CLAUDE_GUIDE
cls
echo.
echo   ============================================================
echo        How to Set Up Your Claude.ai Project
echo   ============================================================
echo.
echo   Do this once. After setup, Claude auto-loads your context.
echo.
echo   STEP 1 -- Go to claude.ai
echo     Open browser: https://claude.ai  and sign in
echo.
echo   STEP 2 -- Create a new Project
echo     Left sidebar -^> Projects -^> + New Project
echo     Name it:  SE Copilot -- [Your Company Name]
echo.
echo   STEP 3 -- Upload your context file
echo     Click "Add content"
echo     Select: context\PRODUCT_CONTEXT.md
echo.
echo   STEP 4 -- Paste Project Instructions
echo     Click "Edit project instructions" and paste:
echo.
echo   --------------------------------------------------------
echo   You are an expert Sales Engineering assistant for
echo   [YOUR COMPANY NAME]. You have deep knowledge of our
echo   product, integrations, and ideal customer profile from
echo   the context document in this project.
echo.
echo   When I describe a prospect, always:
echo   1. Build a company profile with inferred tech stack
echo      and likely pain points
echo   2. Identify the top 3 most relevant use cases
echo   3. Map how our product integrates with their stack
echo   4. Generate a tailored demo script outline
echo.
echo   Ask for more detail if my input is thin. Be specific --
echo   name their tools, reference their industry, use their
echo   language. Never give generic answers.
echo   --------------------------------------------------------
echo.
echo   STEP 5 -- Replace [YOUR COMPANY NAME] then click Save
echo.
echo   DONE! Every new conversation auto-loads your context.
echo.
set /p OPEN_CLAUDE="  Open claude.ai now? (y/n): "
if /i "%OPEN_CLAUDE%"=="y" start https://claude.ai
echo.
pause
goto :MAIN_LOOP

:: ─────────────────────────────────────────────────────────────────────────────
:EXIT
echo.
echo   Goodbye!
echo.
exit /b 0
