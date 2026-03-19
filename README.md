# AE & SE Copilot 🚀
### Your AI-powered Sales Engineering assistant — runs locally, lives in Git.

SE Copilot turns Claude into a personalized SE assistant. Set up your company's
product context once, then generate tailored use cases, integration plans, and
demo scripts for every new prospect — in minutes.

Works on **Mac**, **Windows**, and **Linux**.

---

## What's in this repo?

```
se-copilot/
├── README.md
├── CHANGELOG.md                       ← Track context updates over time
├── .gitignore
│
├── START.sh                           ← Universal launcher (Mac / Linux)
├── START.bat                          ← Universal launcher (Windows — double-click)
├── START.ps1                          ← PowerShell launcher (Windows — richer UI)
│
├── context/
│   ├── PRODUCT_CONTEXT.md             ← YOUR product context file (fill this in)
│   └── CONTEXT_GUIDE.md               ← Field-by-field filling instructions
│
├── examples/
│   └── EXAMPLE_FILLED_CONTEXT.md      ← A fully completed example to learn from
│
├── clients/                           ← LOCAL ONLY — gitignored, never committed
│   └── README.md                      ← Explains local-only storage
│
├── intake/                            ← LOCAL ONLY — all intake content gitignored
│   ├── product/                       ← Product docs (opt-in to share via repo)
│   ├── client/                        ← Prospect docs — always local, never committed
│   └── urls/
│       ├── product_urls.txt           ← Product URLs (opt-in to share via repo)
│       └── client_urls.txt            ← Prospect URLs — always local, never committed
│
├── prompts/
│   ├── 01_pre_discovery.md
│   ├── 02_post_discovery.md
│   ├── 03_demo_script.md
│   ├── 04_use_case_analysis.md
│   └── 05_followup_email.md
│
└── scripts/
    ├── build_prompt.py                ← Core prompt builder + client manager
    ├── ingest.py                      ← Local document extraction engine
    ├── setup_core.sh
    ├── check_context.sh
    └── claude_project_guide.sh
```

**What goes to the repo vs. stays local:**

| Content | Committed to repo | Reason |
|---------|:-----------------:|--------|
| `context/PRODUCT_CONTEXT.md` | ✅ | Shared team knowledge — the whole point |
| `prompts/`, `examples/`, scripts | ✅ | Shared tooling |
| `clients/*.json` | ❌ | Personal prospect profiles |
| `intake/client/` | ❌ | Per-deal documents |
| `intake/urls/client_urls.txt` | ❌ | Prospect URLs |
| `intake/product/` | ❌ default | Product docs — opt-in to share (see `.gitignore`) |
| `intake/urls/product_urls.txt` | ❌ default | Product URLs — opt-in to share (see `.gitignore`) |
| `last_prompt.txt` | ❌ | Generated output |
| `.last_prospect.json`, `.last_mode.json` | ❌ | Personal session state |

---

## Choosing a mode — Claude UI vs. Local extraction

**This is the most important decision before you start using SE Copilot.**
The tool supports three modes for how it handles your documents and URLs.
You choose once and it remembers your preference.

---

### Mode 1 — Claude UI (recommended for most users)

The tool builds a structured prompt and copies it to your clipboard. After
pasting it into Claude, you attach your documents and paste your URLs
**directly in the Claude conversation** — Claude reads them natively.

```
CLI tool builds prompt → you paste into Claude
                              ↓
              You then attach files / paste URLs in Claude UI
              (drag-and-drop PDFs, paste website URLs, etc.)
                              ↓
              Claude reads everything and generates output
```

**Why this is the default:**
- No file management — drop files straight into the conversation
- Claude reads documents with full understanding, not just raw text extraction
- URLs are fetched by Claude directly — works on more sites than local fetching
- Zero setup beyond filling in your context file
- You can add more context mid-conversation if you think of something

**How it works in practice:**
After pasting the prompt, Claude will show you a checklist at the bottom:

```
## ATTACH IN THIS CONVERSATION
- Sales deck → upload as PDF or DOCX
- Their website → paste the URL inline (e.g. https://acmecorp.com)
- Discovery notes → paste as text or upload as TXT
- Job postings → paste the URL or copy-paste the text
...
```

Follow that checklist, then send the conversation.

---

### Mode 2 — Local extraction (for security and compliance requirements)

The tool extracts all document content **on your machine** before the prompt
is assembled. The extracted text is embedded directly in the prompt body.
Nothing is uploaded to Claude — the entire document pipeline runs locally.

