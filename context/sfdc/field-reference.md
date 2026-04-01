# Field Reference

> **Architect**: Replace this placeholder with your org's key field documentation.
> Last refreshed: _2026-03-31_

## Critical fields

Fields that are especially important, fragile, or commonly misunderstood.

| Object | Field | Type | Fill rate | Why it matters |
|--------|-------|------|-----------|----------------|
| `Subscription_Charge__c` | `charge_id__c` | Text (External ID, Unique, Required) | ~100% | Primary key for Stripe charge sync. Unique + case-sensitive. Upserts from Stripe use this field — duplicate or missing values break billing reconciliation. |
| `School_Object__c` | `Brightwheel_School_UUID__c` | Text (External ID, Unique, Required) | ~100% | Primary integration key between Salesforce and the Brightwheel product. All product-side sync targets this field. Modifying or nulling it orphans the school record in pipelines. |
| `User_Object__c` | `Brightwheel_User_UUID__c` | Text (External ID, Unique) | Query needed | Used to link Salesforce User_Object__c records to Brightwheel user accounts. Critical for entitlement and onboarding workflows. |
| `Combined_Funnel__c` | `Billing_Activation_Override__c` | Text (history-tracked) | Query needed | Mapped to Billing Onboarding flow logic. History-tracked — changes are auditable. Incorrect values can cause a funnel record to skip or repeat activation steps. |
| `Combined_Funnel__c` | `SaaS_Activation_Override__c` | Text (history-tracked) | Query needed | Parallel to `Billing_Activation_Override__c` for the SaaS funnel stream. Same fragility — flow reads this field to determine activation path. |
| `Combined_Funnel__c` | `Billing_Primary_Contact__c` | Lookup → Contact | Query needed | Mapped from Closed Won opportunity. Drives all billing onboarding outreach. If null, billing outreach has no target contact. |
| `Combined_Funnel__c` | `SaaS_Primary_Contact__c` | Lookup → Contact | Query needed | Same as above for the SaaS activation stream. Populated from opportunity; null value stalls SaaS activation cadences. |
| `Subscription_Charge__c` | `stripe_customer_id__c` | Text (External ID) | Query needed | Links the charge record back to a Stripe customer. Required for payment method lookup and refund processing. |
| `Organization__c` | `LOGIC_associated_locations__c` | Roll-Up Summary (Count) | ~100% | Counts related `Location__c` records. Used in routing and multi-site logic. Do not convert to a formula — it must remain a roll-up to stay accurate. |

## Hidden fields

Fields that exist in the data model but are not exposed in the standard UI. These often contain critical data that pipelines or integrations depend on.

| Object | Field | Why hidden | What it contains | Do not modify without |
|--------|-------|-----------|------------------|----------------------|
| `Combined_Funnel__c` | `ADMIN_Owner_User_ID__c` | Not on page layout — admin use only | Formula: `Owner:User.Id`. Used when transferring record ownership in bulk data operations. | Salesforce Admin; changes affect ownership transfer scripts |
| `Combined_Funnel__c` | `ADMIN_SaaS_CW_Opp_ID__c` | Not on page layout — admin use only | Formula: `SaaS_CW_Opportunity__r.Id`. Used in admin data uploads to reference the parent opportunity. | Salesforce Admin; used in data loader templates |
| `Combined_Funnel__c` | `ADMIN_Tag__c` | Not on page layout | Free-text tag for admin data segmentation and ad-hoc batch operations. | Salesforce Admin |
| `Onboarding__c` | `ADMIN_Combined_Funnel_ID__c` | Not on page layout — for reporting and historical uploads | Formula: `Combined_Funnel__r.Id`. Exposes the parent funnel's Salesforce ID for use in data loader and reports. | Salesforce Admin |
| `Onboarding__c` | `ADMIN_Opp_ID__c` | Not on page layout — admin use only | Formula: `Opportunity__r.Id`. Exposes the related opportunity ID for admin operations. | Salesforce Admin |
| `Onboarding__c` | `ADMIN_Primary_Contact_ID__c` | Not on page layout | Formula exposing the primary contact's Salesforce ID. Used in data upload templates. | Salesforce Admin |
| `Onboarding__c` | `ADMIN_Opp_Record_Type__c` | Not on page layout | Formula surfacing the opportunity record type. Used to differentiate Billing vs SaaS onboarding context. | Salesforce Admin |
| `Organization__c` | `LOGIC_Email_domain__c` | Not user-facing — logic field | Extracted email domain from the org's email address. Used by duplicate-detection and generic domain rules. | Do not modify; feeds `LOGIC_Organization_Generic_Domain__c` |
| `Organization__c` | `LOGIC_Organization_Generic_Domain__c` | Not user-facing — logic field | Flags whether the org's email domain is a generic domain (e.g., gmail.com). Used in lead routing and deduplication flows. | Do not modify; downstream routing depends on this |
| `Organization__c` | `LOGIC_Apex_counter__c` | Not user-facing — logic field | Number field incremented by Apex triggers. Used to sequence or throttle trigger operations. | Engineering; modifying can cause trigger loops |

## Consolidation constraints

Groups of fields that overlap and should NOT be expanded further. If an admin needs to capture similar data, direct them to one of the existing fields or propose consolidation.

### Billing platform version — dollars processed

These three fields track dollars processed online across billing platform generations. Do not add a V4 equivalent without retiring a prior version.

