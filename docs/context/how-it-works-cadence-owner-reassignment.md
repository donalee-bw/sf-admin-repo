Cadence Owner Reassignment Automation (Lead + Contact)
Lakhwinder Kaur - February 2026

Summary This automation ensures Sales cadences remain aligned to the correct Sales rep when a Lead or Contact is reassigned. When the owner of a Lead or Contact changes between Sales users, and the record is actively enrolled in a Sales cadence, the automation removes the target from the existing cadence and re-enrolls them into the same cadence under the new owner. This re-enrollment restarts cadence progress from Step 1.

What Was Built Two record-triggered Salesforce Flows were created to support cadence reassignment for both object types:
Lead - After Save - Cadence Owner Reassignment
Contact - After Save - Cadence Owner Reassignment
Both flows use the same structure and logic, with the only difference being the target object (Lead vs Contact).

Business Scope and Decisions
Sales cadences only This automation applies only to Sales cadences. Cadences for post-sales and upsell teams are excluded because those workflows depend more heavily on Account, Opportunity, and Case ownership and are considered out of scope.
Cadence restart behavior (chosen approach) When a Lead/Contact with an active Sales cadence is reassigned from one Sales user to another Sales user, the cadence is removed and re-enrolled under the new owner. This causes the cadence to restart from Step 1.
No notifications No Slack or email notifications are sent when the cadence is reassigned. The assumption is that the new owner already receives a standard Salesforce notification when ownership changes.

Flow Names and Trigger Conditions
Flow 1: Lead - After Save - Cadence Owner Reassignment Trigger Type: Record-Triggered Flow (After Save) Trigger Event: Update
The flow runs only when all of the following conditions are true:
OwnerId is changed
OwnerId starts with “005” (ensures the new owner is a User, not a Queue)
Cadence_Label__c starts with “Sales -” (ensures cadence is within Sales scope)
LOGIC_Owned_by_queue__c = false (explicitly excludes queue-owned records)

Flow 2: Contact - After Save - Cadence Owner Reassignment Trigger Type: Record-Triggered Flow (After Save) Trigger Event: Update
This flow uses the same trigger logic as the Lead flow, applied to the Contact object.

How It Works (Logic Overview)
Both flows follow the same sequence:

Step 1: Identify Active Cadence Enrollment The flow performs a lookup on the ActionCadenceTracker object to determine whether the Lead/Contact is currently enrolled in an active cadence.
Lookup Filters:
TargetId = $Record.Id
IsTrackerActive = true
The flow retrieves only the first active tracker found.

Step 2: Confirm an Active Tracker Was Found A decision element checks whether the cadence tracker lookup returned a record.
If no active cadence tracker is found, the flow ends and takes no action.
If an active cadence tracker is found, the flow proceeds to remove and re-enroll the target.

Step 3: Remove Target from Existing Cadence If the target is actively enrolled, the flow removes them from the cadence using the Sales Engagement action:
Action: removeTargetFromSalesCadence Inputs:
targetId = $Record.Id
completionReasonCode = “ManuallyRemoved”

Step 4: Re-Enroll Target Under New Owner After removal, the flow re-enrolls the same Lead/Contact into the same cadence using the cadence ID from the active tracker lookup.
Action: assignTargetToSalesCadence Inputs:
salesCadenceNameOrId = Get_Active_Cadence_Tracker.ActionCadence.Id
targetId = $Record.Id
userId = $Record.OwnerId (new record owner becomes cadence assignee)
This action restarts the cadence from the beginning (Step 1).

Exclusions and Guardrails
Queue-owned Leads/Contacts are excluded Ownership changes to queues are excluded using both:
OwnerId prefix check (005 = User)
LOGIC_Owned_by_queue__c = false
Only cadences labeled “Sales -” are included Any cadence outside this naming convention is excluded.
Cadence progress will reset Re-enrollment restarts cadence steps and may result in repeated outreach.

Outcome When Sales ownership changes on a Lead or Contact that is actively enrolled in a Sales cadence, the cadence is automatically removed and re-enrolled under the new owner. This ensures the cadence assignment remains accurate and Sales reps are not working cadences owned by a previous user.
