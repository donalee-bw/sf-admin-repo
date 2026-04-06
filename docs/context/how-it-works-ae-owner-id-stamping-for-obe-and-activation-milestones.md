# AE Owner ID Stamping for OBE and Activation Milestones

## Purpose
To record the AE responsible at key onboarding milestones — both SaaS/Billing OBE and SaaS/Billing Activation — directly on the Account, ensuring visibility and compensation accuracy even as ownership changes throughout the customer lifecycle.

## ✅ New Fields (on Account Object)
Field API Name
Field Label
Description
SaaS_OBE_AE_Owner_ID__c
SaaS OBE AE Owner (User ID)
Stamped when SaaS Onboarding Eligible Date is populated
Billing_OBE_AE_Owner_ID__c
Billing OBE AE Owner (User ID)
Stamped when Billing Onboarding Eligible Date is populated
SaaS_Activation_AE_Owner_ID__c
SaaS Activation AE Owner (User ID)
Stamped when SaaS Activation Date is populated
Billing_Activation_AE_Owner_ID__c
Billing Activation AE Owner (User ID)
Stamped when Billing Activation Date is populated
Field Type: Text(18) These fields are not currently visible on any page layouts. Only Sys Admins have edit access. Visibility may be extended later based on stakeholder input.

## ⚙️ Automation Summary
### Existing Flows Updated:
SaaS Activation Funnel Movement
Billing Activation Funnel Movement
### Triggered From:
School object
When any of the following fields are changed and not null:
SaaS_Onboarding_Eligible_Date__c
Billing_Onboarding_Eligible_Date__c
SaaS_Activation_Date__c
Billing_Activation_Date__c
### Flow Logic:
Get Related Account
Get AE Owner from Account.AE_Owner__c
Stamp User ID into the appropriate Account field (only if that field is currently blank):
SaaS/Billing OBE AE fields → For all deals
SaaS/Billing Activation AE fields → For all deals
If both milestone dates are set in the same sync, both fields will be stamped using the same AE Owner.

## Permission Management
A new Permission Set has been created: Compensation Account Fields
This grants edit access to the four AE Owner fields listed above. Assigned to:
SalesOps team
Finance team
Marg, Sales Director
Taylor, Sales Director
This ensures the right groups can override values if needed for audit or correction purposes.
