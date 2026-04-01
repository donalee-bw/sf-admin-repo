# Automation Inventory

> Last refreshed: 2026-03-30 (from `bwfullcopy` sandbox)
>
> Totals: **347 active AutoLaunchedFlows**, **37 Screen Flows**, **13 active Process Builders/InvocableProcesses** (deprecated), **162 active Apex triggers** (custom + managed packages), **~115 active validation rules**

---

## Active flows

Flows are grouped by primary object. Subflows and utility flows are noted separately. Only record-triggered and scheduled flows are listed here — screen flows are in the next section.

### Account (28 flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| Account - Before Save - Update Fields | Record-Triggered | Before Save | Sets OBS Owner = Account Owner and stamps auto-convert values |
| Account - Before - Previously Churned | Record-Triggered | Before Save | Flags re-churned accounts when Type changes back to Cancelled Customer |
| Account - After Save - BU Cadence Exit | Record-Triggered | After Save | Exits contacts from Billing Upsell Owner cadences when ownership changes |
| Account - After Save - Case Engt Owners Update | Record-Triggered | After Save | Syncs SaaS Owner / Billing Upsell Owner onto open engagement cases |
| Account - After Save - Core Onboarding - BNP Cadence Removal | Record-Triggered | After Save | Exits contacts from BNP cadences on Account-level changes |
| Account - After Save - EC OBS Cadence Exit | Record-Triggered | After Save | Exits contacts from EC OBS cadences |
| Account - After Save - EDU Owner UPDATE | Record-Triggered | After Save | Propagates EDU Owner from parent to child accounts via subflow |
| Account - After Save - Generic Updates | Record-Triggered | After Save | Catch-all for forced Account field updates (SFDC-side patching) |
| Account - After Save - Onboarding Cadence Exit | Record-Triggered | After Save | Exits cadences when OBS Owner moves to Account Queue |
| Account - After Save - Opp Post CW Stage Sync | Record-Triggered | After Save | Syncs post-CW Opportunity stages when Account-level triggers fire (e.g., BNP Intro Call Date) |
| Account - After Save - Owner Check / Validate SaaS Owner | Record-Triggered | After Save | Validates SaaS Owner is a valid active user |
| Account - After Save - Parent/Child Number of School Sync | Record-Triggered | After Save | Keeps `Number_of_Schools__c` in sync between parent and child accounts |
| Account - After Save - Premium ECE with New School Object | Record-Triggered | After Save | Updates premium school fields when the School Object ID changes |
| Account - After Save - Update Fields Sync | Record-Triggered | After Save | General field sync: timestamps, related record updates |
| Account - After Save - Cadence {EDU} Exit | Record-Triggered | After Save | Exits EDU cadences |
| Account - After Save - BU Cadence OBS Exit | Record-Triggered | After Save | Exits OBS/GOBS cadences |
| Account - After Save - Case Engt Owners Update | Record-Triggered | After Save | Updates owners on engagement cases when Account owners change |
| Account - Trigger Org Sync Flow | Record-Triggered | After Save | Syncs School Organization record when Account fields change |
| Account - update related payer account on open opps | Record-Triggered | After Save | Updates Related Payer Account on open Opportunities |
| Account Owner Changed - Update Related Contacts Owner | Record-Triggered | After Save | Cascades Account owner change to related active school user Contacts |
| CF - Cancelled Customer - Update CF, Tasks, Opps and Cases | Record-Triggered | After Save | On Type = Cancelled Customer: closes CF onboarding fields, tasks, opps |
| CL ALA - Assigned, Not Worked - Instant Resell Eligible | Record-Triggered | After Save | Marks account for instant resell if assigned but not worked |
| CL ALA - Update Related Contacts | Record-Triggered | After Save | Clears sales/no-show fields on contacts when CL ALA fires |
| Onboarding Start Date - Billing / SaaS - Account to Onboardings | Record-Triggered | After Save | Pushes updated Onboarding Start Dates from Account to active Onboarding records |
| SaaS Owner Last Contacted Populated - Update Case Stage to Working | Record-Triggered | After Save | Moves open assigned cases to Working when SaaS Owner Last Contacted is stamped |
| Update Upsell Owner on Child Accounts | Record-Triggered | After Save | Cascades Upsell Owner changes from parent to child accounts |
| Account - Mismatched School UUID Cleanup (AM / PM) | Scheduled | Scheduled (2x daily) | Cleans up mismatched School UUIDs, prioritizing optimal UUID |
| Account - Scheduled - Churn Updates | Scheduled | Scheduled | Identifies officially churned accounts still showing as Customer |
| Account - Scheduled - Create Onboarding Attempts for Child Accounts | Scheduled | Scheduled (daily 11 PM) | Creates Onboarding Attempt records for child accounts created that day |
| Account - Scheduled - Expired Coupon Cases | Scheduled | Scheduled | Creates Proactive Engagement cases when coupon end date is approaching |
| Account - Scheduled - Premium Account Updates | Scheduled | Scheduled | Assigns SaaS Owner and Billing Upsell Owner for premium school accounts |
| Account - Scheduled Start Date Updates | Scheduled | Scheduled | Updates SaaS Onboarding Start Date when Original Close Date is 14+ days past |
| Accounts - Scheduled - Billing Activation Start Date Population | Scheduled | Scheduled | Backfills missing Billing Activation Start Date after Opp CW |
| Auto Close Tasks - Open on New Customer Accounts | Scheduled | Scheduled (5 AM) | Auto-completes open inbound tasks on customer/inactive prospect accounts |
| Auto Create EC Opp on Relaunch Date | Scheduled | Scheduled (daily) | Creates EC Opportunity when EC Relaunch Date = today |
| Auto Create Upsell Opp on Relaunch Date | Scheduled | Scheduled | Creates Upsell Opportunity when Billing Relaunch Date = today |

