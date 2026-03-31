Debug broken Salesforce automation, stuck records, and configuration issues with systematic root cause analysis.

## When to use

- Flow errors or failures
- Records stuck in an unexpected state
- Automation not firing when it should (or firing when it shouldn't)
- Users reporting errors on save
- Data quality issues with no obvious cause

## Process

### 1. Identify the symptom

Get specific details:
- What is the user seeing? (error message, unexpected behavior, missing data)
- Which record(s) are affected? (specific IDs, or a pattern like "all leads assigned today")
- When did it start? (date/time helps correlate with recent changes)
- Is it reproducible? (every time, intermittent, one-time)

### 2. Check recent changes

```bash
git log --oneline -20 -- force-app/
```

Correlate the symptom start date with recent deployments. Also check the Salesforce Setup Audit Trail (Setup > Security > View Setup Audit Trail) for changes made directly in the UI.

### 3. Trace the data flow

Query the affected record:

```bash
sf data query --query "SELECT Id, [all relevant fields] FROM [Object] WHERE Id = '[record_id]'" --target-org sandbox
```

For automation issues, check:
- What are the current field values? Do they match what the automation expects?
- When was the record last modified? By whom?
- Are there related records that should exist but don't?

### 4. Check automation execution

**Flow failures:**
- Salesforce Setup > Automation > Paused and Failed Flow Interviews
- Look for the specific flow and error message
- Common causes: null pointer (field reference on a null record), governor limits, unhandled fault paths

**Flow execution order (when multiple flows exist):**
1. Before-save flows (in unspecified order)
2. Validation rules
3. After-save flows (in unspecified order)
4. Assignment rules, auto-response rules
5. Workflow rules (legacy)
6. Process Builder (legacy)

### 5. Check for conflicting automation

```bash
grep -rl "[ObjectName]" force-app/main/default/flows/
grep -rl "[ObjectName]" force-app/main/default/triggers/
grep -rl "[ObjectName]" force-app/main/default/workflows/ 2>/dev/null
```

### 6. Identify root cause

Common root causes:
- **Missing entry criteria**: Flow runs on every update instead of specific field changes
- **Null reference**: Flow element references a field on a null related record
- **Order of execution**: Before-save flow sets a value, but after-save flow overwrites it
- **Recursive flow**: Flow updates a record, which triggers the same flow again
- **Data quality**: Field values don't match what automation expects (stale picklist values, empty required fields)
- **Permission issue**: Flow runs in system context but the user's field-level security hides the result

### 7. Fix and test

- Propose the fix and run `/sfdc-impact-analysis` before implementing
- Test the fix in sandbox with the specific failing scenario
- Verify the fix doesn't break other scenarios
- Follow `/sfdc-deployment` for production deployment

## Domain context

Read `context/sfdc/` before troubleshooting. The `automation-inventory.md` may document known fragile patterns and their common failure modes.

If the issue involves the engagement cycle, also run `/bw-engagement-cycle` for domain-specific troubleshooting steps.

## Common Salesforce error messages

| Error | Likely cause |
|-------|-------------|
| `FIELD_CUSTOM_VALIDATION_EXCEPTION` | Validation rule blocking the save |
| `CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY` | Trigger or flow error during DML |
| `ENTITY_IS_DELETED` | Attempting to update a deleted record |
| `DUPLICATE_VALUE` | Unique field constraint violated |
| `REQUIRED_FIELD_MISSING` | Required field not populated (check page layout vs. field definition) |
| `INSUFFICIENT_ACCESS_OR_READONLY` | Field-level security or sharing rule blocking access |
| `STRING_TOO_LONG` | Field value exceeds max length |
