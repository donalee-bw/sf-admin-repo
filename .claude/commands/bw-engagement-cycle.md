Brightwheel-specific guardrails for changes touching the Outreach Stage / Cadence / Disposition automation cycle.

Use when flows, fields, or automation reference `Outreach_Stage__c`, `Most_Recent_Disposition__c`, `Unqualified_Reason__c`, or cadence-related fields.

## The cycle

Read `context/sfdc/automation-inventory.md` and `context/sfdc/business-processes.md` for the current state of this cycle. The general pattern:

```
Outreach Stage determines → status of a Lead in a Cadence
Cadence steps produce    → Call/Email/SMS Tasks
Task outcomes set        → Most Recent Disposition
Disposition drives       → Outreach Stage update
Outreach Stage triggers  → Cadence exit/entry criteria
```

If any link in this chain breaks, leads either:
- Stay in a cadence they shouldn't be in (getting calls when they should be resting)
- Fall out of all cadences (going untouched until someone manually notices)

## Before making changes

### 1. Map the cycle path

Identify which link in the cycle the change affects:
- **Stage → Cadence**: Entry/exit criteria on cadence configurations
- **Cadence → Tasks**: Task generation logic in the cadence engine
- **Tasks → Disposition**: Dialer disposition field mapping
- **Disposition → Stage**: Flows or automation that update Outreach Stage from disposition values
- **Stage → Stage**: Flows that directly modify Outreach Stage based on other stage-related fields

### 2. Identify upstream and downstream

For the link being modified:
- What feeds INTO this link? Will those inputs still produce correct results?
- What consumes the OUTPUT of this link? Will downstream components still function?

### 3. Check for known failure modes

Verify the change does not introduce or exacerbate these documented failure patterns:

- **Stage not updating after disposition**: The flow that maps `Most_Recent_Disposition__c` to `Outreach_Stage__c` has a bug or missing condition
- **Lead stuck in cadence after recycling**: Cadence exit criteria don't fire when Outreach Stage changes to a recycle value
- **Stale data on re-entry**: `Unqualified_Reason__c` and recycle reason fields are not cleared when a lead re-enters the active pipeline
- **Manual override masking bugs**: `Manage_Stage_Update` allows reps to force the Outreach Stage, which can mask broken automation

### 4. Full-cycle test

In sandbox:
1. Create a test Lead with a known starting state
2. Trigger each step in the cycle through the change point
3. Verify the lead ends in the correct final state
4. Verify no side effects on other records

## RIC scoring impact

Any change touching this cycle should have:
- **Risk**: Minimum 4 (cross-object automation with circular dependency)
- **Impact**: Minimum 3 (affects multiple teams — SDRs, Sales Ops, data pipeline)
- **Complexity**: Score based on how many links in the cycle are affected

If the change touches **3+ links** in the cycle, escalate to the Architect regardless of RIC score.