### Case (20+ flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| Case - Before Save - Update Fields | Record-Triggered | Before Save | Populates Account/Contact on new cancel cases; sets owner on proactive engagement cases |
| Case - Before Save - Update Owner on Proactive Engagement Case Create | Record-Triggered | Before Save | Assigns SaaS Owner as case owner on Proactive Engagement case create |
| Cancelation Case Duplication Catcher | Record-Triggered | Before Save | Auto-closes duplicate cancellation form requests within 7 days |
| Case Stripe Attempt Date | Record-Triggered | Before Save | Stamps Last Stripe Attempt timestamp when Stripe Attempt Count changes |
| Account - Calculate Cancel Case Dates | Record-Triggered | After Save | Updates Date Cancel Closed and Most Recent Closed Cancel Case Stage |
| Auto Close Case - ACH Verification Handler | Record-Triggered | After Save | Closes duplicate ACH cases, non-premium cases, or no-activity cases |
| Auto Close Case - Billing At-Risk Handler | Record-Triggered | After Save | Auto-closes Billing At-Risk cases under certain conditions |
| Auto Close Case - Failed Payments Handler | Record-Triggered | After Save | Closes non-target or queue-assigned FP cases with no activity |
| Cancel Case Save - Create Post-Save Case | Record-Triggered | After Save | Creates post-save case and tasks when cancellation status = Saved |
| Case - After Save - Billing Retention Updates | Record-Triggered | After Save | Updates Billing Onboarding record, Account, and CF on billing retention case changes |
| Case - After Save - Cancel Link to Opportunity Delay | Record-Triggered | After Save | Relates cancel cases to open Opportunities with a delay |
| Case - After Save - Cancelation Request Email Alert | Record-Triggered | After Save | Sends confirmation email to customer on cancellation request |
| Case - After Save - Close Passback Billing at Risk Case | Record-Triggered | After Save | Updates CF and Opportunity when AE closes Billing At-Risk case |
| Case - After Save - Retention Cadence Entry Flow | Record-Triggered | After Save | Enrolls contacts in retention cadences based on case type/status |
| Case - After Save - Send Email Notifications | Record-Triggered | After Save | Sends notifications to case owners on assignment |
| Case - After Save - Slack Notifications | Record-Triggered | After Save | Slacks case owners on assignment; keeps manager channels posted |
| Case - After Save - Sync Case Fields to Contact | Record-Triggered | After Save | Pushes case fields to the related Contact (Revenue.io implementation) |
| Case - After Create - TeamSysOps Round Robin | Record-Triggered | After Save | Round-robins new SysOps cases |
| Case - Cancel Request Distribution | Record-Triggered | After Save | Distributes cancel request cases to engagement specialists or queues |
| Case - On Create / Update - Gov Transfer Handler | Record-Triggered | After Save | Handles all Gov Transfer automation on case create and update |
| Case -update related accounts when case is canceled | Record-Triggered | After Save | Updates Account fields when cancel case is closed (excl. EC Cancel) |
| Case Comment - Create - Send Email Notifications | Record-Triggered | After Save | Sends email when new case comment is created |
| Auto Close FP Cases Daily - 120 Days After Created Date | Scheduled | Scheduled (daily) | Closes open FP cases where Days Since Created > 120 |
| FP Case - Scheduled - Dup Stripe Case Cleanup | Scheduled | Scheduled (daily) | Closes duplicate Failed Payment cases created same day |
| Scheduled - Case - Cancel JungleGym Billing | Scheduled | Scheduled | Triggers JungleGym subscription cancellation via API |

### Combined Funnel (20+ flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| CF - Open and Operating Date Tracking | Record-Triggered | Before Save | Tracks the last update date and elapsed time on Open and Operating Date |
| CF - 1:1 Onboarding Start Date Population | Record-Triggered | After Save | Populates 1:1 Onboarding Start Date on CF record |
| CF - After Save - OBS Handoff Issue Flagged - Slack AE Manager | Record-Triggered | After Save | Slacks AE managers when OB Handoff Issue field is populated |
| CF - After Save - Remove values for BNP Graduation Date upon Override Approval | Record-Triggered | After Save | Clears BNP graduation date fields when override is approved |
| CF - Billing Ownership Updates / SaaS Ownership Updates | Record-Triggered | After Save | Cascades billing/SaaS owner changes from CF to related records |
| CF - OBC Slack Notification | Record-Triggered | After Save | Sends Slack notification when OBC milestone is hit |
| CF - Onboarding CSAT Survey | Record-Triggered | After Save | Triggers CSAT survey send when Previous CSAT Survey Send Date changes |
| CF - Owner Assignment | Record-Triggered | After Save | Assigns CF records from Combined Funnel Queue to real owners |
| CF - Owner Updated, Update Account Owner and Onboarding Owners | Record-Triggered | After Save | Cascades CF owner to Account and Onboarding records |
| CF - Record Triggered - Update SaaS Onboarding Fields From Combined Funnel Record | Record-Triggered | After Save | Keeps SaaS Onboarding fields in sync with CF (replaces old Process Builder) |
| CF - Update Conversation Notes on Upsell Opportunity | Record-Triggered | After Save | Pushes SaaS/Billing Conversation Notes from CF to Billing Upsell Opp |
| CF - Update Gong Conversation with CF ID on Create | Record-Triggered | After Save | Links Gong Conversation records to new CF records |
| CF - Update Postponed Exit Date Automation | Record-Triggered | After Save | Fires postponement exit automation when exit date is set to today |
| Combined Funnel - After Save - Create - Field Sync to Account | Record-Triggered | After Save | Syncs CF fields to Account on create |
| Combined Funnel - After Save - Opportunity Post CW Stage Sync | Record-Triggered | After Save | Syncs post-CW Opp stages from CF |
| Combined Funnel - After Save - Primary Onboarding Automation | Record-Triggered | After Save | Updates SaaS/Billing Primary Contact when CF primary contact fields change |
| Combined Funnel - After Save - Update/Create - Fields Sync | Record-Triggered | After Save | Master field sync between CF and Account/Onboarding counterparts |
| Combined Funnel Update Billing Onboarding Fields from CF Record | Record-Triggered | After Save | Updates Billing Onboarding from CF on update |
| CF - Scheduled - Postponed Exit Date Automation | Scheduled | Scheduled | Resets SaaS Onboarding Status from Postponed when exit date passes |

