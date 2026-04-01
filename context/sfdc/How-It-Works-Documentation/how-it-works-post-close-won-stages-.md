# Opportunity Post Close Won Stage Automation
Documentation Created by - Lakhwinder Kaur
Date - August 2025

### Business Process Solution Overview
This solution introduces a scalable and automated workflow to support Sales Representatives in managing their expanded post-sale responsibilities. Specifically, it streamlines the collection of SSPR (Student, Staff, Parent, Ratecard) information and standardizes the OBS (Onboarding Services) handoff process in the Post Closed-Won (CW) phase.
In addition, the solution enhances pipeline visibility by introducing automated Opportunity Stages and Statuses — enabling reps to accurately track progress and identify blockers from Closed Won through to full Activation.
### Links
### Full Functional Design &amp; Requirements for Post CW Workflow - Link
Post CW Process SysOps Training Part 1 - July 2025
Post CW Process SysOps Training Part 2 - July 2025
### August 2025 Recent Updates:
SSPR Collection Stage only requires the evaluation of  2 fields veruse 6 fields. Only evaluates the Saas Onboarding Eglible Date and Billing Onboarding Eligible Date on the School Object.
2 New onboarding paths are now included in the Post CW Stage process. 1. Onboarding path = Self-Serve 2. Onboarding Path = Site-add AND Saas Declined training = true

### System Components:
#### New Opportunity Stages: The existing Sales Process was expanded with the four New Opportunity Stages :
SSPR Collection
OB Eligible
Onboarding In Progress
Completed

Because these stages are categorized as Closed stages, they do not appear on the path unless selected as the current stage.

#### New Fields On Opportunity Object:

Post CW Status - Picklist Field ( Post_CW_Status__c) - This field provides a sub-status that complements the main Opportunity Stage, offering more granular visibility into where an Opportunity stands within the Post Closed-Won (CW) workflow. It allows sales reps and stakeholders to track progress, identify blockers, and understand the current state of onboarding and activation.

*Definition of each stage in the requirement document - Link

Opportunity Stage
Post CW Status Values
Closed Won
— (No additional status)
SSPR Collection
1 - Not Started
2 - Partially Complete
OB Eligible
1 - Needs OBK Call Scheduled
Onboarding In Progress
1 - In Progress
2 - OBS Owned At Risk
3 - Open Cancel Case
4 - SaaS Activated, Billing Incomplete
5 - Billing Activated, SaaS Incomplete
**additional values on the screenshot below**
Completed
1 - Fully Activated
2 - Churned

Complete List of Post CW Status Values as of August 2025:

Billing Opt Out Override - Checkbox ( Billing_Opt_Out_Override__c) - Indicates if a customer initially opted into billing at Opportunity Close Won later opts out during post-CW stages. ** Billing Opt out Reason is required when Billing Opt Out Override = True**

### Flows:

[New] School_Subflow_Sync_Opportunity_Post_CW_Stages : (Renamed to Subflow - Sync Opportunity Post CW Stages )
This is the primary subflow responsible for managing Post CW Stage and Post CW Status updates. It is invoked from Flows associated with the Account, Opportunity, School, and Combined Funnel objects.
This subflow contains the core logic that determines and updates the appropriate Post CW Stage and Status based on field values and conditions across related records.
It is triggered across various stages through parent flows operating on different objects, ensuring consistent and centralized logic for all post-transitions.
Important Detail - Need to have the Opportunity and Account Id passed to the subflow from wherever it’s triggered from.

[New] School Object - After Save - Post CW Opp Stages
This flow runs after a School record is created or updated, typically as part of the overnight data sync or when key fields change. It evaluates the Post Closed-Won (CW) logic to determine and update the appropriate Opportunity Stage and Post CW Status.
#### Entry Criteria - This flow is triggered when a School record is created or updated, and the following conditions are met:

