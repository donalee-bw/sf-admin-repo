# Child Sites Creation Automation

# Business Process Solution Overview

The new multisite child creation process is kicked off by the same screen flow that handles moving opportunities to Closed Won. Once the user fills out all the required info to CW an opportunity, the flow checks the “Number of Schools” field. If the number entered is greater than 1, another screen appears to collect details for the child records.

On that new screen, the following fields are required in order to proceed with creating the child sites:

- Child Site Name
- School UUID
- Contact (picklist; the contact must already be added to the original CW opportunity’s account)
- Capacity
- Enrollment
- Amount
- # of Staff
- Center Type
- Current Center Operating Status
- Open and Operating Date (if required based on the selected status)

There are also two key fields that determine if more information is needed:

1. Same Onboarding and SSPR as the Parent?
- If Yes, all SSPR-related values will be copied from the original CW opportunity into the child.
- If No, the user must manually enter:
- Onboarding Path
- Was SSP Added on Call?
- Reason SSP Was Not Added (based on previous answer)
- Reason SSP Was Not Added Details (based on previous answer)
- OBS Owner (based on previous answers)
- OBS Call Scheduled Date (based on previous answers)
- Sales Follow-up Call Scheduled Date (based on previous answers)

2. Same Billing Status at CW as the Parent?
- If Yes, billing-related values will be copied from the original CW opportunity.
- If No, the user must enter:
- Billing Status at Closed Won
- Billing Closed Lost Reason (if applicable)
- Was rate card captured? (if applicable)
- Billing Opt Out Reason Detail (if applicable)
- Billing Primary Contact (picklist; must be from original CW opportunity)
- Current Tool for Billing (if applicable)
- Uses Attendance or Variable Rate Billing
- Billing Conversation Notes
- Billing Intervals (if applicable)
- Target Billing Launch Timeframe (if applicable)
- Expected # of Paying Students (if applicable)

For each child site, all of the above info needs to be provided. After entering the first site’s info, the user needs to click  the “+ Add” button to input the next one. Once all sites have been added, they click the “Create Child Sites” button.

If the number of child sites added doesn’t match the number provided in the “Number of Schools” field earlier in the flow, an error will pop up asking the user to go back and fix it.

If the numbers match, the flow finishes when the user clicks “Create Child Sites.” The child records are then created asynchronously, so they may not appear right away. Depending on system load and how many records are being created, it can take up to 3 minutes for them to show up.

# Technical Process Solution Overview

To create the child records, we iterated over the existing flow that captures the information to CW an opportunity and created a new flow that handles the creation of the child records.

## Updated Flows

Name: Opportunity- Screen- Closed/Won Flow
Description: We added a decision node to the flow that checks the value entered in the “Number of Schools” field on the first screen that captures the CW opportunity info. If the number is 1 (single-site), the flow follows the existing process, which updates the opportunity with the values from the CW screen and also updates the related contact info.

If the number is 2 or more, a new screen appears to capture all the info needed for the child sites. This screen includes a lot of logic and field dependencies based on the user’s input. For each site, a new repeater input is generated to collect the required details.

After that, the flow checks whether the number of repeater inputs matches the number provided in the “Number of Schools” field. If they don’t match, another screen pops up to alert the user about the mismatch and prompts them to go back and double-check the number of child sites entered.

If the numbers do match, the flow moves forward and stores the info from each repeater input into a record variable. This variable is tied to a custom object called Child Site Creation, which was built specifically for this purpose. All the fields on the child site creation screen also exist on this object, so for each repeater input, a new Child Site Creation record is created with the captured data.

Later, these Child Site Creation records are used to create the actual child opportunities, accounts, combined funnels, and onboarding attempt records.

Finally, as long as everything runs smoothly without any errors, the flow wraps up by updating the original CW opportunity with the values entered on the first screen, and it also updates all the related contacts.

## New Flows
Name: Child Site Creation - After Save - Create Child Records
Type: Record-Triggered Flow
Description: This is the flow that handles creating all the child opportunities, accounts, combined funnels, and onboarding attempt records. It runs asynchronously whenever a new Child Site Creation record is created by the “Opportunity - Screen - Closed/Won Flow.” We chose to go the async route for efficiency and to avoid hitting Salesforce governor limits that can happen when creating and updating a large number of records at once. Because of that, the records might not be created instantly—it could take a minute or so for everything to show up.

First, the flow grabs the original CW multi-site opportunity and uses it to create the child opportunity by cloning its values and assigning them to a new opportunity record variable.

Next, it creates the new account using the values stored in the Child Site Creation record, which were captured through the child site creation screen in the CW flow.

The flow then checks whether any new SSPR or Billing Information was provided in the screen flow. If there’s updated info, it overrides the relevant values in the opportunity record before going ahead and creating the child opportunity.

After that, the flow creates the combined funnel, using data from both the Child Site Creation record and the original CW opportunity.

As for the onboarding attempt records, those aren’t created in this flow—they’re handled later in the day by an existing scheduled flow.

We’re also updating the Child Site Creation record to tag the associated child records, which helps with debugging if needed.
