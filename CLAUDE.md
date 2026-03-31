# Salesforce Admin AI Harness — Claude Code

AI guardrails and slash commands for Salesforce admins using Claude Code in VS Code.

---

## Salesforce safety guardrails

Non-negotiable rules. Apply to every response involving Salesforce operations.

### Deployment

- NEVER run `sf project deploy start` against production without a prior successful sandbox deployment in the same session.
- ALWAYS require `--target-org` on every `sf project deploy` command. If omitted, refuse and ask which org is intended.
- Production deployments MUST use `--test-level RunLocalTests` at minimum.

### Destructive changes

Field deletion, object deletion, or flow deactivation in production require ALL of:
1. Explicit user confirmation ("Yes, delete this field in production")
2. A stated rollback path
3. A backup retrieval (`sf project retrieve start`) completed before the change

If any of these three are missing, refuse and state which is missing.

### Data mutations

Any `sf data` command that writes (update, delete, upsert) must:
1. Show a `LIMIT 10` preview of affected records first
2. State the total affected row count
3. Get explicit user confirmation before executing

NEVER run bulk deletes (>100 records) without Architect approval.

### Hardcoded IDs

Flag any Salesforce 18-character ID in metadata or Apex. IDs differ between sandbox and production. Suggest Named Credentials, Custom Metadata Types, or Custom Labels instead.

### Permissions

Any change to Profile, PermissionSet, or PermissionSetGroup requires stating:
1. What access is being granted
2. Why it is needed
3. Who will be affected

### Escalation

If the admin says "I'm not sure" or the change touches 5+ dependent components, stop and recommend involving the Architect.

> "This change has broad impact. I recommend the Architect review before proceeding."

---

## Change management loop

Every configuration change follows this loop. Do not skip steps.

1. **Plan** — What are you changing and why? State in one sentence.
2. **Impact analysis** — Run `/sfdc-impact-analysis`. What depends on this component?
3. **RIC score** — Run `/sfdc-ric-scoring`. Score on Risk, Impact, and Complexity (1–5 each).
4. **Gate check**:
   - Green (3–6): Proceed.
   - Yellow (7–9): Proceed, but flag in the change log and notify the Architect async.
   - Red (10–15): STOP. Present the RIC score card. Architect must review before production deployment. The admin may continue building and testing in sandbox while awaiting review.
5. **Build** — Make the change in SFDX source files.
6. **Deploy to sandbox** — `sf project deploy start --target-org sandbox`
7. **Test** — Verify the change works and nothing broke (SOQL queries, test classes, manual check).
8. **Document** — Write a change-log entry in `change-log/` including the RIC score.
9. **Deploy to production** — After human approval (and Architect approval if Red): `sf project deploy start --target-org production --test-level RunLocalTests`
10. **Verify** — Confirm production deployment with a SOQL check or functional verification.

If any step fails: stop and diagnose before proceeding. Do not skip failed steps by moving forward.

### Change log format

Each entry is a markdown file in `change-log/` named `YYYY-MM-DD-short-description.md`:

```
# [Short description]

**Date**: YYYY-MM-DD
**Author**: [name]
**RIC Score**: R[x] I[x] C[x] = [total] ([Green/Yellow/Red])

## What changed
[List of components modified]

## Why
[One sentence business reason]

## What was tested
[How verification was done in sandbox]

## Rollback
[Steps to revert if needed]
```

---

## Org-specific domain context

Before any Salesforce configuration change, **read all files in `context/sfdc/`** for domain understanding. The Architect maintains this directory. Treat its contents as authoritative. Never write to it.

### If context is missing

If `context/sfdc/` is empty or missing, warn the admin:

> "The domain context directory is empty. For non-trivial changes, ask the Architect to populate `context/sfdc/` with org-specific documentation before proceeding."

Trivial changes (new reports, dashboard modifications, help text updates) may proceed without domain context.

### Freshness checks

The `context/sfdc/README.md` documents what each file contains and when it was last refreshed. If any file's freshness exceeds its stated TTL, flag it:

> "Domain context for [topic] may be stale (last updated [date]). Consider asking the Architect to refresh before proceeding."

### Guardrails from context

Apply any domain-specific guardrails documented in the context files. These may include:
- Fragile automation cycles that require extra testing
- Fields that should not be modified without specific approvals
- Naming overrides or exceptions to standard conventions
- Integration touchpoints that require coordination with external teams
- Field consolidation constraints (e.g., "do not create new classification fields")

---

## Available slash commands

Run these in Claude by typing `/command-name`:

| Command | When to use |
|---------|-------------|
| `/sfdc-impact-analysis` | Before modifying any field, flow, or metadata component |
| `/sfdc-ric-scoring` | After impact analysis — scores Risk, Impact, Complexity |
| `/sfdc-change-reviewer` | Full change review including RIC score card |
| `/sfdc-deployment-manager` | End-to-end sandbox → production deployment |
| `/sfdc-deployment` | Step-by-step deployment checklist |
| `/sfdc-flow-builder` | Building or modifying Flows |
| `/sfdc-field-management` | Adding or changing custom fields |
| `/sfdc-validation-rules` | Creating or modifying validation rules |
| `/sfdc-permissions` | Managing permission sets and profiles |
| `/sfdc-soql` | Writing and running SOQL queries |
| `/sfdc-troubleshooting` | Debugging broken automation or stuck records |
| `/leandata-routing` | Diagnosing why a Lead or Contact was routed to a specific rep, team, or queue |
| `/bw-engagement-cycle` | Changes touching the Outreach Stage / Cadence / Disposition cycle |
