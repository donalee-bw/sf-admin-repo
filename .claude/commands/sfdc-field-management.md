Create and modify custom fields safely, with deduplication checks, proper naming, and field-level security.

## When to use

- Adding a new custom field to any object
- Modifying field type, length, formula, or picklist values
- Reviewing field-level security for existing fields

## Process

### 1. State the business need

Before creating a field, articulate: "This field captures [what data] because [business reason]. It will be used by [who/what]."

### 2. Check for existing fields

```bash
grep -r "[keyword]" force-app/main/default/objects/[ObjectName]/fields/
```

```bash
sf sobject describe --sobject [ObjectName] --target-org sandbox | grep -i "[keyword]"
```

If an existing field captures similar data, STOP. Propose consolidation instead of creating a new field. Document why consolidation is or isn't feasible.

### 3. Name the field

Convention: `Descriptive_Snake_Case__c`

The field name should be descriptive, consistent with existing field naming on the same object, and not abbreviated beyond recognition.

### 4. Choose the field type

| Type | When to use | Considerations |
|------|-------------|----------------|
| Text | Short free-text (names, codes) | Set appropriate length (default 255 is often too long) |
| Text Area (Long) | Notes, descriptions | Not filterable or groupable in reports |
| Number | Quantities, scores | Set decimal places explicitly |
| Currency | Money amounts | Respects org currency settings |
| Date / DateTime | Temporal data | DateTime includes time zone handling |
| Checkbox | Boolean flags | Default to unchecked (false) |
| Picklist | Controlled vocabulary | Prefer picklist over free text for categorical data |
| Lookup | Relationship to another object | Consider whether it should be Master-Detail |
| Formula | Derived/computed values | Read-only; test formula syntax before deploying |

### 5. Write description and help text

Every field must have:
- **Description**: What this field stores and why. Visible to admins in Setup.
- **Help text**: What the user should enter. Visible as a tooltip on the record page.

### 6. Set field-level security

Start with the **principle of least privilege**:
- Default: visible to System Administrator only
- Add visibility to specific Profiles or Permission Sets as documented in the business need
- Never grant edit access to all profiles by default

```bash
sf project retrieve start --metadata PermissionSet:[PS_Name] --target-org sandbox
```

### 7. Add to page layouts

Add the field to the relevant page layout sections. Consider:
- Which section of the layout is appropriate
- Whether the field should be required on the layout (vs. required via validation rule)
- Whether the field should appear on related list layouts

### 8. Deploy and verify

Follow `/sfdc-deployment`. After deploying to sandbox:
- Verify the field appears on the correct page layouts
- Verify field-level security restricts access as intended
- For formula fields: verify the formula returns correct values on sample records

## Anti-patterns

- Creating a new field when an existing one captures the same data
- Using free text where a picklist would enforce data quality
- Granting edit access to all profiles by default
- Missing description or help text
- Setting field length to 255 for a field that will never exceed 20 characters
- Creating formula fields without testing the formula syntax first