### Contact (25+ flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| Contact - Before Save - Updates | Record-Triggered | Before Save | Core before-save field updates on Contact |
| Update Contact Last Assigned | Record-Triggered | Before Save | Stamps Last Assigned date/time before save |
| Contact - After Save - Outreach Stage Temp Patch | Record-Triggered | Before Save | Temporary patch for Outreach Stage field sync |
| CF - Zap - Webinar 1/2/3 Registration/Join | Record-Triggered | After Save | Updates webinar date fields when Zapier stamps registration/join status from Demio |
| CL - Contact Update Resell Date / CL ALA Return Path | Record-Triggered | After Save | Manages resell dates and inbound return path for churned/recycled contacts |
| Contact - After - Create EC Opportunity | Record-Triggered | After Save | Creates EC Opportunity when `Needs_EC_Opp_Created__c` = true |
| Contact - After - Local Customer Update | Record-Triggered | After Save | Populates Local Customer flag based on zip code |
| Contact - After Save - Cadence Owner Reassignment | Record-Triggered | After Save | Reassigns active cadences when contact owner changes |
| Contact - After Save - Sales Cadence Entry Flow | Record-Triggered | After Save | Main entry flow for all sales cadences (demo, discovery, no-show logic) |
| Contact - After Save - Post CW / Post Demo / Sales Starter Cadence Exit | Record-Triggered | After Save | Exits cadences at post-CW or post-demo milestones |
| Contact - After Save - EC OBS / EC Sales Retention Cadence Exit | Record-Triggered | After Save | Exits EC onboarding and retention cadences |
| Contact - After Save - OBS & GOBS Cadence Removal | Record-Triggered | After Save | Removes contacts from OBS/GOBS cadences |
| Contact - After Save - Onboarding Primary Update | Record-Triggered | After Save | Updates Primary Onboarding Contact fields |
| Contact - After Save - Org Reassignment & Slack Message | Record-Triggered | After Save | Reassigns Organization and sends Slack on contact reassignment |
| Contact - After Save - JG Account Flag | Record-Triggered | After Save | Flags contact's account as having a JungleGym record |
| Contact - After Save - Demo Path Population | Record-Triggered | After Save | Populates demo path fields based on event outcomes |
| Contact - CP Active Form - Primary Contact Logic | Record-Triggered | After Save | Updates Primary Contact fields from CP Active Form data |
| Contact - Last Inbound Activity Update | Record-Triggered | After Save | Updates Last Inbound Activity from HubSpot activity signals |
| Contact - Total Number of Webinar Misses | Record-Triggered | After Save | Counts missed webinars for cadence exit logic |
| Contact - Trigger Org Sync Flow | Record-Triggered | After Save | Syncs Contact changes to the related Organization record |
| Contact - Update Capacity On Non-Customer Account From Contact | Record-Triggered | After Save | Updates enrollment/capacity fields on non-customer Accounts from Contact |
| Primary Contact Automation | Record-Triggered | After Save | Sets primary contact flags across related records |
| Contact - Scheduled - Catch All Exit Flows | Scheduled | Scheduled | Nulls out stale Most Recent Cadence Enter fields not caught by exit flows |
| Contact - Scheduled - Next Manual Task Date Update | Scheduled | Scheduled | Clears Next Manual Task Date when date has passed |
| Contact - Scheduled Daily - Missed EC Webinar | Scheduled | Scheduled (daily) | Triggers EC webinar miss logic for cadence exit automation |

### Opportunity (15+ flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| Auto Create Upsell Opp on SaaS Closed Won | Record-Triggered | After Save | Creates a Billing Upsell Opp when SaaS Opp closes won |
| CF - Billing Upsell Opp CW - Combined Funnel and Onboarding Create or Update | Record-Triggered | After Save (subflow) | On BU Opp CW: creates/updates Combined Funnel and Billing Onboarding records |
| CF - Billing Upsell Opp Closed Lost - Update Combined Funnel | Record-Triggered | After Save | Updates CF when BU Opp goes to Closed Lost |
| CF - Relate CF and SaaS Onboarding on Create of Billing Opp | Record-Triggered | After Save | Relates CF and SaaS Onboarding records to new Billing Opp on create |
| Billing Funnel Stage Changed Date / Billing Activation Funnel Movement | Record-Triggered | After Save | Stamps stage-change dates on billing funnel records |
| Child Site Creation - After Save - Create Child Records | Record-Triggered | After Save | Creates Child Site records for multi-site Opps at CW |
| Opportunity - After Save - Experience Curriculum CW | Record-Triggered | After Save | Creates EC Onboarding record and task-based sequence on EC Opp CW |
| Billing CL Reason on Account | Record-Triggered | After Save | Stamps Billing CL Reason on Account when Billing Upsell Opp is CL |
| Auto Close Upsell - Assign Task and Update Account | Record-Triggered | After Save | Auto-closes stale upsell opps and creates follow-up tasks |
| Auto conversion trigger | Record-Triggered | After Save | Handles automated Lead conversion routing |

### Lead (8 flows)

| Flow name | Type | Trigger | Purpose |
|-----------|------|---------|---------|
| LDC - Remove from Personal Campaign | Record-Triggered | After Save (Campaign Member) | Removes Lead from personal campaign to stop assignment looping |
| CL ALA - Assigned, Not Worked - Instant Resell Eligible | Record-Triggered | After Save | Marks lead/account for instant resell on ALA assignment |
| Auto Close Tasks - Recycled or Unqualified Leads | Record-Triggered | After Save | Closes open tasks when Lead is recycled or unqualified |
| Auto Complete Tasks for Recycled or Unqualified Leads | Record-Triggered | After Save | Marks tasks complete on recycle/unqualify |
| Auto Close Tasks - IB Tasks on Converted Leads | Record-Triggered | After Save | Closes inbound tasks when lead converts |

### Other objects

| Flow name | Type | Object | Purpose |
|-----------|------|--------|---------|
| Platform Event Flow - Action Cadence Tracker | Platform Event | Cadence Tracker Event | Listens for Action Cadence Tracker CDC events; updates cadence tracker records |
| Conversation - Update Lead/Contact - Lead Source | Record-Triggered | Conversation | Populates Lead Source from Revenue.io call data |
| Gong Calls on CF Record | Record-Triggered | Conversation | Before Save — relates Gong calls to Combined Funnel |
| RingDNA Conversation - After Save - Update Call Task Fields | Record-Triggered | Conversation | Updates call tasks with recording URL and call data from Revenue.io |
| Completed Onboarding/ENGMT Events - Update Account Date Fields | Record-Triggered | Event | Stamps account date fields when onboarding events are completed |
| Event - After Save - BNP Intro Call Status Updates | Record-Triggered | Event | Updates BNP Intro Call Status on CF based on event outcomes |
| SCHEDULED - Assets - Update Status | Scheduled | Asset | Controls Asset status based on start/end month and purchase dates |
| Offline Payer - Update Based on Renewal Case Status | Record-Triggered | Case | Updates Offline Payer record when renewal case is closed |

### Subflows and utilities (not directly triggered)

