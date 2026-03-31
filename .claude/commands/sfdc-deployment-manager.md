Orchestrate an end-to-end Salesforce deployment from sandbox to production, with verification at each stage.

Use when the admin has changes ready to deploy, or after a successful change review.

## Process

### 1. Run change review

If `/sfdc-change-reviewer` has not been run in the current session, run it now. If it ran recently and source hasn't changed, skip.

Check the RIC routing:
- **Green**: Proceed to deployment.
- **Yellow**: Proceed, but note that the Architect will be notified.
- **Red**: STOP. Confirm Architect approval has been obtained before proceeding to production. Sandbox deployment may proceed without Architect approval.

### 2. Deploy to sandbox

Follow `/sfdc-deployment` steps 1–4:
1. Preview the deployment
2. Deploy to sandbox
3. Verify in sandbox
4. Run Apex tests

If any step fails, stop and help the admin debug. Do not proceed to production.

### 3. Present results and request approval

Summarize:
- Components deployed
- Sandbox verification results
- Test results (pass/fail counts)
- RIC score and routing
- Any domain flags from the change review

Ask: **"Ready for production deployment? [Yes / No / Need more testing]"**

### 4. Deploy to production

Only after human approval (and Architect approval if Red):

Follow `/sfdc-deployment` steps 6–7:
1. Deploy to production with `--test-level RunLocalTests`
2. Verify in production

### 5. Write change log entry

Create `change-log/YYYY-MM-DD-short-description.md` including:
- What changed
- Why
- RIC score card
- What was tested
- Rollback steps

## Rules

- NEVER deploy to production without a successful sandbox deployment first.
- NEVER deploy to production without human approval.
- NEVER deploy to production without `--test-level RunLocalTests`.
- If the RIC score is Red, NEVER deploy to production without confirmed Architect approval.
- If deployment fails, help debug but do not retry automatically. Let the admin decide next steps.
