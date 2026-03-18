#!/usr/bin/env python3
"""
SE Copilot — Prompt Builder
Supports two document ingestion modes:

  MODE 1 — Claude UI
    Skips all local ingestion. Appends a structured attachment checklist
    to the prompt so the user knows exactly what to upload/paste in Claude.
    Recommended for most users.

  MODE 2 — Local (Privacy / Compliance)
    Extracts documents on this machine via ingest.py and embeds the text
    directly in the prompt. Nothing is uploaded — content never leaves the
    local environment.

  MODE 3 — Both
    Runs local extraction first, then appends the attachment checklist so
    the user can add supplementary public URLs or extra files in Claude UI.

Client profiles are saved locally in clients/<slug>.json.
They are gitignored and never leave this machine.
Profiles include a timestamp — the tool warns when a profile is older
than 7 days, but loading it is never blocked.
"""

import os
import sys
import json
import subprocess
import datetime
import re
from pathlib import Path
from typing import Optional

# ── Paths ─────────────────────────────────────────────────────────────────────
BASE_DIR      = Path(__file__).resolve().parent.parent
CONTEXT_PATH  = BASE_DIR / 'context' / 'PRODUCT_CONTEXT.md'
PROMPTS_DIR   = BASE_DIR / 'prompts'
CLIENTS_DIR   = BASE_DIR / 'clients'
LAST_PROSPECT = BASE_DIR / 'scripts' / '.last_prospect.json'
LAST_MODE     = BASE_DIR / 'scripts' / '.last_mode.json'

# How many days before a profile triggers the staleness warning
STALE_DAYS = 7

# ── Prompt menu ───────────────────────────────────────────────────────────────
PROMPT_FILES = {
    "1": ("01_pre_discovery.md",     "Pre-discovery research brief"),
    "2": ("02_post_discovery.md",    "Post-discovery integration plan"),
    "3": ("03_demo_script.md",       "Demo script generator"),
    "4": ("04_use_case_analysis.md", "Use case deep dive"),
    "5": ("05_followup_email.md",    "Follow-up email"),
}

MODES = {
    "1": "Claude UI   — upload files & paste URLs directly in Claude (recommended)",
    "2": "Local       — extract documents privately on this machine (compliance/security)",
    "3": "Both        — extract locally AND add more via Claude UI",
}

# ── Colours ───────────────────────────────────────────────────────────────────
if sys.platform == 'win32':
    C_RESET = C_CYAN = C_GREEN = C_YELLOW = C_RED = C_BOLD = C_DIM = ''
else:
    C_RESET  = '\033[0m'
    C_CYAN   = '\033[0;36m'
    C_GREEN  = '\033[0;32m'
    C_YELLOW = '\033[1;33m'
    C_RED    = '\033[0;31m'
    C_BOLD   = '\033[1m'
    C_DIM    = '\033[2m'

def ok(msg):   print(f"  {C_GREEN}[OK]{C_RESET} {msg}")
def warn(msg): print(f"  {C_YELLOW}[WARNING]{C_RESET} {msg}")
def err(msg):  print(f"  {C_RED}[ERROR]{C_RESET} {msg}")
def info(msg): print(f"  {msg}")
def div():     print(f"  {C_DIM}{'─'*52}{C_RESET}")
def header(t): print(f"\n  {C_CYAN}{C_BOLD}{t}{C_RESET}\n")

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

