# Object Model

## Core Objects

### Lead
The entry point for new prospects. Leads represent individual decision-makers (center directors, owners) before they're qualified. Heavily automated — 72+ flows touch Lead records.

**Key custom fields:**
- `Outreach_stage__c` — tracks rep engagement stage (drives cadence entry/exit and status updates)
- `Latest_Disposition__c` — most recent call disposition
- `Revenue_Sequence_Type__c` — determines which cadence to enroll into
- `Has_Blocked_Phone__c` — flags leads with blocked phone numbers (blocks from distribution)

**Key behaviors:**
- Before-save flows set Outreach_stage, Status, Owner
- After-save flows handle cadence enrollment/exit, org matching, scoring
- Leads convert to Contact + Account (+ optionally Opportunity)
- Organization/Location matching links Leads to existing school records

### Contact
Post-conversion record for the decision-maker. Similar engagement fields as Lead.

**Key custom fields:**
- `Outreach_stage__c` — same concept as Lead
- `Cadence_ID__c` — current cadence enrollment

**Key behaviors:**
- 40+ flows for cadence management, reassignment, field sync
- Contacts relate to Account (the school/center)

### Account
Represents a childcare center/school. The central object — most rollups and relationships flow through Account.

**Key relationships:**
- Parent Account → Child Accounts (center hierarchy)
- Account → Opportunities (sales deals)
- Account → Contacts (decision-makers)
- Account → Combined_Funnel__c (custom tracking)
- Account → Child_Site_Creation__c (custom)
- Account → Organization/Location (custom matching objects)

**Key behaviors:**
- Owner sync: Account owner changes cascade to related Contacts
- Cadence management: onboarding, churn, EDU cadences trigger on Account
- Scheduled flows: churn updates, premium account updates, coupon cases

### Opportunity
Sales deals. Multiple record types for different business lines.

**Record Types:**
- SaaS
- EC (Early Childhood)
- Gov (Government)
- Bill Upsell
- Assessment
- Prof Dev (Professional Development)

**Key fields:**
- Standard stage field (Demo Set → Discovery → Negotiation → Closed Won / Closed Lost)
- Post-close-won stages sync to Account

**Key behaviors:**
- Combined Funnel creation on stage progression
- Field sync to parent Account
- 50+ flows for stage management

### Combined_Funnel__c (Custom)
Tracks pipeline progression events. Created when Opportunities hit certain stages. Used for reporting and funnel analytics. ~45+ flows manage this object.

### Organization / Location (Custom)
Used for matching inbound Leads to known school entities. Organization represents the school brand/chain; Location represents a specific site. Leads are matched via name, address, and other identifiers.

## Object Relationship Diagram

```
                    HubSpot (MQL Score)
                         │
                         ▼
    ┌──────────┐   convert   ┌───────────┐
    │   LEAD   │ ──────────► │  CONTACT  │
    │          │             │           │
    │ Outreach │             │ Outreach  │
    │ Stage    │             │ Stage     │
    └────┬─────┘             └─────┬─────┘
         │                         │
         │  org/location match     │  lookup
         ▼                         ▼
    ┌──────────┐             ┌───────────┐
    │   ORG /  │             │  ACCOUNT  │◄──── Parent/Child
    │ LOCATION │             │ (Center)  │      hierarchy
    └──────────┘             └─────┬─────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
             ┌───────────┐  ┌──────────┐  ┌──────────────┐
             │OPPORTUNITY│  │COMBINED  │  │CHILD_SITE    │
             │           │  │FUNNEL    │  │CREATION      │
             │ SaaS / EC │  │(Pipeline │  │              │
             │ Gov / etc │  │ Events)  │  │              │
             └───────────┘  └──────────┘  └──────────────┘
```

## Current vs. Future State
There is an active initiative to move from a **Lead-centric** model to an **Opportunity-first** model. See [GTM Sales Ops Technical Implementation Plan](../GTM_Sales_Ops_Technical_Implementation_Plan.md) for full details. Key change: engagement fields (Outreach_stage, cadence logic) will migrate from Lead/Contact to Opportunity.
