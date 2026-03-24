# Gearset Workflow

This guide explains how we use Gearset together with this GitHub repository to manage Salesforce deployments.

---

## How It Works (Overview)

```
Sandbox Org  →  Gearset retrieves metadata  →  GitHub branch  →  PR review  →  Gearset deploys  →  Production
```

Gearset acts as the bridge between your Salesforce orgs and this repository. It reads metadata from orgs and writes it to branches, and deploys from branches back to orgs.

---

## Starting a New Project

### 1. Create a project branch
Before doing anything in Gearset, create a branch in GitHub for your project:

```bash
git checkout main
git pull
git checkout -b feature/your-project-name
git push origin feature/your-project-name
```

Use a short, descriptive name (e.g., `feature/lead-scoring-fields`, `feature/q2-permission-sets`).

### 2. Create your project folder
Copy the `projects/_template/` folder and rename it to match your branch name. Fill in the `project-brief.md`.

### 3. Connect Gearset to your branch
In Gearset:
1. Open your deployment pipeline.
2. Set the **source** to your sandbox org.
3. Set the **target** to this GitHub repository, on your feature branch.
4. Retrieve the metadata changes you want to include.

---

## Committing Metadata with Gearset

When you retrieve metadata in Gearset and choose to commit it to source control:

1. Gearset will commit the metadata files to `force-app/main/default/` on your branch.
2. You'll see the commit appear in GitHub under your branch.
3. Log what was retrieved in your project's `deployment-log.md`.

---

## Deploying to Production

When the project is ready:

1. Open a **Pull Request** in GitHub from your feature branch to `main`.
2. Fill out the PR checklist (sandbox tested, deployment log updated, rollback plan written).
3. A teammate reviews and approves the PR.
4. In Gearset, run the final deployment:
   - Source: your feature branch (or `main` after merge)
   - Target: Production org
5. Log the deployment result in `deployment-log.md`.
6. Merge the PR to `main` if not already done.

---

## Tips

- Always work on a branch, never commit directly to `main`.
- If a deployment fails, refer to your `rollback-plan.md` immediately.
- Tag deployments in Gearset with the project name so they're easy to find later.
- Retrieve only the metadata that is part of your project — avoid retrieving everything.

---

## Org-to-Branch Mapping

| Environment | Branch |
|---|---|
| Production | `main` |
| Full Sandbox | `feature/<project-name>` |
| Developer Sandbox | `feature/<project-name>` |

> Update this table to match your team's actual sandbox setup.
