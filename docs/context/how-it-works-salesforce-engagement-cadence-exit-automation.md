How it works |  Salesforce Engagement Cadence Exit Automation

## Overview
To support the Exit Solutions initiative—automation that removes Leads or Contacts from a cadence when key data changes on the Lead, Contact, Account, or Opportunity—we introduced two Salesforce fields that make cadence participation trackable and actionable for automation.
These fields provide:
Visibility into which cadence record was most recently entered
A standardized “label” that groups cadences by exit criteria logic
A scalable foundation for Flow-based exit handling without hard-coding cadence-by-cadence rules
## Fields Created
### Most Recent Cadence Entered (Lead, Contact)
Purpose: Stores the most recent Cadence a Lead/Contact is enrolled in for downstream automation (exit logic).
Automation: Apex + Flow updates the field in near-real-time (~10s) during enrollment and clears it upon Cadence completion.
Replaces: Prior “Flow on the first Cadence step” workaround (delayed because it required the user to complete step 1).
### Cadence Label (Cadence, Lead, Contact)
Purpose: Standardized Cadence categorization; primary key used by the new exit-flow logic.
Automation: The same process populates the Cadence Label on the Lead/Contact at enrollment and nulls it on completion.

### SE Tag (Lead, Contact)
Purpose: System tracking/troubleshooting field used by SysOps to identify which Flow last processed the Lead/Contact (supports traceability and debugging).
Usage: Updated by automation to stamp the most recent processing Flow/context.

Exit Flows

Sales :

Flow Name
Cadence Label
Entry Criteria
Lead - After Save - Sales Missed Demo Cadence Exit
Sales - Missed Demo
Lead is updated (After Save)
AND Cadence_Label__c = Sales - Missed Demo
AND Demo_Call_No_Show__c = TRUE
AND DoNotCall ≠ TRUE
AND LOGIC_Owned_by_queue__c = FALSE
Lead - After Save - Sales Starter Cadence Exit
Sales - Start Cadence
OR
Sales - Missed Demo
AND Lead is updated (After Save) AND Cadence_Label__c is Sales - Start Cadence OR Sales - Missed Demo AND (any one of these exit signals is true): • Do_Not_Contact__c = TRUE • LOGIC_Owned_by_queue__c = TRUE • Most_Recent_Disposition__c starts with “REC - ” • Most_Recent_Disposition__c starts with “UNQ - ” • Most_Recent_Disposition__c starts with “CC - ” • Most_Recent_Disposition__c starts with “PD - ” • Status = Connected • Status = Recycled • Status = Unqualified • Outreach_stage__c starts with “Recycled ” • Outreach_stage__c starts with “Unqualified” • Outreach_stage__c starts with “Connected” • Manual_Stage_Update__c starts with “Recycled ” • Manual_Stage_Update__c starts with “Unqualified” • Manual_Stage_Update__c starts with “Connected” • ( No_Show_CP__c = TRUE AND Cadence_Label__c is Sales - Start Cadence )
Contact - After Save - Post CW Cadence Exit
Sales - Missed Demo
AND Contact is updated (After Save) AND Cadence_Label__c = Sales - Missed Demo AND (any one of these exit signals is true): • Do_Not_Contact__c = TRUE • LOGIC_Owned_by_queue__c = TRUE • Most_Recent_Disposition__c starts with “REC - ” • Most_Recent_Disposition__c starts with “UNQ - ” • Most_Recent_Disposition__c starts with “CC - ” • Most_Recent_Disposition__c starts with “PD - ” • Most_Recent_Disposition__c contains “Rescheduled” • Outreach_stage__c starts with “Recycled ” • Outreach_stage__c starts with “Unqualified” • Outreach_stage__c starts with “Connected” • Manual_Stage_Update__c starts with “Recycled ” • Manual_Stage_Update__c starts with “Unqualified” • Manual_Stage_Update__c starts with “Connected” Note: this one is configured to only run when the record changes in a way that newly meets the criteria.
Contact - After Save - Sales Starter Cadence Exit
Sales - Start Cadence OR Sales - Missed Demo
AND Contact is updated (After Save) AND Cadence_Label__c is Sales - Start Cadence OR Sales - Missed Demo AND (any one of these exit signals is true): • Do_Not_Contact__c = TRUE • LOGIC_Owned_by_queue__c = TRUE • Most_Recent_Disposition__c starts with “Rec” • Most_Recent_Disposition__c starts with “UNQ - ” • Most_Recent_Disposition__c starts with “CC - ” • Most_Recent_Disposition__c starts with “PD - ” • Outreach_stage__c starts with “Recycled ” • Outreach_stage__c starts with “Unqualified” • Outreach_stage__c starts with “Connected” • Manual_Stage_Update__c starts with “Recycled ” • Manual_Stage_Update__c starts with “Unqualified” • Manual_Stage_Update__c starts with “Connected” • No_Show_CP__c = TRUE AND Cadence_Label__c is Sales - Start Cadence )