- **Account - Subflow - Get Related Accounts** — returns sibling/child accounts for calling flows
- **Account - Subflow - Ownership Assignments** — updates SaaS Owner, Billing Upsell Owner, and EDU Owner fields
- **Account - Subflow - Update Child Account(s) EDU Owner to match Parent** — called by 2 after-save flows
- **Case - Subflow - Send JSON to JG / Build JSON Payload** — sends cancellation payload to JungleGym API
- **CF - Billing Upsell Opp CW - Combined Funnel and Onboarding Create or Update** — core subflow for CW automation
- **Contact - Subflow - Contact Owner Change** — handles cascading logic on owner change
- **Contact - Subflow - Create EC Opportunity** — creates EC Opp from Contact context
- **Lead - Subflow - Org Location Matching Expanded** — matches Lead to Organization by location data points
- **Lead - Subflow - RLA Resting Period Assignment** — assigns resting period on lead recycling
- **Matching - Lead to Organization matching** — core Lead-to-Organization matching logic
- **Onboarding Attempt - Subflow - Create and Update OAs / OAs Field Mappings** — creates/updates Onboarding Attempt records
- **Opportunity - Subflow - Create EC Onboarding Record** — creates EC Onboarding from Opp CW
- **Recycle Lead/Contact at Cadence completion** — recycles contacts/leads at end of cadence
- **Sequence - Subflow - Create and Assign Sequence / Mark Sequences As Complete** — manages task-based sequences
- **Subflow - BUO Cadence - Exit / EDU Cadence Exit / Sales Cadence Entry** — reusable cadence management logic

---

## Screen flows

| Flow name | Object/Context | Purpose |
|-----------|---------------|---------|
| Opportunity - Screenflow - Create EC Onboarding + Task Based Sequence | Opportunity | Creates EC Onboarding record and SFDC sequence from Opp record page |
| Opportunity - Screen - Closed/Won Flow | Opportunity | Enforces all required SaaS CW handoff fields; stamps `DateTime_Closed_by_Screenflow__c` |
| Opportunity - Screen - Create JungleGym Account | Opportunity | Verifies Account/Contact/Opp info and calls JungleGym API to create account |
| Opportunity - Screen - Create JungleGym Child Sites | Opportunity | Creates child Account/Subs in JungleGym and SFDC after Create Account step |
| SCREEN: Account - Active Gov Licensee | Account | Confirms parent account details for active Gov Licensee accounts |
| CF - Screen - Billing-At-Risk Case Creation | Combined Funnel | Allows OBS to create a Passback to Sales / Billing At-Risk case |
| CF - Screen - Postponement Approval | Combined Funnel | Approval screen for SaaS Postponement requests |
| CF - Screen - Request Postponement | Combined Funnel | Sets required postponement fields on CF record |
| Case - Screen - Cancel JungleGym Subscription | Case | Cancels JungleGym subscription; captures cancel category and reason |
| Case - Screenflow - SysOps Request - New Case | Case | Creates a SysOps request case |
| EVENT/OPPTY: Demo Workflow | Event/Opportunity | Updates demo outcome fields on Event and related Opportunity |
| LDC - Screen Flow - Mass Re-Assignment | Lead | Mass re-assigns leads from LDC (Lead Distribution Center) |
| Lead Convert - Cleanup Action | Lead | Cleans up fields/tasks post Lead conversion |
| Lead Log a Conversation | Lead | Logs a call/conversation from a Lead record page |
| Unlock Record | Record page | Unlocks a locked record via quick action |
| Generate Payment Link | Case/Account | Generates a Stripe payment link |

---

## Active triggers

Only **custom org triggers** are listed in detail. Managed package triggers are summarized below.

### Custom Apex triggers

