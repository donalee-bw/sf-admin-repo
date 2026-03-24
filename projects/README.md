# Projects

This folder contains documentation for each Salesforce configuration project.

---

## How to Use This Folder

### Starting a new project

1. Duplicate the `_template/` folder.
2. Rename it to match your GitHub branch name (e.g., `opportunity-stage-update`).
3. Fill in the three template files:
   - `project-brief.md` — scope, stakeholders, timeline
   - `deployment-log.md` — log every deployment as you go
   - `rollback-plan.md` — how to reverse the changes if needed

### When a project is complete

Move the project folder into `archive/` once the deployment to production is confirmed successful and the PR is merged.

---

## Folder Structure

```
projects/
├── README.md                    # This file
├── _template/                   # Copy this for every new project
│   ├── project-brief.md
│   ├── deployment-log.md
│   └── rollback-plan.md
├── archive/                     # Completed projects
└── <your-project-name>/         # Active project folders
```

---

## Active Projects

> List active projects here as a quick reference. Update when projects start or complete.

| Project | Owner | Branch | Status |
|---|---|---|---|
| _(example) Opportunity Stage Update_ | _Jane Smith_ | `feature/opportunity-stage-update` | _In Progress_ |