Opportunity - After Save - Post CW Cadence Exit
Sales - Post Demo (on the related Contact)
AND Opportunity is updated (After Save) AND Record type is SaaS Opportunity OR SaaS Child Opportunity AND Contact__c is not blank AND IsClosed = TRUE AND StageName changed AND stage moved along one of these paths: • Prior stage = SSPR Collection AND New stage = Onboarding In Progress OR Completed • Prior stage = OB Eligible AND New stage = Onboarding In Progress OR Completed Then it only proceeds if the related Contact has Cadence_Label__c = “Sales - Post Demo”.
Opportunity - After Save - Post Demo Cadence Exit
Sales - Post Demo (on the related Contact)
AND Opportunity is updated (After Save) AND Opportunity_Record_Type__c = SaaS OR SaaS Child AND Contact__c is not blank AND StageName changed AND New StageName = Closed Won OR Closed Lost Then it only proceeds if the related Contact has Cadence_Label__c = “Sales - Post Demo”.
Contact - After Save - Post Demo Exit
Sales - Post Demo
AND Contact is updated (After Save) AND Cadence_Label__c = Sales - Post Demo AND (any one of these exit signals is true): • Do_Not_Contact__c = TRUE • LOGIC_Owned_by_queue__c = TRUE • Most_Recent_Disposition__c starts with “REC -” • Most_Recent_Disposition__c starts with “UNQ - ” • Most_Recent_Disposition__c starts with “CC - ” • Outreach_stage__c starts with “Recycled ” • Outreach_stage__c starts with “Unqualified” • Outreach_stage__c starts with “Connected” • Manual_Stage_Update__c starts with “Recycled” • Manual_Stage_Update__c starts with “Unqualified” • Manual_Stage_Update__c starts with “Connected”
Add Retention Flows

### EC Flows :

Flow Name
Cadence Label
Entry Criteria
Contact – After Save – EC Sales/Retention Cadence Exit Flow
EC – Sales StarterEC – Sales Missed DemoEC – Sales Post DemoEC – Retention Starter
After Save (Contact)EC Sales Cadences:• Cadence_Label__c ∈ {EC – Sales Starter, EC – Sales Missed Demo, EC – Sales Post Demo}• AND (Do_Not_Contact__c = TRUE OR New_Case_Type__c ∈ {Cancel Request, EC Cancel Request})EC Retention Starter:• Cadence_Label__c = EC – Retention Starter• AND (Do_Not_Contact__c = TRUE OR Most_Recent_Case_Status__c contains Saved, Canceled, Closed, Auto Closed)
Opportunity – After Save – EC Sales Cadence Exit
EC – Sales StarterEC – Sales Missed DemoEC – Sales Post Demo
After Save (Opportunity)• RecordType = Experience Curriculum Opportunity• ContactId ≠ null• Contact.Cadence_Label__c ∈ EC Sales cadences• AND (StageName ∈ {Demo Scheduled, Rescheduling, Verbal Agreement, Delayed Start, Closed Won, Closed Lost}OR Experience_Curriculum_Demo_Status__c ∈ {Scheduled, Rescheduled})
Contact – After Save – EC OBS Cadence Exit
EC – OBS GenericEC – OBS Missed WebinarEC – OBS Post WebinarEC – OBS Starter
After Save (Contact)• Cadence_Label__c starts with “EC – OBS”• AND (Do_Not_Contact__c = TRUE OR any webinar scheduled date ≤ TODAY( )OR any webinar completed date is populated)
Onboarding – After Save – EC OBS Cadence Exit
Primary Contact in any active cadence
After Save (Onboarding__c)• RecordType = Experience Curriculum Onboarding• Primary_Contact__c ≠ null• AND (EC_Customer_Path__c ∈ {Silver Onboarding, Declined Training, Self Guided Onboarding}OR First_Lesson_Start_Date__c ≤ TODAY())
Account – After Save – EC OBS Cadence Exit
EC – OBS* (any OBS cadence)
After Save (Account)• EEL_Customer_Status__c IS CHANGED• EEL_Customer_Status__c = “Canceled Customer”

BU Flows :

Flow Name
Cadence Label
Entry Criteria
Contact – After Save – BU Cadence Exit Flow
BU - General
After Save (Contact): Cadence_Label__c = “BU - General” AND (Do_Not_Contact__c is changed OR New_Case_Type__c is changed OR Revio_Tag__c is changed OR Declined_SaaS_Training__c is changed OR SaaS_Activation_Funnel_Stage_2024__c is changed OR Cadence_Tag__c = “Remove” OR Cadence_Tag__c is changed). If an active ActionCadenceTracker exists for the Contact (State ≠ Complete/Error), the flow proceeds and calls the BU exit subflow.
Account – After Save – BU Cadence Exit Flow
BU - General
After Save (Account): (Account.Type = “Cancelled Customer” OR CSM_Owner1__c is changed OR CSM_Owner1__c becomes blank). Flow then queries related Contacts where Contact.AccountId = Account.Id AND Contact.Cadence_Label__c = “BU - General”. For each Contact, if the Contact has an active ActionCadenceTracker (State ≠ Complete/Error) AND the Cadence Name starts with “BUO”, the flow sets Contact.Cadence_Tag__c = “Remove” and updates the Contacts in bulk.
Subflow – BUO Cadence – Exit
BU - General
Invoked Subflow: Called from BU exit flows when a Contact is identified as active in a BUO cadence. Subflow evaluates BU exit criteria and removes the Contact from the active cadence when criteria is met.
