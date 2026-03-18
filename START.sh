#!/bin/bash
# =============================================================================
# SE Copilot — Universal Launcher (Mac / Linux)
# Detects your OS and walks you through setup or running the tool.
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"; OS_LABEL="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"; OS_LABEL="Linux"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows_bash"; OS_LABEL="Windows (Git Bash / WSL)"
fi

# ── Read saved document mode ──────────────────────────────────────────────────
# Returns "1", "2", "3", or "" if not set yet
saved_mode() {
    local mode_file="$SCRIPT_DIR/scripts/.last_mode.json"
    if [[ -f "$mode_file" ]]; then
        python3 -c "
import json, sys
try:
    print(json.load(open('$mode_file')).get('mode',''))
except: print('')
" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# ── Intake status ─────────────────────────────────────────────────────────────
intake_status() {
    local status=""

    # Product docs
    local pdocs
    pdocs=$(find "$SCRIPT_DIR/intake/product" -maxdepth 1 -type f \
            ! -name "README.md" ! -name ".*" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$pdocs" -gt 0 ]]; then
        status+="${GREEN}Product docs: ${pdocs} file(s)${RESET}  "
    else
        status+="${DIM}Product docs: empty${RESET}  "
    fi

    # Client docs
    local cdocs
    cdocs=$(find "$SCRIPT_DIR/intake/client" -maxdepth 1 -type f \
            ! -name "README.md" ! -name ".*" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$cdocs" -gt 0 ]]; then
        status+="${GREEN}Client docs: ${cdocs} file(s)${RESET}  "
    else
        status+="${DIM}Client docs: empty${RESET}  "
    fi

    # URLs
    local purls
    purls=$(grep -c "^[^#]" "$SCRIPT_DIR/intake/urls/product_urls.txt" 2>/dev/null || echo 0)
    local curls
    curls=$(grep -c "^[^#]" "$SCRIPT_DIR/intake/urls/client_urls.txt" 2>/dev/null || echo 0)
    if [[ "$purls" -gt 0 || "$curls" -gt 0 ]]; then
        status+="${GREEN}URLs: ${purls} product / ${curls} client${RESET}"
    else
        status+="${DIM}URLs: none added${RESET}"
    fi

    echo -e "$status"
}

# ── Context status ────────────────────────────────────────────────────────────
context_status() {
    if grep -q "\[YOUR COMPANY NAME\]" "$SCRIPT_DIR/context/PRODUCT_CONTEXT.md" 2>/dev/null; then
        echo -e "${YELLOW}Context file: NOT filled in${RESET}"
    else
        echo -e "${GREEN}Context file: Ready${RESET}"
    fi
}

# ── Main loop ─────────────────────────────────────────────────────────────────
while true; do
    clear

    echo ""
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║          SE Copilot — Welcome                ║"
    echo "  ║    AI-powered Sales Engineering Assistant    ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "  ${GREEN}OS:${RESET} $OS_LABEL"
    echo -e "  $(context_status)"

    # Only show intake status when in Local or Both mode (modes 2/3)
    CURRENT_MODE=$(saved_mode)
    if [[ "$CURRENT_MODE" == "2" || "$CURRENT_MODE" == "3" ]]; then
        echo -e "  $(intake_status)"
    elif [[ -z "$CURRENT_MODE" ]]; then
        echo -e "  ${DIM}Mode: not set yet — will be chosen when you build a prompt${RESET}"
    else
        echo -e "  ${DIM}Mode: Claude UI (files uploaded directly in Claude)${RESET}"
    fi
    echo ""

    echo -e "  ${BOLD}What would you like to do?${RESET}"
    echo ""
    echo -e "    ${CYAN}1${RESET}.  First time setup        (check Python, verify everything)"
    echo -e "    ${CYAN}2${RESET}.  Build a prompt           (use cases, integration plan, demo)"
    echo -e "    ${CYAN}3${RESET}.  Manage intake files      (add docs & URLs for product/client)"
    echo -e "    ${CYAN}4${RESET}.  Check context file       (see what's filled in)"
    echo -e "    ${CYAN}5${RESET}.  Claude.ai Project setup  (step-by-step guide)"
    echo -e "    ${CYAN}q${RESET}.  Quit"
    echo ""
    read -rp "  Enter a choice: " CHOICE

    case "$CHOICE" in
        1)
            bash "$SCRIPT_DIR/scripts/setup_core.sh" "$OS"
            ;;
        2)
            python3 "$SCRIPT_DIR/scripts/build_prompt.py"
            ;;
        3)
            clear
            echo ""
            echo -e "  ${CYAN}${BOLD}Manage Intake Files${RESET}"
            echo "  ─────────────────────────────────────────────"
            echo ""
            echo -e "  ${BOLD}Product documents${RESET} → drop files into:"
            echo -e "  ${DIM}  $SCRIPT_DIR/intake/product/${RESET}"
            echo ""
            echo -e "  ${BOLD}Client documents${RESET} → drop files into:"
            echo -e "  ${DIM}  $SCRIPT_DIR/intake/client/${RESET}"
            echo ""
            echo -e "  ${BOLD}Product URLs${RESET} → edit:"
            echo -e "  ${DIM}  $SCRIPT_DIR/intake/urls/product_urls.txt${RESET}"
            echo ""
            echo -e "  ${BOLD}Client URLs${RESET} → edit:"
            echo -e "  ${DIM}  $SCRIPT_DIR/intake/urls/client_urls.txt${RESET}"
            echo ""
            echo "  Supported file types: .pdf  .docx  .txt  .md  .csv  .json"
            echo ""
            echo -e "  ${YELLOW}REMINDER:${RESET} Clear intake/client/ between prospects."
            echo ""

            # Try to open folders
            if [[ "$OS" == "mac" ]]; then
                read -rp "  Open intake folders in Finder? (y/n): " OPF
                if [[ "$OPF" == "y" ]]; then
                    open "$SCRIPT_DIR/intake/product/"
                    open "$SCRIPT_DIR/intake/client/"
                    open "$SCRIPT_DIR/intake/urls/"
                fi
            elif [[ "$OS" == "linux" ]]; then
                read -rp "  Open intake folders in file manager? (y/n): " OPF
                if [[ "$OPF" == "y" ]]; then
                    xdg-open "$SCRIPT_DIR/intake/" 2>/dev/null || true
                fi
            fi

            read -rp "  Press Enter to return to menu..." _
            ;;
        4)
            bash "$SCRIPT_DIR/scripts/check_context.sh"
            ;;
        5)
            bash "$SCRIPT_DIR/scripts/claude_project_guide.sh"
            ;;
        q|Q)
            echo ""
            echo "  Goodbye!"
            echo ""
            exit 0
            ;;
        *)
            echo ""
            echo -e "  ${RED}Invalid choice.${RESET} Please enter 1–5 or q."
            sleep 1
            ;;
    esac
done
