public with sharing class ConvertLeadsInvocableOrg {

    public class LeadConvertRequest {

        @InvocableVariable(
            label = 'Lead ID'
            description = 'ID of the Lead to convert'
            required = true
        )
        public ID leadId;

        @InvocableVariable(
            label = 'Converted Status'
            description = 'Lead Status picklist value that indicates this Lead is converted'
            required = true
        )
        public String convertedStatus;

        @InvocableVariable(
            label = 'Account ID'
            description = 'The specific Account to convert Lead into. If blank then creates new Account.'
        )
        public ID accountId;

        @InvocableVariable(
            label = 'Contact ID'
            description = 'The specific Contact to convert Lead into. If blank then creates new Contact.'
        )
        public ID contactId;

        @InvocableVariable(
            label = 'Overwrite Lead Source?'
            description = 'Overwrite the LeadSource field on the target Contact with the LeadSource field from the Lead? Default is false. If true then must also specify "Contact ID".'
        )
        public Boolean overwriteLeadSource = false;

        @InvocableVariable(
            label = 'Create Opportunity?'
            description = 'Create an Opportunity? Default is true.'
        )
        public Boolean createOpportunity = false;

        @InvocableVariable(
            label = 'Opportunity Name'
            description = 'If "Create Opportunity" is true then this is the name of the new opportunity. If blank then defaults to Company field from the Lead.'
        )
        public String opportunityName;

        @InvocableVariable(
            label = 'Owner ID'
            description = 'Specific user to own the new Account, Contact, and Opportunity records created. Default is the Lead owner.'
        )
        public ID ownerId;

        @InvocableVariable(
            label = 'Send Email to Owner?'
            description = 'Send an email notification to owner specified in "Owner ID"? Default is false.'
        )
        public Boolean sendEmailToOwner = false;

        @InvocableVariable(
            label = 'Associate with Exisiting Account?'
            description = 'Search for Company name in Account and associate contact with Exisiting Account? Default is true.'
        )
        public Boolean existingacc = true;

        @InvocableVariable(
            label = 'Associate with Exisiting Contact?'
            description = 'Search for Email in Contact and associate contact with Exisiting Account? Default is true.'
        )
        public Boolean existingcon = true;
    }

    public class LeadConvertResult {

        @InvocableVariable( label = 'Lead ID' )
        public ID leadId;

        @InvocableVariable( label = 'Account ID' )
        public ID accountId;

        @InvocableVariable( label = 'Contact ID' )
        public ID contactId;

        @InvocableVariable( label = 'Opportunity ID' )
        public ID opportunityId;

    }

    // --------------------------------------------------------------------------------

    @InvocableMethod(
        label = 'Convert Leads Org'
    )

    public static List<LeadConvertResult> convertLeads( List<LeadConvertRequest> requests ) {

        // Bulkifying - Upsert Account/Contact (to remove duplication)
        // Lists
        List<Id> LeadIds = new List<Id>();
        List<String> OrgIds = new List<String>();
        List<String> LeadEmails = new List<String>();
        List<String> LeadPhones = new List<String>();

        // Maps for matching
        Map<Id, Lead> MapofLeads = new Map<Id,Lead>();
        Map<String, Id> MapofOrgId_LeadId = new Map<String,Id>();
        Map<String, Id> MapofEmail_LeadId = new Map<String,Id>();
        Map<String, Id> MapofPhone_LeadId = new Map<String,Id>();

        // Maps for database convert request
        Map<Id, Id> MapofLead_acc = new Map<Id,Id>();
        Map<Id, Id> MapofLead_acc_owner = new Map<Id,Id>();
        Map<Id, Id> MapofLead_con = new Map<Id,Id>();
  

        for(LeadConvertRequest request : requests ) {
            LeadIds.add(request.leadId);
        }

        if(leadIds.size() > 0 & leadIds !=null){
            for(Lead l : [select id, Organization__c, Email, Phone from Lead where Id IN : LeadIds]){
                MapofLeads.put(l.id,l);
                MapofOrgId_LeadId.put(l.Organization__c,l.id);

                if(l.email != null){
                    MapofEmail_LeadId.put(l.email,l.id);
                }
                if(l.phone != null){
                    MapofPhone_LeadId.put(l.phone,l.id);
                }    

                // Add to Lists for if actions
                OrgIds.add(l.Organization__c);
                LeadEmails.add(l.Email);
                LeadPhones.add(l.Phone);
            }
        }

        if(OrgIds != null && OrgIds.size() > 0){
            for(Account acc : [select id, Owner.Id, Organization__c from Account where Organization__c IN : OrgIds]){
                if(MapofOrgId_LeadId.containsKey(acc.Organization__c)){
                    MapofLead_acc.put(MapofOrgId_LeadId.get(acc.Organization__c),acc.id);
                    MapofLead_acc_owner.put(MapofOrgId_LeadId.get(acc.Organization__c),acc.Owner.Id);
                    System.debug('>>>> MapofLead_acc_owner' + MapofLead_acc_owner);
                }
            }
        }

        if(LeadEmails != null && LeadEmails.size() > 0){
            for(Contact con : [select id, Email, Phone from Contact where Email IN : LeadEmails and Phone <> NULL and Email <> NULL]){
                if(MapofEmail_LeadId.containsKey(con.Email) && MapofPhone_LeadId.containsKey(con.Phone)){
                    MapofLead_con.put(MapofEmail_LeadId.get(con.Email),con.id);
                }
            }
        }

        // transform the invocable request to database convert request
        List<Database.LeadConvert> convertRequests = new List<Database.LeadConvert>();
        for ( LeadConvertRequest request : requests ) {
            // If Map Contains AccountId and OwnerId for Lead
            if(request.accountId == null && MapofLead_acc.containskey(request.leadId) && request.existingacc == true){
                request.accountId = MapofLead_acc.get(request.leadId);
                request.ownerId = MapofLead_acc_owner.get(request.leadId);
            }

            // If Map Contains ContactId for Lead
            if(request.contactId == null && MapofLead_con.containskey(request.leadId) && request.existingcon == true){
                request.contactId = MapofLead_con.get(request.leadId);
            }
            convertRequests.add(transform( request ) );
        }

        // convert leads, all or none
        // if any has error then exception is thrown automatically and changes rolled back
        List<Database.LeadConvertResult> convertResults = Database.convertLead( convertRequests, true );

        // transform the database convert results to invocable result
        List<LeadConvertResult> results = new List<LeadConvertResult>();
        for( Database.LeadConvertResult convertResult : convertResults ) {
            results.add( transform( convertResult ) );
        }

        return results;
    }

    // --------------------------------------------------------------------------------

    private static Database.LeadConvert transform( LeadConvertRequest request ) {

        Database.LeadConvert convertRequest = new Database.LeadConvert();

        convertRequest.setLeadId( request.leadId );
        convertRequest.setConvertedStatus( request.convertedStatus );

        if ( request.accountId != null ) {
            convertRequest.setAccountId( request.accountId );
        }

        if ( request.contactId != null ) {
            convertRequest.setContactId( request.contactId );
        }

        if ( request.overwriteLeadSource != null && request.overwriteLeadSource ) {
            convertRequest.setOverwriteLeadSource( request.overwriteLeadSource );
        }

        if ( request.createOpportunity != null && !request.createOpportunity ) {
            convertRequest.setDoNotCreateOpportunity( !request.createOpportunity );
        }

        if ( request.opportunityName != null ) {
            convertRequest.setOpportunityName( request.opportunityName );
        }

        if ( request.ownerId != null ) {
            convertRequest.setOwnerId( request.ownerId );
        }

        if ( request.sendEmailToOwner != null && request.sendEmailToOwner ) {
            convertRequest.setSendNotificationEmail( request.sendEmailToOwner );
        }

        return convertRequest;
    }

    private static LeadConvertResult transform( Database.LeadConvertResult convertResult ) {

        LeadConvertResult result = new LeadConvertResult();

        result.leadId = convertResult.getLeadId();
        result.accountId = convertResult.getAccountId();
        result.contactId = convertResult.getContactId();
        result.opportunityId = convertResult.getOpportunityId();
        System.debug('>>>> leadId ' + result.leadId);
        System.debug('>>>> contactId ' + result.contactId);
        return result;
    }

    public class ConvertLeadException extends Exception {
    }

}