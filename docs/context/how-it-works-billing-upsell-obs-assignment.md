# How it Works | Billing Upsell OBS Assignment
## Scope
This process applies only to Billing Upsell Opportunities with the following Onboarding Paths:
Standard
Site-Add (Declined Training = False) → “Non-DT Site-Add”
All other onboarding paths (Site-Add with DT = True, Self-Serve, Brand New Program, BNP, etc.) follow current behavior and are not impacted by this process.

## Overview
This process ensures that:
OBS Owner chosen in Chili Piper is always respected (no Salesforce round-robin overwrite).
OBS Call Scheduled Date is tracked alongside the OBS Owner.
Combined Funnel and Account records are automatically updated with the correct OBS Owner.
OBS Owner and Call Date are required at Close Won when financial prerequisites are complete.

## Entry Point: Chili Piper Billing Upsell Meeting
When a qualifying Chili Piper meeting is scheduled, the process begins.
### Supported Meeting Types
OBS Single Site and Eng – Brightwheel Billing Training – 30 Min
OBS Multi-Site and Eng – Brightwheel Billing Training – 30 Min
### Steps
Chili Piper event is logged.
Salesforce finds the Billing Upsell Opportunity related to the event that is:
Open OR Closed Won
Not Closed Lost
Opportunity is updated with:
OBS Owner (from Chili Piper booking)
OBS Call Scheduled Date

## Decision: Is the Opportunity Already Closed Won?
If YES:
Update Opportunity, Combined Funnel, and Account immediately with the OBS Owner and Call Date.
Assumption: If Salesforce had already round-robin assigned an OBS (e.g., Gov Lic or exceptions), BUOs must still schedule with that same OBS. This requires enablement so reps know when to respect Salesforce’s round robin vs. Chili Piper’s.
If NO (Opportunity still Open):
Update only the Opportunity.
Combined Funnel and Account will be updated later when the Opp is moved to Closed Won.

## Closed Won Milestone
At the point of moving the Opportunity to Closed Won, Salesforce enforces the following validation rule.
### OBS Fields Required
OBS Owner and OBS Call Scheduled Date are required when:
Onboarding Path = Standard OR Site-Add (Non-DT)
Was Rate Card Captured = Yes
EIN &amp; Bank Info Collected = Yes
### If prerequisites are not met (Rate Card = No OR EIN/Bank = No):
OBS Owner &amp; Date are not required to CW.
Two outcomes:
If left blank → Combined Funnel Owner remains unchanged.
If entered by rep (call scheduled pre-CW) → Combined Funnel and Account are updated with the provided OBS Owner and Call Date.

## Ownership Outcomes
When required:
OBS fields must be populated to CW.
CF and Account automatically sync to the OBS Owner.
Salesforce does not reassign if OBS Owner is present.
When not required:
Opp can move to CW without OBS fields.
If reps fill them early, CF/Account will still update.
If not, CF remains unchanged until the Chili Piper meeting is scheduled.

Start: Chili Piper Billing Upsell Meeting Scheduled
|
├── Meeting Types:
|       • OBS Single Site and Eng – Brightwheel Billing Training – 30 Min
|       • OBS Multi-Site and Eng – Brightwheel Billing Training – 30 Min
|
├── Find Related Billing Upsell Opportunity (Open or CW, not Lost)
|
├── Is Opp Closed Won?
|        ├── Yes → Update Opp + CF + Account with OBS Owner &amp; Date
|        └── No  → Update Opp only; CF/Account update after CW
|
└── At Closed Won Milestone
├── If (Onboarding Path = Standard OR Site-Add Non-DT)
|       AND (Rate Card = Yes AND EIN/Bank = Yes)
|       → OBS Owner &amp; Date REQUIRED
|       → CF + Account updated
|
└── If prerequisites not met
→ OBS Owner &amp; Date NOT required
→ If left blank → CF Owner remains unchanged
→ If OBS Owner &amp; Date entered by rep (call scheduled pre-CW)
→ CF + Account updated with provided OBS
