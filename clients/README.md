# clients/ — Saved Client Profiles

This folder stores your saved prospect/client profiles locally.

## Important

- **Local only** — this folder is excluded from Git by `.gitignore`
- Profiles exist only on YOUR machine, not in the shared repo
- This is intentional — prospect data is specific to your instance
- Teammates have their own `clients/` folder on their machines

## What's stored

Each `.json` file is one saved client profile containing:
- Company details, tech stack, pain points
- Discovery notes and call summaries
- When the profile was created and last updated
- Any locally extracted document/URL content (Local mode only)

## Managing profiles

Use the SE Copilot launcher to:
- Save a new client profile after entering their details
- Switch between saved profiles
- Update an existing profile with new information
- Delete profiles you no longer need

## File naming

Files are named by company slug: `acme_corp.json`, `beta_inc.json`
Do not rename them manually — use the tool to manage them.
