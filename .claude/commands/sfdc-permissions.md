Manage Salesforce permission sets and profiles with principle of least privilege.

## When to use

- Granting access to a new field or object
- Creating a new permission set for a team or role
- Reviewing existing access for security or troubleshooting
- Modifying field-level security after creating a new field

## Principles

- **Prefer Permission Sets over Profiles.** Profiles are org-wide defaults; Permission Sets are additive and can be assigned to specific users. Changes to Profiles affect every user on that profile.
- **Principle of least privilege.** Start with no access, add explicitly what is needed.
- **Document the "why".** Every permission grant should have a stated business reason.

## Process

### 1. State what access is needed and why

"[Role/team] needs [read/edit/create/delete] access to [field/object/feature] because [business reason]."

### 2. Choose Permission Set vs Profile

| Scenario | Use |
|----------|-----|
| New field access for a specific team | Permission Set |
| New object access for a specific role | Permission Set |
| Org-wide default for all users on a license type | Profile (rare, Architect approval recommended) |
| Temporary elevated access | Permission Set (assign, then remove) |

### 3. Name the permission set

Convention: `PS_Role_Purpose`

Examples: `PS_SalesOps_LeadDistribution`, `PS_Marketing_CampaignManagement`, `PS_Admin_DataMigrationBypass`

### 4. Retrieve current state

```bash
sf project retrieve start --metadata PermissionSet:[PS_Name] --target-org sandbox
```

For a new permission set, create the metadata file in `force-app/main/default/permissionsets/`.

### 5. Configure access

**Field-level security:**
```xml
<fieldPermissions>
    <editable>true</editable>
    <field>Lead.Custom_Field__c</field>
    <readable>true</readable>
</fieldPermissions>
```

**Object permissions:**
```xml
<objectPermissions>
    <allowCreate>false</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>true</allowEdit>
    <allowRead>true</allowRead>
    <object>Custom_Object__c</object>
    <viewAllRecords>false</viewAllRecords>
    <modifyAllRecords>false</modifyAllRecords>
</objectPermissions>
```

Grant the minimum necessary:
- Read-only unless edit is specifically needed
- No delete unless explicitly required
- Never `viewAllRecords` or `modifyAllRecords` without Architect approval

### 6. Deploy and verify

Follow `/sfdc-deployment`. After deploying:
- Assign the permission set to a test user in sandbox
- Log in as that user (or use "Login As") to verify access is correct
- Verify the user can see/edit what they should
- Verify the user CANNOT see/edit what they shouldn't

### 7. Document the assignment

Note in the change log:
- Which permission set was created/modified
- Who it should be assigned to
- What access it grants
- Assignment is typically done by an admin in Setup > Users, not via metadata deployment

## Anti-patterns

- Granting `Modify All Data` or `View All Data` system permissions (almost never appropriate for non-admins)
- Modifying Profiles when a Permission Set would suffice
- Granting edit access to fields that should be read-only for that role
- Creating permission sets without clear naming that indicates their purpose
- Leaving temporary elevated access in place after the need has passed