| Trigger name | Object | Events | Purpose |
|-------------|--------|--------|---------|
| AccountTrigger | Account | after insert, after update, after undelete, before delete | Handler pattern — delegates to `AccountTriggerHandler`; rollups and related record updates |
| AccountDeleteTrigger | Account | before delete | Additional pre-delete validation or cleanup on Account |
| CheckAccountFieldUpdate | Account | before update | Field-change detection; used by Enhanced Field History (EFH) |
| ContinuousCleanAccountTrigger | Account | before insert, after insert | ContinuousClean (data.com-era) integration trigger |
| ContinuousCleanAccountUpdateTrigger | Account | before update, after update | ContinuousClean update trigger |
| PS_Account | Account | before delete, after insert/update/delete/undelete | DLRS (Declarative Lookup Rollup Summaries) helper trigger |
| ContactTrigger | Contact | after insert, after update, after undelete, before delete | Handler pattern — delegates to `ContactTriggerHandler` |
| ContactBeforeInsertTrigger | Contact | before insert | Handles before-insert Contact logic (likely generic email domain or dedup) |
| CheckContactFieldUpdate | Contact | before update | EFH field-change tracking |
| ContinuousCleanContactTrigger / UpdateTrigger | Contact | before update/delete, after insert/update | ContinuousClean triggers |
| PS_Contact / PS_Contact_Describe_Async | Contact | before delete, after insert/update/delete/undelete | DLRS rollup triggers |
| Lead (x3) | Lead | before insert/update/delete, after insert/update/delete/undelete | Multi-trigger stack: generic email domain marking, EFH field history, org routing via future method |
| BeforeLeadInsert / BeforeLeadUpdate | Lead | before insert / before update | Additional before-save Lead logic (likely validation or field defaulting) |
| CheckLeadFieldUpdate | Lead | before update | EFH field-change tracking for Lead |
| ContinuousCleanLeadTrigger / UpdateTrigger | Lead | after insert / after update | ContinuousClean triggers |
| CreateLeadListener | Lead | before delete, after insert, after update | Listens for Lead create/update events; likely cadence or assignment logic |
| RHX_Lead | Lead | before delete, after insert/update/delete/undelete | Reporting History Extended (rollup history) trigger |
| updateRelatedListTrigger | Lead | after update | Updates related list records when Lead is updated |
| Opportunity (x2) | Opportunity | before update/delete, after insert/update | Multi-trigger stack on Opportunity |
| OpportunityTrigger | Opportunity | after insert, after update | Additional Opp trigger logic |
| CheckOpportunityFieldUpdate | Opportunity | before update | EFH field-change tracking |
| ContinuousCleanOpportunityTrigger / UpdateTrigger | Opportunity | before insert, after insert/update | ContinuousClean triggers |
| RHX_Opportunity | Opportunity | before delete, after insert/update/delete/undelete | RHX rollup history trigger |
| UpdateRingDNAAgentStatsFromOpportunity | Opportunity | after insert, after update | Updates Revenue.io agent stats from Opportunity changes |
| LeanDataOpportunityContactRoleTrigger | OpportunityContactRole | before delete, after insert/update | LeanData matching on OCR changes |
| OpportunityContactRole | OpportunityContactRole | before insert/update, after insert/update/delete | Core OCR trigger |
| Campaign (x2) | Campaign | before insert/update/delete, after insert/update | Multi-trigger stack on Campaign |
| CheckCampaignFieldUpdate | Campaign | before update | EFH field-change tracking |
| LeanDataCampaignTrigger | Campaign | after update | LeanData matching on Campaign updates |
| CampaignMember | CampaignMember | before insert/update, after insert/update/delete | Core Campaign Member trigger |
| ContinuousCleanCampaignMemberTrigger | CampaignMember | before delete, after insert/update | ContinuousClean trigger |
| ContinuousCleanCaseTrigger | Case | before insert, after insert/update | ContinuousClean trigger |
| RHX_Case | Case | before delete, after insert/update/delete/undelete | RHX rollup history trigger |
| OnboardingTrigger | Onboarding__c | after insert, after update, after undelete, before delete | EFH field history tracking for all Onboarding changes |
| RHX_Onboarding | Onboarding__c | before delete, after insert/update/delete/undelete | RHX rollup history trigger |
| OnboardingAttemptTrigger | Onboarding_Attempt__c | after insert, after update, after undelete, before delete | Handler pattern — delegates to `OnboardingAttemptTriggerHandler` |
| CombinedFunnelTrigger | Combined_Funnel__c | after insert, after update, after undelete, before delete | Handler pattern — delegates to `CombinedFunnelTriggerHandler` |
| RHX_Combined_Funnel | Combined_Funnel__c | before delete, after insert/update/delete/undelete | RHX rollup history trigger |
| SchoolObjectTrigger | School_Object__c | after insert, after update, after undelete, before delete | Handler pattern — delegates to `SchoolObjectTriggerHandler` |
| Organization | Organization__c | before insert, before update | Marks Organization records where email domain is generic |
| RHX_Organization | Organization__c | before delete, after insert/update/delete/undelete | RHX rollup history trigger |
| RestrictDeletionEvents | Event | before delete | Prevents non-admins (not Business & Data Ops or OB SDR Manager role) from deleting Events |
| ContinuousCleanEventTrigger | Event | before delete, after insert/update | ContinuousClean trigger |
| PS_Event | Event | before delete, after insert/update/delete/undelete | DLRS rollup trigger |
| ContinuousCleanTaskTrigger | Task | before delete, after insert/update | ContinuousClean trigger |
| PS_Task | Task | before delete, after insert/update/delete/undelete | DLRS rollup trigger |
| Task (x2) | Task | before insert/update, after insert/update | Multi-trigger stack on Task |
| LinkCallsToOpportunities | Task | before insert | Links call Tasks to open Opportunities |
| UpdateLeadTimeToRespond / UpdateTimeToResponse | Task | after insert/update | Stamps lead time-to-respond and time-to-response metrics |
| UpdateTaskOnCallback | Task | after insert | Updates task fields when callback is created |
| ConverseTaskTrigger | Task | after insert | SMS Magic — creates Converse app tasks |
| UpdateRingDNAAgentStatsFromTask | Task | before insert | Updates Revenue.io agent stats from Task |
| ActionCadenceTrackerChangeTrigger | ActionCadenceTrackerChangeEvent | after insert | Processes Sales Engagement cadence tracker CDC events |
| addLeanDataPermissionSet / UserTrigger | User | after insert/update | Assigns LeanData permission set to new users; User trigger handler |
| RHX_Attachment / RHX_ContentDocumentLink | Attachment / ContentDocumentLink | before delete, after insert/update/delete/undelete | RHX rollup history triggers |
| BatchApexErrorEventTrigger | BatchApexErrorEvent | after insert | Catches Batch Apex errors as platform events |

### Managed package triggers (summarized by package)

| Package | Object namespace | Trigger count | Purpose |
|---------|-----------------|---------------|---------|
| **SMS Magic** (smagicinteract) | `smagicinteract__*` | ~20 | Full SMS messaging platform — incoming/outgoing SMS, MMS, conversations, templates, consent, shared inboxes |
| **Revenue.io / RingDNA** (ringdna, RDNACadence, ringdna107) | `ringdna__*`, `RDNACadence__*`, `ringdna107__*`, `ringdna100__*` | ~18 | Dialer, cadence management, call recording, platform event routing |
| **LeanData** | `LeanData__*` | ~8 | Lead/Account routing, round-robin pools, journey tracking, dataset management |
| **DLRS (rh2)** | `rh2__*` | 4 | Declarative rollup calculations — PS_Describe, PS_Queue, PS_Rollup_Dummy, PS_Import_Rollups, RH_Job |
| **SMS Magic (SML)** | `SML__*` | 2 | Converse Campaign trigger, Report Access Job management |
| **WorkRamp** | `WorkRampApp__*` | 4 | Learning paths, certifications, registrations — syncs with SFDC records |
| **Wootric** | `Wootric__*` | 4 | NPS survey responses — Decline, Response (Lead + non-Lead versions) |
| **Gong** | `Gong__*` | 3 | Call object creation and update triggers for Gong call records |
| **Dropbox Sign / HelloSign** | `HelloSign__*` | 3 | Template and signer role management; UpdateWonOpportunity on signature completion |
| **SimpliList Views** | `simpli_lv__*` | 3 | List view action configuration triggers |
| **EFH (Enhanced Field History)** | `EFH__*` | 1 | HistoryFieldConfigTrigger — manages field history configuration records |

---

## Active validation rules

Rules grouped by object. Bypass mechanism is noted where known.

### Account

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| BillingOnboardingStatusSaaSAtRisk | Prevents reps from selecting SaaS At Risk for Billing Onboarding Status | System Admin profile |
| SaaSOnboardingStatusBillingAtRisk | Prevents reps from selecting Billing At Risk for SaaS Onboarding Status | System Admin profile |