# ── File helpers ──────────────────────────────────────────────────────────────
def read_file(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8')
    except FileNotFoundError:
        err(f"File not found: {path}")
        err("Make sure you're running from the se-copilot folder.")
        sys.exit(1)

def copy_to_clipboard(text: str) -> bool:
    try:
        if sys.platform == 'darwin':
            subprocess.run(['pbcopy'], input=text.encode('utf-8'), check=True)
            return True
        elif sys.platform == 'win32':
            subprocess.run(['clip'], input=text.encode('utf-16'), check=True)
            return True
        else:
            for cmd in [['xclip', '-selection', 'clipboard'],
                        ['xsel', '--clipboard', '--input']]:
                try:
                    subprocess.run(cmd, input=text.encode('utf-8'), check=True)
                    return True
                except (FileNotFoundError, subprocess.CalledProcessError):
                    continue
            return False
    except Exception:
        return False

# ── Context check ─────────────────────────────────────────────────────────────
def check_context_filled() -> bool:
    content = read_file(CONTEXT_PATH)
    if '[YOUR COMPANY NAME]' in content:
        print()
        warn("Your context file still has unfilled placeholders.")
        info("Open context/PRODUCT_CONTEXT.md and replace the [BRACKETS].")
        info("See examples/EXAMPLE_FILLED_CONTEXT.md for guidance.")
        print()
        ans = input("  Continue anyway? (y/n): ").strip().lower()
        return ans == 'y'
    return True

# ── Mode memory ───────────────────────────────────────────────────────────────
def load_last_mode() -> Optional[str]:
    try:
        if LAST_MODE.exists():
            data = json.loads(LAST_MODE.read_text(encoding='utf-8'))
            return data.get('mode')
    except Exception:
        pass
    return None

def save_mode(mode: str):
    try:
        LAST_MODE.write_text(
            json.dumps({'mode': mode}, indent=2),
            encoding='utf-8'
        )
    except Exception:
        pass

# ── Mode selection ────────────────────────────────────────────────────────────
def select_mode() -> str:
    last = load_last_mode()

    if last and last in MODES:
        print()
        div()
        header("Document Mode")
        info(f"Last mode used:  {C_CYAN}{MODES[last]}{C_RESET}")
        print()
        ans = input("  Keep this mode? (y/n): ").strip().lower()
        if ans == 'y':
            return last

    print()
    div()
    header("Document Mode — How should documents and URLs be handled?")

    info(f"  {C_CYAN}1{C_RESET}.  {MODES['1']}")
    print()
    info(f"  {C_CYAN}2{C_RESET}.  {MODES['2']}")
    print()
    info(f"  {C_CYAN}3{C_RESET}.  {MODES['3']}")
    print()

    print(f"  {C_DIM}{'─'*52}{C_RESET}")
    print(f"  {C_YELLOW}Security & Compliance note:{C_RESET}")
    info(f"  {C_DIM}If your organisation restricts sending internal documents")
    info(f"  to cloud services, use Mode 2 (Local). All extraction runs")
    info(f"  on your machine — no file content is uploaded anywhere.{C_RESET}")
    print(f"  {C_DIM}{'─'*52}{C_RESET}")
    print()

    while True:
        choice = input("  Select mode (1, 2, or 3): ").strip()
        if choice in MODES:
            save_mode(choice)
            ok(f"Mode set: {MODES[choice].split('—')[0].strip()}")
            return choice
        err("Please enter 1, 2, or 3.")

# ── Client profile helpers ────────────────────────────────────────────────────
def _slug(company_name: str) -> str:
    """Convert a company name to a safe filename slug."""
    slug = company_name.lower().strip()
    slug = re.sub(r'[^\w\s-]', '', slug)
    slug = re.sub(r'[\s_-]+', '_', slug)
    slug = slug.strip('_')
    return slug or 'unknown'

def _profile_path(company_name: str) -> Path:
    CLIENTS_DIR.mkdir(exist_ok=True)
    return CLIENTS_DIR / f"{_slug(company_name)}.json"

def _age_label(saved_at: str) -> str:
    """Return a human-readable age string from an ISO timestamp."""
    try:
        then = datetime.datetime.fromisoformat(saved_at)
        delta = datetime.datetime.now() - then
        days = delta.days
        if days == 0:
            hours = delta.seconds // 3600
            return f"{hours}h ago" if hours > 0 else "just now"
        elif days == 1:
            return "1 day ago"
        else:
            return f"{days} days ago"
    except Exception:
        return "unknown age"

def _is_stale(saved_at: str) -> bool:
    try:
        then = datetime.datetime.fromisoformat(saved_at)
        return (datetime.datetime.now() - then).days >= STALE_DAYS
    except Exception:
        return False

def list_client_profiles() -> list:
    """Return all saved client profiles sorted by most recently updated."""
    CLIENTS_DIR.mkdir(exist_ok=True)
    profiles = []
    for f in sorted(CLIENTS_DIR.glob('*.json')):
        try:
            data = json.loads(f.read_text(encoding='utf-8'))
            profiles.append({
                'path':       f,
                'company':    data.get('company_name', f.stem),
                'industry':   data.get('industry', ''),
                'saved_at':   data.get('saved_at', ''),
                'stage':      data.get('deal_stage', ''),
            })
        except Exception:
            pass
    # Sort by saved_at descending (most recent first)
    profiles.sort(key=lambda p: p['saved_at'], reverse=True)
    return profiles

def load_client_profile(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding='utf-8'))
    except Exception:
        return {}

