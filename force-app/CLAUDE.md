# Salesforce naming conventions

Apply these rules when creating or modifying any metadata file in `force-app/`.

## Required conventions

| Component | Convention | Example |
|-----------|-----------|---------|
| Custom field | `Descriptive_Snake_Case__c` | `Center_Capacity__c`, `Last_Demo_Date__c` |
| Custom object | `Descriptive_Name__c` | `Routing_Assignment__c` |
| Flow | `ObjectName_TriggerType_Purpose` | `Lead_AfterUpdate_SetOutreachStage` |
| Validation rule | `VR_ObjectName_Purpose` | `VR_Lead_RequireCapacityOnDisposition` |
| Apex class | PascalCase with role suffix | `LeadHandler`, `OpportunityService`, `AccountTriggerHandler` |
| Apex trigger | `ObjectNameTrigger` | `LeadTrigger`, `OpportunityTrigger` |
| Permission set | `PS_Role_Purpose` | `PS_SalesOps_LeadDistribution` |
| Lightning component | camelCase | `leadDetailCard`, `pipelineView` |

## When reviewing existing metadata

- Note naming violations but do NOT rename without explicit user approval.
- Renames can break cross-references in Flows, Apex, reports, and page layouts.
- If a rename is needed, run `/sfdc-impact-analysis` first to identify all references.

## Anti-patterns

- Single-letter or cryptic abbreviations (`cap__c`, `lt__c`, `x__c`)
- Generic names that don't describe the data (`Field1__c`, `Custom_Field__c`)
- Inconsistent casing within the same object (`some_field__c` next to `Other_Field__c`)
