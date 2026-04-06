# Object Model

> **Last refreshed:** 2026-03-31

## Core objects

| Object | Purpose | Approx. records | Key relationships |
|--------|---------|-----------------|-------------------|
| Lead | Prospective customers and inbound requests; scored via HubSpot and distributed via Lead_Request__c | — | Lead_Request__c, Scoring__c, Organization__c |
| Account | Central CRM entity representing a school or district; hub for all onboarding and billing activity | — | Combined_Funnel__c, Onboarding_Attempt__c, School_Object__c, Child_Site_Creation__c, Offline_Payer__c |
| Contact | Individual person associated with an Account; involved in onboarding via junction object | — | Onboarding_contact__c, Combined_Funnel__c (SaaS/Billing primary contacts) |
| Opportunity | Sales opportunity tied to an Account; referenced by onboarding and funnel objects | — | Combined_Funnel__c (SaaS_CW_Opportunity__c, Billing_CW_Opportunity__c), Onboarding__c, Child_Site_Creation__c |
| Task | Activity records; created automatically from message events via metadata configuration | — | Standard activities on most objects |
| Case | Support cases; used for cancellation tracking | — | Onboarding_Attempt__c (Cancelation_Case_Stamp__c), Stripe_FP_Audit__c |

## Custom objects

### Onboarding & Activation

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Combined_Funnel__c` | Account-level tracking object that unifies SaaS and Billing onboarding/activation funnels in a single record. The most heavily instrumented object in the org (365 fields, 16 validation rules). | FTS_Owner__c, Onboarding_Coordinator__c, SaaS_CW_Opportunity__c, Billing_CW_Opportunity__c, SaaS_Primary_Contact__c, Billing_Primary_Contact__c | Account__c (Lookup), Opportunity (x2 Lookup), Contact (x3 Lookup), User (x2 Lookup) |
| `Onboarding__c` | Tracks individual onboarding processes (SaaS or Billing) for an account. Has 6 record types covering Single-site SaaS, Multi-site SaaS, Enterprise, Billing, Experience/Curriculum, and Non-Target. 340 fields. | Primary_Contact__c, FTS_Owner__c, SaaS_Onboarding__c (self-referential) | Account__c (Lookup), Opportunity__c (Lookup), Combined_Funnel__c (Lookup), Contact (Lookup), User (Lookup) |
| `Onboarding_Attempt__c` | Tracks individual activation attempts (SaaS or Billing) with historical KPIs, success rates, and owner stamps. New attempts are created each time an account becomes a customer. Locks down on close/cancel. Record types: Billing, SaaS. | Account_SaaS_Owner_Stamp__c, Account_OBS_Owner_Stamp__c, Account_AE_Owner_Stamp__c, Related_Payer_Account_Stamp__c, Cancelation_Case_Stamp__c | Account__c (Master-Detail), Combined_Funnel__c (Lookup), Opportunity__c (Lookup), Case (Lookup), User (multiple Lookup) |
| `Onboarding_contact__c` | Junction object linking Contacts to Onboarding records, capturing the role of each contact in the onboarding process. | On_boarding_contact_role__c | Onboarding__c (Master-Detail), Contact (Master-Detail), Onboarding_contact_role__c (Lookup) |
| `Onboarding_contact_role__c` | Configuration/picklist object defining valid contact roles within an onboarding process. | — | Referenced by Onboarding_contact__c |
| `Child_Site_Creation__c` | Staging object that temporarily stores values needed to create child site records across Account, Opportunity, and Combined_Funnel__c in a single transaction. | Child_Account_Created__c, Child_Opportunity_Created__c, Child_Combined_Funnel_Created__c, Chosen_Existing_Account__c | Account (x2 Lookup), Opportunity (x2 Lookup), Combined_Funnel__c (Lookup), User (Lookup) |
| `Cancellation_Status__c` | Tracks cancellation status information for accounts undergoing offboarding. | — | 1 relationship field |
| `Opportunity_Snapshot__c` | Point-in-time snapshots of Opportunity state for historical reporting and forecasting. | — | Opportunity (implied) |

### Organization & School Management

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Organization__c` | Connects external TAM/TED database records with Salesforce Leads and Contacts. Stores denormalized contact and school info independent of Account/Contact. | School_Name__c, First_Name__c, Last_Name__c, Outbound_Email__c, Outbound_Phone__c, Center_Type__c, Initial_License_Date__c, LOGIC_associated_accounts__c, LOGIC_associated_Contact__c, LOGIC_associated_leads__c | Related_Organization__c (self-referential Lookup) |
| `School_Object__c` | Stores data specific to educational institutions (name, school ID, location, contact info, programs, student counts). | — | Account__c (Lookup) |
| `Location__c` | Tracks physical locations associated with organizations or schools. Has record types. | — | 3 relationship fields |

### Lead & Distribution

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Lead_Request__c` | Manages lead request creation, tracking, and distribution via the Lead Distribution Center. | Rep_Name__c | Lead__c (Lookup), User (Lookup) |
| `Scoring__c` | Stores historical HubSpot lead scoring records for analysis and reporting. | — | Lead__c (Lookup) |
| `RoundRobin__c` | Manages round-robin lead/opportunity distribution logic and tracks distribution history. Heavily instrumented (365+ fields). | — | 1 relationship field |
| `HS_Conversion_Mapping__c` | Configuration object that maps HubSpot sales values to Salesforce HubSpot recent activity fields. | — | — |

### Payment & Billing Integration

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Stripe_Transaction__c` | Stores credit card transaction data from Stripe. History tracking enabled for audit compliance. | — | — |
| `Stripe_FP_Audit__c` | Audit trail for Stripe FP (failed payment) operations. | Linked_Case__c | Case (Lookup) |
| `StripeAuth__c` | Stores OAuth authorization tokens for the Stripe integration. | — | — |
| `StripeWebHook__c` | Stores Stripe webhook configuration and keys. | — | — |
| `Subscription_Charge__c` | Tracks failed subscription charges. | — | — |
| `Offline_Payer__c` | Identifies and tracks accounts that pay offline (not via Stripe). | — | Account (multiple Lookup) |