```
Your documents → extracted locally by ingest.py
                        ↓
             Text embedded in the prompt
                        ↓
             Prompt copied to clipboard
                        ↓
             Paste into Claude — no file attachments needed
```

**When to use Local mode:**

> **Security and compliance note:**
> Some organisations have policies that restrict or prohibit uploading
> internal documents to cloud-based AI services. This may apply to you if:
>
> - Your company handles regulated data (financial, healthcare, legal, government)
> - Your InfoSec or Legal team has issued AI usage guidelines
> - Your product documentation contains unreleased features, pricing, or IP
>   that is classified as confidential or internal-only
> - Your client has shared documents under NDA that cannot leave your environment
> - You are in a SOC 2, ISO 27001, HIPAA, or similar compliance programme
>
> In any of these situations, **use Local mode**. Your documents are extracted
> on your machine, embedded as text in the prompt, and never uploaded anywhere.
> Claude only ever sees text — not the original files.

**How it works in practice:**
Drop files into `intake/product/` and `intake/client/`, add URLs to the
`.txt` files in `intake/urls/`, then run the tool. It scans and extracts
everything locally, embeds the content in the prompt, and you paste
the complete self-contained prompt into Claude with no attachments.

**Supported file types for local extraction:**
| Type | Extension | Notes |
|------|-----------|-------|
| PDF | `.pdf` | Text-layer PDFs only — scanned/image PDFs cannot be extracted |
| Word | `.docx` | Full text extraction including tables |
| Markdown | `.md` | Preserved as-is |
| Plain text | `.txt` | Preserved as-is |
| CSV | `.csv` | Preserved as-is |
| JSON | `.json` | Preserved as-is |

> **Scanned PDFs:** If a PDF is image-based (scanned document), the extractor
> cannot read it. Save the key content as a `.txt` file instead.

---

### Mode 3 — Both

Runs local extraction first (same as Mode 2), then appends the attachment
checklist so you can add supplementary public URLs or extra files in Claude UI.

**When to use Both mode:**
- Most of your documents are sensitive and must stay local, but you also
  want to pull in the prospect's public website or LinkedIn page via Claude
- You want the security of local extraction for internal docs, plus the
  convenience of Claude's URL fetching for public sources

---

### Switching modes

The mode you choose is remembered between sessions. To change it:
- During prompt building: type `m` at the prompt type menu
- The tool will show the mode selector and save your new preference

---

## Step 0 — Which computer are you on?

```
What computer are you using?
         │
         ├── Mac  ──────────────────────────────────── → MAC SETUP below
         │
         ├── Windows
         │         ├── Simple (double-click)  ──────── → WINDOWS Option A (START.bat)
         │         └── Richer UI (PowerShell) ──────── → WINDOWS Option B (START.ps1)
         │
         └── Linux ──────────────────────────────────── → MAC SETUP (same commands)
```

---

## Step 1 — Get the repo

**Option A — Download ZIP (no Git needed)**
1. Click the green **Code** button at the top of this page
2. Click **Download ZIP**
3. Unzip it — move the `se-copilot` folder to your Desktop or Documents

**Option B — Clone with Git**
```bash
git clone https://github.com/YOUR-ORG/se-copilot.git
cd se-copilot
```

---

## MAC SETUP

### Step 2 — Open Terminal in the folder

1. Press **Cmd + Space**, type **Terminal**, press Enter
2. Type `cd ` (with a space), drag the `se-copilot` folder into Terminal, press Enter

### Step 3 — Run the launcher

```bash
bash START.sh
```

**First time? Choose option 1** (First time setup). It checks Python,
sets permissions, and tells you what to do next.

### Step 4 — Fill in your product context

Open `context/PRODUCT_CONTEXT.md` in any text editor. Replace every `[BRACKET]`
with your real product information. See `examples/EXAMPLE_FILLED_CONTEXT.md`
for a completed reference and `context/CONTEXT_GUIDE.md` for field-by-field help.

> **Start with Sections 1, 2, and 3.** The rest can be added over time.
> Even a partially filled context file is far better than starting from scratch.

### Step 5 — Set up your Claude Project

Choose option 5 from the START menu for a step-by-step walkthrough,
or see the **Claude Project Setup** section below.

### Step 6 — Build your first prompt

Run `bash START.sh` → option 2 (Build a prompt) → choose your mode →
follow the prompts → paste into Claude.

