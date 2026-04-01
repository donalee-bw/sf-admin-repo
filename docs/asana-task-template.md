# Asana Config Change Task Template

Copy the content below into the description field of your Asana config change task template.

---

## Template: Salesforce Configuration Change

**What are you changing?**
_(One sentence: what component, what is changing, and why)_

**Linked ticket / request:**
_(Paste the Slack message link, email thread, or stakeholder request here)_

---

## Claude Code checklist

Complete these steps before moving this task to "Ready for Review".

- [ ] Opened Claude Code and described the change
- [ ] Ran `/sfdc-impact-analysis` — paste output or screenshot below
- [ ] Ran `/sfdc-ric-scoring` — RIC score: R__ I__ C__ = __ (Green / Yellow / Red)
- [ ] Change log entry drafted in `change-log/` in the repo
- [ ] Paul tagged on this task _(required if Yellow or Red)_

**Impact analysis output:**
_(Paste or screenshot here)_

**RIC score card:**
_(Paste here)_

---

## Deployment status

- [ ] Built and tested in sandbox
- [ ] Sandbox verification notes: _(what you checked, what passed)_
- [ ] Approved for production _(Paul signs off if Yellow or Red)_
- [ ] Deployed to production
- [ ] Production verified

---

## Rollback plan

_(If something goes wrong in production, how do we revert? One or two sentences is fine for simple changes.)_
