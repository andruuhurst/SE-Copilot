#!/bin/bash
# =============================================================================
# SE Copilot — Core Setup Logic (Mac/Linux)
# Called by START.sh with OS argument
# =============================================================================

OS="${1:-unknown}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}[OK]${RESET} $1"; }
warn() { echo -e "  ${YELLOW}[WARNING]${RESET} $1"; }
err()  { echo -e "  ${RED}[ERROR]${RESET} $1"; }
info() { echo -e "  $1"; }

echo ""
echo -e "${CYAN}${BOLD}  First Time Setup${RESET}"
echo "  ─────────────────────────────────────────────"
echo ""

# ── Python check ─────────────────────────────────────────────────────────────
if command -v python3 &>/dev/null; then
    PYVER=$(python3 --version 2>&1)
    ok "Python found: $PYVER"
    PYTHON_CMD="python3"
elif command -v python &>/dev/null && python --version 2>&1 | grep -q "Python 3"; then
    PYVER=$(python --version 2>&1)
    ok "Python found: $PYVER"
    PYTHON_CMD="python"
else
    err "Python 3 is not installed."
    echo ""
    if [[ "$OS" == "mac" ]]; then
        info "To install Python on macOS:"
        info "  Option A (easiest): Run this command:"
        info "    ${CYAN}xcode-select --install${RESET}"
        info "  Option B: Download from https://python.org/downloads"
        echo ""
        read -p "  Open python.org in your browser? (y/n): " OPEN
        if [[ "$OPEN" == "y" ]]; then
            open "https://python.org/downloads" 2>/dev/null || \
            xdg-open "https://python.org/downloads" 2>/dev/null
        fi
    elif [[ "$OS" == "linux" ]]; then
        info "To install Python on Linux:"
        info "  Ubuntu/Debian:  ${CYAN}sudo apt install python3${RESET}"
        info "  Fedora/RHEL:    ${CYAN}sudo dnf install python3${RESET}"
        info "  Arch:           ${CYAN}sudo pacman -S python${RESET}"
    fi
    echo ""
    read -p "  Press Enter to return to menu..." _
    exit 1
fi

# ── Git check (optional) ──────────────────────────────────────────────────────
echo ""
if command -v git &>/dev/null; then
    GITVER=$(git --version 2>&1)
    ok "Git found: $GITVER"
else
    warn "Git is not installed (optional — needed to sync updates with your team)"
    echo ""
    info "Without Git, you'll share context updates manually via Slack/Drive."
    if [[ "$OS" == "mac" ]]; then
        info "To install: run  ${CYAN}xcode-select --install${RESET}  in Terminal"
    elif [[ "$OS" == "linux" ]]; then
        info "To install: run  ${CYAN}sudo apt install git${RESET}  (Ubuntu/Debian)"
    fi
fi

# ── Make scripts executable ───────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chmod +x "$SCRIPT_DIR/START.sh" 2>/dev/null
ok "Script permissions set"

# ── Context file check ────────────────────────────────────────────────────────
echo ""
CONTEXT="$SCRIPT_DIR/context/PRODUCT_CONTEXT.md"

if [[ ! -f "$CONTEXT" ]]; then
    err "context/PRODUCT_CONTEXT.md not found."
    info "Make sure you're running this from inside the se-copilot folder."
else
    if grep -q "\[YOUR COMPANY NAME\]" "$CONTEXT"; then
        warn "Context file exists but has NOT been filled in yet."
        echo ""
        info "Next step: open context/PRODUCT_CONTEXT.md in a text editor"
        info "and replace every [BRACKET] with your real product information."
        echo ""
        info "Reference files:"
        info "  examples/EXAMPLE_FILLED_CONTEXT.md  -- completed example"
        info "  context/CONTEXT_GUIDE.md            -- field-by-field guide"
        echo ""
        read -p "  Open context file now? (y/n): " OPEN_CTX
        if [[ "$OPEN_CTX" == "y" ]]; then
            if command -v code &>/dev/null; then
                code "$CONTEXT"
                ok "Opened in VS Code"
            elif [[ "$OS" == "mac" ]]; then
                open -e "$CONTEXT"
                ok "Opened in TextEdit"
            else
                xdg-open "$CONTEXT" 2>/dev/null || nano "$CONTEXT"
            fi
        fi
    else
        ok "Context file looks filled in — ready to use!"
    fi
fi

echo ""
echo "  ─────────────────────────────────────────────"
echo -e "  ${GREEN}${BOLD}Setup complete!${RESET}"
echo ""
info "When ready, run START.sh and choose option 2 to build your first prompt."
echo ""
read -p "  Press Enter to return to menu..." _
