# How It Works | Passback to Sales - Billing at Risk Case
## Why This Was Created: Business Need &amp; Functional Design Intent
### Background
As part of the Post Closed-Won (Post CW) Workflow, Brightwheel recognized a gap in visibility and ownership when a customer’s Billing Onboarding becomes at risk after an Opportunity reaches the stage ‘Onboarding in Progress’.
To address this, a new Case Record Type called “Passback to Sales - Billing at Risk” was introduced. This enhancement ensures that sales representatives are proactively notified and accountable when a Billing-related onboarding issue emerges, even after their Opportunity is technically &quot;won.&quot;

## Business Process Overview
When OBS identifies that Billing Onboarding is at risk, a Case is created and assigned to the Opportunity Owner. This prompts the sales rep to take necessary corrective action. The Case includes a guided process, predefined stages, and logging fields to track rep response and resolution.

## New Record Type
Record Type Name: Passback to Sales
Type:  Billing at Risk
Object: Case
Purpose: Triggered by OBS to return action items to the AE during the Onboarding in Progress stage

## New Fields
Field Label
API Name
Data Type
Who Updates It
Notes
Passback to Sales Sub Type
Passback_Sub_Type__c
Picklist
OBS
Values: Unresponsive, Objection
Passback to Sales Sub Type Reason
Passback_Sub_Type_Reason__c
Picklist
OBS
Required if Objection is selected. Values: Pricing, Product, Timing, Adoption
OBS Billing At-Risk Notes
OBS_Billing_At_Risk_Notes__c
Long Text Area
OBS
Required notes field when creating Case
AE Billing At-Risk Notes
AE_Billing_At_Risk_Notes__c
Long Text Area
AE
Used to communicate resolution outcome back to OBS
Scheduled OBS Call Date
Scheduled_OBS_Call_Date__c
Date (Formula?)
AE
Logged when scheduling follow-up
OBS Owner
OBS_Owner__c
Lookup(User)
System/OBS
References the OBS initiating the case

## New Support Process
Support Process Name: Passback to Sales
### Stages for Support Process:
New
Assigned
Working
Auto Closed (Closed)
Closed: Customer Resumed OB (Closed)
Closed: Customer Unresponsive (Closed)
Closed: Opted Out (Closed)

## New Page Layout
Tailored layout to surface only relevant fields for OBS and AE roles
Required fields dynamically shown based on Sub Type and Status

## Lightning Page Layout
Includes tabs for AE Notes, OBS Notes, and Case Timeline
Related Combined Funnel and Opportunity visible

## Validation Rules
### Sub Type Reason Required
Condition: If Sub Type is &quot;Objection&quot;, then Reason must be selected
Error Message: &quot;Please select a Passback to Sales Sub Type Reason when Sub Type is Objection.&quot;
### OBS Notes Required
Condition: OBS Billing At-Risk Notes must be filled in when creating the Case
Error Message: &quot;OBS Billing At-Risk Notes are required to create a case.&quot;
### BillingAtRiskClosed_Opted_Out
Condition: When Status = 'Closed: Opted Out', AE Billing At-Risk Notes and Billing Opt Out Reason must be entered
Error Message: &quot;To close the case as 'Opted Out', please enter AE Billing At-Risk Notes and select a Billing Opt Out Reason.&quot;
### BillingAtRiskClosed_Resumed_Onboarding
Condition: When Status = 'Closed: Customer Resumed OB', AE Billing At-Risk Notes and Scheduled OBS Call Date (or future onboarding meeting date) must be present
Error Message: &quot;To close the case as 'Customer Resumed OB', you must enter AE Billing At-Risk Notes and provide an OBS Call Scheduled Date if no future onboarding meeting is scheduled.&quot;
### BillingAtRiskClosed_Unresponsive
Condition: When Status = 'Closed: Customer Unresponsive', AE Billing At-Risk Notes must be entered
Error Message: &quot;AE Billing At-Risk Notes are required when closing the case as 'Customer Unresponsive'. Please summarize your outreach efforts.&quot;

## Action Button: Combined Funnel
New custom &quot;Billing at Risk&quot; button on Combined Funnel object
Allows OBS to create the Case directly from the CF record

## Automation Flows
### 1. Case Creation Flow (Triggered by OBS via CF Action)
Screen Flow initiated from Combined Funnel
Prepopulates Opportunity and Account
Assigns to Opportunity Owner
Initializes stage as &quot;New&quot;
Sends Slack notifications to AE and their manager
Updates Combined Funnel to reflect &quot;Billing at Risk&quot; status
### 2. Case Closure Flow (Triggered by AE)
Record-triggered flow that runs on Case update
Evaluates the Case's &quot;Closed Status&quot;
If found:
Closed: Resumed Onboarding → Updates CF Billing Onboarding to Active
Closed: Unresponsive → Updates CF Billing Onboarding to Unresponsive
Closed: Opted Out → Updates CF and Opportunity with opt-out fields
Calls subflow to evaluate and sync Opportunity post-CW SSPR logic