### Case

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| BillingAtRiskClosed_Opted_Out | Requires AE Billing At-Risk Notes and Opt Out Reason when closing as Opted Out | — |
| BillingAtRiskClosed_Resumed_Onboarding | Requires AE notes and OBS call date when closing as Resumed Onboarding | — |
| BillingAtRiskClosed_Unresponsive | Requires AE notes for Passback to Sales / Billing At-Risk at Customer Unresponsive status | — |
| BillingRetention_CL / BillingRetention_CW | Required fields for Billing Retention cases at CL/CW status | — |
| CancellationRequest_RequiredFields_Saved | Required fields to set cancel case status to Saved | — |
| CancelRequestReasonDetailRequired | Cancel Request Reason Detail required for specific cancellation reasons | — |
| CaseReason_Required_Cancel_FailedPayment | Case Reason required for cancel/failed payment cases | — |
| Close_Billing_Penetration_Cases | Required fields to close Billing Penetration record type cases | — |
| Close_Case_Type_Required_Fields | Required fields across case types to close (excl. Closed and Auto Close statuses) | — |
| EC_Cancel_Request_Outcome_Required | Requires EC Cancel Outcome before closing | — |
| Gov_Transfer_Closed_Requirements | Requires Dollar Value of Case (MRR) and Related Payer before Gov Transfer closure | — |
| Gov_Transfer_Contact_Requirements | Requires Contact on all Gov Transfer cases | — |
| Must_Use_Screen_Flow_to_Cancel_Case | Prevents direct case cancellation; must use screen flow | — |
| PassbacktoSales_SubType_Reason_Required | Sub Type Reason required when Sub Type = Objection on Passback to Sales cases | — |
| Req_Fields_FP_Cancel_Cases | Requires Cancel Category on Failed Payment origin cancel cases | — |
| Require_Contact_for_Cancel_Cases | Contact required on non-web-to-case cancel cases | — |
| Required_Fields_for_Cancelation_Reason | Competitor field required for most Cancelation Reason values | — |
| Required_Fields_for_Canceled_Status | Required fields to set status to Canceled or Closed | — |
| Restrict_Closed_Case_Editing | Prevents field edits after case is marked Closed | `BypassClosedCaseEditing` permission or specific profile IDs |
| Restrict_Closed_Status_PostSave | Prevents updating post-save cases to Closed | System Admin or `BypassPostSaveCaseStatusRules` custom permission |
| RestrictCancelStatusSavedNoSaasActivated | Prevents Saved status if school is not yet SaaS-activated | — |
| RestrictOtherClosedCancelCaseReason | When status = Closed, Cancelation Reason must be Duplicate/Made by Mistake/Duplicate Account/EC Churn | — |
| Billing_Upsell_Closed_Statuses | Prevents invalid close statuses on Billing Upsell cases | — |
| BillingRetention_CL / CW | Required fields for Billing Retention CL and CW | — |

### Contact

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| ChilinBot_Phone_Number | Prevents adding the hardcoded ChilinBot phone number to a Contact | — |

### Event

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| Became_Demo_Restrictions | Cannot check Became Demo if `LOGIC_Sales_Discovery_Call__c` = false | — |
| Cannot_Select_More_Than_1_Event_Outcome | Prevents more than one outcome checkbox on a Sales event | — |
| DM_Status_Required | Requires DM Status and Current Center Operating Status on completed/incomplete demo calls | — |
| Related_To_Opportunity_Update | Field Logic Related To Opportunity Trigger required when related Opp is missing or past close date | — |
| Restricted_Future_Event_Outcome_Updates | Prevents setting an outcome on a future-dated event | — |
| Sales_Cannot_Change_Assignto | Prevents sales users from directly editing Assign To field (must use Reassign button) | — |

### Lead

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| Capacity_Requirement_to_Convert | Current Enrollment and Capacity required to convert (Sales profile only) | Non-Sales profiles |
| Center_Type_Required_to_Convert | CHAMP fields required before conversion (Sales profile only) | Non-Sales profiles |
| CHAMP_required_to_convert_lead | CHAMP fields required before conversion (Sales profile only) | Non-Sales profiles |
| ChiliBot_Lead_Do_Not_Edit | Prevents editing ChiliBot-owned leads | — |
| ChilinBot_Phone_Number | Prevents adding the hardcoded ChilinBot phone number to a Lead | — |
| Current_Tech_required_to_convert_lead | Current Tech required to convert (Sales profile only) | Non-Sales profiles |
| Current_User_Lead_Owner | Checks if current user is lead owner; exceptions for System Admin, Retention, API profiles | System Admin, API User, specific profiles |
| How_Did_You_required_to_convert_lead | "How did you hear about us" required to convert (Sales profile only) | Non-Sales profiles |
| Restrict_AE_Ownership_Change | Prevents AEs from changing Lead ownership (except to a queue, `00G...`) | Non-AE roles |

### Onboarding (SaaS Onboarding)

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| Billing_Call_or_Webinar_Date_Required | Billing Call/Webinar Date required when status is set (except Scheduling) | — |
| Billing_Opted_Out_Required_Fields | Required fields when Billing Onboarding Status = Hard Opt Out | — |
| Billing_Postponed_Required_Fields | Required fields when Billing Onboarding Status = Postponed | — |
| BillingOnboardingStatusSaaSAtRisk | Prevents selecting SaaS At Risk on Billing Onboarding Status | — |
| CannotSetBillingStatusToInactive | Prevents setting status to Inactive (must happen via cancellation automation) | — |
| Handoff_Notes_Required_For_All_Issues | Requires Handoff Issue Notes when OB Handoff Issue field has any value | — |
| OB_Handoff_Issue_Required_With_Notes | Requires at least one OB Handoff Issue value when Notes are populated | — |
| SaaS_Onboarding_Status | Only Admins or `CF Postponed Approver` perm set can set status to Postponed | System Admin, `CF Postponed Approver` permission set |
| SaaS_Postponed_Approvers | Only Admins or `CF Postponed Approver` can approve postponement requests | System Admin, `CF Postponed Approver` |
| SaaS_Postponed_Check_in_BeforePostpone | Check-in Date must be within 30 days of Postponement Start Date | — |
| SaaS_Postponed_Check_in_Postponed | Check-in Date must be within 30 days of today while Postponed | — |
| SaaS_Postponed_Exit_Postponed | SaaS Postponed Exit Date can't be changed to past or pushed further out while Postponed | — |
| SaaS_Postponed_Start_Postponed | Postponed Start Date can't be changed while status = Postponed | — |
| SaaSOnboardingStatusBillingAtRisk | Prevents selecting Billing At Risk on SaaS Onboarding Status | — |

