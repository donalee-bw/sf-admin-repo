@isTest
private class RecordMergeTest {
  @isTest
    static void test_RecordMerge_Lead(){
                        
        // Create User
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
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
        insert u;
        
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
          QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Lead');
          insert testQueue;
        }
        
        Lead newLead = new Lead(
          firstName = 'Test',
          lastName  = 'McTester',
          company   = 'Salesforce',
          email     = 'test@gmail.com',
          ownerid   = u.id
        );
        
        Lead dupLead = new Lead(
          firstName = 'Test',
          lastName  = 'McTester2',
          company   = 'Salesforce',
          email     = 'test@gmail.com1',
          ownerid   = u.id
        );
        
        Lead dupLead2 = new Lead(
          firstName = 'Test',
          lastName  = 'McTester3',
          company   = 'Salesforce',
          email     = 'test@gmail.com',
          ownerid   = testGroup.id
        );
        
        insert newLead;
        insert dupLead;
        insert dupLead2;
        
        LeadMergeInvocable.LeadMergeResults request = new LeadMergeInvocable.LeadMergeResults();
        request.LeadMergeID = dupLead.id;
        
        List<LeadMergeInvocable.LeadMergeResults> results = 
            LeadMergeInvocable.mergeLeads(new List<LeadMergeInvocable.LeadMergeResults> {request});
    }
    
    @isTest
    static void test_RecordMerge_Contact(){
    
        Account acct = new Account(
            name = 'Salesforce'
        );

        insert acct;  
        
        Account acct2 = new Account(
            name = 'SFDC Dupe'
        );

        insert acct2;  
              
        Contact newContact = new Contact(
          Accountid = acct.id,
          firstName = 'Test',
          lastName  = 'McTester',
          email     = 'test@gmail.com'
        );
        
        Contact dupContact = new Contact(
          Accountid = acct.id,
          firstName = 'Test',
          lastName  = 'McTester2',
          email     = 'test@gmail.com1'
        );
        
        Contact dupContact2 = new Contact(
          Accountid = acct.id,
          firstName = 'Test',
          lastName  = 'McTester3',
          email     = 'test@gmail.com'
        );
        
        insert dupContact;
        insert dupContact2;
        insert newContact;
                
        AccountContactRelation newACR = new AccountContactRelation(
          AccountId = acct2.id,
          ContactId = newContact.id
        );
        
        AccountContactRelation dupeACR = new AccountContactRelation(
          AccountId = acct2.id,
          ContactId = dupContact2.id
        );
        
        insert newACR;
        insert dupeACR;
        
        ContactMergeInvocable.ContactMergeResults request = new ContactMergeInvocable.ContactMergeResults();
        request.ContactMergeID = dupContact.id;
        
        List<ContactMergeInvocable.ContactMergeResults> results = 
            ContactMergeInvocable.mergeContacts(new List<ContactMergeInvocable.ContactMergeResults> {request});
        
    }}