OR(
IsNEW(),
ISCHANGED({!$Record.SaaS_Adding_Students_Stage_Met_Date__c}),
ISCHANGED({!$Record.SaaS_Adding_Parents_Stage_Met_Date__c}),
ISCHANGED({!$Record.SaaS_Adding_Staff_Stage_Met_Date__c}),
ISCHANGED({!$Record.Billing_Setting_Up_Bills_Stage_Met_Date__c}),
ISCHANGED({!$Record.SaaS_Activation_Funnel_Stage_2024__c}),
ISCHANGED({!$Record.Billing_Activation_Funnel_Stage_2024__c}),
ISCHANGED({!$Record.Cancellation_Date__c})
)
The flow retrieves the Account associated with the School record.
Important: Each School should be linked to only one Account. If multiple Accounts are associated with the same School, the automation may fail to locate the correct Opportunity, leading to inaccurate stage and status updates.
The flow then retrieves the correct Opportunity in one of the Post CW Stages to determine and evaluate which next stage to move to. Example, if the opportunity was at the SSPR Collection Stage, and the Cancellation date was populated on the School Object, then the opportunity would move to Completed - Churn.
This Flow also checks the onboarding path to determine if the opportunity needs to be evaluated for SSPR Post CW stages. Standard is the only Onboarding Path that is considered for evaluation. ** The BNP logic was also built into this flow but we have a filter to block that path since we don’t plan on launching this for 4/1/2025.
August 2025 - To reduce the workload for updating the Post CW Stage Logic in two flows, we added the main subflow to this flow. This means only the subflow needs to be updated for the stage logic, but always check the entry criteria when making changes.

[New] Opportunity - After Save - First Flow - Post CW Stage Sync - ( Opportunity_Before_Save_Post_CW_Stage_Sync)
This is the first flow that evaluates the initial Post CW Stage after an Opportunity is marked Closed Won. It includes a Wait component to allow time for related records—such as multi-site child Accounts, child Opportunities, and child Combined Funnels—to be created. These records are generated by the initial Opportunity Close Won Screen Flow and a separate flow that handles child record creation.
Entry Conditions:

Flow Logic:
The flow first gets the Account related to the triggered Opportunity. Then, it checks whether a related School exists.
If a School is found, the flow calls the Subflow – Sync Opportunity Post CW Stages to evaluate SSPR fields (e.g., SaaS Adding Stage Met Dates) and determine the correct Post CW Stage and Status.
If no related School exists (e.g., in the case of a new customer where the School record will sync overnight), the Opportunity is temporarily set to the default Post CW Stage: SSPR Collection.
Later, when the School record syncs overnight, the School Object - After Save - Post CW Opp Stages flow will re-evaluate the Opportunity and advance it to the correct Post CW Stage based on updated data.
[Update] Event - After Save - Standard Onboarding Path -
This flow was updated to support the Post CW Workflow by automatically updating the OBS Scheduled Call Date field on the related Opportunity when the Pilot OBS Setup Call/Meeting is scheduled and the Event is created in Salesforce. Also updates the Combined Funnel Owner, which then updates the Accoun Owner and OBS Field.
OBS Scheduled Call Date  - This field is a required input for Opportunities in the OB Eligible stage. Once populated, it allows the Opportunity to progress to the Onboarding In Progress stage.
Other events this flow is triggered on - Sales Follow-up Calls

[New] Opportunity - After Save - Triggers on Opp Post CW Opp Stage
This flow is a record trigger flow that is triggered based on the following:
Billing Opt-Out Override
OBS Call Scheduled Date
When triggered, the flow calls the Subflow – Sync Opportunity Post CW Stages, which evaluates the current field values and determines the appropriate Opportunity Stage and Post CW Status for the Opportunity.

[New] Account - After Save - Opp Post CW Stage Sync
This flow is a record trigger flow that is triggered based on the following:
Number of Open Cancel Cases
Bill Rate Upload Date
School_c
If any triggers are changed, the flow runs and evaluates the post-cw stages by calling on the subflow.
Entry Condition :

[New] Combined Funnel - After Save - Opportunity Post CW Stage Sync
This is a record-triggered flow on the Combined Funnel object. It is triggered when either of the following fields is updated:
SaaS Onboarding Status
Billing Onboarding Status
These status changes are critical for determining the current Onboarding Stage of the related Opportunity.
Once triggered, the flow calls the Subflow – Sync Opportunity Post CW Stages, which evaluates the updated onboarding data and updates the corresponding Post CW Status and Opportunity Stage accordingly.

