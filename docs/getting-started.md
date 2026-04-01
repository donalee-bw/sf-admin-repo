# Getting Started

Welcome to the team repository. This guide will get you up and running from scratch.

---

## Step 1: Get Access

1. Create a free account at [github.com](https://github.com) if you don't have one.
2. Share your GitHub username with your team lead.
3. You'll receive an email invitation to join the repository — accept it.

---

## Step 2: Install Required Tools

### Git
Download and install Git: [https://git-scm.com/downloads](https://git-scm.com/downloads)

After installing, open a terminal and configure it:
```bash
git config --global user.name "Your Name"
git config --global user.email "you@company.com"
```

### GitHub Desktop (Optional but Recommended for Beginners)
If you prefer a visual interface over the command line, install GitHub Desktop:
[https://desktop.github.com](https://desktop.github.com)

---

## Step 3: Clone the Repository

This downloads the repository to your computer:

```bash
git clone https://github.com/YOUR-ORG/YOUR-REPO-NAME.git
```

Or in GitHub Desktop: **File > Clone Repository**, then choose the repo from the list.

---

## Step 4: Connect Gearset to This Repo

1. Log in to [Gearset](https://app.gearset.com).
2. Go to **Settings > Source Control**.
3. Connect your GitHub account.
4. Select this repository as your source control target.
5. Set your default branch to `main`.

Gearset will now commit metadata it retrieves from your orgs into this repository.

---

## Step 5: Understand the Folder Structure

| Folder | What's in it |
|---|---|
| `force-app/main/default/` | Salesforce metadata committed by Gearset |
| `docs/` | This guide and other process documentation |
| `scripts/soql/` | Saved SOQL queries |
| `scripts/apex/` | Saved anonymous Apex scripts |
| `scripts/data-loader/` | Data loader configuration files |
| `projects/` | One folder per project with tracking docs |
| `.github/` | Pull request and issue templates |

---

## Step 6: Read These Guides Next

- [Claude Code Workflow](claude-code-workflow.md) — How to use Claude Code before every config change
- [Gearset Workflow](gearset-workflow.md) — How to use Gearset with this repo
- [Branching Strategy](branching-strategy.md) — How we use branches
- [Deployment Checklist](deployment-checklist.md) — Required steps for every deployment
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Git basics and team rules
