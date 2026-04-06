# Org Overview

## Environment
| Field | Value |
|-------|-------|
| Org Name | Brightwheel-Full |
| Type | Sandbox |
| Instance URL | brightwheel1--full.sandbox.my.salesforce.com |
| Username | paul.acullador@mybrightwheel.com.full |
| API Version | 66.0 |
| CLI | Salesforce CLI (`sf` command) |

## Company Context
Brightwheel is a childcare/education SaaS platform. The Salesforce org supports the sales organization (SDRs, AEs, managers) and post-sale teams. The CRM tracks childcare centers ("schools") as Accounts, with Leads/Contacts representing decision-makers at those centers.

## Metadata Inventory (approximate)
| Component | Count | Notes |
|-----------|-------|-------|
| Apex Classes | ~117 | Trigger handlers, batch jobs, schedulers, invocable actions, test classes |
| Flows | ~506 | Lead, Contact, Account, Opportunity, Combined Funnel, Slack, cadence flows |
| LWC Components | 5 | logDispositionUtil, voiceNumberSelector, workQueue, workQueueCadenceGroup, workQueueStepItem |
| Aura Components | present | Legacy, mostly managed package |
| Custom Objects | Opportunity (custom fields), Combined_Funnel__c, Child_Site_Creation__c, Organization (custom), Location (custom) |
| Triggers | Thin triggers delegating to handler classes |

## Apex Patterns
- **Trigger handlers:** `AccountTriggerHandler`, `ContactTriggerHandler`, `CombinedFunnelTriggerHandler` — all logic in handler, trigger file is 1-2 lines
- **Batch/Schedulers:** `AccountUpdateSweep` + `AccountUpdateSweepScheduler`, `ContactSweep` + `ContactSweepSheduler` (note: typo in original)
- **Invocable actions:** `ContactMergeInvocable`
- **Test convention:** `<ClassName>Test` (e.g., `AccountTriggerHandlerTest`)
- **Service classes:** `AgentOutboundNumberPreferenceService` (Service Cloud Voice)
- **API versions in use:** 63.0–66.0 (use 66.0 for new work)

## Flow Patterns
- Heavy use of before-save and after-save record-triggered flows
- Scheduled flows for batch operations (churn updates, org rematching, cadence exits)
- Screen flows for rep-facing UIs (lead recycling, log-a-conversation)
- Subflows for reusable logic (cadence entry, org/location matching)
- Naming convention: `Object_Trigger_Description` (e.g., `Lead_Before_Save_Updates`, `Account_After_Save_Generic_Updates`)

## LWC Patterns
- `workQueue` family: rep-facing task management (work queue with cadence groups and step items)
- `voiceNumberSelector`: Service Cloud Voice integration, targets `lightning__VoiceExtension`
- `logDispositionUtil`: call disposition logging utility

## Installed Packages
| Package | Namespace | Version | Purpose |
|---------|-----------|---------|---------|
| EFH | `EFH` | 1.7 | (Managed package — referenced by some Apex classes) |