### Opportunity (40+ rules — key ones)

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| Assessments_Closed_Lost/Won_Fields | Required fields before Assessments Opp is moved to CL/CW | — |
| Billing_Opt_Out_Override_Requirement | Requires Billing Opt Out Override Reason if override = true | — |
| Billing_Upsell_Account_Name_Length_Check | Account Name + " - Billing Onboarding" must be under 80 chars at CW | — |
| Billing_Upsell_CW_Requirements | Prevents BU Opp CW if Billing Activation Date is already populated | — |
| BNP_RequireOBSandIntroCallDate | Requires OBS Owner and BNP 1:1 Intro Call Date at CW for BNP/BNP Site-Add paths | — |
| BOTH_Declined_Billing_Training_Reason | Declined Billing Training Reason required if Declined = true (Standard Path) | — |
| Closed_Lost_Reason_ChoseCompetitor | Current Tech required if CL Reason = Chose Competitor | — |
| Closed_Lost_Reason_Req_NEW | Requires CL Reason on close lost | — |
| Closed_Opp_Restricted_Fields | Prevents changing specific fields after CW | System Admin |
| EC_Closed_Lost_Required_Fields | Requires CL Reason and Detail on EC Opp CL | — |
| EC_CW_NetNewCustomer_Webinar_Requirement | Primary Onboarding Contact must have EC webinar registration fields complete at CW | — |
| EC_Delayed_Start_Required_Fields | Curriculum Start Month and Contact required when moved to Delayed Start | — |
| ECStageErrorOpenDemos | Prevents stage change if there are open Events on EC Opp | — |
| GovLicensee_Closed_Lost_fields_required | CL Reason and CL Reason Detail required for Gov Licensee CL | — |
| Gov_Licensee_CW_Requirements_2/3 | `# of Total Staff` required at CW for Gov Licensee (except Site-Add/BNP); billing/EIN required | — |
| Gov_Payer_CW_Requirements | Number of Licenses and Term Length required; contract dates must align at Gov Payer CW | — |
| Open_and_Operating_Date_Required | Open and Operating Date required if Current Center Operating Status ≠ Open and Operating | — |
| Opp_Post_CL_Sales_Neglected_Do_Not_Edit | Prevents stage changes for CL Sales Neglected opps | — |
| Opportunity_Post_CS_Stage_Do_Not_Edit | Prevents manually saving opps to post-CW stages | — |
| SaaS_Cannot_CW_on_Customer_Account | Cannot CW SaaS Opp if Account Type = Customer | — |
| SaaS_CW_Amount_Required | Amount required at CW | — |
| SaaS_CW_Screenflow_required | `DateTime_Closed_by_Screenflow__c` must be stamped within last 15 minutes to CW | System Admin |
| SaaS_CWAndCL_CHAMP_Required | CHAMP fields required at CW or CL for SaaS Opps | — |
| SaaS_Low_Amount_SelfServe_Path_Required | Onboarding Path must be Self Serve for Opps under $49 | — |
| SaaS_Multi_Site_Info_Required | Multi-Site Info required if Number of Schools > 1 at CW | — |
| SaaS_Multi_Site_Number_of_Schools | Number of Schools must be > 1 if Multi-Site checkbox is checked | — |
| SaaS_OnboardingPath_Standard | Requires "Was SSP added on call" for Standard path (SaaS + Gov Lic) | — |
| Upsell_CW_Billing_Opted_In_Req_Fields | Required billing fields at Upsell CW | — |
| Upsell_Opp_Closed_Lost_Required_Reason | Billing CL Reason required on Billing Upsell CL | — |

### User

| Rule name | Purpose | Bypass mechanism |
|-----------|---------|------------------|
| Profile_Change_Only_Sys_Admins | Only System Admins can change User profiles | System Admin |

---

## Integrations

| System | Direction | Objects touched | Frequency | Notes |
|--------|-----------|-----------------|-----------|-------|
| **JungleGym** (internal billing platform) | Outbound | Case, Account | On-demand (screen flow / scheduled) | Cases trigger JSON payloads to JungleGym subscription cancellation API via `Case - Subflow - Send JSON to JG`; also `Scheduled - Case - Cancel JungleGym Billing` |
| **Stripe** | Inbound | Case (`Failed Payment` record type), Account | Real-time (webhook) | Stripe payment events create/update Failed Payment cases; Stripe Attempt Count/Date fields stamped via `Case Stripe Attempt Date` flow |
| **Revenue.io / RingDNA** (ringdna) | Bidirectional | Task, Opportunity, Contact, Lead, `ringdna__Conversation__c`, `RDNACadence__*` | Real-time | Dialer and sales engagement platform; call tasks synced via `UpdateRingDNAAgentStatsFrom*` triggers and `RingDNA Conversation - After Save` flow; cadence actions via platform events |
| **Gong** | Inbound | `Gong__Gong_Call__c`, Combined Funnel, Opportunity | Real-time | Call recordings and conversation data synced; CF related via `CF - Update Gong Conversation with CF ID` flow; `computeOppAtTimeOfCallVals` trigger stamps Opp fields at call time |
| **LeanData** | Bidirectional | Lead, Account, Campaign Member, `LeanData__*` | Real-time | Lead/Account routing and round-robin assignment; `LDC - Remove from Personal Campaign` flow prevents assignment loops |
| **SMS Magic** (smagicinteract) | Bidirectional | Lead, Contact, Account, `smagicinteract__*` | Real-time | SMS/MMS messaging platform; ~20 triggers manage message routing, consent, shared inboxes, and conversation objects |
| **Zapier** (Demio webinars) | Inbound | Contact | Real-time (zap) | Zapier writes webinar registration/join dates to Contact fields when prospects register or attend Demio webinars; caught by `CF - Zap - Webinar *` flows |
| **Sigma Computing** | Outbound (embedded) | Opportunity | On-demand | JWT-authenticated Sigma dashboards embedded in Opportunity record pages via `SigmaEmbedComponent_JWT_Opportunity` Visualforce component |
| **WorkRamp** | Bidirectional | `WorkRampApp__*` | Real-time | LMS integration; 4 triggers manage Academy Paths, Certifications, Registrations |
| **Wootric** | Inbound | `Wootric__*` | Real-time | NPS survey platform; Response and Decline triggers fire on survey completion |
| **Dropbox Sign / HelloSign** | Bidirectional | `HelloSign__*`, Opportunity | Real-time | E-signature platform; `UpdateWonOpportunity` trigger fires after signature completion |
| **DLRS (Rollup Helper / rh2)** | Internal | Account, Contact, Opportunity, Onboarding__c, etc. | Asynchronous | Declarative rollup calculations; PS_* triggers coordinate async rollup jobs |
| **Enhanced Field History (EFH)** | Internal | Lead, Contact, Account, Opportunity, Onboarding__c, etc. | Real-time | Extended field history beyond SFDC's 20-field limit |

---

## Fragile patterns

### Pattern 1: Multi-trigger stack on Lead, Contact, and Opportunity

**Components involved**: 3–4 triggers named "Lead" / "Contact" / "Opportunity" on the same object, plus named triggers (BeforeLeadInsert, BeforeLeadUpdate, CheckLeadFieldUpdate, ContinuousClean*, etc.)

