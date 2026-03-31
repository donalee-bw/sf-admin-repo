Analyze dependencies and downstream effects before a Salesforce metadata change.

## When to use

- Before modifying or deleting any field, flow, validation rule, Apex class, or permission set
- Before renaming any metadata component
- Step 2 of the change management loop

## Inputs

Ask the admin to confirm or provide:
- **Component type**: field, flow, validation rule, Apex class, trigger, permission set, page layout
- **Component name**: API name (e.g., `Outreach_Stage__c`, `Lead_AfterUpdate_SetOutreachStage`)
- **Change type**: modify, delete, rename, deactivate

## Process

### 1. Retrieve latest metadata

```bash
sf project retrieve start --target-org sandbox --metadata [ComponentType]:[ComponentName]
```

If the component exists only in local source and hasn't been deployed, skip this step.

### 2. Search for references in the project

Search `force-app/` for all references to the component name across:

- **Flows** (`.flow-meta.xml`): field references in conditions, assignments, formulas, record lookups
- **Validation rules** (`.validationRule-meta.xml`): field references in formulas
- **Apex classes** (`.cls`): field and object references in SOQL, DML, property access
- **Apex triggers** (`.trigger`): field and object references
- **Page layouts** (`.layout-meta.xml`): field placement
- **Permission sets** (`.permissionset-meta.xml`): field-level security grants
- **Formula fields**: cross-object references

### 3. Check data population

For field changes, run a SOQL query to understand data impact:

```bash
sf data query --query "SELECT COUNT(Id) FROM [Object] WHERE [Field] != null" --target-org sandbox
```

Fields with >1,000 populated records should be flagged as higher impact.

### 4. Check domain context

Read `context/sfdc/` for any documented guardrails about this component:
- Is it part of a fragile automation cycle?
- Is it an integration touchpoint?
- Are there documented consolidation constraints?

### 5. Present the dependency table

```
## Impact Analysis: [Component Name]

Change type: [modify/delete/rename/deactivate]

### Dependencies

| Dependent component | Type | Relationship | Risk if changed |
|---------------------|------|-------------|-----------------|
| [name] | Flow | References field in condition | [would break / would need update / informational] |

### Data impact

- Records with data in this field: [count]
- Percentage of total records: [x%]

### Domain flags

- [any flags from context/sfdc/ files, or "None"]

### Summary

- Total dependents: [count]
- Would-break dependents: [count]
- Recommendation: [proceed with caution / update dependents first / escalate to Architect]
```

The output feeds directly into `/sfdc-ric-scoring`.
