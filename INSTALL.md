# Admin AI Harness — Install Guide

This guide sets up Claude Code in VS Code so you can use AI-assisted Salesforce administration with built-in safety guardrails.

**Time to complete**: ~15 minutes

---

## What you're installing

Claude Code is an AI assistant that runs inside VS Code. This repo adds Salesforce-specific guardrails and slash commands on top of it:

- **Safety guardrails** that prevent destructive changes (always active)
- **Change management loop** that enforces impact analysis before every change (always active)
- **Slash commands** for common admin tasks like impact analysis, RIC scoring, deployment, and troubleshooting

---

## Step 1 — Install prerequisites

You need the following installed on your Mac. Open **Terminal** and run each check:

### Check Node.js (v18 or higher)

```bash
node --version
```

If you see `v18.x.x` or higher, you're good. If not, install it from [nodejs.org](https://nodejs.org) (download the LTS version).

### Check Salesforce CLI

```bash
sf --version
```

If you see a version number, you're good. If not:

```bash
npm install -g @salesforce/cli
```

### Check Git

```bash
git --version
```

Git comes pre-installed on Macs. If you get an error, install Xcode Command Line Tools:

```bash
xcode-select --install
```

---

## Step 2 — Install VS Code

Download and install [Visual Studio Code](https://code.visualstudio.com) if you don't already have it.

---

## Step 3 — Install the Claude Code extension

1. Open VS Code
2. Click the **Extensions** icon in the left sidebar (or press `Cmd+Shift+X`)
3. Search for **Claude Code**
4. Click **Install** on the extension published by Anthropic
5. When prompted, sign in with your Anthropic account (or create one at [claude.ai](https://claude.ai))

---

## Step 4 — Open this repo in VS Code

1. Open VS Code
2. Go to **File > Open Folder**
3. Navigate to and select this repo folder (`bw Full Copy SFDC`)
4. Click **Open**

VS Code will load the project. You should see the file tree on the left.

---

## Step 5 — Connect your Salesforce orgs

In the VS Code terminal (`` Ctrl+` `` to open it), connect to your orgs:

**Sandbox:**
```bash
sf org login web --alias sandbox
```

This opens a browser window. Log in with your Salesforce sandbox credentials.

**Production** (when you need it — admins typically work in sandbox first):
```bash
sf org login web --alias production
```

Verify your connections:
```bash
sf org list
```

You should see both orgs listed.

---

## Step 6 — Open Claude in VS Code

1. Press `Cmd+Shift+P` to open the Command Palette
2. Type **Claude** and select **Claude: Open**
   - Or look for the Claude icon in the left sidebar

Claude is now running inside VS Code with all the Salesforce guardrails active.

---

## Step 7 — Test it

Type this in the Claude chat:

> "What slash commands do I have available for Salesforce work?"

Claude should list all available commands. Then try:

> "I need to add a new field to the Lead object to capture the center's enrollment capacity."

Claude will walk you through the field management process with safety checks.

---

## Available slash commands

Type `/` in the Claude chat to see all commands. The Salesforce-specific ones are:

| Command | What it does |
|---------|-------------|
| `/sfdc-impact-analysis` | Analyzes what depends on a component before you change it |
| `/sfdc-ric-scoring` | Scores your change on Risk, Impact, and Complexity |
| `/sfdc-change-reviewer` | Full change review — runs impact analysis + RIC score |
| `/sfdc-deployment-manager` | Guides you through sandbox → production deployment |
| `/sfdc-deployment` | Step-by-step deployment checklist |
| `/sfdc-flow-builder` | Builds or modifies Flows with best practices |
| `/sfdc-field-management` | Adds or changes custom fields safely |
| `/sfdc-validation-rules` | Creates validation rules with null handling and bypass |
| `/sfdc-permissions` | Manages permission sets and profiles |
| `/sfdc-soql` | Writes and runs SOQL queries safely |
| `/sfdc-troubleshooting` | Debugs broken automation or stuck records |
| `/bw-engagement-cycle` | Extra guardrails for the Outreach Stage/Cadence/Disposition cycle |

---

## How the safety guardrails work

The guardrails are always active — you don't need to turn them on. Claude will:

- **Refuse to deploy to production** without a successful sandbox deployment first
- **Refuse to run data mutations** without showing you a preview of affected records first
- **Flag hardcoded Salesforce IDs** in metadata (IDs differ between sandbox and production)
- **Stop and escalate to the Architect** if a change touches 5+ dependent components or you say "I'm not sure"
- **Run the RIC scoring gate** before every configuration change

### RIC score zones

Every change is scored on Risk + Impact + Complexity (1–5 each):

| Score | Zone | What happens |
|-------|------|-------------|
| 3–6 | 🟢 Green | You proceed autonomously |
| 7–9 | 🟡 Yellow | You proceed, Architect is notified |
| 10–15 | 🔴 Red | Stop — Architect must review before production |

---

## The change log

Every deployment should have a change log entry in `change-log/`. Claude will remind you and help you write it. The log is named `YYYY-MM-DD-short-description.md` and documents:

- What changed
- Why
- RIC score
- What was tested
- How to roll back if needed

---

## Getting help

- **Ask Claude**: Claude can answer questions about Salesforce admin tasks, explain slash commands, or walk you through any process in this guide.
- **Slack your team**: Post in the admin team channel if something isn't working.
- **Architect escalation**: For Red-scored changes or anything where you're unsure, reach out to your Architect before proceeding.

---

## For Architects — maintaining domain context

The `context/sfdc/` directory is yours to maintain. Claude reads these files before every configuration change. Keep them updated as the org evolves:

| File | Update when... | TTL |
|------|---------------|-----|
| `object-model.md` | New objects or relationships are added | 90 days |
| `business-processes.md` | Sales motions or pipeline stages change | 60 days |
| `automation-inventory.md` | New flows, triggers, or integrations are deployed | 30 days |
| `field-reference.md` | New critical or hidden fields are identified | 60 days |

Update the "Last refreshed" date in each file and in `context/sfdc/README.md` after each refresh. Claude will warn admins when context is stale.
