# Salesforce Domain Context

This directory contains org-specific domain knowledge maintained by the Architect. Claude reads these files before every configuration change to apply domain-specific guardrails.

## File inventory

| File | Contents | TTL | Last refreshed |
|------|----------|-----|----------------|
| `object-model.md` | Objects, fields, relationships, custom objects, key data volumes | 90 days | _[Architect: update this date]_ |
| `business-processes.md` | Sales motions, pipeline stages, cadence logic, disposition lifecycle | 60 days | _[Architect: update this date]_ |
| `automation-inventory.md` | Active flows, triggers, validation rules, integrations, known fragile patterns | 30 days | _[Architect: update this date]_ |
| `field-reference.md` | Key custom fields, fill rates, hidden fields, consolidation constraints | 60 days | _[Architect: update this date]_ |
| `How-It-Works-Documentation/` | Process walkthroughs for specific automations and business workflows | 90 days | 2026-03-31 |

## How Claude uses these files

1. The safety and domain rules in `CLAUDE.md` read all files in this directory before any change.
2. The `/sfdc-impact-analysis` command checks for documented fragile patterns.
3. The `/sfdc-ric-scoring` command raises scores when changes touch documented sensitive areas.
4. The `/bw-engagement-cycle` command reads automation and process docs for cycle-specific context.

## How to maintain

- **The Architect owns this directory.** Admins and Claude read from it but never write to it.
- Update files when org configuration changes (new objects, new automation, retired processes).
- Update the "Last refreshed" dates in the table above after each refresh.
- If a file's age exceeds its TTL, Claude will warn admins that context may be stale.
- Add new files as needed. Claude reads all `.md` files in this directory.

## What to document

For each topic, focus on what an admin needs to know to avoid breaking things:

- **Fragile patterns**: Circular automation, tightly coupled flows, integration touchpoints
- **Field consolidation constraints**: Fields that overlap and should not be duplicated
- **Hidden fields**: Fields not visible in the UI but critical to data pipelines
- **Naming exceptions**: Any deviations from the standard naming conventions
- **Integration touchpoints**: External systems that read or write Salesforce data
- **Known tech debt**: Areas where the current configuration is suboptimal and changes require extra care
