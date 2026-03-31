# Automation Inventory

> **Architect**: Replace this placeholder with your org's automation inventory.
> Last refreshed: _[date]_

## Active flows

| Flow name | Type | Object | Trigger | Purpose | Dependencies |
|-----------|------|--------|---------|---------|-------------|
| _[name]_ | _[Record-Triggered/Screen/...]_ | _[object]_ | _[Before/After Save]_ | _[what it does]_ | _[what it depends on]_ |

## Active triggers

| Trigger name | Object | Events | Purpose |
|-------------|--------|--------|---------|
| _[name]_ | _[object]_ | _[before insert, after update, ...]_ | _[what it does]_ |

## Active validation rules

| Rule name | Object | Purpose | Bypass mechanism |
|-----------|--------|---------|------------------|
| _[name]_ | _[object]_ | _[what it enforces]_ | _[how to bypass for data migration]_ |

## Integrations

| System | Direction | Objects touched | Frequency | Contact |
|--------|-----------|-----------------|-----------|---------|
| _[system]_ | _[inbound/outbound/bidirectional]_ | _[objects]_ | _[real-time/daily/weekly]_ | _[who to ask]_ |

## Fragile patterns

Document any circular automation dependencies, tightly coupled flows, or automation that is known to break frequently.

### Pattern: _[Name]_

**Components involved**: _[list the flows, triggers, fields in the cycle]_

**How it works**:
```
[describe the dependency chain]
```

**Known failure modes**:
- _[failure mode 1]_
- _[failure mode 2]_

**Testing approach**: _[how to verify the full cycle works after a change]_

## Deprecated automation

List any Process Builders, Workflow Rules, or automation marked for retirement. Admins should not modify these — migrate to Flow instead.

| Component | Type | Object | Status | Notes |
|-----------|------|--------|--------|-------|
| _[name]_ | _[Process Builder/Workflow Rule]_ | _[object]_ | _[Active but deprecated]_ | _[migration plan]_ |