### Workforce & Training

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `WorkRamp_Assignment__c` | Tracks training assignments in WorkRamp for Salesforce users. | WorkRampApp_User__c | User (Lookup) |
| `WorkRamp_Assignment_Log__c` | Error and activity log for DML operations on WorkRamp_Assignment__c. | WorkRamp_Assignment__c | WorkRamp_Assignment__c (Lookup) |
| `WorkRamp_Event__c` | Tracks WorkRamp training events. | — | — |
| `User_Object__c` | Custom record store for production user data (supplements standard User object). | — | 2 relationship fields |

### Contact Center & Call Management

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Contact_Center_Agent_Preference__c` | Stores agent routing and skill preferences for the contact center. | Agent__c | User (Lookup) |
| `Local_Presence_Agent_Mapping__c` | Maps agents to local geographic presence numbers to improve DM Connect rates on outbound calls. | — | — |
| `Local_Customer__c` | Sales tool that surfaces 2-3 local customers from the same geography as the lead being dialed. | — | 3 relationship fields |

### Configuration & Miscellaneous

| Object | Purpose | Key fields | Key relationships |
|--------|---------|------------|-------------------|
| `Area_code__c` | Lookup table mapping US area codes to state names and abbreviations. | Area_code__c, State__c, State_abbreviation__c | — |
| `Generic_Email_Domain__c` | Configuration list of generic/shared email domains (e.g., gmail.com) for validation and deduplication. | — | — |
| `Dynamic_Id_Setting__c` | Configuration object for dynamic ID assignment and external ID mapping. | — | — |
| `In_product_requests__c` | Receives in-product pricing, demo, and mobile demo requests from the brightwheel app. | — | — |

### Custom Metadata Types (`__mdt`)

| Type | Purpose |
|------|---------|
| `Holidays__mdt` | Defines non-operational dates (holidays, weekends, company closures) for scheduling logic |
| `Custom_Sequence__mdt` | Holds custom sequence events for outreach cadences |
| `Create_Tasks_on_Messages_Setting__mdt` | Configuration flags for auto-creating Tasks from message activity |
| `Outreach_Sequence_Mapping__mdt` | Maps outreach sequences to internal configuration values |

### Platform Event

| Event | Purpose |
|-------|---------|
| `CadenceTrackerEvent__e` | High-volume platform event that publishes cadence/engagement tracking data in real time (PublishAfterCommit) |

## Known model issues

1. **Field bloat on Combined_Funnel__c and Onboarding__c** — These objects have 365 and 340 fields respectively. This indicates heavy denormalization and likely includes deprecated, redundant, or audit-only fields that have accumulated over time. Recommend an audit against Salesforce field-usage logs.

2. **Custom fields on standard objects not versioned** — Custom fields on Account, Contact, Lead, Opportunity, Task, and Case are not present in this repository's metadata package. Their definitions exist in the org but are managed separately, creating a risk of configuration drift between environments.

3. **Cascade-delete risk on Onboarding_Attempt__c** — The Master-Detail relationship to Account means deleting an Account record automatically deletes all associated Onboarding_Attempt__c records. Verify this is the intended behavior given that attempts contain historical KPI data.

4. **Onboarding_contact__c dual Master-Detail design** — This junction object has Master-Detail relationships to both Onboarding__c and Contact. Deletion of either parent will cascade. This limits flexibility compared to a Lookup-based junction.

5. **Organization__c parallel data structure** — Stores denormalized contact info (name, email, phone, address) independent of Account/Contact records. This creates a risk of data getting out of sync with the CRM, and it is unclear how this object stays current with changes to related Account/Contact records.

6. **Owner stamping pattern** — Onboarding_Attempt__c uses multiple "Owner Stamp" lookup fields (e.g., Account_SaaS_Owner_Stamp__c, Account_OBS_Owner_Stamp__c) to record which users owned the record at various stages. This requires flow/automation maintenance and is not standard Salesforce ownership tracking.

7. **Child_Site_Creation__c as a staging object** — Described as a "temporary" record store. If the creation process fails mid-transaction, orphaned staging records may accumulate and require manual cleanup.

8. **LOGIC_* rollup fields on Organization__c** — Fields prefixed with LOGIC_ (e.g., LOGIC_associated_accounts__c) appear to be rollup/formula fields tracking cross-object counts. These may become stale if the underlying relationships change.

## ID prefix reference

| Prefix | Object |
|--------|--------|
| `00Q` | Lead |
| `001` | Account |
| `003` | Contact |
| `006` | Opportunity |
| `00T` | Task |
| `500` | Case |
| `00U` | User |
| — | Combined_Funnel__c |
| — | Onboarding__c |
| — | Onboarding_Attempt__c |
| — | Organization__c |
| — | Lead_Request__c |
| — | Stripe_Transaction__c |

> **Note:** Custom object key prefixes (3-character ID prefix) are assigned at org creation and cannot be derived from metadata files. To populate the table above, go to Setup > Object Manager > [Object] > Details and look for the "Key Prefix" field, or run: `SELECT KeyPrefix, QualifiedApiName FROM EntityDefinition WHERE IsCustomizable = true ORDER BY QualifiedApiName` in the Developer Console.
