# Claude Code Workflow

How the Brightwheel Salesforce admin team uses Claude Code as the starting point for every configuration change.

---

## The core norm

> **Before touching Setup, open Claude Code and describe what you're trying to do.**

Claude will guide you through impact analysis, risk scoring, and the right guardrails for your change. This applies to every non-trivial configuration change — fields, flows, validation rules, permissions, and automation.

Trivial exceptions (report/dashboard edits, help text updates) may skip Claude Code, but when in doubt, start there.

---

## How it fits into Asana

Every config change task in Asana requires these checklist items before moving to "Ready for Review":

```
[ ] Opened Claude Code and described the change
[ ] Ran /sfdc-impact-analysis — output noted in task
[ ] Ran /sfdc-ric-scoring — RIC score recorded: R__ I__ C__ = __ (Green / Yellow / Red)
[ ] Change log entry drafted in change-log/
[ ] Paul tagged on this task if score is Yellow or Red
```

Yellow and Red scores do not block you from building and testing in sandbox. They block production deployment until Paul has reviewed.

---

## RIC score gates

| Score | Color | Action |
|-------|-------|--------|
| 3–6 | Green | Proceed to deployment |
| 7–9 | Yellow | Proceed in sandbox; tag Paul async before production |
| 10–15 | Red | Stop. Paul must review before production deployment |

---

## Which Claude Code command to use

| You're trying to… | Use this command |
|-------------------|-----------------|
| Understand what depends on a component | `/sfdc-impact-analysis` |
| Score a change before building | `/sfdc-ric-scoring` |
| Add or modify a custom field | `/sfdc-field-management` |
| Build or change a Flow | `/sfdc-flow-builder` |
| Write a validation rule | `/sfdc-validation-rules` |
| Change a profile or permission set | `/sfdc-permissions` |
| Write or run a SOQL query | `/sfdc-soql` |
| Debug broken automation | `/sfdc-troubleshooting` |
| Touch the Outreach Stage / Cadence / Disposition cycle | `/bw-engagement-cycle` |
| Deploy from sandbox to production | `/sfdc-deployment-manager` |
| Diagnose a LeanData routing issue | `/leandata-routing` |

Not sure which to use? Just describe your task in plain English — Claude will invoke the right command automatically.

---

## Paul's review process

Paul reviews Yellow and Red changes before production deployment. To request review:

1. Tag Paul on the Asana task.
2. Paste the RIC score card output into the task comments.
3. Include a link to or screenshot of the `/sfdc-impact-analysis` output.

Paul does not need to be involved in Green changes unless you have a specific question.

---

## New admin onboarding

Before making any real changes, every new admin should:

1. Read this guide and [CLAUDE.md](../CLAUDE.md).
2. Open Claude Code and run `/sfdc-field-management` on a practice field in the sandbox.
3. Complete the full checklist (impact analysis, RIC score, change log entry) — even for the practice field.

This builds the habit before anything touches production.