def save_client_profile(fields: dict):
    """Save or update a client profile. Always updates saved_at timestamp."""
    if not fields.get('company_name'):
        return
    fields['saved_at'] = datetime.datetime.now().isoformat()
    path = _profile_path(fields['company_name'])
    CLIENTS_DIR.mkdir(exist_ok=True)
    path.write_text(
        json.dumps(fields, indent=2, ensure_ascii=False),
        encoding='utf-8'
    )

def delete_client_profile(path: Path) -> bool:
    try:
        path.unlink()
        return True
    except Exception:
        return False

# ── Prospect memory (session shortcut) ───────────────────────────────────────
def load_last_prospect() -> dict:
    try:
        if LAST_PROSPECT.exists():
            return json.loads(LAST_PROSPECT.read_text(encoding='utf-8'))
    except Exception:
        pass
    return {}

def save_last_prospect(fields: dict):
    try:
        LAST_PROSPECT.write_text(
            json.dumps(fields, indent=2, ensure_ascii=False),
            encoding='utf-8'
        )
    except Exception:
        pass

# ── Client selector UI ────────────────────────────────────────────────────────
def show_client_manager() -> Optional[dict]:
    """
    Full client management screen.
    Returns a loaded profile dict if the user selects one,
    or None if they choose to enter a new prospect.
    """
    while True:
        clear()
        print(f"\n  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}     SE Copilot — Client Profiles{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}\n")

        profiles = list_client_profiles()

        if not profiles:
            info(f"{C_DIM}No saved client profiles yet.{C_RESET}")
            info("Profiles are saved automatically after you enter prospect details.")
            print()
            info(f"  {C_CYAN}n{C_RESET}. Enter a new prospect")
            info(f"  {C_CYAN}q{C_RESET}. Back to main menu")
            print()
            choice = input("  Choose: ").strip().lower()
            if choice == 'n':
                return None
            return 'back'

        # Display profiles
        print(f"  {C_BOLD}Saved client profiles:{C_RESET}\n")
        for i, p in enumerate(profiles, 1):
            age    = _age_label(p['saved_at'])
            stale  = _is_stale(p['saved_at'])
            stage  = f"  [{p['stage']}]" if p['stage'] else ""
            ind    = f"  {p['industry']}" if p['industry'] else ""

            age_str = (f"{C_YELLOW}{age}{C_RESET}"
                       if stale else f"{C_DIM}{age}{C_RESET}")

            print(f"    {C_CYAN}{i}{C_RESET}.  {C_BOLD}{p['company']}{C_RESET}"
                  f"{ind}{stage}  {age_str}")

        print()
        div()
        info(f"  {C_CYAN}n{C_RESET}. New prospect (enter details fresh)")
        info(f"  {C_CYAN}d{C_RESET}. Delete a profile")
        info(f"  {C_CYAN}q{C_RESET}. Back to main menu")
        print()

        choice = input("  Select a profile number, or n / d / q: ").strip().lower()

        if choice == 'q':
            return 'back'

        if choice == 'n':
            return None

        if choice == 'd':
            _delete_profile_flow(profiles)
            continue

        # Numeric selection
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(profiles):
                profile = load_client_profile(profiles[idx]['path'])
                saved_at = profile.get('saved_at', '')

                print()
                div()

                # Staleness warning — informational only, never blocks
                if _is_stale(saved_at):
                    age = _age_label(saved_at)
                    print()
                    warn(f"This profile was last updated {age}.")
                    info("It may not reflect the prospect's current state,")
                    info("stack changes, or recent conversations.")
                    info(f"{C_DIM}You can update any fields when prompted below.{C_RESET}")
                    print()
                else:
                    age = _age_label(saved_at)
                    ok(f"Profile loaded — last updated {age}")
                    print()

                return profile
            else:
                err("Invalid number. Please try again.")
                input("\n  Press Enter to continue...")
        except ValueError:
            err("Please enter a number, or n / d / q.")
            input("\n  Press Enter to continue...")

