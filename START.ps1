# =============================================================================
# SE Copilot — PowerShell Launcher (Windows)
# Run this by right-clicking and selecting "Run with PowerShell"
# Or from PowerShell terminal: .\START.ps1
# =============================================================================

$Host.UI.RawUI.WindowTitle = "SE Copilot"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host "       SE Copilot  --  Welcome" -ForegroundColor Cyan
    Write-Host "       AI-powered Sales Engineering Assistant" -ForegroundColor Cyan
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-Warning($msg) { Write-Host "  [WARNING] $msg" -ForegroundColor Yellow }
function Write-Error-Msg($msg) { Write-Host "  [ERROR] $msg" -ForegroundColor Red }
function Write-Info($msg) { Write-Host "  $msg" -ForegroundColor White }
function Write-Step($num, $msg) { Write-Host "  $num. $msg" -ForegroundColor Cyan }

# ── Detect environment ────────────────────────────────────────────────────────
function Get-SystemInfo {
    $info = @{}

    # OS
    $info.OS = [System.Environment]::OSVersion.VersionString
    $info.IsWindows = $true

    # Python
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    $python3Cmd = Get-Command python3 -ErrorAction SilentlyContinue

    if ($python3Cmd) {
        $info.PythonCmd = "python3"
        $info.PythonVersion = (python3 --version 2>&1).ToString()
        $info.HasPython = $true
    } elseif ($pythonCmd) {
        $ver = (python --version 2>&1).ToString()
        if ($ver -match "Python 3") {
            $info.PythonCmd = "python"
            $info.PythonVersion = $ver
            $info.HasPython = $true
        } else {
            $info.PythonCmd = $null
            $info.PythonVersion = "Python 2 found (need Python 3)"
            $info.HasPython = $false
        }
    } else {
        $info.PythonCmd = $null
        $info.PythonVersion = "NOT INSTALLED"
        $info.HasPython = $false
    }

    # Git
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    $info.HasGit = $null -ne $gitCmd
    if ($info.HasGit) {
        $info.GitVersion = (git --version 2>&1).ToString()
    }

    # Context file status
    $contextPath = Join-Path $PSScriptRoot "context\PRODUCT_CONTEXT.md"
    $info.ContextExists = Test-Path $contextPath
    if ($info.ContextExists) {
        $content = Get-Content $contextPath -Raw
        $info.ContextFilled = -not ($content -match "\[YOUR COMPANY NAME\]")
    } else {
        $info.ContextFilled = $false
    }

    return $info
}

# ── Main Menu ─────────────────────────────────────────────────────────────────
function Show-MainMenu($sysInfo) {
    Write-Header

    # System status bar
    Write-Host "  System Status" -ForegroundColor DarkGray
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray

    if ($sysInfo.HasPython) {
        Write-Success "Python: $($sysInfo.PythonVersion)"
    } else {
        Write-Error-Msg "Python: $($sysInfo.PythonVersion)"
    }

    if ($sysInfo.HasGit) {
        Write-Success "Git: $($sysInfo.GitVersion)"
    } else {
        Write-Warning "Git: Not installed (optional — needed for team updates)"
    }

    if ($sysInfo.ContextExists -and $sysInfo.ContextFilled) {
        Write-Success "Context file: Filled in and ready"
    } elseif ($sysInfo.ContextExists -and -not $sysInfo.ContextFilled) {
        Write-Warning "Context file: Found but NOT filled in yet"
    } else {
        Write-Error-Msg "Context file: Not found"
    }

    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  What would you like to do?" -ForegroundColor White
    Write-Host ""
    Write-Step "1" "First time setup          -- install dependencies, verify everything"
    Write-Step "2" "Build a prompt            -- generate use cases, integration plan, demo"
    Write-Step "3" "Manage intake files       -- add docs & URLs for product/client"
    Write-Step "4" "Open my context file      -- fill in or update product info"
    Write-Step "5" "Check context file status -- see what's filled in"
    Write-Step "6" "Claude.ai Project setup   -- step-by-step instructions"
    Write-Step "7" "Pull latest from GitHub   -- get team's newest context updates"
    Write-Step "8" "Exit"
    Write-Host ""

    $choice = Read-Host "  Enter a number (1-7)"
    return $choice
}

