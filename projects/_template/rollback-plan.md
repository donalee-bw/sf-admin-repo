# Rollback Plan: [Project Name]

> Fill this out **before** deploying to production. If something goes wrong, this is the first document you reach for.

---

## When to Roll Back

Initiate a rollback immediately if any of the following occur after deployment:
- [ ] _(Describe a specific failure condition for this project, e.g., "Opportunity stage field is blank on existing records")_
- [ ] Users cannot access records or pages they previously could
- [ ] A critical workflow or automation stops functioning
- [ ] Data is incorrect or missing

---

## Who to Notify First

| Person | Role | Contact |
|---|---|---|
| | Project Owner | |
| | Business Stakeholder | |
| | Salesforce Admin Lead | |

---

## Rollback Steps

### Step 1: Stop the damage
_(e.g., deactivate the flow, disable the validation rule, remove the field from the page layout)_

1.
2.
3.

### Step 2: Restore previous configuration
_(e.g., re-deploy the previous version from Gearset using the last known-good commit on `main`)_

1. In Gearset, open the deployment history.
2. Find the last successful production deployment before this project.
3. Deploy the affected components back to production.

### Step 3: Verify the rollback
- [ ] Confirm users can access affected records/pages
- [ ] Confirm the specific failure condition no longer exists
- [ ] Run a quick smoke test on related functionality

### Step 4: Communicate
- [ ] Notify stakeholders that rollback is complete
- [ ] Document what happened in the deployment log
- [ ] Schedule a post-mortem if needed

---

## Notes

_(Anything specific to this project that would affect a rollback — e.g., data migrations that can't be reversed, third-party system dependencies, etc.)_