def _delete_profile_flow(profiles: list):
    """Sub-flow for deleting one or more profiles."""
    print()
    div()
    header("Delete a Client Profile")

    for i, p in enumerate(profiles, 1):
        age = _age_label(p['saved_at'])
        print(f"    {C_CYAN}{i}{C_RESET}.  {p['company']}  {C_DIM}({age}){C_RESET}")

    print()
    info(f"  {C_CYAN}q{C_RESET}. Cancel")
    print()
    choice = input("  Enter profile number to delete: ").strip().lower()

    if choice == 'q':
        return

    try:
        idx = int(choice) - 1
        if 0 <= idx < len(profiles):
            company = profiles[idx]['company']
            confirm = input(
                f"\n  Delete \"{company}\"? This cannot be undone. (y/n): "
            ).strip().lower()
            if confirm == 'y':
                if delete_client_profile(profiles[idx]['path']):
                    ok(f"Deleted: {company}")
                else:
                    err("Could not delete profile.")
            else:
                info("Cancelled.")
            input("\n  Press Enter to continue...")
        else:
            err("Invalid number.")
            input("\n  Press Enter to continue...")
    except ValueError:
        err("Please enter a number.")
        input("\n  Press Enter to continue...")

# ── Multi-line input ──────────────────────────────────────────────────────────
def multiline_input(prompt: str) -> str:
    print(f"\n  {C_CYAN}{prompt}{C_RESET}")
    print(f"  {C_DIM}Paste or type your text. Type END on a new line when done.{C_RESET}")
    print(f"  {C_DIM}(Or press Enter twice to leave blank){C_RESET}")
    lines = []
    blank_count = 0
    while True:
        try:
            line = input()
        except EOFError:
            break
        if line.strip().upper() == 'END':
            break
        if line.strip() == '':
            blank_count += 1
            if blank_count >= 2:
                break
            lines.append('')
        else:
            blank_count = 0
            lines.append(line)
    return '\n'.join(lines).strip()

