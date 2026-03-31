global class StripeAchCallouts {

    @future(callout=true)
    global static void StripeAchCalls (String customer_id, String fingerprint, String ba_id , String ba_status, String ba_object) {

        // Stripe API key
        String StripeAuth_key = [select key__c from StripeAuth__c].key__c;

        // GET customer call to Stripe
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.stripe.com/v1/customers/'+ customer_id);
        req.setMethod('GET');
        req.setHeader('Authorization', StripeAuth_key);
        HttpResponse res = http.send(req);
        System.debug('>>>> response ' + res.getStatusCode());

        // If the request is successful, parse the JSON response
        string account_type;
        String uuid;
        String cus_email;
        if (res.getStatusCode() == 200) {
            // Use deserializer and Map JSON body
            Map<String, Object> hookmap2 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> dataresults3 = (Map<String, Object>) hookmap2.get('metadata');
            //System.Debug('>>>> hookmap ' + hookmap2);
            //System.Debug('>>>> results keys ' + dataresults3.keySet());

            // Data from Stripe Customer API call
            account_type = String.valueOf(dataresults3.get('account_type'));
            uuid = String.valueOf(dataresults3.get('uuid'));
            cus_email = String.valueOf(hookmap2.get('email'));

            System.Debug('>>>> results_cust ' + account_type +' '+ uuid +' '+ cus_email);
        }

        // Is BW Organization
        if(account_type == 'Organization') {
            // Get SFDC lookup IDs
            String acct;
            String cas;
            String con;
            try {
                acct = [SELECT Id FROM Account WHERE bw_Organization_UUID__c =:uuid].id;
            }
            catch (Exception e) {
            }
            try {
                con = [SELECT Id, email FROM Contact WHERE email =:cus_email].id;
            }
            catch (Exception e) {
            }
            try {
                cas = [SELECT Id, Stripe_Bank_Id__c FROM Case WHERE Stripe_Bank_Id__c =:ba_id].id;
            }
            catch (Exception e) {
            }
            System.Debug('>>>> results_acct '+ acct);
            System.Debug('>>>> results_con '+ con);
            System.Debug('>>>> results_cas '+ cas);

            if(cas == null) {
                // Create new SFDC Case
                Case ca = new Case();
                ca.RecordTypeId = '0123u000000FS4nAAG';
                ca.OwnerId = '00G3u000002C69nEAC';
                ca.AccountId = acct;
                ca.ContactId = con;
                ca.Origin = 'Stripe';
                ca.Subject = 'Stripe ACH creation';
                ca.Stripe_Bank_Id__c = ba_id;
                ca.Stripe_ACH_Status__c = ba_status;
                ca.Stripe_customer_ID__c = customer_id;
                ca.Stripe_account_email__c = cus_email;
                insert ca;
            }
            else {
                // Update existing SFDC Case
                Case ca = [SELECT Id, Stripe_Bank_Id__c FROM Case WHERE Stripe_Bank_Id__c =:ba_id];
                ca.Stripe_ACH_Status__c = ba_status;
                update ca;
            }
        }    
    }
}