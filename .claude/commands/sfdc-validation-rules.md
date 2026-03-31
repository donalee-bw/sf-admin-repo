Write and test Salesforce validation rules with proper null handling, data-first testing, and bypass mechanisms for data migrations.

## When to use

- Enforcing required fields conditionally (e.g., "require Capacity when dispositioning")
- Preventing invalid data combinations
- Replacing manual data quality checks with automated enforcement

## Process

### 1. Define the business rule in plain language

State the rule as: "A [Object] record should NOT be saved if [condition]."

The validation rule formula must evaluate to **TRUE to block** the save.

### 2. Name the rule

Convention: `VR_ObjectName_Purpose`

Example: `VR_Lead_RequireCapacityOnDisposition`

### 3. Write the formula

Always handle nulls first. Salesforce formulas behave unpredictably with null values.

```
AND(
  NOT(ISBLANK(Disposition__c)),
  ISBLANK(Capacity__c)
)
```

Pattern: `AND( [triggering condition is met], [required data is missing] )`

Common formula functions:
- `ISBLANK()` / `NOT(ISBLANK())` — null checking
- `ISPICKVAL(field, 'value')` — picklist comparison
- `TEXT(picklist_field)` — convert picklist to text for regex or contains
- `$Profile.Name` — user profile (for bypass logic)
- `$User.Bypass_Validation__c` — custom bypass checkbox (see step 5)

### 4. Test against existing data before activation

Check how many existing records would violate the new rule:

```bash
sf data query --query "SELECT COUNT(Id) FROM [Object] WHERE [condition that matches the rule]" --target-org sandbox
```

If >0 records would violate the rule:
- The rule will NOT retroactively block existing records (only blocks on save)
- But those records will fail if anyone edits and saves them for any reason
- Document this impact and decide whether to clean the data first or accept the risk

### 5. Document a bypass mechanism

For data migrations and bulk updates, validation rules need a bypass. Standard pattern:

1. Check if a `Bypass_Validation__c` checkbox already exists on the User object — if so, use it
2. If not, create one: custom checkbox on User, `Bypass_Validation__c`
3. Add to the formula: `AND( NOT($User.Bypass_Validation__c), [original formula] )`
4. Only System Administrators should have the ability to check this box
5. The box should be unchecked after migration completes

### 6. Write the error message

The error message should:
- Tell the user what is wrong (not just "Validation Error")
- Tell the user how to fix it
- Be placed on the relevant field (not at the page level) when possible

Example: "Capacity is required when dispositioning a lead. Please enter the center's licensed capacity."

### 7. Deploy and test

Follow `/sfdc-deployment`. Test both cases:
- Create/update a record that **violates** the rule → should be blocked with the error message
- Create/update a record that **passes** the rule → should save successfully
- If bypass exists: enable bypass, save a violating record → should save successfully

## Anti-patterns

- Validation rules without null handling (causes unexpected blocks on unrelated edits)
- Page-level error messages when a field-level message would be more helpful
- No bypass mechanism for data migrations
- Rules that are too strict for the current data quality (blocking all saves until legacy data is cleaned)
- Generic error messages like "Please fix the errors" with no guidance
