Step-by-step deployment from local SFDX source to sandbox to production.

## Prerequisites

- Impact analysis completed (`/sfdc-impact-analysis`)
- RIC score computed (`/sfdc-ric-scoring`)
- Gate check passed (Green/Yellow proceed; Red requires Architect approval)
- Changes exist in local SFDX source files

## Process

### 1. Preview the deployment

```bash
sf project deploy preview --target-org sandbox
```

Review the list of components that will be deployed. Verify it matches what you expect — no unexpected additions or deletions.

### 2. Deploy to sandbox

```bash
sf project deploy start --target-org sandbox
```

If the deployment fails:
- Read the error message carefully
- Common failures: missing dependencies, API version mismatch, formula syntax errors, duplicate API names
- Fix the issue in source and retry. Do not skip to production.

### 3. Verify in sandbox

```bash
sf data query --query "SELECT Id, [relevant fields] FROM [Object] LIMIT 5" --target-org sandbox
```

For flow changes: create or update a test record in sandbox and verify the flow triggered correctly.
For validation rule changes: attempt to save a record that violates the rule and confirm it is blocked.

### 4. Run Apex tests

```bash
sf apex run test --target-org sandbox --test-level RunLocalTests --wait 10
```

All tests must pass. If tests fail:
- Determine if the failure is related to your change or pre-existing
- Fix related failures before proceeding
- Pre-existing failures should be documented but do not block deployment

### 5. Request human approval

> **Ready for production deployment.**
>
> - Components: [list]
> - Sandbox verification: [passed/issues noted]
> - Test results: [X passed, Y failed (pre-existing)]
> - RIC score: [R/I/C = total, zone]
>
> Approve production deployment?

If Red, also confirm Architect approval was obtained.

### 6. Deploy to production

```bash
sf project deploy start --target-org production --test-level RunLocalTests
```

NEVER deploy to production without `--test-level RunLocalTests` at minimum.

### 7. Verify in production

```bash
sf data query --query "SELECT Id, [relevant fields] FROM [Object] LIMIT 5" --target-org production
```

Confirm the component is active and functioning.

### 8. Write change log entry

Create `change-log/YYYY-MM-DD-short-description.md` with: what changed, why, RIC score, what was tested, rollback steps.

## Rollback

If the production deployment causes issues:

1. Retrieve the prior version: `git checkout HEAD~1 -- force-app/[path to component]`
2. Deploy the prior version: `sf project deploy start --target-org production --test-level RunLocalTests`
3. Verify the rollback
4. Document the rollback in the change log

For destructive changes (field/object deletion), rollback requires restoring from the backup retrieval taken before the change.
