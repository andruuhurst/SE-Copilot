# intake/client — Client / Prospect Documents

Drop prospect-specific files here before building a prompt.

## Supported file types
| Type | Extension | Example use |
|------|-----------|-------------|
| PDF | .pdf | RFP, RFI, technical questionnaire, org chart |
| Word | .docx | Discovery call notes, email thread export |
| Markdown | .md | Notes from research, exported Notion pages |
| Text | .txt | Copied LinkedIn bios, job postings, Slack notes |
| CSV | .csv | Contact list, tech audit spreadsheet |
| JSON | .json | Their public API schema, config samples |

## What to put here
- Discovery call notes
- RFP or technical questionnaire documents
- Job postings you've copied (great tech stack signals)
- LinkedIn profile exports or copied bios
- Email threads with the prospect
- Their technical documentation (if they've shared it)
- Architecture diagrams they've shared
- Any company research you've done

## IMPORTANT — Clear between prospects
This folder is for ONE prospect at a time. Before working on a new
prospect, either:
  1. Delete the files from the previous prospect, OR
  2. Move them to an archive folder (e.g. clients/CompanyName/)

Mixing files from multiple prospects will confuse Claude.

## How it works
When you run "Build a prompt" (option 2 from START menu), the tool
reads all files here and includes them as client context — giving Claude
much richer information than typing notes into the CLI alone.

## Tips
- Discovery call notes as a .txt file are extremely valuable
- Copied job postings reveal tech stack better than anything else
- Even a rough bullet-point list is better than nothing