# ── Prospect info collection ──────────────────────────────────────────────────
def get_prospect_info(prompt_type: str, prefill: dict) -> dict:
    """
    Collect prospect details.
    prefill: existing profile or last_prospect data to pre-populate from.
    All fields shown with current value — user presses Enter to keep or types to update.
    """
    print()
    div()
    print(f"\n  {C_BOLD}Prospect details{C_RESET} "
          f"{C_DIM}(press Enter to keep current value){C_RESET}\n")

    def field(label: str, key: str, hint: str = '') -> str:
        current = prefill.get(key, '').strip()
        display = f"{C_DIM}[{current}]{C_RESET} " if current else ''
        hint_str = f"{C_DIM}e.g. {hint}{C_RESET} " if hint and not current else ''
        val = input(f"  {label}: {display}{hint_str}").strip()
        return val if val else current

    fields: dict = {}
    fields['company_name'] = field("Company name",      'company_name')
    fields['industry']     = field("Industry",          'industry',    'FinTech, Healthcare, SaaS')
    fields['company_size'] = field("Size / stage",      'company_size','200 engineers, Series B')
    fields['tech_stack']   = field("Tech stack",        'tech_stack',  'AWS, Python, Kafka')
    fields['pain_points']  = field("Pain points",       'pain_points')
    fields['deal_stage']   = field("Deal stage",        'deal_stage',  'Pre-discovery, POC, Negotiation')
    fields['source']       = field("Info source",       'source',      'LinkedIn, discovery call, website')

    if prompt_type in ("2", "3", "4"):
        # For discovery notes, always offer to append rather than replace
        existing_notes = prefill.get('discovery_notes', '').strip()
        if existing_notes:
            print(f"\n  {C_CYAN}Existing discovery notes:{C_RESET}")
            preview = existing_notes[:200] + ('...' if len(existing_notes) > 200 else '')
            info(f"  {C_DIM}{preview}{C_RESET}")
            print()
            action = input(
                "  Discovery notes: (k)eep / (r)eplace / (a)ppend: "
            ).strip().lower()
            if action == 'r':
                fields['discovery_notes'] = multiline_input("New discovery notes:")
            elif action == 'a':
                new_notes = multiline_input("Additional notes (will be appended):")
                fields['discovery_notes'] = (
                    existing_notes + '\n\n---\n\n' + new_notes
                    if new_notes else existing_notes
                )
            else:
                fields['discovery_notes'] = existing_notes
        else:
            fields['discovery_notes'] = multiline_input("Discovery call notes:")

    if prompt_type == "3":
        fields['attendees'] = field("Demo attendees",  'attendees', 'CTO, Staff Engineer')
        fields['duration']  = field("Demo duration",   'duration',  '30 min')

    if prompt_type == "5":
        existing_summary = prefill.get('call_summary', '').strip()
        if existing_summary:
            action = input(
                "\n  Call summary: (k)eep / (r)eplace / (a)ppend: "
            ).strip().lower()
            if action == 'r':
                fields['call_summary'] = multiline_input("New call summary:")
            elif action == 'a':
                new_summary = multiline_input("Additional summary (will be appended):")
                fields['call_summary'] = (
                    existing_summary + '\n\n---\n\n' + new_summary
                    if new_summary else existing_summary
                )
            else:
                fields['call_summary'] = existing_summary
        else:
            fields['call_summary'] = multiline_input("What happened in the last call?")
        fields['next_step'] = field("Proposed next step", 'next_step')

    # Save to both persistent profile and session shortcut
    save_client_profile(fields)
    save_last_prospect(fields)
    return fields

# ── Local ingestion ───────────────────────────────────────────────────────────
def run_local_ingestion() -> dict:
    empty = {
        'product_docs': '', 'product_urls': '',
        'client_docs':  '', 'client_urls':  '',
        'has_product': False, 'has_client': False,
    }
    try:
        sys.path.insert(0, str(BASE_DIR / 'scripts'))
        import ingest
        print()
        info("Scanning local documents and URLs...")
        result = ingest.run_ingestion(str(BASE_DIR), 'both')

        counts = []
        if result.get('product_docs') or result.get('product_urls'):
            n = len(result['product_docs']) + len(result['product_urls'])
            counts.append(f"product: {n:,} chars")
        if result.get('client_docs') or result.get('client_urls'):
            n = len(result['client_docs']) + len(result['client_urls'])
            counts.append(f"client: {n:,} chars")

        if counts:
            ok(f"Local ingestion complete — {', '.join(counts)}")
        else:
            warn("No documents or URLs found in intake/ folders.")
            info("Add files to intake/product/ and intake/client/,")
            info("or add URLs to intake/urls/ txt files.")
        return result
    except Exception as e:
        warn(f"Local ingestion skipped: {e}")
        return empty

def intake_status() -> str:
    parts = []
    for folder, label in [
        (BASE_DIR / 'intake' / 'product', 'Product docs'),
        (BASE_DIR / 'intake' / 'client',  'Client docs'),
    ]:
        if folder.exists():
            files = [f for f in folder.iterdir()
                     if f.is_file()
                     and not f.name.startswith('.')
                     and f.name != 'README.md']
            count = len(files)
            parts.append(
                f"{label}: {C_GREEN}{count} file(s){C_RESET}"
                if count else f"{label}: {C_DIM}empty{C_RESET}"
            )
    for url_file, label in [
        (BASE_DIR / 'intake' / 'urls' / 'product_urls.txt', 'Product URLs'),
        (BASE_DIR / 'intake' / 'urls' / 'client_urls.txt',  'Client URLs'),
    ]:
        if url_file.exists():
            urls = [
                l.strip() for l in
                url_file.read_text(encoding='utf-8').splitlines()
                if l.strip() and not l.strip().startswith('#')
            ]
            parts.append(
                f"{label}: {C_GREEN}{len(urls)} URL(s){C_RESET}"
                if urls else f"{label}: {C_DIM}none{C_RESET}"
            )
    return '   '.join(parts) if parts else "No intake content."