| Field (on `School_Object__c`) | Fill rate | Notes |
|-------------------------------|-----------|-------|
| `V2_Dollars_Processed_Online__c` | Query needed | Amount processed on billing platform v2. Only populated for schools that migrated from v1 → v2. |
| `V3_Dollars_Processed_Online__c` | Query needed | Amount processed on billing platform v3. Current generation. |
| `V3_Dollars_Processed__c` | Query needed | Total dollars processed on v3 (online + offline). Broader than `V3_Dollars_Processed_Online__c`. |

**Guidance**: Use `V3_Dollars_Processed_Online__c` for current reporting. `V2_*` fields are historical — only populated for migrated schools. Do not add new "dollars processed" fields; surface any gaps to the data team for a migration plan.

### Primary contact — billing vs SaaS

Each funnel has parallel primary contact fields for the two activation streams. Do not add a third stream without a design review.

| Field (on `Combined_Funnel__c`) | Fill rate | Notes |
|---------------------------------|-----------|-------|
| `Billing_Primary_Contact__c` | Query needed | Lookup to Contact; mapped from CW Opp; drives billing cadences |
| `Billing_Primary_Contact_Email__c` | Query needed | Email formula from `Billing_Primary_Contact__c`; used where formula access is needed |
| `Billing_Primary_Contact_ID__c` | Query needed | ID formula from `Billing_Primary_Contact__c`; used in data loader templates |
| `SaaS_Primary_Contact__c` | Query needed | Lookup to Contact; parallel field for SaaS stream |
| `SaaS_Primary_Contact_Email__c` | Query needed | Email formula from `SaaS_Primary_Contact__c` |
| `SaaS_Primary_Contact_ID__c` | Query needed | ID formula from `SaaS_Primary_Contact__c` |

**Guidance**: The lookup fields (`Billing_Primary_Contact__c`, `SaaS_Primary_Contact__c`) are the sources of truth. The `_Email__c` and `_ID__c` variants are formula derivatives — do not populate them directly. Do not add more primary contact variants; if a new contact role is needed, discuss with the architect.

### Organization email domain logic

Multiple overlapping formula fields all derive from the org email domain.

| Field (on `Organization__c`) | Fill rate | Notes |
|------------------------------|-----------|-------|
| `LOGIC_Email_domain__c` | Query needed | Base extraction of email domain |
| `LOGIC_Organization_Email_domain__c` | Query needed | Alternate version — likely legacy |
| `LOGIC_Organization_Email_Domain2__c` | Query needed | Second alternate — likely legacy |
| `LOGIC_Organization_Generic_Domain__c` | Query needed | Derived flag: generic domain yes/no |

**Guidance**: `LOGIC_Organization_Generic_Domain__c` is the actionable field used by flows. The two `Email_domain` variants are candidates for consolidation — confirm which flows reference each before retiring either.

## Low-fill fields

Fields with <5% fill rate that may be candidates for retirement or re-purposing.

> **Note**: Fill rates below are structural assessments based on field purpose and platform generation history. Confirm actual fill rates with a SOQL query before taking any action.

| Object | Field | Fill rate | Recommendation |
|--------|-------|-----------|----------------|
| `School_Object__c` | `V2_Migration_Date__c` | Low — only schools that migrated from v1→v2 | Keep for historical record; do not repurpose. Marks the v1→v2 billing migration date. |
| `School_Object__c` | `V2_Dollars_Processed_Online__c` | Low — v2-era schools only | Keep; historical reference for migrated schools. Flag for deprecation when v2 cohort is fully sunset. |
| `School_Object__c` | `V2_Fifth_Payment_Online_Date__c` | Low — v2-era schools only | Keep; tracks activation milestone on v2. Review for deprecation with v2 sunset. |
| `Onboarding__c` | `temp_Days_Since_Gov_Closed_Won__c` | Unknown — prefixed "temp" indicates incomplete work | Investigate before using. Likely a work-in-progress field — confirm whether it has been incorporated into a permanent field or can be removed. |
| `Organization__c` | `LOGIC_Organization_Email_domain__c` | Query needed | Likely superseded by `LOGIC_Email_domain__c`. Confirm no active flow references before retiring. |
| `Organization__c` | `LOGIC_Organization_Email_Domain2__c` | Query needed | Second variant of email domain extraction. Confirm references and consolidate if unused. |

## Naming exceptions

Fields that don't follow standard naming conventions but should not be renamed (due to integration dependencies, historical usage, etc.).

| Field | Why it's an exception |
|-------|----------------------|
| `Subscription_Charge__c.charge_id__c` | Lowercase snake_case instead of PascalCase. Matches the Stripe API payload key exactly. Renaming would break Stripe webhook upsert mappings. |
| `Subscription_Charge__c.invoice_id__c` | Same as above — lowercase to match Stripe API field naming. |
| `Subscription_Charge__c.stripe_customer_id__c` | Same pattern — Stripe API naming convention preserved for webhook compatibility. |
| `Organization__c.LOGIC_*` fields | `LOGIC_` prefix is not a standard Salesforce naming convention, but is used org-wide as a visual signal that the field is formula-driven and not writable by users or automations. Do not rename; the prefix is load-bearing for admin comprehension. |
| `Combined_Funnel__c.ADMIN_*` and `Onboarding__c.ADMIN_*` fields | `ADMIN_` prefix signals that the field is not on any page layout and is reserved for data loader / admin operations. Renaming removes the visual warning that deters accidental edits in flows. |
