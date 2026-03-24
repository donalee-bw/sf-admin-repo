# Salesforce Admin Team Repository

This is the shared repository for our Salesforce configuration team. It is the central home for metadata, documentation, scripts, and project tracking.

---

## What's in This Repo

| Folder | Purpose |
|---|---|
| `force-app/` | Salesforce metadata managed by Gearset |
| `docs/` | Guides, checklists, runbooks, and process documentation |
| `scripts/` | SOQL queries, Apex scripts, and data loader configs |
| `projects/` | Per-project documentation and deployment logs |
| `.github/` | Pull request and issue templates |

---

## How This Repo Works with Gearset

1. Gearset connects to this GitHub repository to read and write Salesforce metadata.
2. Each configuration project gets its own **branch** (e.g., `feature/opportunity-stage-update`).
3. Gearset commits metadata to that branch when you retrieve changes from a sandbox.
4. When the project is ready to deploy to production, you open a **Pull Request** to merge the branch into `main`.
5. After the PR is reviewed and approved, Gearset deploys from `main` to production.

See [docs/gearset-workflow.md](docs/gearset-workflow.md) for a step-by-step guide.

---

## Quick Links

- [Getting Started](docs/getting-started.md) — New to the team or this repo? Start here.
- [Gearset Workflow](docs/gearset-workflow.md) — How to use Gearset with this repo.
- [Deployment Checklist](docs/deployment-checklist.md) — Steps to follow before and after every deployment.
- [Branching Strategy](docs/branching-strategy.md) — How we use branches.
- [New Project Template](projects/_template/) — Copy this folder when starting a new project.

---

## Branch Overview

| Branch | Purpose |
|---|---|
| `main` | Always reflects production. Protected — no direct pushes. |
| `feature/<project-name>` | One branch per project or ticket. |

---

## Need Help?

- Check the [docs/](docs/) folder for guides and runbooks.
- If something is wrong with a deployment, see the project's `rollback-plan.md`.
- For Git questions, see [CONTRIBUTING.md](CONTRIBUTING.md).