# ── Attachment block ──────────────────────────────────────────────────────────
def build_attachment_block(mode: str, has_local_content: bool) -> str:
    if mode == "2":
        return ""

    intro = ""
    if mode == "3" and has_local_content:
        intro = (
            "Local documents have been extracted and embedded above. "
            "You can optionally supplement with additional files or URLs below.\n\n"
        )

    return f"""
---

## ATTACH IN THIS CONVERSATION

{intro}After pasting this prompt into Claude, attach or paste any of the
following that you have available. Claude will read them as part of this
conversation.

### Product context (supplements the Project context)
- **Sales deck or one-pager** → upload as PDF or DOCX
- **Technical documentation or integration guide** → upload as PDF, DOCX, or MD
- **Your product website or docs site** → paste the URL inline
  e.g. `https://docs.yourcompany.com`
- **Your GitHub repo** → paste the URL (public repos only)
  e.g. `https://github.com/your-org/your-repo`
- **Release notes or changelog** → upload as TXT or MD

### Client / prospect context
- **Discovery call notes** → upload as TXT/DOCX, or paste the text directly
- **RFP or technical questionnaire** → upload as PDF or DOCX
- **Job postings** → paste the URL or copy-paste the job description as text
  (job postings reveal tech stack better than almost any other source)
- **Their website or engineering blog** → paste the URL inline
- **Their LinkedIn company page** → paste the URL inline
- **Their GitHub org** → paste the URL (public orgs only)
- **Any documents they've shared** → upload as PDF, DOCX, or TXT

### Tips
- You can attach multiple files at once — drag and drop them all in
- Pasted URLs are fetched automatically by Claude
- Plain text notes pasted inline work just as well as uploaded files
- The more context you provide, the more specific Claude's output will be
"""

# ── Build prospect block ──────────────────────────────────────────────────────
def build_prospect_block(fields: dict, ingested: dict) -> str:
    lines = ["\n---\n", "## PROSPECT INFORMATION\n"]
    labels = {
        'company_name':    'Company',
        'industry':        'Industry',
        'company_size':    'Size / Stage',
        'tech_stack':      'Tech Stack',
        'pain_points':     'Known Pains / Trigger',
        'deal_stage':      'Deal Stage',
        'source':          'Source of Info',
        'discovery_notes': 'Discovery Notes',
        'attendees':       'Demo Attendees',
        'duration':        'Demo Duration',
        'call_summary':    'Call Summary',
        'next_step':       'Proposed Next Step',
    }
    for key, label in labels.items():
        val = fields.get(key, '').strip()
        if val:
            lines.append(f"**{label}:** {val}\n")

    client_extra = (
        ingested.get('client_docs', '') + '\n' +
        ingested.get('client_urls', '')
    ).strip()
    if client_extra:
        lines.append("\n### Additional Client Research (locally extracted)\n")
        lines.append(client_extra)

    return '\n'.join(lines)

# ── Assemble final prompt ─────────────────────────────────────────────────────
def build_final_prompt(template: str, fields: dict,
                       ingested: dict, mode: str) -> str:
    context = read_file(CONTEXT_PATH)

    product_extra = (
        ingested.get('product_docs', '') + '\n' +
        ingested.get('product_urls', '')
    ).strip()
    if product_extra:
        context += (
            "\n\n---\n\n"
            "## ADDITIONAL PRODUCT CONTEXT (locally extracted)\n\n"
            + product_extra
        )

    prospect_block = build_prospect_block(fields, ingested)

    has_local = bool(product_extra or
                     ingested.get('client_docs', '').strip() or
                     ingested.get('client_urls', '').strip())
    attachment_block = build_attachment_block(mode, has_local)

    return (
        "# SE COPILOT — PRODUCT CONTEXT\n\n"
        + context
        + "\n\n"
        + prospect_block
        + "\n\n---\n\n"
        + "# TASK\n\n"
        + template
        + attachment_block
    )

