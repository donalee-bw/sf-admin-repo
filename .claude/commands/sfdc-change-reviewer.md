Review all proposed Salesforce metadata changes for impact, naming, safety, and domain risks before deployment. Produces a RIC score card that routes changes to the right level of review.

Use proactively before any `sf project deploy`, or when the admin asks for a change review.

## Context to read first

Read all files in `context/sfdc/` for domain-specific guardrails and fragile patterns.

## Process

### 1. Identify changed components

```bash
git diff --name-only HEAD
```

List modified metadata files under `force-app/`. Categorize each by component type (field, flow, validation rule, Apex, permission set, page layout).

### 2. Run impact analysis

For each changed component, follow the `/sfdc-impact-analysis` steps. Collect the dependency tables and domain flags.

### 3. Run RIC scoring

Follow `/sfdc-ric-scoring` using the aggregate impact data across all changed components. If multiple components are changed, score the change set as a whole — use the highest individual scores across dimensions.

### 4. Validate naming

Check each new or renamed component against naming conventions (see `force-app/CLAUDE.md`). List violations.

### 5. Check domain context

Read `context/sfdc/` for documented fragile areas. If any changed component touches a documented fragile pattern, flag it with a high-risk warning.

### 6. Produce the change review report

```
# Change Review — [Date]

## Components changed

| Component | Type | Change |
|-----------|------|--------|
| [API name] | [field/flow/...] | [added/modified/deleted] |

## Dependencies affected

| Changed component | Dependent | Type | Risk |
|-------------------|-----------|------|------|
| [name] | [name] | [flow/class/...] | [would break / needs update / informational] |

## RIC Score Card

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Risk | X/5 | [one sentence] |
| Impact | X/5 | [one sentence] |
| Complexity | X/5 | [one sentence] |
| **Total** | **X/15** | **[Green/Yellow/Red]** |

Routing: [Admin proceeds / Architect notification required / Architect review required]

## Naming violations

[List violations, or "None"]

## Domain flags

[Fragile patterns touched, or "None"]

## Recommendation

[Proceed / Fix issues first / Escalate to Architect]
```

## Rules

- Score conservatively. Round UP when in doubt.
- If the change set includes both low-risk and high-risk components, the overall score reflects the highest-risk component.
- Do not approve changes that violate safety guardrails regardless of RIC score.
- If `context/sfdc/` is empty or missing, note this as a gap but do not block Green-scored changes.
