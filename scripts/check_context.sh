#!/bin/bash
# =============================================================================
# SE Copilot — Context File Status Checker
# =============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTEXT="$SCRIPT_DIR/context/PRODUCT_CONTEXT.md"

echo ""
echo -e "${CYAN}${BOLD}  Context File Status${RESET}"
echo "  ─────────────────────────────────────────────"
echo ""

if [[ ! -f "$CONTEXT" ]]; then
    echo -e "  ${RED}[ERROR]${RESET} context/PRODUCT_CONTEXT.md not found."
    echo "  Make sure you're running from the se-copilot folder."
    echo ""
    read -p "  Press Enter to return to menu..." _
    exit 1
fi

# File stats
LINES=$(wc -l < "$CONTEXT")
SIZE=$(wc -c < "$CONTEXT")
SIZE_KB=$(echo "scale=1; $SIZE / 1024" | bc 2>/dev/null || echo "?")

echo "  File:  context/PRODUCT_CONTEXT.md"
echo "  Lines: $LINES"
echo "  Size:  ${SIZE_KB} KB"
echo ""

# Count placeholders
PLACEHOLDER_COUNT=$(grep -c "\[YOUR\|PRODUCT\|\[DATE\|\[COMPANY\|\[Module\|\[Tier\|\[Competitor\|\[Vertical\|\[SE " "$CONTEXT" 2>/dev/null || echo "0")

if [[ "$PLACEHOLDER_COUNT" -gt 0 ]]; then
    echo -e "  ${YELLOW}[WARNING]${RESET} ~$PLACEHOLDER_COUNT lines with unfilled placeholders found"
    echo ""
    echo "  To find them: search for [ in the file"
    echo "  Replace each [BRACKET] with your real information"
else
    echo -e "  ${GREEN}[OK]${RESET} No unfilled placeholders detected"
    echo ""
    echo "  Remember to update this file when:"
    echo "    - Product ships new features (update Sections 2 & 4)"
    echo "    - You win a deal with a new use case (update Section 4 & 9)"
    echo "    - Pricing changes (update Section 5)"
    echo "    - New competitors emerge (update Section 6)"
fi

# Section checks
echo ""
echo "  Section presence:"
SECTIONS=(
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
)
for section in "${SECTIONS[@]}"; do
    if grep -qi "$section" "$CONTEXT"; then
        echo -e "    ${GREEN}[FOUND]${RESET}   $section"
    else
        echo -e "    ${RED}[MISSING]${RESET} $section"
    fi
done

echo ""
read -p "  Press Enter to return to menu..." _
