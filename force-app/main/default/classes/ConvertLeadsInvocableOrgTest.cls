@isTest
private class ConvertLeadsInvocableOrgTest {

    @isTest
    static void test_convert_lead_yes_opportunity() {

        Lead ld = new Lead(
            firstName = 'Test',
            lastName = 'McTester',
            company = 'Salesforce'
        );

        insert ld;

        Test.startTest();

        ConvertLeadsInvocableOrg.LeadConvertRequest request = new ConvertLeadsInvocableOrg.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, masterLabel FROM LeadStatus WHERE isConverted = true LIMIT 1 ].masterLabel;
        request.createOpportunity = true;
        request.opportunityName = 'Test Opportunity';
        request.ownerId = UserInfo.getUserId();
        request.sendEmailToOwner = true;

        List<ConvertLeadsInvocableOrg.LeadConvertResult> results = ConvertLeadsInvocableOrg.convertLeads( new List<ConvertLeadsInvocableOrg.LeadConvertRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadsInvocableOrg.LeadConvertResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId ] );
        System.assertEquals( 1, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }

    @isTest
    static void test_convert_lead_no_opportunity() {

        Organization__c org = new Organization__c(
            name = 'test'
        );

        insert org;
        
        Account acct = new Account(
            name = 'Salesforce',
            Organization__c = org.id
        );

        insert acct;

        Contact cont = new Contact(
            accountId = acct.id,
            firstName = 'Test',
            lastName = 'McTester',
            email = 'test@test.com',
            phone = '1234567890'
        );

        insert cont;

        Lead ld = new Lead(
            firstName = 'Test',
            lastName = 'McTester',
            company = 'Salesforce',
            email = 'test@test.com',
            phone = '1234567890',
            Organization__c = org.id
        );

        insert ld;

        Test.startTest();

        ConvertLeadsInvocableOrg.LeadConvertRequest request = new ConvertLeadsInvocableOrg.LeadConvertRequest();
        request.leadId = ld.id;
        request.convertedStatus = [ SELECT id, masterLabel FROM LeadStatus WHERE isConverted = true LIMIT 1 ].masterLabel;
        request.createOpportunity = false;
        //request.accountId = acct.id;
        //request.contactId = cont.id;
        request.overwriteLeadSource = true;

        List<ConvertLeadsInvocableOrg.LeadConvertResult> results = ConvertLeadsInvocableOrg.convertLeads( new List<ConvertLeadsInvocableOrg.LeadConvertRequest>{ request } );

        Test.stopTest();

        System.assert( results != null );
        System.assertEquals( 1, results.size() );

        ConvertLeadsInvocableOrg.LeadConvertResult result = results[0];

        System.assertEquals( 1, [ SELECT count() FROM Account WHERE id = :result.accountId AND id = :acct.id ] );
        System.assertEquals( 1, [ SELECT count() FROM Contact WHERE id = :result.contactId AND id = :cont.id ] );
        System.assertEquals( 0, [ SELECT count() FROM Opportunity WHERE id = :result.opportunityId ] );

    }

}