# ── Setup ─────────────────────────────────────────────────────────────────────
function Run-Setup($sysInfo) {
    Write-Header
    Write-Host "  First Time Setup" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    # Python check
    if (-not $sysInfo.HasPython) {
        Write-Error-Msg "Python 3 is not installed."
        Write-Host ""
        Write-Host "  To install Python on Windows:" -ForegroundColor Yellow
        Write-Host ""
        Write-Step "1" "Open your browser"
        Write-Step "2" "Go to: https://python.org/downloads"
        Write-Step "3" "Click the yellow 'Download Python 3.x.x' button"
        Write-Step "4" "Run the downloaded installer"
        Write-Step "5" "IMPORTANT: Check the box 'Add Python to PATH'" -ForegroundColor Yellow
        Write-Step "6" "Click 'Install Now'"
        Write-Step "7" "Restart your computer"
        Write-Step "8" "Re-open this script"
        Write-Host ""

        $openBrowser = Read-Host "  Open python.org now? (y/n)"
        if ($openBrowser -eq "y") {
            Start-Process "https://python.org/downloads"
        }
        Read-Host "  Press Enter to return to menu"
        return
    }

    Write-Success "Python found: $($sysInfo.PythonVersion)"

    # Git check (optional)
    if (-not $sysInfo.HasGit) {
        Write-Warning "Git is not installed (optional but recommended for team use)"
        Write-Host ""
        Write-Info "Git lets you sync context updates with your team automatically."
        Write-Info "Without it, you'll share updates manually via email/Slack."
        Write-Host ""
        $installGit = Read-Host "  Open git-scm.com to install Git? (y/n)"
        if ($installGit -eq "y") {
            Start-Process "https://git-scm.com/download/win"
        }
    } else {
        Write-Success "Git found: $($sysInfo.GitVersion)"
    }

    # Context file check
    Write-Host ""
    if ($sysInfo.ContextExists -and -not $sysInfo.ContextFilled) {
        Write-Warning "Context file exists but has not been filled in yet."
        Write-Host ""
        Write-Info "Next step: Fill in context\PRODUCT_CONTEXT.md"
        Write-Info "  - Open it in Notepad or any text editor"
        Write-Info "  - Replace every [BRACKET] with your real product info"
        Write-Info "  - Save the file"
        Write-Host ""
        Write-Info "Reference files to help you:"
        Write-Info "  examples\EXAMPLE_FILLED_CONTEXT.md  -- completed example"
        Write-Info "  context\CONTEXT_GUIDE.md            -- field-by-field guide"
        Write-Host ""
        $openFile = Read-Host "  Open context file in Notepad now? (y/n)"
        if ($openFile -eq "y") {
            $contextPath = Join-Path $PSScriptRoot "context\PRODUCT_CONTEXT.md"
            Start-Process "notepad.exe" $contextPath
        }
    } elseif ($sysInfo.ContextExists -and $sysInfo.ContextFilled) {
        Write-Success "Context file is filled in and ready to use!"
    } else {
        Write-Error-Msg "Context file not found. Make sure you're in the se-copilot folder."
    }

    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Info "When ready, choose option 2 from the main menu to build your first prompt."
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Build Prompt ──────────────────────────────────────────────────────────────
function Run-BuildPrompt($sysInfo) {
    if (-not $sysInfo.HasPython) {
        Write-Host ""
        Write-Error-Msg "Python is required. Please run Setup first (option 1)."
        Write-Host ""
        Read-Host "  Press Enter to return to menu"
        return
    }

    $scriptPath = Join-Path $PSScriptRoot "scripts\build_prompt.py"
    & $sysInfo.PythonCmd $scriptPath

    Read-Host "  Press Enter to return to menu"
}

# ── Open Context File ─────────────────────────────────────────────────────────
function Open-ContextFile {
    $contextPath = Join-Path $PSScriptRoot "context\PRODUCT_CONTEXT.md"
    if (Test-Path $contextPath) {
        Write-Host ""
        Write-Info "Opening context\PRODUCT_CONTEXT.md..."
        Write-Host ""
        Write-Info "Tips:"
        Write-Info "  - Replace every [BRACKET] with your real info"
        Write-Info "  - See examples\EXAMPLE_FILLED_CONTEXT.md for reference"
        Write-Info "  - Save when done, then choose option 2 to build a prompt"
        Write-Host ""

        # Try VS Code first, fall back to Notepad
        $vsCode = Get-Command code -ErrorAction SilentlyContinue
        if ($vsCode) {
            Start-Process "code" $contextPath
            Write-Success "Opened in VS Code"
        } else {
            Start-Process "notepad.exe" $contextPath
            Write-Success "Opened in Notepad"
        }
    } else {
        Write-Error-Msg "context\PRODUCT_CONTEXT.md not found."
    }
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Check Context Status ──────────────────────────────────────────────────────
function Check-ContextStatus($sysInfo) {
    Write-Header
    Write-Host "  Context File Status" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    $contextPath = Join-Path $PSScriptRoot "context\PRODUCT_CONTEXT.md"

    if (-not (Test-Path $contextPath)) {
        Write-Error-Msg "context\PRODUCT_CONTEXT.md not found."
        Write-Info "Make sure you're running this from the se-copilot folder."
        Write-Host ""
        Read-Host "  Press Enter to return to menu"
        return
    }

    $content = Get-Content $contextPath -Raw
    $lines = Get-Content $contextPath

    # Count placeholders
    $placeholders = ($content | Select-String -Pattern "\[YOUR|\[PRODUCT|\[DATE|\[COMPANY|\[MODULE|\[Tier|\[Competitor|\[Vertical|\[Module|\[SE " -AllMatches).Matches.Count

    Write-Info "File: context\PRODUCT_CONTEXT.md"
    Write-Info "Lines: $($lines.Count)"
    Write-Info "Size: $([math]::Round((Get-Item $contextPath).Length / 1KB, 1)) KB"
    Write-Host ""

    if ($placeholders -gt 0) {
        Write-Warning "Unfilled placeholders found: ~$placeholders"
        Write-Host ""
        Write-Info "To find them: open the file and search for [ (left bracket)"
        Write-Info "Each [BRACKET] needs to be replaced with your real information."
    } else {
        Write-Success "No unfilled placeholders detected — looks complete!"
        Write-Host ""
        Write-Info "Remember to update it when:"
        Write-Info "  - Product ships new features"
        Write-Info "  - You win a deal with a new use case"
        Write-Info "  - Pricing changes"
        Write-Info "  - New competitors emerge"
    }

    # Section completion summary
    Write-Host ""
    Write-Host "  Section checks:" -ForegroundColor DarkGray
    $sections = @("COMPANY OVERVIEW","PRODUCT MODULES","INTEGRATIONS","PAIN POINT","PRICING","COMPETITIVE","REFERENCE ARCH","OBJECTION","PROOF POINTS","DEMO GUIDANCE")
    foreach ($section in $sections) {
        if ($content -match $section) {
            Write-Host "    [FOUND]   $section" -ForegroundColor Green
        } else {
            Write-Host "    [MISSING] $section" -ForegroundColor Red
        }
    }

    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Claude Project Guide ──────────────────────────────────────────────────────
function Show-ClaudeGuide {
    Write-Header
    Write-Host "  How to Set Up Your Claude.ai Project" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Info "Do this once. After setup, Claude loads your context automatically."
    Write-Host ""

    Write-Host "  STEP 1 — Open Claude.ai" -ForegroundColor Yellow
    Write-Info "  Go to: https://claude.ai  and sign in"
    Write-Host ""

    Write-Host "  STEP 2 — Create a new Project" -ForegroundColor Yellow
    Write-Info "  In the left sidebar, click 'Projects'"
    Write-Info "  Click '+ New Project'"
    Write-Info "  Name it:  SE Copilot -- [Your Company Name]"
    Write-Host ""

    Write-Host "  STEP 3 — Upload your context file" -ForegroundColor Yellow
    Write-Info "  Click 'Add content'"
    Write-Info "  Navigate to this folder: $PSScriptRoot"
    Write-Info "  Select: context\PRODUCT_CONTEXT.md"
    Write-Host ""

    Write-Host "  STEP 4 — Paste Project Instructions" -ForegroundColor Yellow
    Write-Info "  Click 'Edit project instructions' and paste the following:"
    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host @"
  You are an expert Sales Engineering assistant for [YOUR COMPANY NAME].
  You have deep knowledge of our product, integrations, and ideal customer
  profile from the context document in this project.

  When I describe a prospect, always:
  1. Build a company profile with inferred tech stack and pain points
  2. Identify the top 3 most relevant use cases from our product context
  3. Map how our product integrates with their specific stack
  4. Generate a tailored demo script outline

  Ask for more detail if my input is thin. Be specific — name their tools,
  reference their industry, use their language. Never give generic answers.
"@ -ForegroundColor White
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "  STEP 5 — Replace [YOUR COMPANY NAME] then click Save" -ForegroundColor Yellow
    Write-Host ""
    Write-Success "Done! Every new conversation in this Project auto-loads your context."
    Write-Host ""

    $openClaude = Read-Host "  Open claude.ai now? (y/n)"
    if ($openClaude -eq "y") {
        Start-Process "https://claude.ai"
    }

    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Manage Intake ─────────────────────────────────────────────────────────────
function Manage-Intake {
    Write-Header
    Write-Host "  Manage Intake Files" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
    Write-Info "Drop documents into these folders, then run 'Build a prompt'."
    Write-Info "The tool reads them automatically when generating output."
    Write-Host ""

    $productPath = Join-Path $PSScriptRoot "intake\product"
    $clientPath  = Join-Path $PSScriptRoot "intake\client"
    $urlsPath    = Join-Path $PSScriptRoot "intake\urls"
    $pUrlFile    = Join-Path $urlsPath "product_urls.txt"
    $cUrlFile    = Join-Path $urlsPath "client_urls.txt"

    # Count files
    $pFiles = @(Get-ChildItem $productPath -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne "README.md" })
    $cFiles = @(Get-ChildItem $clientPath -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -ne "README.md" })

    Write-Host "  PRODUCT documents  ($($pFiles.Count) file(s)):" -ForegroundColor Yellow
    Write-Info "    $productPath"
    if ($pFiles.Count -gt 0) {
        foreach ($f in $pFiles) { Write-Success "    $($f.Name)" }
    } else {
        Write-Host "    (empty — drop PDF, DOCX, TXT, MD files here)" -ForegroundColor DarkGray
    }
    Write-Host ""

    Write-Host "  CLIENT documents  ($($cFiles.Count) file(s)):" -ForegroundColor Yellow
    Write-Info "    $clientPath"
    if ($cFiles.Count -gt 0) {
        foreach ($f in $cFiles) { Write-Success "    $($f.Name)" }
    } else {
        Write-Host "    (empty — drop prospect notes, RFPs, job postings here)" -ForegroundColor DarkGray
    }
    Write-Host ""

    Write-Host "  PRODUCT URLs:" -ForegroundColor Yellow
    Write-Info "    $pUrlFile"
    Write-Host "  CLIENT URLs:" -ForegroundColor Yellow
    Write-Info "    $cUrlFile"
    Write-Host ""
    Write-Host "  Supported types: .pdf  .docx  .txt  .md  .csv  .json" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  REMINDER: Clear intake\client\ between prospects." -ForegroundColor Yellow
    Write-Host ""

    $openF = Read-Host "  Open intake folders in Explorer? (y/n)"
    if ($openF -eq "y") {
        Start-Process "explorer.exe" $productPath
        Start-Process "explorer.exe" $clientPath
        Start-Process "explorer.exe" $urlsPath
    }
    Write-Host ""
    $editP = Read-Host "  Edit product_urls.txt now? (y/n)"
    if ($editP -eq "y") {
        $vsCode = Get-Command code -ErrorAction SilentlyContinue
        if ($vsCode) { Start-Process "code" $pUrlFile }
        else { Start-Process "notepad.exe" $pUrlFile }
    }
    $editC = Read-Host "  Edit client_urls.txt now? (y/n)"
    if ($editC -eq "y") {
        $vsCode = Get-Command code -ErrorAction SilentlyContinue
        if ($vsCode) { Start-Process "code" $cUrlFile }
        else { Start-Process "notepad.exe" $cUrlFile }
    }
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Git Pull ──────────────────────────────────────────────────────────────────
function Run-GitPull($sysInfo) {
    Write-Header
    Write-Host "  Pull Latest Context from GitHub" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""

    if (-not $sysInfo.HasGit) {
        Write-Error-Msg "Git is not installed."
        Write-Host ""
        Write-Info "To install Git:"
        Write-Step "1" "Go to: https://git-scm.com/download/win"
        Write-Step "2" "Download and run the installer (keep all default settings)"
        Write-Step "3" "Restart this script"
        Write-Host ""
        $openGit = Read-Host "  Open git-scm.com now? (y/n)"
        if ($openGit -eq "y") { Start-Process "https://git-scm.com/download/win" }
        Read-Host "  Press Enter to return to menu"
        return
    }

    # Check if it's a git repo
    $gitDir = Join-Path $PSScriptRoot ".git"
    if (-not (Test-Path $gitDir)) {
        Write-Warning "This folder is not a Git repository."
        Write-Host ""
        Write-Info "To connect it to GitHub:"
        Write-Step "1" "Ask your SE lead for the GitHub repo URL"
        Write-Step "2" "Open PowerShell in this folder"
        Write-Step "3" "Run: git remote add origin [REPO URL]"
        Write-Step "4" "Run: git pull origin main"
        Write-Host ""
        Read-Host "  Press Enter to return to menu"
        return
    }

    Write-Info "Pulling latest changes from GitHub..."
    Write-Host ""
    git pull
    Write-Host ""
    Write-Success "Done! Your context file is now up to date."
    Write-Host ""
    Read-Host "  Press Enter to return to menu"
}

# ── Main Loop ─────────────────────────────────────────────────────────────────
$running = $true
while ($running) {
    $sysInfo = Get-SystemInfo
    $choice = Show-MainMenu $sysInfo

    switch ($choice) {
        "1" { Run-Setup $sysInfo }
        "2" { Run-BuildPrompt $sysInfo }
        "3" { Manage-Intake }
        "4" { Open-ContextFile }
        "5" { Check-ContextStatus $sysInfo }
        "6" { Show-ClaudeGuide }
        "7" { Run-GitPull $sysInfo }
        "8" { $running = $false }
        default {
            Write-Host ""
            Write-Host "  Invalid choice. Please enter 1-7." -ForegroundColor Red
            Write-Host ""
            Start-Sleep -Seconds 1
        }
    }
}

Write-Host ""
Write-Host "  Goodbye!" -ForegroundColor Cyan
Write-Host ""