# ── Deliver prompt ────────────────────────────────────────────────────────────
def deliver_prompt(final_prompt: str, mode: str):
    print()
    div()
    copied = copy_to_clipboard(final_prompt)
    print()

    mode_label = MODES.get(mode, '').split('—')[0].strip()

    if copied:
        ok(f"Prompt copied to clipboard!  ({len(final_prompt):,} chars)  [{mode_label}]")
        print()
        info(f"  {C_CYAN}→ Go to claude.ai{C_RESET}")
        info(f"  {C_CYAN}→ Open your SE Copilot Project{C_RESET}")
        info(f"  {C_CYAN}→ Start a new conversation{C_RESET}")
        info(f"  {C_CYAN}→ Paste  (Cmd+V on Mac  /  Ctrl+V on Windows){C_RESET}")
        if mode in ("1", "3"):
            print()
            info(f"  {C_YELLOW}Then attach your files / paste URLs in Claude{C_RESET}")
            info(f"  {C_DIM}(see the ATTACH IN THIS CONVERSATION section at the")
            info(f"  bottom of the pasted prompt for the full checklist){C_RESET}")
    else:
        out_path = BASE_DIR / 'last_prompt.txt'
        out_path.write_text(final_prompt, encoding='utf-8')
        ok(f"Prompt saved → last_prompt.txt  ({len(final_prompt):,} chars)  [{mode_label}]")
        info("Open that file, select all, copy, then paste into Claude.")
        if mode in ("1", "3"):
            info("Then attach your files and URLs as directed in the prompt.")
    print()
    div()

# ── Main loop ─────────────────────────────────────────────────────────────────
def main():
    # Ensure clients dir exists at startup
    CLIENTS_DIR.mkdir(exist_ok=True)

    while True:
        clear()
        print(f"\n  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}     SE Copilot — Prompt Builder{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}\n")

        # Status bar
        last_mode = load_last_mode()
        profiles  = list_client_profiles()

        if last_mode:
            mode_label = MODES.get(last_mode, '').split('—')[0].strip()
            info(f"{C_DIM}Mode: {mode_label}{C_RESET}")
        if last_mode in ("2", "3"):
            info(f"{C_DIM}Intake: {intake_status()}{C_RESET}")

        # Show saved profiles in status bar
        if profiles:
            profile_names = ', '.join(
                f"{C_YELLOW}{p['company']}{C_RESET}"
                if _is_stale(p['saved_at'])
                else p['company']
                for p in profiles[:5]
            )
            suffix = f" +{len(profiles)-5} more" if len(profiles) > 5 else ""
            info(f"{C_DIM}Saved clients: {C_RESET}{profile_names}{C_DIM}{suffix}{C_RESET}")
        else:
            info(f"{C_DIM}Saved clients: none yet{C_RESET}")
        print()

        if not check_context_filled():
            break

        # Main menu
        print(f"  {C_BOLD}What do you need to generate?{C_RESET}\n")
        for key, (_, label) in PROMPT_FILES.items():
            print(f"    {C_CYAN}{key}{C_RESET}. {label}")
        print()
        print(f"    {C_CYAN}c{C_RESET}. Switch client / manage profiles")
        print(f"    {C_CYAN}m{C_RESET}. Change document mode  "
              f"{C_DIM}(currently: {MODES.get(last_mode or '1', '').split('—')[0].strip()}){C_RESET}")
        print(f"    {C_CYAN}q{C_RESET}. Quit")
        print()

        choice = input("  Select (1-5, c, m, q): ").strip().lower()

        if choice == 'q':
            print()
            info("Goodbye!")
            print()
            break

        if choice == 'm':
            LAST_MODE.unlink(missing_ok=True)
            select_mode()
            input("\n  Press Enter to continue...")
            continue

        if choice == 'c':
            result = show_client_manager()
            if result == 'back':
                continue
            # result is either a loaded profile dict or None (new prospect)
            prefill = result if result else {}
            # Fall through to prompt type selection with this prefill
            _run_prompt_flow(prefill)
            continue

        if choice not in PROMPT_FILES:
            err("Invalid choice — enter 1-5, c, m, or q.")
            input("\n  Press Enter to try again...")
            continue

        # Direct prompt type selection — load last prospect as prefill
        last = load_last_prospect()
        _run_prompt_flow(last, prompt_type=choice)

