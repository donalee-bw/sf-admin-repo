# Gov Standard Onboarding Path – Process &amp; Automation
## Overview
This document outlines the Gov Standard Onboarding Path process and automation logic, ensuring smooth tracking of sales follow-ups, onboarding meetings, and ownership transitions in Salesforce.
Requirement Doc - https://docs.google.com/document/d/18OYxVjO9Tga87GOqQGuR9Nyv1Y3SMe76MbN6n6nO5kc/edit?tab=t.0

## 1. Handling Closed Won Opportunities Without SSPR
If a Government licensee opportunity is Closed Won without the SSPR, the Sales Follow-up Call Scheduled Date is required.
To satisfy this requirement, the Sales Rep must schedule a Sales Follow-up Meeting in Chili Piper using the meeting type:➡ &quot;Sales - BW Setup Follow-up&quot;
Timing Impact:
If this meeting is scheduled before closing the Opportunity, it will automatically update the Sales Follow-up Scheduled Date on:✅ The related Contact - “Gov Sales Follow-up Scheduled Date”✅ The Open Gov Lic Opportunity - “Sales Follow-up Scheduled Date”

## 2. Handling Closed Won Opportunities With SSPR
If SSPR is added at the point of Opportunity Close Won, the OBS Owner and OBS Scheduled Date are required.
Process Steps:1️⃣ OBS Owner must be assigned.2️⃣ OBS Call/meeting must be scheduled in Chili Piper. (Initial Account Setup Meeting Type)3️⃣ OBS Call Scheduled Date must be manually entered into the Opportunity.
Ownership Transition:
Once these steps are completed, ownership of the Combined Funnel and Onboarding transitions to the assigned OBS.

## 3. Ownership of Combined Funnel &amp; Onboarding with Sales Follow-up.
Until the Sales Rep schedules the OBS Meeting, ownership of the following remains with the &quot;Standard Onboarding Queue&quot;:
✅ Combined Funnel
✅ Onboarding
✅ Account - Account Queue
Ownership remains with the Standard Onboarding Queue until the Sales Rep schedules one of the following OBS meetings in Chili Piper:
PILOT: OBS Single-Site – Brightwheel Setup (45 Min)
PILOT: OBS Multi-Site – Brightwheel Setup (45 Min)
When the OBS Meeting is scheduled, Chili Piper selects the OBS automatically (RR).
At this point, ownership of the following will change from the &quot;Standard Onboarding Queue&quot; to the assigned OBS:✅ Combined Funnel✅ Onboarding✅ Account &amp; Contacts

## 4. Salesforce Components -
Asana Ticket - SSP: Sales &lt;&gt; Onboarding Process update - SFDC Updates (Gov &amp; Upsell)
New Fields on Contact Object - Gov Sales Follow-up Scheduled Date &amp; Gov Sales Follow-up Scheduled Date
New/Updated Validation Rules :
Contact Action Layouts for Opportunity Page - to review
Other Automation that were updated and the logic:

## 5. Summary of Gov Standard Onboarding Path
Stage
Action Required
Automation/Ownership
Opportunity Closed Won without SSPR
Sales Rep must schedule Sales - BW Setup Follow-up in Chili Piper
Updates Sales Follow-up Scheduled Date on Contact &amp; Open Opportunity
Opportunity Closed Won with SSPR
OBS Owner and OBS Scheduled Date are required
Ownership transitions to the assigned OBS
Opportunity Ownership (Before OBS Meeting is Scheduled)
Defaulted to Standard Onboarding Queue
Combined Funnel, Onboarding &amp; Opportunity remain with Standard Onboarding Queue
OBS Meeting Scheduled
Sales Rep schedules PILOT: OBS Single-Site or Multi-Site Brightwheel Setup (45 Min) in Chili Piper
Ownership transitions to selected OBS (from Chili Piper) for Onboarding &amp; Opportunity

# Billing Upsell - Standard Onboarding Path
## Onboarding Path = Standard
## Overview
This document outlines the Billing Upsell - Standard Onboarding Path process, including the requirements, automation logic, and ownership assignment for newly created Billing Onboarding Records in Salesforce.

## 1. Billing Upsell Requirements
If Billing is opted in, the following fields must be completed:
&quot;Was ratecard captured?&quot; → Yes/No
If No, a Sales Follow-up Scheduled Date is required.
&quot;EIN/Bank Information Captured?&quot; → Yes (This is a required field to Close Win the Billing Upsell Opportunity)

## 2. Ownership Assignment of the Billing Onboarding Record
The ownership of the newly created Billing Onboarding Record depends on the SaaS Onboarding Status:
### A. If SaaS is NOT activated yet (Customer is still onboarding)
The Billing Onboarding Record is assigned to the same OBS handling the SaaS onboarding.
This ensures a consistent onboarding experience, keeping the same OBS for both SaaS and Billing onboarding.
### B. If SaaS is already activated (Customer has completed SaaS onboarding)
If the Sales Rep did NOT capture the Ratecard at Billing Upsell Close Won:
The Billing Onboarding Record is assigned to the &quot;Standard Onboarding Path Queue&quot;.
When the Sales Rep completes the follow-up call and captures the Ratecard, they must:
Schedule the OBS Call in Chili Piper.
The Chili Piper round-robin assigns the Billing Onboarding Record to a new OBS.
If the Ratecard was captured at Close Won:
The Sales Rep must check the SaaS Onboarding Status.
Regardless of whether the customer is still onboarding with SaaS or already activated, the Sales Rep must:
Schedule the OBS Call in Chili Piper.
Manually enter the OBS Scheduled Date and OBS Owner on the Billing Upsell Opportunity at Close Won.

