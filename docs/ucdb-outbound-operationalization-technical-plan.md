# UCDB → Salesforce Outbound Sales Operationalization
## Technical Project Plan

**Author:** Donalee Jones (SysOps)  
**Architect:** Josepf Presti  
**Last Updated:** April 9, 2026  
**Status:** Draft — Pending Stakeholder Review

---

## Table of Contents

1. [Project Context & Settled Decisions](#1-project-context--settled-decisions)
2. [Solution Overview: Option 2](#2-solution-overview-option-2)
3. [Data Model](#3-data-model)
4. [Opportunity Configuration](#4-opportunity-configuration)
5. [Contact-to-Opportunity Relationship](#5-contact-to-opportunity-relationship)
6. [Disposition → Opportunity Stage Automation](#6-disposition--opportunity-stage-automation)
7. [Closed Lost: Recycled vs. Unqualified](#7-closed-lost-recycled-vs-unqualified)
8. [Account Configuration](#8-account-configuration)
9. [Inbound Workflow Change](#9-inbound-workflow-change)
10. [Automation Audit: Existing Components](#10-automation-audit-existing-components)
11. [UCDB / Fivetran Integration](#11-ucdb--fivetran-integration)
12. [Pre-Existing Issues to Resolve Before Build](#12-pre-existing-issues-to-resolve-before-build)
13. [Open Questions](#13-open-questions)
14. [Full Build List & Effort Estimates](#14-full-build-list--effort-estimates)
15. [Risks & Dependencies](#15-risks--dependencies)

---

## 1. Project Context & Settled Decisions

The following decisions have been made and are not re-opened by this document.

| Decision | Detail |
|---|---|
| Data model | Option D — UCDB entities map 1:1 to Salesforce objects: Org → Parent Account, Center → Child Account, Person → Contact |
| Outbound operationalization path | Option B — Contact/Account model. UCDB is the source of truth for outbound distribution. Leads are converted into Parent Account + Child Account + Contact + Opportunity. |
| Inbound workflow | Leads continue to arrive from HubSpot/web forms and are worked as Leads. For inbound/outbound parity, reps will manually convert their Lead into an Account + Contact + Opportunity at the point of assignment (not at demo). The volume of dependent automations at the top of the inbound funnel makes auto-conversion out of scope. |
| Outbound solution | **Option 2: Full Cycle in the Opportunity.** An Opportunity is automatically created on the Child Account at the moment of outbound distribution. The Opportunity tracks the entire outreach cycle end-to-end from first attempt through close. |

---

## 2. Solution Overview: Option 2

### How It Works

When UCDB distributes a center to an outbound rep, a SaaS Opportunity is automatically created on the Child Account (center). The Opportunity tracks the full outbound sales cycle — from first call attempt through connection, DM reached, demo, and close. All meaningful milestones and activity live on the Opportunity from day one.

Outbound reps work through Contacts on the Child Account. Call activity logged via RingDNA/Revio automatically advances the Opportunity stage based on the call disposition. Reps do not need to manually manage the Opportunity stage for most transitions.

Separately, inbound reps are asked to manually convert their Lead into an Account + Contact + Opportunity at the point of assignment. This brings inbound to parity with outbound on the same object model.

### Outbound Flow

```
UCDB Distributes Center
  → Child Account assigned to rep
    → Opportunity auto-created (StageName: Assigned)
      → Rep works Contacts on Account
        → Call dispositions auto-advance Opp stage
          → Demo Scheduled
            → Opp advances to Close
              → Closed Won → Onboarding
              → Recycled → Account enters resting period, UCDB re-queues
              → Closed Lost → Account marked Unqualified, UCDB excludes
```

### Key Design Decisions Made During Planning

| Decision | Rationale |
|---|---|
| Use existing SaaS Opportunity record type (not a new Outbound record type) | Unified reporting surface; existing post-CW onboarding automation (Combined Funnel, Onboarding records) fires correctly for outbound CW without additional wiring |
| Track inbound vs. outbound via `Inbound_or_Outbound__c` field (not rep role) | `Inbound_or_Outbound__c` is stamped at creation and survives ownership changes; rep role is mutable |
| Auto-create Contact Roles for all Account Contacts at Opp creation | Gives reps a native view of all center contacts on the Opportunity record |
| Route automation via Account → Opp lookup (not Contact Role lookup) | Simpler, more resilient; covers contacts added after Opp creation; pattern already used by existing flows |
| Separate Recycled and Closed Lost as distinct terminal Opportunity stages | They trigger fundamentally different downstream behavior: Recycled = UCDB re-queues; Closed Lost = permanent exclusion |

---

## 3. Data Model

### Object Mapping (UCDB → Salesforce)

| UCDB Entity | Salesforce Object | Notes |
|---|---|---|
| Organization (franchise group / single-site owner) | **Parent Account** | Top of the Account hierarchy |
| Center (physical location) | **Child Account** | What the rep is assigned; where the Opp lives |
| Person (owner, director, admin) | **Contact** | Multiple Contacts per Child Account; roles from UCDB |
| Distribution event | **Opportunity** (auto-created) | SaaS record type; created at distribution; tracks full cycle |

### Object Relationships

```
Parent Account (Org)
  └── Child Account (Center)          ← Rep assigned here
        ├── Contact (Owner)           ← Contact Roles on Opp
        ├── Contact (Director)        ← Contact Roles on Opp
        ├── Contact (Admin)           ← Contact Roles on Opp
        └── Opportunity (SaaS)        ← Full cycle tracked here
              └── Activities / Tasks  ← Call dispositions drive Opp stage
```

**One open outbound Opportunity per Child Account at any time.** When a center is recycled and re-distributed, the prior Opportunity must be closed (Recycled stage) before a new one is created. This is enforced in the Opp auto-creation flow.

---

## 4. Opportunity Configuration

### 4.1 Stage Picklist

The following stages are to be added to the existing SaaS Opportunity stage picklist. Existing stages remain unchanged.

**New stages (pre-demo, outbound-specific):**

| Stage | Description | Auto-set by | Forecast Category |
|---|---|---|---|
| Assigned | Opp auto-created at distribution | Auto-creation flow | Omitted |
| Connected | Rep reached someone at the center (not DM) | Disposition: `CC - Not Yet Qualified - Qualifying Soon` or any other `CC -` | Pipeline |
| DM Reached | Decision maker reached and pitched | Disposition: `CC - Pitched DM (Follow Up Task)` | Pipeline |
| Demo Scheduled | Demo booked | Disposition: `CC - Demo*` (not Cancelled/Confirmed); also stamps `Demo_Call_Scheduled__c` | Pipeline |
| Rescheduling | Demo was cancelled, awaiting new date | Disposition: `CC - Demo Cancelled` | Pipeline |
| **Recycled** | Center will be re-distributed after a waiting period | Rep action or disposition: `REC -` | Omitted |

**Existing stages retained for outbound use:**

| Stage | Outbound use |
|---|---|
| Awaiting Decision | Post-demo, awaiting rep's decision call |
| Verbal Agreement | Verbal commitment received |
| Closed Won | Deal closed; triggers onboarding automation |
| Closed Lost | Permanent disqualification (Unqualified) |

**Picklist guard:** A validation rule (`VR_Opportunity_OutboundStageRequiresFlag`) will block saving an Opp to pre-demo outbound stages (`Assigned`, `Connected`, `DM Reached`, `Recycled`) if `Inbound_or_Outbound__c != 'Outbound'`. This prevents inbound reps from accidentally using outbound-only stages during the transition period.

### 4.2 New Opportunity Fields

| Field API Name | Type | Purpose |
|---|---|---|
| `Recycle_Reason__c` | Picklist | Sub-reason when StageName = Recycled; drives Account wait period via CMT lookup |
| `Inbound_or_Outbound__c` | Picklist (existing) | Stamped at creation: `Outbound` (auto-create flow) or `Inbound` (manual conversion). **Do not rely on current rep role for this.** |

**`Recycle_Reason__c` picklist values:**
- No Budget
- Not Ready
- Not Responding — No Contact Made
- Not Responding — Spoke to Non-DM
- Not Responding — Spoke to DM (Did Not Pitch)
- Using Competitor
- Features Request
- Non Primary Contact
- Not Yet Qualified

### 4.3 Existing Opportunity Fields Affected

| Field | Current behavior | Required change |
|---|---|---|
| `Closed_Lost_Reason__c` | Post-demo close reasons | Add outbound Unqualified sub-reasons (see Section 7) |
| `First_Meeting_Held__c` | Stamped when `StageName = Closed Won` | **Change to stamp when `StageName` transitions to `Demo Scheduled`**. The demo is the first meeting in the outbound cycle. The existing flow (`Opportunity_Before_Save_Record_Updated_Update_Opp_Fields`) handles this; update trigger condition. |
| `Demo_Call_Scheduled__c` | Stamps date when changed | Stamp this field when Opp moves to `Demo Scheduled`; already partially handled by the existing Before Save flow |
| `Inbound_or_Outbound__c` | Set in EC Opp subflow only | Must be set by: (1) outbound auto-creation flow = `Outbound`; (2) inbound manual conversion = `Inbound` |

### 4.4 Validation Rules

| Rule | Logic | Purpose |
|---|---|---|
| `VR_Opportunity_OutboundStageRequiresFlag` | If `StageName IN (Assigned, Connected, DM Reached, Recycled)` AND `Inbound_or_Outbound__c != 'Outbound'` → Error | Prevents inbound reps using outbound stages during transition |
| `VR_Opportunity_RecycledRequiresReason` | If `StageName = 'Recycled'` AND `Recycle_Reason__c` is blank → Error | Ensures reason is captured before Opp closes; required for Account update and UCDB signal |
| `VR_Opportunity_OutboundCLRequiresReason` | If `StageName = 'Closed Lost'` AND `Inbound_or_Outbound__c = 'Outbound'` AND `Closed_Lost_Reason__c` is blank → Error | Same; ensures Unqualified reason is captured |
| `VR_Opportunity_FeaturesRequestRequiresDate` | If `Recycle_Reason__c = 'Features Request'` AND `Resell_Eligible_Date__c` is blank → Error | Features Request requires a manual re-engage date (no fixed wait period) |

### 4.5 Path Assistant Update

The existing `Default_Opportunity` Path Assistant is tied to the `__MASTER__` record type and only covers Closed Lost, Closed Won, and Verbal Agreement steps. Since all outbound and inbound Opps use the **SaaS record type**, the Path Assistant for SaaS should be updated (or created if one does not yet exist for that record type) to include guidance for the new stages. No new record type is required.

Stages to add or update in the SaaS Path Assistant:

- **Demo Scheduled** step: prompt for `Demo_Call_Scheduled__c`, `Contact__c` (primary demo contact)
- **Recycled** step: prompt for `Recycle_Reason__c`; if Features Request, prompt for `Resell_Eligible_Date__c`
- **Closed Lost** step: prompt for `Closed_Lost_Reason__c`
- **Closed Won** step: existing prompts (`Amount`, `OBS_Owner__c`, `Names_and_Roles_of_Implementers__c`, etc.) — confirm all required CW fields are populated by outbound reps before close; the existing SaaS CW flow (`Opportunity_SaaS_CW_After_Save_Create_Combined_Funnel_and_Onboarding_Records`) reads these fields at Closed Won to create onboarding records

---

## 5. Contact-to-Opportunity Relationship

### 5.1 Design Principle: Separate Rep UX from Automation Routing

Contact Roles (what reps and managers see on the Opp record) and automation routing (how the system finds the right Opp when a call disposition is logged) are distinct concerns and configured differently.

### 5.2 Contact Roles — Auto-Create at Opp Creation

When an outbound Opp is auto-created, query all Contacts on the Child Account and bulk-create `OpportunityContactRole` records. For a childcare center, this is typically 2–5 contacts — record volume is not a concern.

The existing `Opportunity_Create_Contact_Role_on_Opp_Creation` flow creates a role for only one Contact and should be extended to handle multiple Contacts at creation.

**Ongoing: new Contacts added post-creation**

A Contact After-Save flow (`Contact_After_Save_Create_Role_on_Outbound_Opp`) should handle contacts added mid-cycle: when a new Contact is created on an Account that has an open outbound SaaS Opp, auto-create a Contact Role on that Opp. This covers new contacts discovered as reps work the account.

### 5.3 Automation Routing — Account → Opp Lookup

For the Task disposition → Opp stage logic, the flow resolves the Opportunity by:

```
Task.WhoId (Contact) → Contact.AccountId → Opportunity
  WHERE AccountId = Contact.AccountId
  AND Inbound_or_Outbound__c = 'Outbound'
  AND IsClosed = false
```

This approach is simpler than a Contact Role join, works for any Contact on the Account regardless of whether a Contact Role has been created yet, and is already the pattern used by the existing `CL_ALA_REC_or_UNQ_Contact_Update_Open_SaaS_Opp_to_CL` flow.

**Target state (RingDNA configuration):** Configure RingDNA to log outbound call tasks with `WhatId = Opportunity` when reps call from the Opportunity view. This enables direct Opp update from the Task without the Contact lookup, and is the cleanest long-term architecture. The Account → Opp lookup path serves as the fallback during the transition.

### 5.4 Opp Deduplication Guard

The Opp auto-creation flow must check for an existing open outbound Opp on the Child Account before creating a new one. If one exists, do not create a duplicate — alert the assigning user instead. This keeps the Account → Opp lookup unambiguous (one open outbound Opp per center at a time).

---

## 6. Disposition → Opportunity Stage Automation

### 6.1 How the Current Chain Works

```
RingDNA/Revio call logged
  → Task.Disposition__c changes
    → Task_After_Save_Disposition_Handling (Active)
        → writes Contact.Most_Recent_Disposition__c
          → Contact_Updates_Before_Save_Flow (currently Obsolete — see Section 12)
              → maps disposition prefix to Contact.Outreach_stage__c
```

Under Option 2, the chain is extended to also update `Opportunity.StageName` directly, bypassing Contact Outreach Stage as the intermediary.

### 6.2 Disposition → Opportunity Stage Mapping

| Disposition value / prefix | Current Contact stage | Opportunity stage (Option 2) | Notes |
|---|---|---|---|
| `NA -` (No Answer) | Working | **No change** | Activity-level event; do not advance Opp on no-answers |
| `CC - Not Yet Qualified - Qualifying Soon` | Connected | **Connected** | Early connection, not DM |
| Any other `CC -` | Working | **Connected** | Any call connected = minimum Connected |
| `CC - Pitched DM (Follow Up Task)` | Connected | **DM Reached** | Decision maker reached; maps to a distinct Opp stage |
| `CC - Demo*` (not Cancelled/Confirmed) | Demo Scheduled | **Demo Scheduled** | Also stamps `Demo_Call_Scheduled__c` and `First_Meeting_Held__c` |
| `CC - Demo Confirmed` | Demo Confirmed | **Demo Scheduled** | No separate Opp stage; `Demo_Call_Scheduled__c` covers confirmation |
| `CC - Demo Cancelled` | Demo Missed | **Rescheduling** | Stays in pipeline; not a loss |
| `REC -` (any Recycle prefix) | Recycled - [sub-reason] | **Recycled** | Terminal; stamps `Recycle_Reason__c` from sub-reason; triggers Account update |
| `UNQ -` (any Unqualified prefix) | Unqualified - [sub-reason] | **Closed Lost** | Permanent disqualification; stamps `Closed_Lost_Reason__c` |

### 6.3 Forward-Only Stage Progression

Opportunity stages must only advance forward. A Contact can regress (e.g., Connected → no-answer → Working on the Contact Outreach Stage), but the Opportunity must not. The automation includes a stage ordinal guard:

```
Stage ordinal:
1 = Assigned
2 = Connected
3 = DM Reached
4 = Demo Scheduled / Rescheduling
5 = Awaiting Decision
6 = Verbal Agreement
7 = Closed Won / Recycled / Closed Lost
```

Only update `Opportunity.StageName` if the proposed new stage ordinal is greater than the current stage ordinal. This is enforced as a decision node within the automation flow.

### 6.4 New Automation Components

**`Task_After_Save_Update_Outbound_Opp_Stage`** (new After-Save flow on Task, or extension of existing `Task_After_Save_Disposition_Handling`)

Entry criteria: `Task.Disposition__c` is changed AND (`WhatId` starts with `006` OR `WhoId` starts with `003`)

Logic:
1. If `WhatId` starts with `006` (Opportunity) → update Opp directly
2. Else: `WhoId` → Contact → Account → open outbound SaaS Opp (via Account → Opp lookup)
3. Apply disposition-to-stage mapping (Section 6.2)
4. Apply forward-only ordinal guard
5. Update `Opportunity.StageName` and any relevant stamp fields

**`Contact_After_Save_Create_Role_on_Outbound_Opp`** (new After-Save flow on Contact)

Entry criteria: Contact is created or `AccountId` changes AND Account has an open outbound SaaS Opp

Logic: Create `OpportunityContactRole` if one doesn't already exist for this Contact on the open Opp

### 6.5 Contact Outreach Stage: Demoted, Not Removed

`Contact.Outreach_stage__c` continues to run via `Contact_Updates_Before_Save_Flow`. It remains as a secondary field on the Contact record for rep context (call-by-call activity view) but is no longer the source of truth for tracking the sales cycle or driving downstream automation. Cadence exits, recycling signals, and UCDB triggers all move to `Opportunity.StageName`.

---

## 7. Closed Lost: Recycled vs. Unqualified

### 7.1 Two Distinct Terminal States

Recycled and Unqualified are separate Opportunity stage values because they trigger fundamentally different behavior:

| | Recycled | Closed Lost (Unqualified) |
|---|---|---|
| UCDB behavior | Re-queue after a waiting period | Permanently exclude |
| `Resell_Eligible_Date__c` | Set to future date (reason-driven) | Null — no re-distribution |
| Account status | `Outbound_Distribution_Status__c = Recycled` | `Outbound_Distribution_Status__c = Unqualified` |
| Can be re-distributed? | Yes, when eligibility date passes | No — requires admin override |
| Automation trigger | `Opportunity_After_Save_Outbound_Recycled_Account_Update` | `Opportunity_After_Save_Outbound_Unqualified_Account_Update` |

### 7.2 Opportunity Fields for Terminal States

| Field | Type | Stage it applies to | Purpose |
|---|---|---|---|
| `Recycle_Reason__c` | Picklist (new) | Recycled | Sub-reason; drives Account wait period via CMT; required by validation rule |
| `Closed_Lost_Reason__c` | Picklist (existing — extend) | Closed Lost | Permanent disqualification reason; required by validation rule for outbound |

**`Closed_Lost_Reason__c` values to add for outbound Unqualified:**
- Under Capacity (<10 children)
- Non-Target Market
- International
- Language Barrier
- Out of Business
- Do Not Contact
- Existing Customer
- Public School — No Headstart
- Enterprise

### 7.3 Custom Metadata Type: Recycle Wait Periods

The current automation hardcodes a 90-day resting period for all closed-lost accounts regardless of reason. Option 2 requires reason-specific wait periods that can be adjusted without editing flows.

**New Custom Metadata Type: `Outbound_Recycle_Period__mdt`**

Fields:
- `Recycle_Reason__c` (Text) — matches `Recycle_Reason__c` picklist value
- `Wait_Days__c` (Number) — days until eligible for redistribution
- `Manual_Date_Required__c` (Checkbox) — when true, rep must enter date manually

**Initial records:**

| Reason | Wait Days | Manual Date? |
|---|---|---|
| No Budget | 90 | No |
| Not Ready | 60 | No |
| Using Competitor | 180 | No |
| Features Request | — | Yes |
| Non Primary Contact | 30 | No |
| Not Responding — No Contact Made | 45 | No |
| Not Responding — Spoke to Non-DM | 60 | No |
| Not Responding — Spoke to DM (Did Not Pitch) | 75 | No |
| Not Yet Qualified | 60 | No |

### 7.4 Terminal State Automation Flows (New)

**`Opportunity_After_Save_Outbound_Recycled_Account_Update`**

Trigger: Outbound SaaS Opp, `StageName` changes to `Recycled`

Actions:
- Query `Outbound_Recycle_Period__mdt` by `Recycle_Reason__c`
- Set `Account.Resell_Eligible_Date__c = TODAY() + Wait_Days__c` (skip if `Manual_Date_Required__c = true`)
- Set `Account.Outbound_Distribution_Status__c = 'Recycled'`
- Stamp `Account.Outbound_Recycle_Reason__c` from Opp
- Set `Account.Last_Recycled_Date__c = TODAY()`
- Increment `Account.Recycle_Count__c + 1`
- Set `Account.Last_Inactive_Date__c = TODAY()`
- Move Account owner to Account Queue (via `Account_Queue` Custom Label — not hardcoded ID)
- Move related Contact owners to Account Queue
- Exit any active cadences on related Contacts

---

**`Opportunity_After_Save_Outbound_Unqualified_Account_Update`**

Trigger: Outbound SaaS Opp, `StageName` changes to `Closed Lost`

Actions:
- Set `Account.Outbound_Distribution_Status__c = 'Unqualified'`
- Stamp `Account.Outbound_Unqualified_Reason__c` from `Opp.Closed_Lost_Reason__c`
- Set `Account.Resell_Eligible_Date__c = NULL`
- Set `Account.Last_Inactive_Date__c = TODAY()`
- Move Account owner to Account Queue (via Custom Label)
- Move related Contact owners to Account Queue
- Exit any active cadences on related Contacts

---

**`Account_After_Save_Org_Level_DQ_Close_Child_Opps`**

Trigger: Parent Account, `Org_Outbound_Status__c` changes to `Unqualified`

Actions:
- Get all Child Accounts under this Parent Account
- Get all open outbound SaaS Opps on those Child Accounts
- Bulk update Opps: `StageName = 'Closed Lost'`, `Closed_Lost_Reason__c = 'Org-Level Disqualification'`
- Update each Child Account: `Outbound_Distribution_Status__c = 'Unqualified'`, `Outbound_Unqualified_Reason__c` from Parent
- **Note:** If the org has a large number of child accounts, this may need to be implemented as an invocable Apex batch to avoid governor limits. Scope with Donalee/Paul before build.

---

## 8. Account Configuration

### 8.1 Child Account (Center-Level) — New Fields

| Field API Name | Type | Purpose | UCDB reads? |
|---|---|---|---|
| `Outbound_Distribution_Status__c` | Picklist | Primary status field: `Active`, `Recycled`, `Unqualified`, `Never Distributed` | **Yes — primary signal** |
| `Outbound_Recycle_Reason__c` | Picklist | Why center was recycled; mirrors `Recycle_Reason__c` on Opp | Yes — for context |
| `Outbound_Unqualified_Reason__c` | Picklist | Why center is permanently excluded; mirrors `Closed_Lost_Reason__c` | Yes — for context |
| `Recycle_Count__c` | Number | How many times this center has been recycled | Optional — for UCDB scoring |
| `Last_Recycled_Date__c` | Date | When the most recent recycle occurred (historical) | No — internal reporting |

**Existing fields retained for Option 2:**

| Field | Option 2 use |
|---|---|
| `Resell_Eligible_Date__c` | Set to reason-specific future date on Recycled; null on Unqualified. **UCDB reads this as the re-distribution eligibility date.** |
| `Last_Inactive_Date__c` | Set to TODAY() on both Recycled and Unqualified |
| `Last_Transfer_Date__c` | Set to TODAY() on terminal state |
| `Account.Type` | Set to `Inactive Prospect` on both Recycled and Unqualified |

**Enable field history tracking on:** `Outbound_Distribution_Status__c`, `Resell_Eligible_Date__c`

### 8.2 Parent Account (Org-Level) — New Fields

| Field API Name | Type | Purpose |
|---|---|---|
| `Org_Outbound_Status__c` | Picklist | `Active`, `Unqualified` — set when the entire organization is disqualified |
| `Org_Unqualified_Reason__c` | Picklist | Why the org is permanently excluded (e.g., Signed with Competitor, Enterprise, Out of Business) |
| `Org_Unqualified_Date__c` | Date | When org-level disqualification was applied |

**Org-level DQ process note:** Setting `Org_Outbound_Status__c = Unqualified` on a Parent Account triggers the `Account_After_Save_Org_Level_DQ_Close_Child_Opps` flow, which cascades the disqualification to all Child Accounts and closes all open outbound Opps. Define who has permission to set this field — recommend restricting to Sales Ops or Admin profiles.

### 8.3 Unqualified Override Process

When a center or org marked as Unqualified needs to be re-evaluated (e.g., a center that was under capacity has grown), a defined override process must exist before go-live:

- Define who can reset `Outbound_Distribution_Status__c` from `Unqualified` back to `Active`
- Recommended: a Screen Flow that requires a manager to enter a justification before clearing the flag
- Minimum: field-level security restricting edit access to Sales Ops / Admin profiles
- Field history tracking provides the audit trail

Without a defined process, informal overrides will create data quality issues in UCDB.

---

## 9. Inbound Workflow Change

### 9.1 Behavioral Change Required

Under Option 2, inbound reps convert their Lead into an Account + Contact + Opportunity **at the point of assignment**, not at demo. This brings inbound to parity with outbound on the same object model.

### 9.2 Technical Change: `ConvertLeadsInvocable.cls`

The existing `ConvertLeadsInvocable` Apex class handles Lead conversion. Currently `createOpportunity` defaults to `false`, meaning no Opportunity is created at conversion.

**Required change:** When inbound reps convert at assignment, pass `createOpportunity = true`. The converted Opportunity should:
- Use the SaaS record type
- Set `StageName` to the appropriate early stage (e.g., `Assigned` or `Demo Scheduled`, depending on where in the inbound cycle conversion occurs)
- Set `Inbound_or_Outbound__c = 'Inbound'`

**Note:** The class currently does not set `StageName` explicitly, falling back to the Salesforce default `Prospecting` — which does not exist in the current picklist. This is a latent bug that must be fixed before `createOpportunity = true` is enabled for any rep. Explicitly set `StageName` in the conversion call.

### 9.3 Inbound Impact Considerations

- Pre-demo Inbound Opportunities will now exist in the pipeline, which inflates pipeline volume. Reports must filter by stage or a combination of `Inbound_or_Outbound__c` and `StageName` to separate true pipeline from early-stage inbound.
- Inbound rep quota and productivity metrics are currently based on activity against Leads. Under Option 2, activities shift to Opportunities. Sales Ops must redefine metrics before rollout.
- If inbound reps are slow to adopt conversion at assignment, reporting will be inconsistent. Define an enforcement timeline and manager accountability model.

---

## 10. Automation Audit: Existing Components

### 10.1 Flows to Retire / Decommission

| Flow | Reason |
|---|---|
| `Closed_Lost_Inactive_Prospect_Account_Updates` | Obsolete Process Builder (API 50.0); hardcoded OwnerId and 90-day resting period; fires on Account-level rollup (can't distinguish Recycled vs. Unqualified). Replaced by the two new terminal state flows. |
| `CL_ALA_REC_or_UNQ_Contact_Update_Open_SaaS_Opp_to_CL` | Contact Outreach Stage → Opp Closed Lost link. Replaced by direct Opp stage automation. Retire after new flows are verified. |
| `ALA_Account_Being_Worked_by_Outbound_SDR` | Obsolete Process Builder; was the predecessor to the distribution trigger. Contains hardcoded IDs. Do not reactivate — use as reference only for the new distribution flow. |
| `Contact_Before_Save_Updates` | Obsolete. Decommission. |
| `Contact_After_Save_Outreach_Stage_Temp_Patch` | Obsolete. Decommission. |
| `RLA_Update_Lead_Status_from_Outreach_Stage` | Obsolete. Decommission. |
| `RLA_Recycle_and_UQ_Leads_from_Outreach_Stage` | Obsolete. Decommission. |

### 10.2 Flows to Update

| Flow | Required change |
|---|---|
| `Opportunity_After_Save_Post_Demo_Cadence_Exit` | Add `Recycled` to entry criteria alongside `Closed Won` and `Closed Lost` — all three terminal states should exit active cadences on related Contacts |
| `Contact_Screenflow_Recycled_Unqualified_Process` | Add a step: after updating the Contact, look up the related open outbound Opp on the Account and set `StageName = Recycled` (with reason) or `Closed Lost`. Without this, a rep using the screen flow won't trigger the Opp terminal state automation. |
| `Opportunity_Before_Save_Record_Updated_Update_Opp_Fields` | Update `First_Meeting_Held__c` trigger: stamp when `StageName` transitions to `Demo Scheduled` (not only at Closed Won); update stage counter logic to handle new pre-demo stages |
| `Opportunity_Create_Contact_Role_on_Opp_Creation` | Extend from single-Contact to bulk-create Contact Roles for all Contacts on the Child Account |
| `Contact_Updates_Before_Save_Flow` | Fix `forREC2OutreachStage` and `forUNQ2OutreachStage` formulas — both still reference `ringdna100__Latest_Disposition__c` (legacy field) instead of `Most_Recent_Disposition__c`. This is a current bug independent of Option 2. Also verify/reactivate — this flow is marked Obsolete in the retrieved metadata. |

### 10.3 Flows Requiring Audit (Record Type Scope Verification)

Because outbound Opps share the SaaS record type with inbound, every active flow that fires on SaaS Opportunities will also fire on outbound Opps from day one. The following flows must be reviewed to confirm they either (a) handle outbound correctly, or (b) have explicit exclusions that prevent them from firing incorrectly on new outbound stages.

| Flow | Audit question |
|---|---|
| `Opportunity_SaaS_CW_After_Save_Create_Combined_Funnel_and_Onboarding_Records` | Fires on SaaS Closed Won — will fire for outbound CW. Confirm required fields (`Contact__c`, `OBS_Owner__c`, `Target_Launch_Date_SaaS__c`) will be populated by outbound reps before CW. This is likely correct behavior — outbound CW should trigger onboarding. |
| `Opportunity_After_Save_Slack_Notifications` | Fires on stage changes — will it spam Slack for every pre-demo stage change across hundreds of outbound Opps? May need record type exclusion or stage-value scoping. |
| `Opportunity_After_Save_Sync_Fields_to_Account` | Syncs Opp fields to Account — confirm sync logic handles the case where multiple Opps (one outbound, potentially one inbound) exist on the same Account over time |
| `Closed_Lost_Opp_Updates` | Old Process Builder — confirm whether it's active in live org and what it does on Closed Lost; verify it won't fire incorrectly on `Recycled` stage (which is a different value, so it likely won't — confirm) |
| `Auto_Create_Upsell_Opp_on_SaaS_Closed_Won` | Creates EC upsell Opp on SaaS CW — will this fire for outbound CW? Confirm whether outbound centers should trigger upsell Opp creation at CW |
| `Opportunity_After_Save_EC_Sales_Cadence_Exit` | Exits sales cadence on CW — verify it handles outbound CW correctly and doesn't need outbound-specific exclusions |
| `OpportunityUpdateSweep.cls` (batch) | Targets SaaS and one other record type by hardcoded record type ID. Outbound Opps on SaaS RT will be included. Confirm `Sales_Neglected__c` logic is appropriate for outbound reps with many accounts in early stages. |

### 10.4 New Flows to Build

| Flow | Object | Trigger | Description |
|---|---|---|---|
| `Account_After_Save_Outbound_Opp_Auto_Create` | Account | After-Save, owner changes to outbound rep | Auto-creates SaaS Opp when center is distributed; sets `Inbound_or_Outbound__c = 'Outbound'`; deduplication guard (no Opp if one already open); bulk-creates Contact Roles for all Account Contacts |
| `Task_After_Save_Update_Outbound_Opp_Stage` | Task | After-Save, `Disposition__c` changes | Applies disposition → Opp stage mapping with forward-only ordinal guard; routes via WhatId = Opp or Contact → Account → Opp lookup |
| `Contact_After_Save_Create_Role_on_Outbound_Opp` | Contact | After-Save, Contact created or `AccountId` changes | Creates `OpportunityContactRole` if open outbound Opp exists on Account and no role exists yet |
| `Opportunity_After_Save_Outbound_Recycled_Account_Update` | Opportunity | After-Save, `StageName` changes to `Recycled` | Queries CMT for wait period; stamps Account fields; moves owner to queue; exits cadences |
| `Opportunity_After_Save_Outbound_Unqualified_Account_Update` | Opportunity | After-Save, `StageName` changes to `Closed Lost` (outbound only) | Stamps Account Unqualified fields; moves owner to queue; exits cadences |
| `Account_After_Save_Org_Level_DQ_Close_Child_Opps` | Account (Parent) | After-Save, `Org_Outbound_Status__c` changes to `Unqualified` | Cascades disqualification to all Child Accounts and open Opps |

---

## 11. UCDB / Fivetran Integration

### 11.1 What UCDB Reads

| Signal | Object.Field | Value/Logic | Action in UCDB |
|---|---|---|---|
| Center eligible for distribution | `Account.Outbound_Distribution_Status__c` | `Active` or `Recycled` + `Resell_Eligible_Date__c <= TODAY()` | Include in next distribution cycle |
| Center in resting period | `Account.Outbound_Distribution_Status__c` | `Recycled` AND `Resell_Eligible_Date__c > TODAY()` | Do not distribute yet |
| Center permanently excluded | `Account.Outbound_Distribution_Status__c` | `Unqualified` | Never distribute |
| Re-distribute date | `Account.Resell_Eligible_Date__c` | Date field | Distribute when this date passes |
| Recycle reason (context) | `Account.Outbound_Recycle_Reason__c` | Picklist value | Optional — for cycle scoring or rep assignment logic |
| Unqualified reason (context) | `Account.Outbound_Unqualified_Reason__c` | Picklist value | Optional — for reporting |

### 11.2 Fivetran Confirmation Required

Before go-live, confirm:
- `Account.Outbound_Distribution_Status__c` is included in the Fivetran SFDC connector schema (new field, must be added after creation)
- `Account.Outbound_Recycle_Reason__c` is included
- `Account.Resell_Eligible_Date__c` is already being synced (field exists today)
- `Opportunity.StageName` is already being synced (confirm `Recycled` value will be picked up after picklist addition)

---

## 12. Pre-Existing Issues to Resolve Before Build

These are bugs or gaps in the current configuration that will create problems for Option 2 if not addressed first. None are blocking for planning but all are blocking for build.

| Issue | Detail | Action |
|---|---|---|
| `Contact_Updates_Before_Save_Flow` is Obsolete in metadata | The primary disposition-to-Contact-stage mapping engine is marked Obsolete in the retrieved metadata, but `Task_After_Save_Disposition_Handling` is Active and still stamps `Most_Recent_Disposition__c`. If the mapping flow is not running in the live org, Contact Outreach Stage is not being updated. Verify live org state before designing the Option 2 automation chain that depends on this flow as reference. | Investigate live org; reactivate or confirm replacement is active |
| `forREC2OutreachStage` / `forUNQ2OutreachStage` formulas use legacy field | Both formulas in `Contact_Updates_Before_Save_Flow` still reference `ringdna100__Latest_Disposition__c` instead of `Most_Recent_Disposition__c`, despite a 10/29/2025 update note. Granular Recycled/Unqualified sub-stage mapping on Contact is currently broken. | Fix before Option 2 build — update both formulas to reference `Most_Recent_Disposition__c` |
| `ConvertLeadsInvocable.cls` defaults `createOpportunity = false` with no explicit `StageName` | Enabling Opportunity creation at inbound conversion without setting `StageName` will result in a `Prospecting` default, which does not exist in the current picklist. | Fix the Apex class to explicitly set `StageName` when `createOpportunity = true` before enabling inbound conversion |
| Hardcoded OwnerId in legacy flows | `0053u0000035xeBAAQ` (Account Queue) is hardcoded in two legacy flows. The `Account_Queue` Custom Label already exists in the org — use it. Any replacement flows must use the Custom Label, not a hardcoded ID. | Use Custom Label in all new flows; do not copy hardcoded ID from legacy flows |

---

## 13. Open Questions

The following questions must be answered before or during build. Each is flagged with its owner.

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | What is the exact distribution signal? When UCDB distributes a center, what field/event fires in Salesforce? Is it Account owner change (to an outbound rep role), a field stamped by LeanData, or a dedicated distribution field? | Josepf / Sales Ops | Auto-creation flow build |
| 2 | Does the outbound Opp owner = Account owner (the rep), or is there a separate Opp owner? For SDR → AE handoff models, the Opp may need to transfer to the AE while the Account stays with the SDR. | Sales leadership | Auto-creation flow build |
| 3 | When a center is recycled and re-distributed, is it always assigned to a different rep, or can it go back to the same rep? Does the re-assignment happen in UCDB or in Salesforce? | Josepf / Sales Ops | Recycle flow design |
| 4 | What is the Opportunity Volume impact? Given outbound distribution volume, how many open Opps will exist at any given time? Sales Ops must review pipeline reporting and forecasting before go-live. | Sales Ops | Pipeline reporting design |
| 5 | For "Features Request" recycle reason: who sets the manual re-engage date, and is there a fallback if they don't? | Sales Ops | Validation rule / CMT |
| 6 | Does outbound Closed Won trigger the same onboarding path as inbound? Specifically: should `Opportunity_SaaS_CW_After_Save_Create_Combined_Funnel_and_Onboarding_Records` fire for outbound CW? If yes, are reps expected to fill in all required CW fields (OBS Owner, etc.)? | Josepf / Onboarding team | CW flow audit |
| 7 | Inbound-outbound center overlap: when an inbound Lead arrives for a center already being worked outbound as an Account, what is the intended routing behavior? LeanData rules need to be defined before both flows are live. | Sales Ops / LeanData admin | LeanData config |
| 8 | Can an Unqualified account be re-qualified? If yes, what is the approval process? | Sales leadership | Override process design |
| 9 | Org-level DQ (Parent Account): if a franchise group is unqualified, should all its centers be individually unqualified even if some were previously active customers? Or should the DQ apply only to centers that have never closed won? | Josepf / Sales leadership | Org DQ flow design |
| 10 | Should `Recycle_Count__c` on Account be factored into UCDB's prioritization of which centers to re-distribute first (e.g., centers recycled fewer times get higher priority)? | Josepf / Data team | UCDB integration scope |
| 11 | Is the back-to-school deadline achievable for full Option 2 scope, or should a phased approach be planned? (Phase 1: outbound only; Phase 2: inbound parity) | Josepf | Project timeline |

---

## 14. Full Build List & Effort Estimates

Effort is rated relative to admin/SysOps capacity: **Low** = ≤1 day, **Medium** = 2–4 days, **High** = 1+ weeks.

### Phase 0: Fix Pre-Existing Issues (prerequisite for all build)

| # | Item | Type | Effort | Owner |
|---|---|---|---|---|
| 0.1 | Verify / reactivate `Contact_Updates_Before_Save_Flow` in live org | Investigation | Low | Donalee |
| 0.2 | Fix `forREC2OutreachStage` / `forUNQ2OutreachStage` to use `Most_Recent_Disposition__c` | Flow fix | Low | Donalee |
| 0.3 | Fix `ConvertLeadsInvocable.cls` to set explicit `StageName` when `createOpportunity = true` | Apex | Low | Paul |
| 0.4 | Replace hardcoded `OwnerId` with `Account_Queue` Custom Label in any replacement flows | Config | Low | Donalee |

### Phase 1: Foundation Config (no automation yet)

| # | Item | Type | Effort | Owner |
|---|---|---|---|---|
| 1.1 | Add `Recycled` to SaaS Opportunity stage picklist | Config | Low | Donalee |
| 1.2 | Create `Recycle_Reason__c` picklist field on Opportunity | Config | Low | Donalee |
| 1.3 | Add Unqualified sub-reasons to `Closed_Lost_Reason__c` picklist | Config | Low | Donalee |
| 1.4 | Create `Outbound_Distribution_Status__c` picklist on Account (Child) | Config | Low | Donalee |
| 1.5 | Create `Outbound_Recycle_Reason__c` on Account (Child) | Config | Low | Donalee |
| 1.6 | Create `Outbound_Unqualified_Reason__c` on Account (Child) | Config | Low | Donalee |
| 1.7 | Create `Recycle_Count__c` (Number) on Account (Child) | Config | Low | Donalee |
| 1.8 | Create `Last_Recycled_Date__c` (Date) on Account (Child) | Config | Low | Donalee |
| 1.9 | Create `Org_Outbound_Status__c`, `Org_Unqualified_Reason__c`, `Org_Unqualified_Date__c` on Account (Parent) | Config | Low | Donalee |
| 1.10 | Create `Outbound_Recycle_Period__mdt` Custom Metadata Type + records | Config | Low | Donalee |
| 1.11 | Set forecast categories for new Opp stages | Config | Low | Donalee |
| 1.12 | Enable field history tracking on `Outbound_Distribution_Status__c`, `Resell_Eligible_Date__c` | Config | Low | Donalee |
| 1.13 | Build validation rules (4 rules per Section 4.4) | Config | Low | Donalee |
| 1.14 | Update or create Path Assistant for SaaS record type to include new stages (Demo Scheduled, Recycled, updated Closed Lost/CW steps) | Config | Low | Donalee |
| 1.15 | Field-level security for `Org_Outbound_Status__c` (restrict to Sales Ops / Admin) | Config | Low | Donalee |

### Phase 2: Core Automation

| # | Item | Type | Effort | Owner |
|---|---|---|---|---|
| 2.1 | `Account_After_Save_Outbound_Opp_Auto_Create` (distribution trigger + Contact Role bulk create + dedup guard) | New Flow | Medium | Donalee / Paul |
| 2.2 | `Task_After_Save_Update_Outbound_Opp_Stage` (disposition → Opp stage with forward-only guard) | New Flow | Medium | Paul |
| 2.3 | `Contact_After_Save_Create_Role_on_Outbound_Opp` | New Flow | Low | Donalee |
| 2.4 | `Opportunity_After_Save_Outbound_Recycled_Account_Update` | New Flow | Medium | Donalee |
| 2.5 | `Opportunity_After_Save_Outbound_Unqualified_Account_Update` | New Flow | Low–Med | Donalee |
| 2.6 | `Account_After_Save_Org_Level_DQ_Close_Child_Opps` | New Flow | Medium | Paul |
| 2.7 | Update `Opportunity_After_Save_Post_Demo_Cadence_Exit` to include `Recycled` | Flow update | Low | Donalee |
| 2.8 | Update `Contact_Screenflow_Recycled_Unqualified_Process` to also close related Opp | Flow update | Low–Med | Donalee |
| 2.9 | Update `Opportunity_Before_Save_Record_Updated_Update_Opp_Fields` — `First_Meeting_Held__c` at Demo Scheduled | Flow update | Low | Donalee |
| 2.10 | Update `Opportunity_Create_Contact_Role_on_Opp_Creation` — bulk create for all Account Contacts | Flow update | Low | Donalee |
| 2.11 | Configure RingDNA to log outbound Tasks with `WhatId = Opportunity` | RingDNA config | Low–Med | Sales Ops |

### Phase 3: Automation Audit & Cleanup

| # | Item | Type | Effort | Owner |
|---|---|---|---|---|
| 3.1 | Audit 120 Opportunity-related flows for SaaS RT scope impact | Audit | High | Donalee + Paul |
| 3.2 | Retire `CL_ALA_REC_or_UNQ_Contact_Update_Open_SaaS_Opp_to_CL` | Decommission | Low | Donalee |
| 3.3 | Decommission 6 Obsolete flows (see Section 10.1) | Decommission | Low | Donalee |
| 3.4 | Update `OpportunityUpdateSweep` neglect logic for outbound stages | Apex | Low | Paul |
| 3.5 | `OpportunityUpdateSweep` — confirm outbound record type (SaaS) is handled correctly | Apex review | Low | Paul |

### Phase 4: Inbound Parity & Reporting

| # | Item | Type | Effort | Owner |
|---|---|---|---|---|
| 4.1 | Update `ConvertLeadsInvocable.cls` — `createOpportunity = true`, explicit `StageName`, set `Inbound_or_Outbound__c = 'Inbound'` | Apex | Low–Med | Paul |
| 4.2 | LeanData routing rules — inbound Lead matching existing outbound Account | LeanData | Medium | Sales Ops |
| 4.3 | Pipeline report filters — separate pre-demo outbound from traditional pipeline | Reports | Medium | Sales Ops |
| 4.4 | Unqualified override Screen Flow (manager approval to re-qualify a center) | Screen Flow | Low | Donalee |
| 4.5 | Confirm Fivetran schema includes new Account fields | Fivetran | Low | Data team |
| 4.6 | UCDB query updates to read new `Outbound_Distribution_Status__c` field | UCDB | TBD | Data / Engineering |

---

## 15. Risks & Dependencies

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Back-to-school deadline** — full Option 2 scope may not be achievable in time | High | High | Plan Phases 1–2 as MVP (outbound only); defer Phase 4 inbound parity to Phase 2 of project |
| **120+ flow audit** — some flows may fire incorrectly on outbound Opps before they're reviewed | High | Medium | Prioritize the 8 flows in Section 10.3 before go-live; accept risk on lower-risk flows with monitoring |
| **Inbound rep adoption** — reps slow to convert at assignment breaks inbound pipeline reporting | Medium | Medium | Define a hard adoption date; manager accountability; reporting flag for "unconverted inbound Opps" |
| **Hardcoded IDs in legacy flows** — existing automation uses hardcoded Salesforce IDs that differ between sandbox and production | High | Medium | All new flows use Custom Labels; existing flows with hardcoded IDs are retired, not extended |
| **`Contact_Updates_Before_Save_Flow` Obsolete status** — if disposition-to-stage mapping is not running in live org, the Contact outreach stage chain is broken, affecting the baseline we're building on | Medium | High | Investigate live org immediately (Phase 0.1) |
| **UCDB schema change** — new Account fields must be added to Fivetran connector before UCDB can read them | Low | High | Add fields to Fivetran schema as part of Phase 1 completion, not post-launch |
| **Governor limits on Org-level DQ flow** — cascading CL across many Child Accounts in one transaction | Low | Medium | Build as Apex batch if org has >200 Child Accounts; scope with Paul |
| **Opportunity volume inflation** — auto-creating Opps at distribution significantly increases open Opp count; pipeline reporting must be recalibrated before go-live | Medium | Medium | Sales Ops must redefine pipeline and forecast views before Phase 2 go-live |

---

*This document is a working technical specification. All configuration changes follow the org's standard change management loop: Plan → Impact Analysis → RIC Score → Build (sandbox) → Test → Deploy (production). No production deployments without prior successful sandbox verification.*