### Manually Update Opportunity Stage after CW:
### If you need to manually update the Opportunity Stage after Closed Won or update the Post CW Status after Close Won, you must check the checkbox on the Opportunity labeled “Post_CW_Set_by_Automation__c” to true. This enables you to edit those fields. We have validation rules in place to prevent users from changing the Post CW Stages and Post CW Status. (Currently, these rules are only on the SaaS Opportunity page layout but can be accessed via Salesforce Inspector.)

Stage Logic from requirement Document :

Stage
Post CW Status
Definition
Closed Won

Opportunity is Closed Won, unchanged from our definition today
SSPR Collection
Not Started
Partially Complete
This stage will reflect the Opportunity needing SSPR collection steps. The respective Post CW Status can be defined as:

New Logic -

Saas Onboarding Eligible Date
Billing Onboarding Eligible Date

**Old Logic**
According to the School Object fields, none of the steps have been completed.
‘SaaS Adding Students Stage Met Date’
‘SaaS Adding Parents Stage Met Date’
‘SaaS Adding Staff Stage Met Date’
Billing Rate Uploaded Date (Account) or Billing Setting Up Bills Stage Met Date (CF)
According to the the fields above at least 1 step has been completed by not all steps

Note: ‘Billing Status at CW’ = Opted In will need to equal ‘Opted In’ in order for the system to consider the need for Bill Rate Uploaded Date as a requirement for SSPR Collection Stage.

Post CW Billing Override
Need a way for the AE to indicate that the customer will no longer be setting up billing so they can become OBE, additionally this can be leveraged if an Billing At Risk is not solved by the AE. We are going to create a field Billing Opt Out Override which can be checked by reps to indicate this.

OB Eligible
Needs OBK Call Scheduled
This stage will reflect the Opportunity being completed of all SSPR collections but will ensure the OBS Kickoff Call is scheduled.

If any of the fields below as Null, the Opportunity will remain in this Stage and Post CW Status:

Initial OB Kickoff Call Scheduled Date (NET NEW field)
Onboarding In Progress
In Progress
AE Owned At Risk
OBS Owned At Risk
Open Cancel Case
SaaS Activated, Billing Incomplete
Billing Activated, SaaS Incomplete

This stage will reflect the Opportunity having SSPR collection completed and all calls scheduled. The respective Post CW Status values will be defined as:
CF Onboarding Status = Active. Onboarding is in progress and the owner of all activities is the OBS.

CF Billing Onboarding Status= review logic here

Number of Open Cancel Request Cases =&gt;1
Customer is At Risk of cancellation and being worked by Accounts team

‘SaaS Activation Funnel Stage’ = ‘Activated’ but ‘Billing Activation Funnel Stage’ is not ‘Activated’
‘Billing Activation Funnel Stage’ = ‘Activated’ but ‘SaaS Activation Funnel Stage’ is not ‘Activated’

Note: 3, 4, 5 ,6  will only be applicable for ‘Billing Status at CW’ = ‘Opted In’ customers
Completed
Fully Activated
Churned
If SaaS only, then SaaS Activated, If Billing then SaaS &amp; Billing Activated
‘Cancelation Date’ on SO &gt; Close Date of Opportunity

### Onboarding In Progress Post CW Status Mapping - OBS Owned At Risk
We want to map the Billing Onboarding Status and SaaS Onboarding Status to the Post CW Status for the Onboarding In Progress Stage:

If Billing Status at CW = Opt In and Billing Opt Out Override = FALSE then,
If at least one of the Status values from Billing Onboarding Status and SaaS Onboarding Status =
Postponed, Unresponsive, SaaS At Risk, Billing At Risk, Requesting Postpone - Awaiting Approval, Requesting Opt Out Awaiting Approval, then (OBS Owned At Risk)
Otherwise, both both being Active results in Post CW Status = (In Progress)

SaaS Only, Billing Status at CW NOT Opt in or Billing Opt Out Override = TRUE then,
Postponed, Unresponsive, SaaS At Risk, Billing At Risk, Requesting Postpone - Awaiting Approval, Requesting Opt Out Awaiting Approval, then (OBS Owned At Risk)
Active results in Post CW Status = (In Progress)

June 2025 Update:
Bluffer for Stage SSPR Adding Met dates for CW - 4 days