## 3. Process Summary
Stage
Action Required
Ownership Assignment
Billing Opt-In
Sales Rep answers &quot;Was Ratecard Captured?&quot;
-
Ratecard NOT Captured
Sales Follow-up Scheduled Date Required
-
EIN/Bank Info Not Captured
Cannot Close Win the Billing Upsell Opportunity
-
If SaaS is NOT Activated
Assign Billing Onboarding Record to same OBS as SaaS
Same OBS as SaaS
If SaaS is Activated &amp; Ratecard NOT Captured
Assign Billing Onboarding Record to Queue
Standard Onboarding Path Queue
Sales Rep Captures Ratecard Later
Schedules OBS Call in Chili Piper
OBS assigned via Chili Piper Round-Robin
Ratecard Captured at Close Won
Sales Rep checks SaaS Onboarding Status and manually enters OBS details
OBS manually assigned by Sales Rep

## 4. Salesforce Build -

# Final Summary &amp; Process Documentation – AE &amp; Billing Post-CW Check-In Fields
#### Overview
As part of tracking AE Post-CW Check-Ins, we have implemented new fields on both the Contact and Combined Funnel objects. These fields are updated through Chili Piper meeting types and automation flows, ensuring accurate tracking of scheduled and completed follow-ups for both SaaS/Gov and Billing Upsell customers.

### Fields Created &amp; How They Work
#### On Contact (Source of Truth for Scheduled &amp; Completed Dates):
AE Post-CW Check-In Scheduled Date → Updated when a “Sales - BW Post Sale 15 Day Followup” meeting is scheduled via Chili Piper.
AE Post-CW Check-In Completed Date → Populated when the rep marks the event as completed in Salesforce (via automation).
Billing AE Post-CW Check-In Scheduled Date → Updated when a “Billing Upsell - BW Post Sale 15 Day Followup” meeting is scheduled via Chili Piper.
Billing AE Post-CW Check-In Completed Date → Populated when the rep marks the event as completed in Salesforce (via automation).
#### On Combined Funnel (Formula Fields Referencing Contact Data):
AE Post-CW Check-In Scheduled Date → Pulls from the Primary SaaS Contact’s AE Post-CW Scheduled Date.
AE Post-CW Check-In Completed Date → Pulls from the Primary SaaS Contact’s AE Post-CW Completed Date.
Billing AE Post-CW Check-In Scheduled Date → Pulls from the Primary Billing Contact’s Billing AE Post-CW Scheduled Date.
Billing AE Post-CW Check-In Completed Date → Pulls from the Primary Billing Contact’s Billing AE Post-CW Completed Date.

### Automation &amp; Process Flow
Scheduling a Follow-Up Meeting:
When an AE schedules a Chili Piper meeting, the appropriate Scheduled Date field is updated on the Contact record.
Meeting Types Used:
SaaS/Gov: “Sales - BW Post Sale 15 Day Followup”
Billing Upsell: “Billing Upsell - BW Post Sale 15 Day Followup”
Marking the Meeting as Completed:
Once the AE marks the event as completed, the Event Standard Path Flow updates the corresponding Completed Date on the Contact record.
Data Reflection on Combined Funnel:
The formula fields on the Combined Funnel reference the Primary SaaS Contact or Primary Billing Contact and automatically display the correct Scheduled and Completed Dates from the Contact record.

### Key Decisions &amp; Handling Updates
✔️ Overwriting Scheduled/Completed Dates:
If a meeting is rescheduled or scheduled for a win-back customer, the Scheduled Date should update, and the Completed Date should be cleared (null).
This applies to both SaaS/Gov and Billing Upsell follow-ups.
✔️ Separate Tracking for Billing Upsell:
Since Billing Upsell has a different Chili Piper meeting type, two new fields were created on Contact to separately track these follow-ups.

# Multi-Site OBS Ownership Updates
An update has been made to automate multiple-site OBS ownership changes when scheduling the &quot;PILOT: OBS Multi-Site: Brightwheel Setup - 45 Min&quot; meeting via Chili Piper.
Update Details:
When this meeting is scheduled using Chili Piper Round Robin, the event is created in Salesforce and assigned to the selected OBS.
If the event is related to a Multi-Site Child Account, the automation:
Identifies all other child accounts under the same parent account.
Updates the Account Owner and OBS Owner on the parent and all child accounts.
Updates the Combined Funnel Owner to the assigned OBS on all the related Combined Funnels.
If the event is related to a Multi-Site Parent Account, the automation:
Identifies all related child accounts under that parent.
Updates the Account Owner and OBS Owner across all accounts in the hierarchy (parent + children).
Updates the Combined Funnel Owner to the assigned OBS on all the related Combined Funnels.
