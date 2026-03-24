# Branching Strategy

This document explains how we use branches in this repository. The goal is to keep things simple and safe.

---

## The Two Rules

1. **`main` always reflects production.** Nothing goes into `main` that hasn't been deployed and tested.
2. **Every project gets its own branch.** Never mix two projects on the same branch.

---

## Branch Types

### `main`
- Represents what is currently deployed in the **Production org**.
- **Protected** — no one can push directly to this branch.
- Updated only through Pull Requests that have been reviewed and approved.

### `feature/<project-name>`
- Created for each new configuration project or ticket.
- Named after the project (e.g., `feature/lead-scoring-fields`, `feature/q2-permission-sets`).
- Gearset commits metadata to this branch during development.
- Deleted after the PR is merged (optional).

---

## Naming Convention

Use lowercase letters and hyphens. Include a short description of the work.

| Good | Avoid |
|---|---|
| `feature/opportunity-stage-update` | `featureBranch1` |
| `feature/q3-profile-cleanup` | `mychanges` |
| `feature/service-cloud-setup` | `test` |

---

## Branch Lifecycle

```
1. Create branch from main
      git checkout main && git pull
      git checkout -b feature/project-name

2. Do your work (Gearset commits metadata, you update project docs)

3. Open a Pull Request to main

4. PR reviewed and approved by a teammate

5. Merge to main

6. Deploy from main to production via Gearset

7. Delete the feature branch (optional)
```

---

## Setting Up Branch Protection on GitHub

To enforce these rules, a GitHub admin should configure branch protection on `main`:

1. Go to the repository on GitHub.
2. Click **Settings > Branches**.
3. Under **Branch protection rules**, click **Add rule**.
4. Set **Branch name pattern** to `main`.
5. Enable:
   - **Require a pull request before merging**
   - **Require approvals** (set to 1)
   - **Do not allow bypassing the above settings**
6. Click **Save changes**.
