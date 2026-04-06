# Integrations

## Integration Map

```
                         SALESFORCE
                    (Brightwheel-Full)
                           │
          ┌────────────────┼────────────────┐
          │                │                │
     INBOUND          ENGAGEMENT        POST-SALE
          │                │                │
    ┌─────▼─────┐   ┌─────▼──────┐   ┌─────▼──────┐
    │  HubSpot  │   │Revenue.io  │   │   Stripe   │
    │           │   │ (RingDNA)  │   │            │
    └───────────┘   └────────────┘   └────────────┘
    ┌───────────┐   ┌────────────┐   ┌────────────┐
    │ChiliPiper │   │    Gong    │   │ JungleGym  │
    │  (TBD)    │   │            │   │            │
    └───────────┘   └────────────┘   └────────────┘
    ┌───────────┐   ┌────────────┐   ┌────────────┐
    │ Outreach  │   │    SCV     │   │   Slack    │
    │ (Legacy)  │   │  (Voice)   │   │  (Notifs)  │
    └───────────┘   └────────────┘   └────────────┘
```

## System Details

### HubSpot (Inbound / MQL Scoring)
- **Direction:** HubSpot → Salesforce
- **What syncs:** MQL scores on Leads and Contacts
- **Salesforce touchpoints:** `Scoring_New_Lead_Record_Create`, `Scoring_Updated_Lead_Record_Create` flows
- **Gotcha:** 2 dedicated HubSpot notification flows create Tasks on Lead/Contact score changes

### Revenue.io / RingDNA (Engagement)
- **Direction:** Bidirectional
- **What it does:** Dialer, guided selling sequences, call recording
- **Salesforce touchpoints:** 2 RingDNA flows sync Conversation → Task fields
- **Gotcha:** Revenue.io natively supports Opportunity (important for Opp-first migration). Guided Selling binds to standard objects.

### Service Cloud Voice / SCV (Engagement)
- **Direction:** Bidirectional
- **What it does:** Telephony integration — click-to-dial, inbound routing, call recording
- **Salesforce touchpoints:** `voiceNumberSelector` LWC, `AgentOutboundNumberPreferenceService` Apex, `logDispositionUtil` LWC
- **Note:** This is the active dialer. Components target `lightning__VoiceExtension`.

### Sales Engagement / Action Cadences (Native)
- **What it does:** Drives structured outreach sequences for reps (call, email, wait steps)
- **Salesforce touchpoints:** 42+ cadence exit flows across Lead, Contact, Opportunity, Account
- **Key patterns:** Cadence entry via subflow (`Subflow_Sales_Cadence_Entry`), exits triggered by Outreach_stage changes
- **Gotcha:** Cadence task completion requires Sales Engagement API, not standard Task DML

### Gong (Call Intelligence)
- **Direction:** Gong ← Salesforce (reads call data)
- **What it does:** Call recording analysis, coaching insights
- **Salesforce touchpoints:** Binds to standard objects (Opportunity, Contact)

### Outreach (Legacy Engagement)
- **Direction:** Bidirectional
- **What it does:** Legacy sequence/cadence tool (being replaced by Sales Engagement)
- **Salesforce touchpoints:** 6 Outreach flows — stage updates, recycle/UNQ actions
- **Note:** Still active but declining. New automation should target Sales Engagement, not Outreach.

### Slack (Notifications)
- **Direction:** Salesforce → Slack
- **What it does:** Sends notifications on key CRM events
- **Salesforce touchpoints:** 18+ Slack notification flows across Lead, Contact, Opportunity, Case
- **Pattern:** Dedicated flows per object/event type

### ChiliPiper (Scheduling — TBD)
- **Status:** Planned/under evaluation
- **What it does:** Automated meeting scheduling from inbound leads
- **Note:** Binds to standard objects

### Stripe (Payments / Post-Sale)
- **Direction:** Bidirectional
- **What it does:** Payment processing for Brightwheel subscriptions
- **Salesforce touchpoints:** Account-level billing fields, Bill Upsell Opportunity record type

### JungleGym (School Platform)
- **Direction:** JungleGym ↔ Salesforce
- **What it does:** Brightwheel's internal school management platform
- **Salesforce touchpoints:** School UUID fields on Account, `Account_Mismatched_School_UUID_Cleanup` flow
