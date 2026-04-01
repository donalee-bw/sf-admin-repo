# JungleGym Account and Subscription Creation

### Business Process Solution Overview
We’ve implemented a streamlined process that allows Sales reps to create a customer Account and Subscription directly from Salesforce Opportunities, driving consistency and reducing manual steps. This solution:
Centralizes data entry
Enforces data quality
Automates follow-up actions
Provides user feedback
#### Key Steps
Launch Create Account
Button labeled Create Account and Subscriptions appears in the top-right of the Opportunity page.
Pop-up Data Capture
The button launches a screen flow where the rep is required to input the required information that is necessary to create an Account in JungleGym.
The popup is pre-populated with information from the Opportunity, Account, and Contact records and changes to information in the popup will write back to the Salesforce records.
Offline Payer
Offline payers are only accepted for Annual Subscriptions. If the Subscription picklist is changed to Annual then the SaaS Offline Payer field will be displayed. If this field is checked then the SaaS Offline Contract Start and End Date, and the Government Grant/Subsidized/Sponsored Fields will appear and First Bill Date will be set to blank and greyed out to prevent user input.
Only the SaaS Offline Payer checkbox is required for the JungleGym sync, it’s mapped to a payerType key with a value of either &quot;online&quot; or &quot;offline&quot;. The other three fields, while necessary for Salesforce’s Offline Payer process, aren’t sent to JungleGym.
Existing Accounts (excl.  s)
Existing Account Identification logic is documented here: How It Works |  JG Account Check Documentation
If the customer already exists in JungleGym but is not an admin (e.g. teacher, guardian), reps must request a new email address. If none is available, they should escalate to their manager.
If the customer is already an admin in JungleGym, the flow can proceed. A warning will appear letting the rep know the existing account will be updated, not recreated.
The sync sends Exists In JG, JG Identification Role, and Org Id. If Exists In JG is true, the related Org and School Ids are pulled from the Account object. Note: If the Opportunity isn’t tied to the same Account as the original Closed Won Opportunity, the sync may fail because it won’t be able to retrieve the existing Org and School UUIDs from the School Object.
Account &amp; Subscription Creation
After entering the information and clicking submit, the data is compiled into a JSON payload and sent to JungleGym using an asynchronous API callout.
JungleGym parses the JSON payload and uses the information to create Account and Subscription Records.
Sync Back to Salesforce
JungleGym will populate the JungleGym Sync Status field with either Success or Failed depending on the result of the transaction.
After successful JG Account creation the Admin Id, Organization Id, and School Id are automatically populated on the Opportunity record.
If the transaction failed, Users are required to manually create the records in JungleGym.
User Notifications
On Refresh: When the JungleGym Sync Status field is populated a green check mark or red warning sign will be displayed in the top right hand corner of the Opportunity record indicating to the user if the sync was successful or failed.
Slack: Reps receive a DM in Slack with a link to the Account record with the status of the sync
Multi-Site
If the opportunity is a multi-site, a second button “Create Child Account and Subscriptions” will display after the parent information is sent. This will show a popup with a repeater element that will capture the information that is necessary to create a child Account in JungleGym. Once this screenflow is completed it will create one Child Site Creation record for each child site element in the repeater and send a separate JSON payload for each child site. No Account/Opportunity/Combined Funnel is created for child sites at this time.
When the parent Opportunity is closed won, reps will be asked to complete the Billing and SSPR information for each child site. When the closed won process is finished it will trigger a Record Triggered Flow on the Child Site Creation object that will create the child Account/Opportunity/Combined Funnel for each site.

### Sales Documentation
New Customer Sign Up SOP
Offline Payer &amp; Existing Account Loom

### Promo Codes

Promo codes are automatically applied to JungleGym Accounts created using this process. In order for this to work correctly the promo code selected on the Opportunity must match the corresponding value in JungleGym. The picklist values on the Opportunity have been updated to reflect the active promos currently offered by sales. However, there are 2 scenarios where old promo codes could still be selected, 1. Old values are still visible on the lead record, these could carry over to the Opportunity. 2. Opportunities that had old promo codes selected prior to this process going live. If an old promo code is selected then the rep will be forced to select an active value in the Create Account and Subscriptions package. If an Opportunity is Closed Won without using the JG Sync process and has an old promo code selected then the CW process will fail. In this case the rep should be instructed to select the Promo Code that matches the JG value. A list of active promo codes can be found here

Technical Process Solution Overview
Component
Type
Description
Opportunity - Screen - Create JungleGym Account
Screen Flow
Displays popup when Create Account and Subscription button is clicked. Sends Account/Opp/Contact information to JungleGymAccountCreationService
Opportunity - Screen - Create JungleGym Child Sites
Screen Flow
Displays a popup when the Create Child Account and Subscriptions button is clicked. Captures initial child site information required to create account in JungleGym, creates Child Site Creation records and sends information to JungleGymAccountCreationService
Opportunity- Screen- Closed/Won Flow
Screen Flow
The overall Closed Won process remains the same, but this flow has been modified to pull in existing Child Site Creation information, the user will need to input Billing and SSPR information which is not captured at the time of Child Site creation. After the Opp is closed won the Child Site Creation records are updated to trigger Child Site Creation - After Save - Create Child Records
JungleGymAccountCreationService
Apex Class
Queries fields, related records, and auth token then adds them to a wrapper and sends to JungleGymCalloutQueueable
JungleGymPayloadBuilder
Apex Class
Creates JSON payload with data from JungleGymAccountCreationService, called from and returns payload to JungleGymCalloutQueueable
JungleGymCalloutQueueable
Apex Class
Sends JSON payload to the JungleGym API endpoint.
JungleGymUtils
Apex Class
Handles data transformation for scenarios where JG expects a different data type than Salesforce provides
JungleGymCreationServiceTest
Apex Class
Provides test coverage for JungleGymAccountCreationService, JungleGymCalloutQueueable, JungleGymPayloadBuilder, and JungleGymUtils
Child Site Creation - After Save - Create Child Records
Record Triggered Flow (Child-Site Creation)
When Child Site Creation records are updated to
Opportunity - After Save - Send Slack Notifications
Record Triggered Flow
(Opportunity)
Sends Slack notification to Opportunity owner when JungleGym Sync Status field is updated
Opportunity - After Save - Update UUID
Record Triggered Flow (Opportunity)
Populates UUIDs on the Parent Account when they are populated in the JungleGym callback.
JGAuth Key
Custom Setting
Holds Authorization token sent in Http callout. Used to ensure the transaction is secure.