---

## WINDOWS SETUP

### Which option?

```
Windows Setup
      │
      ├── Option A: START.bat  ← Recommended for most users
      │   Double-click to run. Works on all Windows versions.
      │
      └── Option B: START.ps1  ← PowerShell (richer experience)
          Color-coded status, auto-opens files, shows intake counts.
          Requires a one-time permission change (see below).
```

### Step 2 — Check Python is installed

1. Press **Windows + R**, type `cmd`, press Enter
2. Type `python --version`, press Enter
3. If you see `Python 3.x.x` you're good
4. If you see an error: download from [python.org](https://python.org),
   check **"Add Python to PATH"** during install, restart your computer

### Step 3a — Option A: START.bat

Double-click `START.bat`. **First time? Enter `1`** to run setup.

### Step 3b — Option B: START.ps1 (one-time permission setup)

1. Click Start → type **PowerShell** → right-click → **Run as administrator**
2. Paste and press Enter:
   ```
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Type `Y`, press Enter, close this window
4. Right-click `START.ps1` → **Run with PowerShell**

---

## Setting up documents and URLs

### If you're using Mode 1 (Claude UI)

No setup needed. After pasting the prompt into Claude, follow the
**ATTACH IN THIS CONVERSATION** checklist at the bottom of the prompt.

### If you're using Mode 2 or 3 (Local extraction)

**Product documents** (set up once, update as your product evolves):

1. From the START menu, choose option 3 (Manage intake files)
2. Drop files into `intake/product/`:
   - Sales decks, one-pagers (PDF/DOCX)
   - Technical documentation (PDF/DOCX/MD)
   - Integration guides
   - Release notes
3. Add your product's URLs to `intake/urls/product_urls.txt`:
   ```
   https://www.yourcompany.com
   https://docs.yourcompany.com/getting-started
   https://www.yourcompany.com/pricing
   ```

> **Note for teams using Git:** `intake/product/` and `product_urls.txt` are
> gitignored by default so they stay local. If your team wants to share product
> docs through the repo, edit `.gitignore` and comment out those two lines —
> then everyone gets the same product documents on `git pull`. Client content
> is always local regardless.

**Client documents** (clear and refill for each new prospect):

1. Drop prospect files into `intake/client/`:
   - Discovery call notes (save as `.txt`)
   - RFP or technical questionnaire (PDF/DOCX)
   - Copied job postings (`.txt`) — these are excellent tech stack signals
   - Any documents the prospect has shared
2. Add the prospect's URLs to `intake/urls/client_urls.txt`:
   ```
   https://www.prospectcompany.com/about
   https://engineering.prospectcompany.com
   https://www.linkedin.com/company/prospectcompany
   ```

> ⚠️ **Clear `intake/client/` between prospects.** This folder is for one
> deal at a time. The `.gitignore` excludes it from Git commits — prospect
> data stays on your machine only.

---

## Client profiles — switching between active deals

SE Copilot saves each prospect as a local profile so you can switch between
multiple active deals instantly — without re-entering anything. This is
designed for the reality of sales work: multiple opportunities developing
in the same week, jumping between calls, needing to pick up exactly where
you left off with each client.

### How profiles are saved

Every time you enter or update prospect details and generate a prompt, the
tool **automatically saves a profile** to `clients/<company_name>.json`.
There is no separate save step — it just happens. The next time you open
the tool, that profile is waiting for you in the client manager.

All profiles are **local to your machine only**. They are gitignored and
never committed to the shared repo. Your saved clients are your own instance
— teammates manage their own profiles independently.

---

### Opening the client manager

From anywhere in the prompt builder, press **`c`** and Enter.

You'll see a numbered list of all your saved profiles, sorted by most
recently updated:

```
  ══════════════════════════════════════════════
       SE Copilot — Client Profiles
  ══════════════════════════════════════════════

  Saved client profiles:

   1.  Acme Corp
       Industry: FinTech
       Stack:    AWS + Kafka + Python
       Updated:  2h ago

   2.  Beta Inc
       Industry: Healthcare SaaS
       Stack:    Azure + .NET + SQL Server
       Updated:  1 day ago

   3.  Gamma Ltd
       Industry: Developer Tools
       Stack:    GCP + Go + Kubernetes
       Updated:  8 days ago  ← shown in yellow (stale advisory)

  Enter a number to load, or press Enter to cancel.
```

Type a number and press Enter to load that client instantly.

---

### What happens when you load a profile

All fields from that client's last session are pre-filled in every prompt.
When the tool asks for prospect details, you'll see the existing values
displayed in brackets:

```
  Company name: [Acme Corp]
  Industry: [FinTech]
  Size / stage: [Series C, ~300 engineers]
  Tech stack: [AWS + Kafka + Python + Datadog]
  Pain points: [3 outages last quarter, 47min MTTR]
  Deal stage: [Post-discovery]
```

Press **Enter** to keep any field as-is, or type a new value to update it.
This means returning to a client mid-week takes about 10 seconds instead of
re-entering everything from scratch.

**Discovery notes** have an extra option — keep, replace, or append:

```
  Existing discovery notes:
  "Pain confirmed: 3 incidents Q3, avg 47min MTTR. Champion is Sarah..."

  Discovery notes: (k)eep / (r)eplace / (a)ppend:
```

Choose **append** after a follow-up call to layer new notes on top of the
previous session without losing anything. Choose **replace** if you're
starting a new phase of the deal. The same keep/replace/append choice
applies to call summaries.

---

### Switching between clients mid-session

After generating a prompt, the tool shows:

```
  What next?

    1. Another prompt for Acme Corp
    2. Switch to a different client
    3. New prospect (enter details fresh)
    q. Quit
```

Choose **2** to jump straight to the client manager and load a different
profile — without going back to the main menu. This is designed for the
scenario where you're prepping for back-to-back calls: generate a demo
script for Acme Corp, switch to Beta Inc, generate a pre-discovery brief,
switch back to Acme Corp for a follow-up email — all in a single session.

---

### Staleness warning

Profiles older than **7 days** show their age in yellow in the list and
display an advisory message when loaded:

```
  [ADVISORY] Profile is 8 days ago old

  The profile for Gamma Ltd was last updated 8 days ago.
  A lot can change in a week — consider reviewing key fields
  like tech stack, pain points, and discovery notes before generating.

  This is advisory only — you can proceed without updating.
```

This is **never a blocker**. You can press Enter through it and generate
immediately. It exists only to prompt a quick sanity check when a deal has
been sitting for a while — tech stacks change, champions move on, pain
priorities shift. For deals you're actively working in the same week,
you will almost never see this warning.

---

### Deleting a profile

From the client manager, press **`d`** and Enter. You'll see the same
numbered list. Enter the number of the profile to delete and confirm:

```
  Delete profile for "Gamma Ltd"? This cannot be undone. (y/n):
```

Profiles don't expire on their own — they stay until you delete them.
Good times to delete: a deal closes (won or lost), a prospect goes cold,
or you want to clean up your list at the end of a quarter.

---

### What's stored in a profile

| Field | Stored |
|-------|--------|
| Company name, industry, size / stage | ✅ |
| Tech stack, pain points | ✅ |
| Deal stage | ✅ |
| Source of information | ✅ |
| Discovery notes | ✅ (with append history) |
| Call summaries | ✅ (with append history) |
| Demo attendees and duration | ✅ |
| Created and last-updated timestamps | ✅ |
| Locally extracted document content | ❌ (re-extracted fresh each run) |

The last point is intentional — document content from `intake/` is
re-extracted every time you build a prompt so it always reflects whatever
files are currently in the folder, not a potentially outdated snapshot.

---

## Daily workflow

### Single prospect session

```
Run START launcher → option 2 (Build a prompt)
        │
        ▼
Press 'c' → client manager → select 'n' (new prospect)
        │
        ▼
Enter prospect details → auto-saved as a profile
        │
        ▼
Select document mode + prompt type
        │
        ▼
Prompt copied to clipboard → paste into Claude
        │
        ▼
"What next?" → 1 (another prompt), 3 (new prospect), or q (quit)
```

### Switching between multiple active deals (same session)

```
Run START launcher → option 2
        │
        ▼
Press 'c' → client manager

  ┌─────────────────────────────────────────────┐
  │  1. Acme Corp    FinTech    2h ago           │
  │  2. Beta Inc     SaaS       1 day ago        │
  │  3. Gamma Ltd    DevTools   8 days ago 🟡    │
  └─────────────────────────────────────────────┘

Type '1' → load Acme Corp (all fields pre-filled)
        │
        ▼
Generate demo script → prompt to clipboard → paste into Claude
        │
        ▼
"What next?" → press '2' (switch client)
        │
        ▼
Client manager appears again → type '2' → load Beta Inc
        │
        ▼
Generate pre-discovery brief → prompt to clipboard → paste into Claude
        │
        ▼
"What next?" → press '2' again → switch back to Acme Corp
        │
        ▼
Generate follow-up email → done
```

No re-launching the tool. No re-entering prospect details. Each client
loads exactly where you left off.

---

## Claude Project Setup (do once)

1. Go to [claude.ai](https://claude.ai) and sign in
2. Click **Projects** in the left sidebar → **+ New Project**
3. Name it: `SE Copilot — [Your Company Name]`
4. Click **Add content** → upload `context/PRODUCT_CONTEXT.md`
5. Click **Edit project instructions** and paste:

```
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
```

6. Replace `[YOUR COMPANY NAME]`, click **Save**

> **Note on the Project + CLI together:** When you use the CLI tool to build
> a prompt, the full product context is already embedded in the prompt text.
> Pasting it into your Claude Project means Claude sees the context twice —
> once from the Project document and once from the prompt. This is harmless,
> but if you want to avoid it, you can paste CLI-generated prompts into a
> regular Claude conversation (not the Project) and Claude will still have
> everything it needs from the prompt itself.

---

## Keeping your context up to date

| Trigger | Section to update |
|---------|------------------|
| New feature shipped | Section 2 (Modules) + Section 4 (Use Cases) |
| New integration added | Section 3 + Section 7 (Architectures) |
| New competitor | Section 6 (Competitive) |
| Pricing changed | Section 5 (Pricing) |
| Won deal with new use case | Section 4 + Section 9 (Proof Points) |
| New objection heard | Section 8 (Objection Handling) |

Always update `CHANGELOG.md` when you push changes so teammates know what improved.

```bash
# Push an update
git add context/PRODUCT_CONTEXT.md CHANGELOG.md
git commit -m "Added FinTech use case from Acme Corp win"
git push

# Pull a teammate's update
git pull
```

---

## Troubleshooting

### Mac / Linux

| Problem | Fix |
|---------|-----|
| `bash: START.sh: No such file or directory` | Re-do Step 2 — drag the folder into Terminal |
| `python3: command not found` | Run `xcode-select --install` or download from python.org |
| Prompt not copied to clipboard | Saved to `last_prompt.txt` — open and copy manually |
| URL fetch fails (Local mode) | Check internet connection; some sites block automated fetching — paste the URL in Claude UI instead |
| PDF shows "image-based" warning | Save content as `.txt` and drop that in intake/ instead |
| Claude gives generic answers | Context file needs more detail in Sections 3 and 4 |
| Client profile not showing up | Profile is saved by company name slug — search `clients/` folder for the `.json` file |
| Stale warning on a recent profile | System clock may have drifted — the warning triggers at 7 days; it's advisory only |

### Windows

| Problem | Fix |
|---------|-----|
| `'python' is not recognized` | Reinstall Python from python.org — check "Add to PATH" |
| START.bat closes immediately | Right-click → Run as administrator |
| `running scripts is disabled` | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in PowerShell as admin |
| Prompt not copied | Saved to `last_prompt.txt` — open in Notepad and copy all |
| Can't find saved client profiles | Look in the `clients\` folder inside `se-copilot` — files are named `company_name.json` |

---

## Manager rollout checklist

- [ ] Create a private GitHub repo and push this project to it
- [ ] Fill in `context/PRODUCT_CONTEXT.md` with your SE lead (2–3 hours)
- [ ] Decide on default mode for your team (UI vs. Local) — document in CHANGELOG
- [ ] **Optional:** If you want product docs shared via the repo, edit `.gitignore`
      and comment out the `intake/product/` and `intake/urls/product_urls.txt` lines,
      then add your product docs to `intake/product/` and commit them.
      All client content stays local regardless.
- [ ] Create the Claude.ai Project and set the project instructions
- [ ] Invite all AEs and SEs as repo collaborators
- [ ] Share the repo link — teammates follow this README to onboard (<30 min)
- [ ] Schedule monthly "context review" — SE lead updates, logs in CHANGELOG, pushes
- [ ] After each major deal: add the use case and outcome to the context file

---

*Requires a Claude.ai account. Runs on Mac, Windows, and Linux.*
*No third-party Python packages required — uses Python standard library only.*
*Prospect data in `intake/client/` is excluded from Git by `.gitignore`.*
*Local mode: document content never leaves your machine.*
