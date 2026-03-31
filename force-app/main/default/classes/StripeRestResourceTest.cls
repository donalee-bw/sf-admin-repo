@isTest
private class StripeRestResourceTest {

    static testMethod void StripeWebhookTestCreated() {

        // Test School object
        School_object__c s = new School_object__c();
        s.Name = 'Test School';
        s.Brightwheel_School_UUID__c = '1234-5678-9000';
        s.Owner_Email__c = 'test@test.com';
        s.Owner_Last_Name__c = 'Test';
        s.Owner_Last_Name__c = 'McTtester';
        insert s;

        // Test Account object
        Account a = new Account();
        a.name = 'test account';
        a.School_object__c = s.Id;
        insert a;

        // Test Contact object
        Contact c = new Contact();
        c.LastName = 'McTtester';
        c.FirstName = 'Test';
        c.AccountId = a.id;
        c.Email = 'contact.testing@test.com';
        insert c;

        // Create test custom setings key record for HMACSHA265
        insert new StripeWebHook__c(key__c = 'whsec_AKGWvmCUZJUr7bDLJmq6FN3pQh3aoPGW');

        // Create test custom setings key record for HMACSHA265
        insert new StripeAuth__c(key__c = 'Bearer sk_test_ubkgSIETFW8l2NDfw4ILAZkP');

        //Test JSON webhook payloads
        String JsonMsgFP = '{"data": {"object": {"id": "in_1GTeDSGN6k7tv4xPzehl2Aul","amount_due": 10001,"attempt_count": 2,"charge": "ch_1GTeLIGN6k7tv4xPmpZVApn3",' +
                            '"customer": "cus_H1h8BojsFSTB6u","customer_email": "contact.testing@test.com"}},"type": "invoice.payment_failed"}';

        System.Debug('>>>> JMFP ' + JsonMsgFP);

        String JsonMsgACH = '{"data": {"object": {"id": "ba_1Jh3tqGN6k7tv4xPWJAeYKQc","object": "bank_account","customer": "cus_H1h8BojsFSTB6u","fingerprint": "NXxng6kXyEIBdOe2",' +
                            '"status": "new"}},"type": "customer.source.created"}';

        System.Debug('>>>> JMACH ' + JsonMsgACH);


        // Test calls
        Test.startTest();

        // Webhook Call 1
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri ='/services/apexrest/invoice';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(JsonMsgFP);
        RestContext.request = request;
        RestContext.response = response;

        // Webhook Header - Stripe-Signature - https://www.freeformatter.com/hmac-generator.html#ad-output t+v1
        Map<String, String> headers = RestContext.request.headers;
        headers.put('Stripe-Signature', 't=1585878606,v1=91e9488c7cb28790e020e78b06c8ef981d73ade6b823e8fbaaf8bbbad8bbeb0b,v0=dbd1aa978c7f17537a04bdb99cde7adfa30bbbb1b4cac041acf71dd0e75ed4a1');

        // Callout Mock response
        Test.setMock(HttpCalloutMock.class, new StripeCallMockTest.SuccessfulResponseMock());

        StripeRestResource.doPost();

        // Webhook Call 2
        RestRequest request2 = new RestRequest();
        RestResponse response2 = new RestResponse();

        request2.requestUri ='/services/apexrest/invoice';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueof(JsonMsgACH);
        RestContext.request = request2;
        RestContext.response = response2;

        // Webhook Header - Stripe-Signature - https://www.freeformatter.com/hmac-generator.html#ad-output t+v1
        Map<String, String> headers2 = RestContext.request.headers;
        headers2.put('Stripe-Signature', 't=1585878606,v1=51248cd1668f692abd9c878e635a3e699c9382f5d219d72149d0a553c97d36c1,v0=dbd1aa978c7f17537a04bdb99cde7adfa30bbbb1b4cac041acf71dd0e75ed4a1');

        // Callout Mock response
        //Test.setMock(HttpCalloutMock.class, new StripeCallMockTest.SuccessfulResponseMock());

        StripeRestResource.doPost();

        Test.stopTest();
    }
}