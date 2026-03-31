@isTest(SeeAllData=false)
private class JungleGymAccountCreationServiceTest {
    // Capture the HTTP request body for assertions
    private static String capturedRequestBody;

    // Mock HTTP callout to intercept the request body
    private class MockHttpCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            capturedRequestBody = req.getBody();
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"mock":"response"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Helper to create RecordRef instances
    private static JungleGymAccountCreationService.RecordRef newRef(Id recId) {
        JungleGymAccountCreationService.RecordRef rr = new JungleGymAccountCreationService.RecordRef();
        rr.recordId = recId;
        return rr;
    }

    @isTest
    static void testProcessRecordsOpportunity() {
        // Set up authentication record
        JGAuth__c auth = new JGAuth__c(Key__c = 'testKey');
        insert auth;

        // Create Account
        Account acc = new Account(
            Name = 'Test Acc',
            Center_Type__c = 'After School',
            Capacity__c = 50,
            BillingStreet = '123 St',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = '12345',
            BillingCountry = 'USA'
        );
        insert acc;

        // Create Contact
        Contact con = new Contact(
            FirstName = 'First',
            LastName = 'Last',
            Email = 'test@test.com',
            Phone = '1234567890'
        );
        insert con;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Opp1',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            Contact__c = con.Id,
            Subscription__c = 'Monthly',
            Amount = 100,
            Billing_Intervals__c = 'Weekly',
            First_Bill_Date__c = Date.today().addDays(1),
            Promo_code__c = 'None',
            ACH_Fee_Structure__c = 'Variable',
            ACH_Fee_Flat__c = '$1.00',
            ACH_Fee_Variable__c = '0.5%',
            ACH_Fee_Max__c = '$1.00',
            HelloSign_Payment_Processing_Fee__c = 0.02,
            Center_Type__c = 'After School',
            Organization_Id__c = 'Org123',
            Number_of_Schools__c = 2
        );
        insert opp;

        // Set mock and invoke
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Test.startTest();
        JungleGymAccountCreationService.processRecords(
            new List<JungleGymAccountCreationService.RecordRef>{ newRef(opp.Id) }
        );
        Test.stopTest();

        // Verify payload contains key values
        System.assert(capturedRequestBody.contains(opp.Id), 'Payload should include opportunity id');
        System.assert(capturedRequestBody.contains(acc.Name), 'Payload should include account name');
    }

    @isTest
    static void testUtilsAndPayloadBuilder() {
        // Prepare data for payload builder
        Account acc = new Account(
            Name = 'Acc2',
            BillingStreet = 'Street',
            BillingCity = 'City',
            BillingState = 'State',
            BillingPostalCode = 'Zip',
            BillingCountry = 'CAN'
        );
        insert acc;
        Contact con = new Contact(
            FirstName = 'FN',
            LastName = 'LN',
            Email = 'a@b.com'
        );
        insert con;
        Opportunity opp = new Opportunity(
            Name = 'Opp2',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            Contact__c = con.Id,
            Subscription__c = 'Annual',
            Amount = 200,
            Promo_code__c = 'None',
            First_Bill_Date__c = Date.today(),
            ACH_Fee_Structure__c = 'Flat',
            ACH_Fee_Flat__c = '$3.00',
            ACH_Fee_Variable__c = '1%',
            ACH_Fee_Max__c = '$1.00',
            HelloSign_Payment_Processing_Fee__c = 0.05,
            Center_Type__c = 'Camp_2',
            Organization_Id__c = 'Org456'
        );
        insert opp;

        // Reload with related fields
        opp = [SELECT Id, Name, Subscription__c, Amount, Promo_code__c, First_Bill_Date__c,Capacity__c,Number_of_schools__c,
                     ACH_Fee_Structure__c, ACH_Fee_Flat__c, ACH_Fee_Variable__c, ACH_Fee_Max__c,
                     HelloSign_Payment_Processing_Fee__c, Owner.Email, Organization_Id__c,
                     AccountId, Account.Name, Account.BillingStreet, Account.BillingCity,
                     Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                     Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Closed_Won_School_ID__c,
                     Contact__r.Email, Contact__r.Normalized_Phone__c, Contact__r.US_Time_Zone__c,
                     Center_Type__c, Exists_In_JG__c, JG_Identification_Reason__c, SaaS_Offline_Payer__c, Exists_In_JG_Override__c
              FROM Opportunity WHERE Id = :opp.Id];

        // Build and verify payload
        Map<String,Object> payload = JungleGymPayloadBuilder.buildFrom(opp);
        Map<String,Object> acctMap = (Map<String,Object>) payload.get('Account');
        System.assertEquals(acc.Name, acctMap.get('name'));
        Map<String,Object> oppMap = (Map<String,Object>) payload.get('Opportunity');
        System.assertEquals(200, oppMap.get('amount'));
        Map<String,Object> contactMap = (Map<String,Object>) payload.get('Contact');
        System.assertEquals(con.Email, contactMap.get('email'));
    }

    @isTest
    static void testProcessRecordsChildSite() {
        // Set up authentication record
        JGAuth__c auth = new JGAuth__c(Key__c = 'testKey2');
        insert auth;

        // Parent data
        Account acc = new Account(Name='Acc3', BillingStreet='S', BillingCity='C', BillingState='St', BillingPostalCode='Z', BillingCountry='usa');
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='User', Email='u@u.com', Phone='8585552993');
        insert con;
        Opportunity opp = new Opportunity(Name='Opp3', StageName='Closed Won', CloseDate=Date.today(), AccountId=acc.Id,
                                         Subscription__c='Monthly', Amount=300);
        insert opp;

        // Child-Site record
        Child_Site_Creation__c cs = new Child_Site_Creation__c(
            Child_Site_Name__c = 'Child1',
            Original_CW_Opportunity__c = opp.Id,
            Street_Address__c = 'Addr', City__c = 'City', State_Province__c = 'State',
            Zip_Postal_Code__c = 'Zip', Country__c = 'Canada',
            Contact__c = con.Id, Capacity__c = 10, Amount__c = 300,
            First_Bill_Date__c = Date.today()
        );
        insert cs;

        // Set mock and invoke
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout());
        Test.startTest();
        JungleGymAccountCreationService.processRecords(
            new List<JungleGymAccountCreationService.RecordRef>{ newRef(cs.Id) }
        );
        Test.stopTest();
    }
}