Override Process for OBE: This process can be used when adding SaaS or billing requirements for the SSRP Stage needs to be skipped, or a customer may not be able to meet those requirements. On the opportunity, we have two new fields: 'Approved Accelerated Onboarding Date' and 'Approved OBE Override Date'. If either field is filled in, it will trigger a flow to skip the SSRP Stage and move to the next stage, such as 'OB Eligible' or 'Onboarding in Progress', if an OBS call has already been scheduled. There's a permission set to allow editing these two fields, currently handled only by Lauren.

1. 'Approved Accelerated Onboarding Date'
-Purpose: Identify instances &amp; date of when a customer is approved to be passed to OBS without SSPR completed; comp still to be based on OBE date fields
-Location: Opportunity &amp; CF
-Field type: Date field
-Edit permissions: OBS Managers/Leaders, OB Ops
2. 'Approved OBE Override Date'
-Purpose: Identify instances &amp; date of when a customer will never be able to meet OBE thresholds so OBE override was approved; to be used for comp calcs
-Location: Opportunity &amp; CF
-Field type: Date field
-Edit permissions: OBS Managers/Leaders, OB Ops

August 2025 :

SSPR Logic Update – Go-Live: August 5, 2025
Purpose
Simplify the logic that controls when a record enters the SSPR stage in the onboarding process.
What Changed
Previous Logic:
Entry into SSPR depended on checking if the school had met thresholds for:
Adding Students
Adding Parents
Adding Staff
Billing Upload/Rate Care uploaded ( if billing is opted in)
Updated Logic:
Now only requires the population of either:
SaaS Onboarding Eligible Date, or
Billing Onboarding Eligible Date (only if Billing is opted in)
On the School Object
Self-Self / Declined Training - Post-Close Won Flow Update – Go-Live: August 5, 2025
Scope
Applies only to the following Opportunity Record Types:
SaaS
SaaS Child
Government Licensee
Gov Child
Trigger Conditions
Onboarding Path is Self-Serve or
Onboarding Path is Site-Add AND Declined SaaS Training is True
Applied to any opportunities with a closed date greater than 8/3/2025.
Onboarding Flow (3 Stages)
SSPR
Changes to SSPR after 5 minutes the Opportunity is Closed Won
Begins when Opportunity is Closed Won
SaaS Onboarding Eligible Date is required
If Billing is opted in, Billing Onboarding Eligible Date is also required
No OBS owner is assigned at this stage
Onboarding In Progress
Triggered once all required OBE fields are populated
OBS owner is assigned via round-robin based on:
Customer type (Core or Government), not enterprise
School type (Single Site or Multi-Site)
If Multi-site, if the other accounts are still onboarding, then assign the same OBS, otherwise RR.
Completed
Final stage with sub-status options:
Fully Activated
Churned
Ownership at Closed Won
Combined Funnel is routed to the Standard Onboarding Path Queue
••Account is routed to the Account Queue

Common Trouble Shooting Steps:

The Opportunity Stage did not change. Saas, Saas Child, Gov Licensee or Gov Child Opportunity with the onboarding path of Standard or self-serve or Site add with Saas declined training did not move to SSPR Collection stage after 5 minutes of closing winning.
Check is Saas Opportunity was closed by the Screen Flow by checking the Date/Time Closed by Screenflow field on the Opportunity - we used in the first flow criteria to update the stage, so if that is missing could be the reason why it didnt change.
Onboarding Path wasn’t Standard or self-serve or Site add with Saas declined training At the Time of CW and was changed afterwards.
Post CW Stage Incorrect :
Work backwards. Review the School Object.
Check the Saas Activation Date. If it’s populated and it’s greater than the Opportunity Closed Date and Billing is not opted-in OR Billing opt out Override = True . Then change the Opp Stage to Completed and Post CW Status = Fully activated
If Billing is also opted-in, check that the Billing Activation Date is populated and it’s greater than the Opportunity Closed Date. Then change the Opp Stage to Completed and Post CW Status = Fully activated
If Billing is opted-in and only Saas Acitvate date is populated and Billing opt out Override = False, then the Opportunity Stage = Onboarding in progress and post cw status = Saas activated only
If OBS Scheduled Call is blank on the Opportunity, and the Saas Onboading Eligibility date is populated ( billing not opted-in). Opportunity Stage = OB Elgible  and Post CW Status = Calls needed.

Related Processes:

Passback to Sales Billing Cases
SSPR Logic Update Asana ticket
Declined Training: SSPR Opp Stages, POS + Upsell OBS Assignment
