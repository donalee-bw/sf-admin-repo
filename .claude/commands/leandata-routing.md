Diagnose why a Lead or Contact was routed to a specific rep, team, or queue in LeanData.

## When to use

- A rep says "I should have gotten this lead but didn't"
- A manager asks "why did this lead go to Low Intent instead of Rapid Response?"
- A lead is stuck in a queue and wasn't assigned to anyone
- Routing looks correct in LeanData but the Salesforce owner is wrong
- Verifying that the Apr '26 routing matrix is being applied correctly

## Step 1 — Get the record identifier

Ask the admin:
- Lead or Contact email address (preferred — most precise)
- Or: full name + approximate date created

Also ask: what did they expect to happen? (Which team/rep should have received it, and why?)

## Step 2 — Query the record

Run Query 1 (Lead by email) or Query 4 (routing decision path) from:
`scripts/soql/leandata-routing-troubleshoot.soql`

Always run against production:

```bash
sf data query --query "
SELECT Id, Name, Email, Owner.Name, Owner.UserRole.Name,
lean_data_action__c, leandata_processing_timeframe__c,
leandata_revenue_sequence_type__c, leandata_reprocess__c,
user_type__c, open_and_operating__c, hs_number_of_sites__c,
school_size__c, center_type__c, hs_last_form_submission_type__c,
demo_path__c, lead_source_routing_criteria__c, leadsource,
form_abandonment_lead__c, hs_recent_conversion__c,
outreach_stage__c, owned_by_sales__c, logic_owned_by_queue__c,
inbound_or_outbound__c, State, CreatedDate
FROM Lead
WHERE Email = 'email@example.com'
LIMIT 5
" --target-org production --result-format table
```

## Step 3 — Interpret the LeanData outcome

Check `lean_data_action__c` first. It tells you what LeanData decided:

| Value | Meaning |
|-------|---------|
| `Target - Assigned` | Routed to a US pool (Rapid Response, Low Intent, High Value, etc.) |
| `Target - Assigned High Value` | Routed to High Value pool |
| `Target - Assigned High Intent` | Routed as high intent |
| `Target - Assigned Low Intent` | Routed to Low Intent pool |
| `Target - Assigned Rapid Response` | Routed to Rapid Response pool |
| `Target - Assigned BNP` | Routed as Brand New Program |
| `Target - Assigned High Value MultiSite` | Routed to High Value multi-site path |
| `Target - Assigned to PK AE` | Routed to Pakistan AE pool |
| `Target - Assigned to PK SDR` | Routed to Pakistan SDR pool |
| `Non-Target` | Lead failed target qualification — sent to Unqualified queue |
| `Converted into Existing Account` | Lead matched an existing Account and was converted |
| `Converted into Existing Contact` | Lead matched an existing Contact and was converted |
| `Merged into Existing Lead` | Lead was merged into a duplicate |

Then check `leandata_processing_timeframe__c`:
- `Working Hours` — routed during normal business hours
- `After Working Hours` / `Before Working Hours` / `Overnight Hours` — may have been held in a time-based queue; could explain delay in rep assignment

## Step 4 — Trace the routing decision against the Apr '26 matrix

### Core SaaS matrix (CS_Apr26)

Walk through these fields in order — the first rule that matches determines the team:

1. **`user_type__c`** — is this a Staff/Parent user?
   - Staff/Parent → some rules route to Low Intent regardless of other fields (rules 4, 32–36)

2. **`open_and_operating__c`** — what is the school's operating status?
   - `"Opening in more than 3 months"` → **PK_SDR** (rule 5)
   - `"Opening within 3 months"` → capacity and multi-site determine next step
   - `"Yes, we're open and enrolling"` or blank → proceed to capacity check

3. **`hs_number_of_sites__c`** — is this multi-site?
   - Multi-site + open/operating or opening within 3 months → **US_High-Value** (rules 8, 10)

4. **`school_size__c`** — what is the capacity bucket?
   - `60-100` or `100+` → **US_High-Value** (rules 7, 11)
   - `10-19` or `20-59` → Rapid Response or Low Intent depending on offer type and demo path
   - `1-9` or blank → split pool or PK_AE depending on operating status

5. **`hs_last_form_submission_type__c`** (Offer Type) — what did they submit?
   - `Demo Request`, `PTL`, `Pricing Inquiry` → active routing paths
   - `Content Request`, `Blog`, `Webinar`, `Parent Referral`, `SEM Brand` → **Low Intent** (rules 32–36)

