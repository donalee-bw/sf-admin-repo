# Business Rules & Tribal Knowledge

## Lead Lifecycle

### Distribution & Assignment
- Leads are assigned to reps via RLA (Round-Robin Lead Assignment) automation
- Leads with blocked phone numbers (`Has_Blocked_Phone__c = true`) should be excluded from distribution
- **Edge case:** A Lead with one blocked number AND one good number should NOT be fully blocked — reps should still dial the good number
- High-priority inbound leads can be rerouted from outbound queue to inbound queue via `Lead_Reassignment_to_Inbound_Queue`
- Resting period: recycled leads go to a resting queue before re-entering the pool (`RLA_Lead_Resting_Period_Assignment`)

### Outreach Stage (the engine of rep workflow)
`Outreach_stage__c` is the most interconnected field in the org. It exists on both Lead and Contact and drives:
- **Cadence entry/exit** — changing Outreach_stage triggers enrollment into or removal from Sales Engagement cadences
- **Lead Status updates** — `RLA_Update_Lead_Status_from_Outreach_Stage` keeps Status in sync
- **Recycling/UNQ** — `RLA_Recycle_and_UQ_Leads_from_Outreach_Stage` moves leads to recycle/unqualified
- **Field clearing on reassignment** — `Lead_Before_Save_RLA_Clear_Fields_on_Reassignment` resets Outreach_stage, Status, and Disposition when a Lead changes owner

**Warning:** Any change to Outreach_stage values or logic has a cascading effect on 20+ flows. Treat this field as a state machine — map all transitions before modifying.

### Lead-to-Org Matching
Inbound Leads are automatically matched to existing Organization/Location records (representing known schools). This happens via:
- `New_Lead_Org_Location_Matching` (after-save)
- `Lead_to_Organization_matching` / `Lead_Subflow_Org_Location_Matching` (subflows)
- Scheduled rematching: `Lead_Scheduled_Org_Rematch`

### Lead Conversion
Standard Salesforce Lead conversion creates Contact + Account. Combined Funnel records may be created downstream. Post-conversion, engagement logic shifts from Lead flows to Contact flows.

## Cadence / Sales Engagement Patterns

### Entry
- Cadences are entered via `Subflow_Sales_Cadence_Entry` (shared subflow)
- Entry is triggered by after-save flows based on `Revenue_Sequence_Type__c` and Owner
- Different cadence types: Sales, Starter, Missed Demo, Government

### Exit
- 42+ cadence exit flows across Lead, Contact, Opportunity, Account
- Exit triggers: Outreach_stage changes, owner changes, cadence completion, account-level events (churn, onboarding)
- Catch-all: `Lead_Scheduled_Catch_All_Exit_Flows` runs on schedule to clean up missed exits
- On cadence completion: `Recycle_Lead_Contact_at_Cadence_completion` sets Outreach_stage

### Owner Reassignment
When a Lead/Contact owner changes while enrolled in a cadence:
- `Lead_After_Save_Cadence_Owner_Reassignment` re-enrolls into a new cadence under the new owner
- Fields are cleared first by before-save flow

## Opportunity Patterns

### Record Types & Usage
| Record Type | Business Line |
|-------------|--------------|
| SaaS | Core Brightwheel product sales |
| EC | Early Childhood |
| Gov | Government contracts |
| Bill Upsell | Billing upgrade for existing customers |
| Assessment | Assessment product |
| Prof Dev | Professional development |

### Post-Close-Won
- Opportunity stage changes after Close-Won sync to Account (`Account_After_Save_Opp_Post_CW_Stage_Sync`)
- Combined Funnel records are created at key stage transitions
- Account-level fields updated for onboarding tracking

## Account Patterns

### Hierarchy
- Parent Account → Child Accounts (center hierarchy for multi-site organizations)
- `Account_After_Save_Parent_Child_Number_of_School_Sync` keeps counts in sync

### Owner Cascade
- Account owner changes trigger Contact owner updates (`Account_Owner_Changed_Update_Related_Contacts_Owner`)

### Scheduled Jobs
- `Account_Scheduled_Churn_Updates` — marks churned accounts
- `Account_Scheduled_Premium_Account_Updates` — updates premium status
- `Account_Scheduled_Expired_Coupon_Cases` — creates cases for expired coupons

## Gotchas & Warnings

1. **Outreach_stage is a state machine** — never modify its picklist values or flow logic without mapping all 20+ dependent flows first
2. **Cadence task completion requires API** — you can't just update Task.Status; you need the Sales Engagement API
3. **Flow count is high (~506)** — many are legacy/inactive. Always check `Status` before assuming a flow is active
4. **Typo in codebase** — `ContactSweepSheduler` (missing 'c') — this is the actual class name, don't "fix" it
5. **EFH managed package** — some Apex classes reference `EFH` namespace. Don't modify managed package components.
6. **Opportunity-first migration is planned** — new Lead-centric automation may be short-lived. Check the [GTM implementation plan](../GTM_Sales_Ops_Technical_Implementation_Plan.md) before building new Lead flows.
7. **Action buttons are on FlexiPages** — not page layouts. Each record type may have its own FlexiPage.
