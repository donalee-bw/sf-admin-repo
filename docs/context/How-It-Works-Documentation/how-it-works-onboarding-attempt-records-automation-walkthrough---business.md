# Main Onboarding Attempt Record Automation

# Business Process Solution Overview

It is essential for the business to be able to track current and historical Onboarding attempts on a single account for a variety of reasons: KPIs, goals, success rate of each Onboarding attempt, YoY/MoM activation rates etc. When an account becomes a customer (through a CW SaaS, Billing, or Gov opportunity), a new SaaS and/or Billing Onboarding Attempt(s) is created. The Onboarding Attempt status will remain “In Progress” until that attempt is deemed closed (either by the customer canceling or activating).  While the attempt is In Progress, the data on the Onboarding Attempt is updating in real time. Once the attempt is Closed or Canceled, the Attempt locks down and no future changes will be made to it. See below for a more detailed description of how this process works:

## Onboarding Attempt Creation Process

When a SaaS or Government Opportunity is CW:
FIRST, the automation will check for any In Progress SaaS or Billing Onboarding Attempts associated with the account. If one exists, the automation will set it to Closed.
THEN, the automation will create a SaaS and Billing Onboarding Attempt and set the statuses to “In Progress”.
If the Billing Status at CW equals Hard Opt Out, the Billing Onboarding Attempt will still be created, but the status will be Closed.

When a Billing Upsell Opportunity is CW:
FIRST, the automation will check for any In Progress Billing Onboarding Attempts associated with the account. If one exists, the automation will set it to Closed.
THEN, the automation will create a Billing Onboarding Attempt and set the status to “In Progress”.

Mapped Fields on SaaS Onboarding Attempts (at Creation or Update)

Field Name
Source
Brightwheel School UUID
School Object
Brightwheel Organization UUID
School Object
Number of Sites - Stamp
School Object
Account Name
Account
Opportunity
Opportunity
Opportunity CW Date
Opportunity
SaaS Funnel Start Date - Stamp
School Object
Combined Funnel Owner - Stamp
Combined Funnel
Account AE Owner - Stamp
Account
Billing Upsell Owner - Stamp
Account
SaaS Owner - Stamp
Account
Days since CW - Stamp
Account
SaaS Adding Parents Stage Met Date - Stamp
School Object
SaaS Adding Staff Stage Met Date - Stamp
School Object
SaaS Adding Students Stage Met Date - Stamp
School Object
SaaS Logging Activities Stage Met Date - Stamp
School Object
SaaS Parents Signing Up Stage Met Date - Stamp
School Object
SaaS Staff Logging In Stage Met Date - Stamp
School Object
SaaS Tracking Attendance Stage Met Date - Stamp
School Object
SaaS Activation Date - Stamp
School Object
Initial Setup Call Scheduled - Stamp
Combined Funnel
Initial Setup Call Completed - Stamp
Combined Funnel
Onboarding Training Call Scheduled - Stamp
Combined Funnel
Onboarding Training Call Completed - Stamp
Combined Funnel
Brand New Program - Stamp
Combined Funnel
Onboarding Path - Stamp
Combined Funnel
Related Payer Account - Stamp
Account
Related Payer Account Type - Stamp
Account
Account Customer Type - Stamp
Account
Account Type - Stamp
Account
SaaS Onboarding Eligible Date - Stamp
School Object
SaaS Activation Funnel Stage - Stamp
School Object
SaaS Activation Override - Stamp
Combined Funnel
SaaS Override Reasoning - Stamp
Combined Funnel
Date of SaaS Override
Automation, when SaaS Activation Override on Combined Funnel is updated and SaaS Onboarding Attempt is In Progress.

Mapped Fields on Billing Onboarding Attempts (at Creation or Update)

Field Name
Source
Brightwheel School UUID
School Object
Brightwheel Organization UUID
School Object
Number of Sites - Stamp
School Object
Account Name
Account
Opportunity
Opportunity
Opportunity CW Date
Opportunity
Billing Activation Start Date - Stamp
Account
Combined Funnel Owner - Stamp
Combined Funnel
Cancelation Date - Stamp
School Object
Account AE Owner - Stamp
Account
Billing Upsell Owner - Stamp
Account
SaaS Owner - Stamp
Account
Days since CW - Stamp
Account
# Days to Activate from CW - Stamp
Account
Billing Adding Payers Stage Met Date - Stamp
School Object
Billing Adding Students Stage Met Date - Stamp
School Object
Billing Complete Set-Up Stage Met Date - Stamp
School Object
Billing Online Payments Stage Met Date - Stamp
School Object
Billing Sending Bills Stage Met Date - Stamp
School Object
Billing Setting Up Bills Stage Met Date - Stamp
School Object
Billing Submit Verify Stage Met Date - Stamp
School Object
Billing Verify Complete Stage Met Date - Stamp
School Object
Billing Activation Date - Stamp
School Object
Initial Setup Call Scheduled - Stamp
Combined Funnel
Initial Setup Call Completed - Stamp
Combined Funnel
Onboarding Training Call Scheduled - Stamp
Combined Funnel
Onboarding Training Call Completed - Stamp
Combined Funnel
Billing Training Call Scheduled - Stamp
Combined Funnel
Billing Training Call Completed - Stamp
Combined Funnel
Brand New Program - Stamp
Combined Funnel
Onboarding Path - Stamp
Combined Funnel
# of Students at Billing Activation - Stamp
School
Related Payer Account - Stamp
Account
Related Payer Account Type - Stamp
Account
Account Customer Type - Stamp
Account
Billing Status at CW - Stamp
Combined Funnel
Account Type - Stamp
Account
Billing Onboarding Eligible Date - Stamp
School Object
Bill Rate Uploaded Date - Stamp
School Object
Billing Activation Override - Stamp
Combined Funnel
Billing Override Reasoning - Stamp
Combined Funnel
Billing Override Approved by Manager - Stamp
Combined Funnel
Billing Activation Funnel Stage - Stamp
School Object
Date of Billing Override
Automation, when Billing Activation Override on Combined Funnel is updated and SaaS Onboarding Attempt is In Progress.

## Onboarding Attempt Update Process

Once an update triggers a status change on an Onboarding Attempt, the automation takes a snapshot of all the values listed in the tables above. From that moment on, those values remain locked until another status update occurs. Below is the list of statuses, what they mean for SaaS and Billing Onboarding Attempts, and what triggers an Onboarding Attempt to be updated to each status.

SaaS Onboarding Attempt Statuses
IN PROGRESS
Set when a new Onboarding Attempt is created
Active
Postponed
Unresponsive
Requesting Postpone - Awaiting Approval
CANCELED
Set when the field Cancelation Date on the School Object is updated with a date.
Inactive
CLOSED
Set when there’s a new CW opportunity or when the field SaaS Activation Date on the School Object is updated and the date value is greater than Original Close Date on the Account
Billing Onboarding Attempt Statuses
IN PROGRESS
Set when a new Onboarding Attempt is created
Active
Postponed
Unresponsive
Requesting Postpone - Awaiting Approval
Billing At Risk
Requesting Opt Out - Awaiting approval
Soft Opt Out (at POS)
CANCELED
Set when the field Cancelation Date on the School Object is updated with a date.
Inactive
CLOSED
Set when there’s a new CW opportunity or when the field Billing Activation Date on the School Object is updated and the date value is greater than Billing Activation Start Date on the Account
Hard Opt Out (at POS)
Opted Out

When an Onboarding Attempt record is set to IIn Progress, it can only move to either Canceled or Closed. A Closed status can never be changed to Canceled, and vice versa.
