Write and run SOQL queries with governor limit awareness and safety practices.

## When to use

- During impact analysis (checking field population, record counts)
- During deployment verification (confirming changes took effect)
- When troubleshooting data issues
- When the admin needs to explore or report on data

## Running queries

Always specify the target org:

```bash
sf data query --query "SELECT Id, Name FROM Account LIMIT 10" --target-org sandbox
```

For queries that return many rows, use `--result-format csv`:

```bash
sf data query --query "SELECT Id, Name FROM Account WHERE Type = 'Customer'" --target-org sandbox --result-format csv
```

## Safety rules

- ALWAYS add `WHERE` filters for exploratory queries. Never `SELECT * FROM Object` without a filter.
- ALWAYS add `LIMIT` for initial exploration. Start with `LIMIT 10`, increase as needed.
- Run against **sandbox** first. Only query production when sandbox data is insufficient.
- Never expose query results containing PII (email, phone, names) in logs or change documentation without redaction.

## Governor limits

| Limit | Value | Implication |
|-------|-------|-------------|
| Query row limit | 50,000 rows | Add `LIMIT` or narrow `WHERE` for large objects |
| Relationship queries | 20 per query | Avoid deeply nested sub-selects |
| Query timeout | 120 seconds | Use indexed fields in `WHERE` for large tables |

## Common patterns

### Count records

```sql
SELECT COUNT(Id) FROM Lead WHERE Outreach_Stage__c = 'Working'
```

### Check field population

```sql
SELECT COUNT(Id) FROM Lead WHERE Custom_Field__c != null
```

### Relationship queries

```sql
-- Owner details
SELECT Id, Name, Owner.Name, Owner.UserRole.Name FROM Lead LIMIT 10

-- Account relationship
SELECT Id, FirstName, LastName, Account.Name FROM Contact LIMIT 10
```

### Activity queries

```sql
SELECT Id, Subject, Type, Status, CreatedDate
FROM Task
WHERE WhoId = '00Q...'
AND IsDeleted = false
ORDER BY CreatedDate DESC
LIMIT 20
```

### Aggregate queries

```sql
SELECT Status, COUNT(Id) cnt
FROM Lead
GROUP BY Status
ORDER BY COUNT(Id) DESC
```

### Date filtering

```sql
-- SOQL date literals (no quotes needed)
SELECT Id, Name FROM Opportunity WHERE CreatedDate = THIS_MONTH
SELECT Id, Name FROM Lead WHERE LastModifiedDate > LAST_N_DAYS:30
```

## Org-specific patterns

Read `context/sfdc/` for org-specific query patterns:
- Object model documentation may include common join paths
- Field reference documentation may note hidden or critical fields
- Business process documentation may specify key status/stage field values

## Anti-patterns

- `SELECT Id FROM [Object]` without `WHERE` or `LIMIT` on objects with >10K records
- Nested sub-selects more than 2 levels deep
- Using non-indexed fields in `WHERE` on large objects (causes query timeout)
- Hardcoded record IDs in queries (use variables or query by name instead)