def _run_prompt_flow(prefill: dict, prompt_type: Optional[str] = None):
    """
    Run the full prompt generation flow.
    If prompt_type is None, ask the user to select one.
    prefill: existing client profile or empty dict for new prospect.
    """
    # Select prompt type if not already chosen
    if prompt_type is None:
        clear()
        print(f"\n  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}")
        company = prefill.get('company_name', '')
        if company:
            print(f"  {C_CYAN}{C_BOLD}     {company}{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}     Select prompt type{C_RESET}")
        print(f"  {C_CYAN}{C_BOLD}{'═'*52}{C_RESET}\n")

        for key, (_, label) in PROMPT_FILES.items():
            print(f"    {C_CYAN}{key}{C_RESET}. {label}")
        print(f"    {C_CYAN}q{C_RESET}. Back")
        print()
        prompt_type = input("  Select (1-5, q): ").strip().lower()
        if prompt_type == 'q':
            return
        if prompt_type not in PROMPT_FILES:
            err("Invalid choice.")
            input("\n  Press Enter to continue...")
            return

    filename, label = PROMPT_FILES[prompt_type]
    print(f"\n  {C_GREEN}Selected:{C_RESET} {label}")

    # Select / confirm mode
    mode = select_mode()

    # Local ingestion if needed
    ingested = {
        'product_docs': '', 'product_urls': '',
        'client_docs':  '', 'client_urls':  '',
        'has_product': False, 'has_client': False,
    }
    if mode in ("2", "3"):
        ingested = run_local_ingestion()

    # Load template
    template = read_file(PROMPTS_DIR / filename)

    # Collect / update prospect info
    fields = get_prospect_info(prompt_type, prefill)

    # Build and deliver
    final_prompt = build_final_prompt(template, fields, ingested, mode)
    deliver_prompt(final_prompt, mode)

    # What next?
    print()
    print(f"  {C_BOLD}What next?{C_RESET}\n")
    print(f"    {C_CYAN}1{C_RESET}. Another prompt for {C_BOLD}{fields.get('company_name','same prospect')}{C_RESET}")
    print(f"    {C_CYAN}2{C_RESET}. Switch to a different client")
    print(f"    {C_CYAN}3{C_RESET}. New prospect (enter details fresh)")
    print(f"    {C_CYAN}q{C_RESET}. Quit")
    print()
    nxt = input("  Choose (1, 2, 3, q): ").strip().lower()

    if nxt == 'q':
        print()
        info("Goodbye!")
        print()
        sys.exit(0)
    elif nxt == '2':
        result = show_client_manager()
        if result == 'back':
            # User pressed q in client manager — loop back to "What next?"
            _run_prompt_flow(fields, prompt_type=None)
        else:
            # result is a loaded profile dict or None (new prospect)
            new_prefill = result if isinstance(result, dict) else {}
            _run_prompt_flow(new_prefill)
    elif nxt == '3':
        try:
            LAST_PROSPECT.unlink(missing_ok=True)
        except Exception:
            pass
        if mode in ("2", "3"):
            print()
            warn("Remember to clear intake/client/ before building your next prompt.")
            info("Delete or archive the previous prospect's files from that folder")
            info("so they don't mix with your new prospect's context.")
            print()
        _run_prompt_flow({})
    # nxt == '1': loop with same fields as prefill
    else:
        _run_prompt_flow(fields, prompt_type=None)

if __name__ == '__main__':
    main()
