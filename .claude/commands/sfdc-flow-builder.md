Build and modify Salesforce Flows following best practices — fault handling, bulkification, and entry criteria scoping.

## When to use

- Creating a new flow
- Modifying an existing flow
- Migrating from Process Builder or Workflow Rules to Flow

## Process

### 1. Clarify the requirement

Before writing anything, establish:
- **Object**: Which object triggers or is affected by the flow?
- **Trigger**: When should it run? (record create, update, delete, screen action, schedule)
- **Logic**: What should happen? (update fields, create records, send notifications, call Apex)
- **Conditions**: Under what conditions should it run? (specific field values, record types, criteria)

### 2. Check for existing flows

```bash
ls force-app/main/default/flows/ | grep [ObjectName]
```

Also search for Process Builder and Workflow Rules on the same object — these may conflict:

```bash
grep -r "[ObjectName]" force-app/main/default/workflows/ 2>/dev/null
```

Multiple automation on the same trigger can cause order-of-execution issues.

### 3. Choose the flow type

| Type | When to use |
|------|-------------|
| Record-Triggered Flow (Before Save) | Field defaulting, validation-like logic, same-record updates |
| Record-Triggered Flow (After Save) | Cross-object updates, sending emails, creating related records |
| Screen Flow | User-facing forms, guided wizards, interactive processes |
| Autolaunched Flow | Called from other flows, Apex, or APIs |
| Scheduled Flow | Time-based batch processing |

Prefer **Before Save** for same-record field updates (no DML, better performance).

### 4. Build the flow

Name per convention: `ObjectName_TriggerType_Purpose`

Required elements:
- **Entry criteria**: Scope the flow narrowly. Never run on every record update — specify which field changes trigger the flow.
- **Fault paths**: Every DML or external callout element must have a fault connector. Fault paths should log the error (create a Task, send an email to admin, or log to a custom object).
- **Bulkification**: Flows run per-batch, not per-record. Avoid SOQL or DML inside loops. Use collection variables and batch DML elements.

### 5. Validate

Before deploying, check:
- [ ] Entry criteria are specific (not "every update")
- [ ] Fault paths exist for all DML and callout elements
- [ ] No SOQL or DML inside loops
- [ ] No hardcoded record IDs
- [ ] No Process Builder or Workflow Rules that could conflict
- [ ] Flow is named per convention

### 6. Deploy and test

Follow `/sfdc-deployment`. Test by creating/updating records that match and don't match the entry criteria. Verify:
- Flow fires when it should
- Flow does NOT fire when it shouldn't
- Fault paths handle errors gracefully

## Domain context

Read `context/sfdc/` before building flows. Check `automation-inventory.md` for documented fragile patterns. If the flow touches the engagement cycle, also run `/bw-engagement-cycle`.

## Anti-patterns

- **Missing fault paths**: Silent failures are the top cause of automation support tickets
- **Overly broad entry criteria**: Running on every update wastes governor limits and causes unintended side effects
- **Process Builder**: Deprecated. All new automation should use Flow. Migrate existing Process Builders when modifying them.
- **Workflow Rules**: Deprecated. Same guidance as Process Builder.
- **DML in loops**: Causes governor limit failures on bulk operations
- **Recursive flows**: Flow A updates Object X → Flow B updates Object X → Flow A fires again. Guard with entry criteria that prevent re-entry.
