#!/bin/bash
# =============================================================================
# SE Copilot — Claude.ai Project Setup Guide
# =============================================================================

CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${CYAN}${BOLD}  How to Set Up Your Claude.ai Project${RESET}"
echo "  ─────────────────────────────────────────────"
echo ""
echo "  Do this once. After setup, Claude auto-loads your context"
echo "  at the start of every conversation."
echo ""
echo -e "  ${YELLOW}STEP 1 — Open Claude.ai${RESET}"
echo "  Go to: https://claude.ai  and sign in"
echo ""
echo -e "  ${YELLOW}STEP 2 — Create a new Project${RESET}"
echo "  In the left sidebar, click 'Projects'"
echo "  Click '+ New Project'"
echo "  Name it:  SE Copilot -- [Your Company Name]"
echo ""
echo -e "  ${YELLOW}STEP 3 — Upload your context file${RESET}"
echo "  Click 'Add content'"
echo "  Upload the file:  context/PRODUCT_CONTEXT.md"
echo ""
echo -e "  ${YELLOW}STEP 4 — Paste Project Instructions${RESET}"
echo "  Click 'Edit project instructions' and paste:"
echo ""
echo "  ─────────────────────────────────────────────"
cat << 'INSTRUCTIONS'
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
INSTRUCTIONS
echo "  ─────────────────────────────────────────────"
echo ""
echo -e "  ${YELLOW}STEP 5 — Replace [YOUR COMPANY NAME] then click Save${RESET}"
echo ""
echo -e "  ${GREEN}Done!${RESET} Every new conversation in this Project will"
echo "  automatically load your product context. No pasting required."
echo ""

read -p "  Open claude.ai now? (y/n): " OPEN
if [[ "$OPEN" == "y" ]]; then
    open "https://claude.ai" 2>/dev/null || \
    xdg-open "https://claude.ai" 2>/dev/null || \
    echo "  Visit https://claude.ai in your browser"
fi

echo ""
read -p "  Press Enter to return to menu..." _