6. **`demo_path__c`** — how did they engage?
   - `Chase Me` → pool-based routing (split or Low Intent depending on lead source)
   - `Autodial` or `Schedule Me` → direct Rapid Response routing (rules 18–20)

7. **`lead_source_routing_criteria__c`** — lead source category
   - `Paid Social` or `MPP` → **Low Intent** (rules 24–29)
   - `Not PS & MPP` → proceeds to offer type/demo path evaluation

8. **`hs_recent_conversion__c`** — check for Reddit
   - Contains `"Reddit"` + Demo Request → **Low Intent** (rule 2)

9. **`form_abandonment_lead__c`** = true → **Low Intent** (rule 3)

10. **`center_type__c`** = `Camp` with valid state → **Rapid Response** (rule 1)

### EDU matrix (EDU_Apr26)

1. **`center_type__c`** — `"I'm an admin or director"` vs `"I'm a homeschool Parent"`
   - Homeschool Parent → **CAT Inbound - Low** (rule 1)
   - Admin or director → proceed to capacity

2. **`school_size__c`** — `100+` → **CAT Inbound - Large**; all others → **CAT Inbound - High** (Demo Request) or **CAT Inbound - Low** (Content Request, Paid Social)

3. **`leadsource`** — Paid Social → downgrade to Low or Low regardless of capacity for non-Demo offer types

## Step 5 — Identify the issue

Based on your analysis, the routing issue is typically one of:

| Root cause | What to look for |
|------------|-----------------|
| **Wrong field value** | A routing decision field (`school_size__c`, `open_and_operating__c`, etc.) has an unexpected value that sent the lead down the wrong path |
| **Missing field value** | A key field is null — LeanData may have fallen through to a catch-all rule |
| **Timeframe hold** | `leandata_processing_timeframe__c` shows After/Before/Overnight Hours — lead was held then assigned to a time-based queue |
| **LeanData re-queue** | `leandata_reprocess__c = true` — LeanData hasn't finished processing yet |
| **Record still in queue** | `logic_owned_by_queue__c = true` and `Owner.Name` shows a queue name — was never assigned to a rep |
| **Matrix rule gap** | The lead's combination of field values doesn't match any current rule — falls through to default (usually Non-Target or Low Intent) |
| **Reddit/form abandonment override** | `hs_recent_conversion__c` contains "Reddit" or `form_abandonment_lead__c = true` — overrides what would otherwise be a higher-value routing path |

## Step 6 — Communicate the finding

Report back to the admin with:
1. **What LeanData decided**: the `lean_data_action__c` value and what it means
2. **Why**: which field value(s) triggered that matrix rule
3. **Whether it's correct**: does the field data match what the routing matrix says should happen?
4. **Next step** (if something is wrong):
   - If a field value is wrong → identify which system set it and when (check field history)
   - If a matrix rule is missing → flag to Sales Ops to update the routing configurator
   - If LeanData didn't process → check `leandata_reprocess__c` and whether the record meets entry criteria

## Pool name reference (Apr '26)

| Team | LeanData Lead Pool | LeanData Contact Pool |
|------|-------------------|----------------------|
| US Rapid Response | `CORE_US_Rapid-Response_Lead` | `CORE_US_Rapid-Response_Contact` |
| US Low Intent | `CORE_US_Low-Intent_Lead` | `CORE_US_Low-Intent_Contact` |
| US High Value | `CORE_US_High-Value_Lead` | `CORE_US_High-Value_Contact` |
| PK SDR | `CORE_PK_SDR_Lead` | `CORE_PK_SDR_Contact` |
| PK AE | `CORE_PK_AE_Lead` | `CORE_PK_AE_Contact` |
| Split 10–59 | `CORE_Split_10-59_Lead` | `CORE_Split_10-59_Contact` |
| Split 1–9 | `CORE_Split_1-9_Lead` | `CORE_Split_1-9_Contact` |
| CAT Inbound Large | `CAT_IB-Large_Lead` | `CAT_IB-Large_Contact` |
| CAT Inbound High | `CAT_IB-High_Lead` | `CAT_IB-High_Contact` |
| CAT Inbound Low | `CAT_IB-Low_Lead` | `CAT_IB-Low_Contact` |

## Safety rules

- This skill is **read-only**. Do not update lead fields or re-trigger LeanData manually.
- If a field value appears wrong and needs correction, stop and follow the data mutation rules in CLAUDE.md (preview affected records, get confirmation, state row count) before any update.
- If the issue suggests a matrix rule change is needed, escalate to Sales Ops — do not modify LeanData configuration directly.
