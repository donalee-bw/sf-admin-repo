Score a proposed Salesforce change on Risk, Impact, and Complexity (1–5 each). The composite score routes the change to the right level of review.

## When to use

- After `/sfdc-impact-analysis` has produced a dependency table
- Step 3 of the change management loop

## Scoring dimensions

### Risk (R) — What could break?

| Score | Criteria |
|-------|----------|
| 1 | Additive-only, no dependencies. New report, new dashboard, new field with no automation. |
| 2 | Low-dependency modification. Page layout change, help text, field description. |
| 3 | Component with 3–4 dependents. Field used in a few flows or reports. |
| 4 | Automation/flows with cross-object effects. Components read by integrations. |
| 5 | Circular automation (e.g., engagement cycle). Permission model changes. Integration endpoints. |

### Impact (I) — Who or what is affected?

| Score | Criteria |
|-------|----------|
| 1 | Admin/internal visibility only. Reports, dashboards, list views. |
| 2 | Single team's workflow. One team's page layout or validation rule. |
| 3 | Multiple teams or >50 users affected. |
| 4 | Customer-facing processes or data integrity. Fields feeding external systems, conversion logic. |
| 5 | Revenue pipeline, compliance, or org-wide automation. Opportunity stages, lead routing, cadence logic. |

### Complexity (C) — How hard to implement and test?

| Score | Criteria |
|-------|----------|
| 1 | Single-component, declarative, no logic. Add a field, modify a layout. |
| 2 | Multi-component, declarative, simple logic. Validation rule with straightforward formula. |
| 3 | Multi-component with conditional logic. Flow with decision elements, cross-object formula fields. |
| 4 | Cross-object automation with timing/order dependencies. Record-triggered flows updating related records. |
| 5 | Multi-system change or Apex required. SF + external API, trigger + flow interaction, batch processing. |

## Routing

| Composite (R+I+C) | Zone | Action |
|--------------------|------|--------|
| 3–6 | **Green** | Admin proceeds autonomously. Document in change log. |
| 7–9 | **Yellow** | Admin proceeds. Architect notified async. Change log must include RIC score card. |
| 10–15 | **Red** | STOP. Present score card. Architect must review before production deployment. |

**Override rule**: Any single dimension at **5** forces the composite to **Yellow minimum**, regardless of other scores.

**When in doubt, round UP.** False positives (unnecessary architect review) are cheaper than false negatives (broken production).

## Output format

```
## RIC Score Card

| Dimension | Score | Rationale |
|-----------|-------|-----------|
| Risk | X/5 | [one sentence citing dependency count or pattern] |
| Impact | X/5 | [one sentence citing affected users or processes] |
| Complexity | X/5 | [one sentence citing component count or logic depth] |
| **Total** | **X/15** | **[Green/Yellow/Red]** |

Routing: [Admin proceeds / Architect notification required / Architect review required]
```

If Red, append:

```
### Architect review request

**Change summary**: [one sentence]
**Key risks**: [bulleted list of top concerns]
**Sandbox status**: [tested / not yet tested]
**Blocking question for Architect**: [specific question]
```

## Scoring from impact analysis data

Use `/sfdc-impact-analysis` output to drive scores:

- **Dependent count**: 0 = R1, 1–2 = R2, 3–4 = R3, 5+ = R4, circular/integration = R5
- **Would-break count**: 0 = no adjustment, 1+ = raise R by 1 (cap at 5)
- **Data population**: <100 records = no adjustment, 100–10K = raise I by 1, >10K = raise I by 2 (cap at 5)
- **Domain flags**: any flag from `context/sfdc/` raises the relevant dimension by 1
