# How It Works | Bill Rate Uploaded Date
### School Object - Bill Rate Uploaded Date | Data
The Bill_Rate_Uploaded_Date__c field is set on the School Object  via a nightly job owned by  Product / Engineering. If this date is not being populated as expected in Salesforce, please reach out directly to Matt Ong – PM for support.
### Account - Bill Rate Uploaded Date | Salesforce Automation
#### School Object - After Save - Updates (flow)

Purpose: This flow keeps Account and Combined_Funnel__c fields in sync with updates to School Object, ensuring accurate onboarding and billing data — particularly when Premium_ECE__c, Billing_Submit_Verify_Stage_Met_Date__c, or Bill_Rate_Uploaded_Date__c are updated.
The flow ensures that when Bill_Rate_Uploaded_Date__c is populated on the School Object, it is copied over to the related Account — but only if the Account’s field is currently blank. This ensures consistent billing readiness data across objects.

#### School Object - After Save - Post CW Opp Stages (flow)

Purpose: This Salesforce Flow automates Opportunity stage and status updates after Close Won, using School Object and Account data to determine onboarding progress, billing setup, or churn — reducing the need for manual updates.

The flow reads (evaluates) the value of Bill_Rate_Uploaded_Date__c on the Account to determine the next steps for the related Opportunity.
The flow does not update Bill_Rate_Uploaded_Date__c — neither on the Account nor on the School Object.
School Object - Sync Opportunity Post CW Stages (flow)
Purpose: This flow automatically updates the stage and Post-CW (Post-Close Won) status of an Opportunity based on data from the related School and Account records.
The flow reads (evaluates) the value of Account.Bill_Rate_Uploaded_Date__c to help determine Billing Progress and set the Post CW Stage on the Opportunity.
This flow never modifies the field on the Account or School Object.

#### Account - After Save - Opp Post CW Stage Sync (flow)
Purpose: This flow ensures Opportunities in Post-CW stages stay aligned with onboarding progress by re-evaluating them whenever related Account data changes. Triggered by updates to the Account object — such as changes to Bill_Rate_Uploaded_Date__c, open cancel case count, or School Object — it updates fields on the related closed Opportunity, including StageName and Post_CW_Status__c.
The flow uses the Account.Bill_Rate_Uploaded_Date__c field as a condition to determine whether to re-evaluate a related closed Opportunity that is in a post-close-won (Post CW) stage.
This flow never modifies the field on the Account or School Object.
