@IsTest
private class ConvertLeadsOrgFuture_Test {
    @IsTest
    Static void test_ConverteLeadsOrgFuture_Test(){
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
            accountId                  = acct.id,
            firstName                  = 'Test',
            lastName                   = 'McTester',
            email                      = 'test@test.com',
            phone                      = '1234567890'
        );

        insert cont;

        Lead ld = new Lead(
            firstName                  = 'Test',
            lastName                   = 'McTester',
            company                    = 'Salesforce',
            email                      = 'test@test.com',
            phone                      = '1234567890',
            LOGIC_Auto_Converted__c    = false,
            LOGIC_Bypass_Validation__c = false,
            Organization__c            = org.id
        );
        
        Lead ld2 = new Lead(
            firstName                  = 'Test',
            lastName                   = 'McTester2',
            company                    = 'Salesforce',
            email                      = 'test2@test.com',
            phone                      = '1234567890',
            LOGIC_Auto_Converted__c    = false,
            LOGIC_Bypass_Validation__c = false,
            Organization__c            = org.id
        );

        insert ld;
        insert ld2;
        List<id> leadid = new List<id>();
        
        Test.startTest();
        Database.leadConvert lc = new Database.leadConvert();
        LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                      FROM LeadStatus
                                     WHERE IsConverted=true
                                     LIMIT 1];
                
        lc.setLeadId(ld.id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.accountId = acct.id;
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        leadid.add(ld.id);
        
        ConvertLeadsOrgFuture.ConvertLeadsFutureMethod(leadid);
        Test.stopTest();
        
    }

}