**How it works**:
```
On Lead update:
  → BeforeLeadUpdate (before update)
  → CheckLeadFieldUpdate (before update)
  → Lead (x3) (before update/delete, after insert/update/delete)
  → ContinuousCleanLeadUpdateTrigger (after update)
  → RHX_Lead (after insert/update/delete/undelete)
  → CreateLeadListener (after insert/update)
  → updateRelatedListTrigger (after update)
  → UpdateLeadTimeToRespond (after insert/update)
```

**Known failure modes**:
- Trigger execution order within the same event is not guaranteed in Salesforce — depends on deployment order
- CPU time overruns on bulk Lead operations (likely why the "Do nothing" Process Builder exists: to absorb CPU budget on update chains)
- If any single trigger throws an uncaught exception, the entire transaction rolls back, failing all triggers

**Testing approach**: Use `Test.startTest()`/`Test.stopTest()` with bulk inserts (200+ records); watch CPU time limits; validate outcome fields from all trigger layers, not just the last one.

---

### Pattern 2: Combined Funnel ↔ Account ↔ Onboarding circular sync

**Components involved**: `CF - Owner Updated, Update Account Owner and Onboarding Owners`, `Account - After Save - Generic Updates`, `CF - Record Triggered - Update SaaS Onboarding Fields`, `Combined Funnel Update Billing Onboarding Fields`, `Onboarding Start Date - SaaS/Billing - Account to Onboardings`

**How it works**:
```
CF owner updated
  → CF - Owner Updated → updates Account.SaaS_Owner__c + Account.OBS_Owner__c
  → Account - After Save fires
  → Account - After Save - Generic Updates updates other Account fields
  → Account - After Save - Opp Post CW Stage Sync may fire
  → CF - Record Triggered - Update SaaS Onboarding may re-fire if CF fields changed
```

**Known failure modes**:
- Flows marked `RecordAfterSave` run asynchronously in separate transactions — can appear to succeed in unit tests but fail in bulk operations due to governor limits across chained transactions
- A bulk Account update (e.g., data load updating OBS Owner) fires all Account after-save flows for each record, potentially creating thousands of async flow interviews
- Onboarding records may be temporarily out of sync with Account/CF between async flow executions

**Testing approach**: Test owner-change scenarios end-to-end on a single record first, then verify at bulk (50+); check final state of Account, CF, and Onboarding together after all async jobs complete.

---

### Pattern 3: Opportunity CW gate — screenflow timestamp + validation rule

**Components involved**: `Opportunity - Screenflow - Closed/Won Flow`, `SaaS_CW_Screenflow_required` validation rule, `DateTime_Closed_by_Screenflow__c` field

**How it works**:
```
Rep clicks CW button → launches screen flow
  → Screen flow stamps DateTime_Closed_by_Screenflow__c = NOW()
  → Screen flow saves the Opp
  → Validation rule: NOW() - DateTime_Closed_by_Screenflow__c < 15 minutes
```

**Known failure modes**:
- If the screen flow errors mid-way (e.g., JungleGym API callout fails), `DateTime_Closed_by_Screenflow__c` may or may not be stamped — the rep is stuck and cannot CW manually
- Time-zone edge cases: the 15-minute window uses the server clock
- Data migration / backfill of CW Opps requires setting this field manually or bypassing via System Admin profile

**Testing approach**: Test the full screen flow path including error branches; verify that API failures roll back the timestamp; confirm System Admin can bypass in migration scenarios.

---

### Pattern 4: Cancellation case chain

**Components involved**: `Case - Before Save - Update Fields`, `Cancelation Case Duplication Catcher`, `Must_Use_Screen_Flow_to_Cancel_Case` validation rule, `Case - Screen - Cancel JungleGym Subscription`, `Scheduled - Case - Cancel JungleGym Billing`, `Case - Subflow - Send JSON to JG`

**How it works**:
```
Customer submits cancellation form (web-to-case)
  → Before Save: populate Account/Contact
  → Duplication Catcher: auto-close if duplicate within 7 days
  → Case is assigned via Cancel Request Distribution flow
  → Rep completes screen flow → changes status to Saved → triggers JungleGym API callout
  → Cancel JungleGym Subscription screen flow sends JSON payload to JG API
  → Account update fires → cancellation case chain closes
```

**Known failure modes**:
- JungleGym API failures leave the case in an intermediate state (status changed but subscription not cancelled)
- The deduplication logic (7-day window on same email) may fire incorrectly if the customer's email changes between attempts
- `Must_Use_Screen_Flow_to_Cancel_Case` blocks all non-screen-flow saves — data migration must use System Admin profile or temporarily deactivate

**Testing approach**: Mock JungleGym API endpoint in sandbox; verify duplication catch fires correctly for same-email same-day submits; confirm status transitions are blocked without screen flow for non-admin users.

---

## Deprecated automation

These Process Builders and InvocableProcesses are **active but deprecated**. Do not modify — migrate to Flow instead.

| Component | Type | Object | Status | Notes |
|-----------|------|--------|--------|-------|
| CF - Trigger - Billing Upsell Opp CW - Combined Funnel and Onboarding Create or Update | Process Builder | Opportunity (CF) | Active — being replaced by record-triggered flow of same name | Superseded by `CF - Billing Upsell Opp CW - Combined Funnel and Onboarding Create or Update` AutoLaunchedFlow |
| HS Progressive Forms - Set delay - Trigger | Process Builder | (HubSpot) | Active | Legacy HubSpot progressive forms delay logic |
| LDC - Stamp Date/Time of Close | Process Builder | Lead | Active | Stamps LDC close date/time — consider migrating to Before Save flow |
| New In Product or Mobile Request | Process Builder | Lead/Contact | Active | Routes in-product or mobile signup requests |
| Production user record clear LOGIC matching count | Process Builder | User | Active | Clears matching count logic on user records |
| Production user record trigger for school object record matching | Process Builder | User | Active | Triggers school object matching from user record changes |
| School ID account update on contact relationship | Process Builder | Contact | Active | Updates School ID on Account from Contact relationship |
| Slack - Lead Request | Process Builder | Lead | Active | Sends Slack notification on lead request events |
| Update Is Deferred Rollup Field on Participants (x1) | InvocableProcess | (Revenue.io) | Active | Revenue.io-managed invocable process for rollup field updates |
| Update Is Email opened/replied/sent Rollup Field on Participants (x3) | InvocableProcess | (Revenue.io) | Active | Revenue.io-managed invocable processes |
| Update Is Performed Rollup Field on Participants | InvocableProcess | (Revenue.io) | Active | Revenue.io-managed invocable process |
