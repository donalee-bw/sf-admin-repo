# Deployment Checklist

Use this checklist for every deployment to production. Copy it into your project's `deployment-log.md` or reference it directly.

---

## Before Deployment

### Planning
- [ ] Project brief is complete (`projects/<name>/project-brief.md`)
- [ ] All metadata changes have been reviewed by the project owner
- [ ] Stakeholders have approved the go-live date and time
- [ ] A rollback plan has been written (`projects/<name>/rollback-plan.md`)

### Sandbox Testing
- [ ] All changes were deployed to a **full sandbox** first
- [ ] UAT (User Acceptance Testing) completed by the business stakeholder
- [ ] No critical errors or validation rule failures in sandbox
- [ ] If reports/dashboards are included: verified they work as expected

### Repository
- [ ] All metadata is committed to the feature branch in GitHub
- [ ] Pull Request has been opened and the PR checklist is filled out
- [ ] PR has been reviewed and approved by at least one teammate
- [ ] Deployment log is up to date

### Timing
- [ ] Scheduled during low-traffic hours (avoid month-end, quarter-end, business-critical periods)
- [ ] Relevant stakeholders notified of the deployment window

---

## During Deployment

- [ ] Deployment started in Gearset
- [ ] Monitoring deployment progress in Gearset
- [ ] No unexpected errors — if errors occur, **stop and refer to rollback plan**

---

## After Deployment

### Smoke Testing (Do These Immediately)
- [ ] Log in to production as a standard user and verify key functionality works
- [ ] Test the specific features/fields/flows that were deployed
- [ ] Confirm no existing functionality is broken

### Wrap-Up
- [ ] Deployment result logged in `projects/<name>/deployment-log.md`
- [ ] Stakeholders notified that deployment is complete
- [ ] PR merged to `main` in GitHub
- [ ] Feature branch deleted (optional, keeps things tidy)
- [ ] If issues found post-deployment: rollback plan initiated

---

## Rollback Trigger Criteria

Initiate rollback immediately if:
- Users cannot access records or objects they previously could
- A critical business process (e.g., case creation, opportunity stage updates) is broken
- Validation rules are blocking records that should be valid
- Data has been unexpectedly changed or deleted

See `projects/<name>/rollback-plan.md` for the specific steps.
