# Field Reference

> **Architect**: Replace this placeholder with your org's key field documentation.
> Last refreshed: _[date]_

## Critical fields

Fields that are especially important, fragile, or commonly misunderstood.

| Object | Field | Type | Fill rate | Why it matters |
|--------|-------|------|-----------|----------------|
| _[object]_ | _[field]_ | _[type]_ | _[x%]_ | _[why admins need to know about this]_ |

## Hidden fields

Fields that exist in the data model but are not exposed in the standard UI. These often contain critical data that pipelines or integrations depend on.

| Object | Field | Why hidden | What it contains | Do not modify without |
|--------|-------|-----------|------------------|----------------------|
| _[object]_ | _[field]_ | _[reason]_ | _[what data]_ | _[who to consult]_ |

## Consolidation constraints

Groups of fields that overlap and should NOT be expanded further. If an admin needs to capture similar data, direct them to one of the existing fields or propose consolidation.

### _[Group name]_

| Field | Fill rate | Notes |
|-------|-----------|-------|
| _[field 1]_ | _[x%]_ | _[notes]_ |
| _[field 2]_ | _[x%]_ | _[notes]_ |

**Guidance**: _[which field to use, which to deprecate, or consolidation plan]_

## Low-fill fields

Fields with <5% fill rate that may be candidates for retirement or re-purposing.

| Object | Field | Fill rate | Recommendation |
|--------|-------|-----------|----------------|
| _[object]_ | _[field]_ | _[x%]_ | _[keep/retire/repurpose]_ |

## Naming exceptions

Fields that don't follow standard naming conventions but should not be renamed (due to integration dependencies, historical usage, etc.).

| Field | Why it's an exception |
|-------|----------------------|
| _[field]_ | _[reason]_ |
