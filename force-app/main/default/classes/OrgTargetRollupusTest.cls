@isTest
private class OrgTargetRollupusTest {

    static testmethod void insertobjects() {
        
     /*
        // Create Orgs
        Organization__c org = new Organization__c(
        name = 'test'
        );
        insert org;

        Organization__c org1 = new Organization__c(
        name = 'test1'
        );
        insert org1;
        
        // Create Lead
        Lead ld = new Lead(
            firstName = 'Test',
            lastName = 'McTester',
            company = 'Salesforce',
            email = 'test@test.com',
            phone = '1234567899',
            State = 'CO',
            Organization__c = org.id
        );
        insert ld;

        // Create Acct
        Account acct = new Account(
            name = 'Salesforce',
            type = 'Prospect'
        );
        insert acct;

        // Create Opportunity
        Opportunity op = new Opportunity(
            name = 'Salesforce oOP',
            StageName = 'Evaluation',
            CloseDate = System.today().addMonths(1),
            AccountId = acct.Id,
            RecordTypeId = '0123u000000aNBgAAM'
        );
        insert op;


        // Create User
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
        Alias = 'standt',
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName
        );
        
        // Creating a Queue
        Group g = new Group(Type='Queue', Name='Queue name');
        insert g;
            

        // The following code runs as user 'u'
        System.runAs(u) {
            //System.debug('>>>> Current User: ' + UserInfo.getUserName());
            //System.debug('>>>> Current Profile: ' + UserInfo.getProfileId());
            //System.debug('>>>> Current ID: ' + UserInfo.getUserId());
        
        // Finish creating Queue       
        QueuesObject q = new QueueSObject(QueueID = g.id, SobjectType = 'Lead');
        insert q;
        
        // ------------------  Updates on objects for Scenarios + Org update trigger (code coverage) ------------------------------------
        // Target unknown and owned
        ld.ownerId = u.id;
        update ld;
        
        org.LOGIC_Apex_counter__c = 1;
        update org;
        
        // Target unknown and queue
        ld.ownerId = g.id;
        update ld;
        
        org.LOGIC_Apex_counter__c = 2;
        update org;

        // Target target and queue
        ld.FTS_program_type__c = 'preschool_or_child_care';
        ld.FTS_number_of_students__c = 21;
        update ld;
        
        org.LOGIC_Apex_counter__c = 3;
        update org;

        // Target target and owned
        ld.ownerId = u.id;
        update ld;
        
        org.LOGIC_Apex_counter__c = 4;
        update org;

        // Non Target target and queue
        ld.FTS_program_type__c = 'preschool_or_child_care';
        ld.FTS_number_of_students__c = 19;
        ld.ownerId = g.id;
        update ld;
        
        org.LOGIC_Apex_counter__c = 5;
        update org;

        // Non Target target and owned
        ld.ownerId = u.id;
        update ld;
        
        org.LOGIC_Apex_counter__c = 6;
        update org;

        // Acct as Prospect with Op
        acct.Organization__c = org.id;
        update acct;
        
        org.LOGIC_Apex_counter__c = 7;
        update org;

        // Acct as Prospect without Op
        op.StageName = 'Closed Lost';
        update op;
        
        org.LOGIC_Apex_counter__c = 8;
        update org;

        // Acct as Customer
        acct.type = 'Customer';
        update acct;
        
        org.LOGIC_Apex_counter__c = 9;
        update org;

        // Acct as Inactive Prospect
        acct.type = 'Prospect';
        update acct;
        
        org.LOGIC_Apex_counter__c = 10;
        update org;

        org1.LOGIC_Apex_counter__c = 10;
        update org1;
        }
        */
    }
}