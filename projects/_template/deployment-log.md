# Deployment Log: [Project Name]

Record every deployment here — sandbox or production — as you go. This creates a clear audit trail.

---

## Log

| Date | Deployed By | From | To | Components | Status | Notes |
|---|---|---|---|---|---|---|
| YYYY-MM-DD | Name | Dev Sandbox | Full Sandbox | List of components | Success / Failed / Partial | Any relevant notes |
| YYYY-MM-DD | Name | Full Sandbox | Production | List of components | Success | |

---

## Component List

List all metadata components included in this project:

| Type | API Name | Description |
|---|---|---|
| Custom Field | `Opportunity.Stage__c` | New stage picklist value |
| Validation Rule | `Opportunity.Require_Close_Date` | Enforces close date on stage change |
| Flow | `Opportunity_Stage_Notification` | Sends email on stage change |

---

## Deployment Issues

Record any errors or issues encountered during deployments:

| Date | Environment | Issue | Resolution |
|---|---|---|---|
| | | | |
