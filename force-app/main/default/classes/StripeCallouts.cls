//2022-02-03: SYS-129:  Adding logic for ChargeType and ACH as the CC charges have payment-details which are not populated on ACH 
//                      and caused de-referencing null object errors so the Failed Payment cases were not being created
//2022-04-26: SYS-249:  Adding more logic to reduce failures (null references) and querying school object to get account info 
//2024-04-26: Asana ticket: Adding Stripe FP Audit logic to capture any missing data coming from Stripe
global class StripeCallouts {

    @future(callout=true)
    global static void StripeCalls (String amount_due, String attempt_count, String customer_id , String charge_id, String invoice_customer_email, String invoice_id) {
       
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
        string uuid;
        string account_type;
        if (res.getStatusCode() == 200) {
                        
            // Use deserializer and Map JSON body
            Map<String, Object> hookmap2 = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> dataresults3 = (Map<String, Object>) hookmap2.get('metadata');
            //System.Debug('>>>> results keys ' + dataresults3.keySet());

            // Data from Stripe Customer API call
            account_type = String.valueOf(dataresults3.get('account_type'));
            uuid = String.valueOf(dataresults3.get('uuid'));
            String organization_id = String.valueOf(dataresults3.get('organization_id'));

            System.Debug('>>>> results_cust ' + account_type +' '+ uuid +' '+ organization_id);
        }

        // Is BW Organization
        if(account_type == 'Organization') {
            // GET charge call to Stripe
            String ChargeType;
            system.debug('>>>> charge_id: ' + charge_id);
            
            if(charge_id <> NULL && charge_id.startsWithIgnoreCase('ch_')){
               ChargeType = 'CreditCard';
            }
            else {
               ChargeType = 'ACH';
            }
            
            system.debug('>>>> ChargeType: ' + ChargeType);
            
            Http http1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setEndpoint('https://api.stripe.com/v1/charges/'+ charge_id);
            req1.setMethod('GET');
            req1.setHeader('Authorization', StripeAuth_key);
            HttpResponse res1 = http1.send(req1);
            System.debug('>>>> response ' + res1.getStatusCode());

            String failure_code;
            String failure_message;
            String reason;
            String seller_message;
            String funding;
            String brand;
            if (res1.getStatusCode() == 200) {
                
                //BW Update - Insert New Stripe FP Audit record 
                Stripe_FP_Audit__c FPA = new Stripe_FP_Audit__c();
                FPA.Stripe_Invoice_ID__c    = invoice_id;
                FPA.Stripe_Customer_Id__c   = customer_id;
                FPA.Stripe_Amount_Due__c    = Decimal.valueof(amount_due)/100;
                FPA.Stripe_Invoice_Email__c = invoice_customer_email;
            
                Insert FPA;
            
                // Use deserializer and Map JSON body
                Map<String, Object> hookmap3 = (Map<String, Object>) JSON.deserializeUntyped(res1.getBody());
                //System.Debug('>>>> results keys ' + hookmap3);

                String amount = String.valueOf(hookmap3.get('amount'));
                failure_code = String.valueOf(hookmap3.get('failure_code'));
                failure_message = String.valueOf(hookmap3.get('failure_message'));

                // Data from Stripe Charge API call
                Map<String, Object> dataresults4 = (Map<String, Object>) hookmap3.get('outcome');
                reason = String.valueOf(dataresults4.get('reason'));
                seller_message = String.valueOf(dataresults4.get('seller_message'));

                // Data from Stripe Charge API call
                if (ChargeType == 'CreditCard'){
                   Map<String, Object> dataresults5 = (Map<String, Object>) hookmap3.get('payment_method_details');
                   Map<String, Object> dataresults6 = (Map<String, Object>) dataresults5.get('card');
                   funding = String.valueOf(dataresults6.get('funding'));
                   brand = String.valueOf(dataresults6.get('brand'));
                }    

                System.Debug('>>>> results_charge '+ amount +' '+ failure_code +' '+ failure_message +' '+ reason +' '+ seller_message +' '+ funding +' '+ brand);
            }

            // Get SFDC lookup IDs
            String acct      = NULL;
            String cas       = NULL;
            String con       = NULL;
            String SchoolObj = NULL;
            try {
                cas = [SELECT Id, Stripe_invoice_ID__c FROM Case 
                            WHERE Status != 'Closed' AND Status != 'Auto Closed' 
                              AND Stripe_invoice_ID__c =:invoice_id 
                            LIMIT 1].id;
            }
            catch (Exception e) {}
            if (cas == NULL){
                system.debug('BW: did not find case, looking for acct/contact');
                try {
                    acct = [SELECT Id FROM Account WHERE bw_Organization_UUID__c =:uuid LIMIT 1].id;
                }
                catch (Exception e) {}
                try {
                    con = [SELECT Id, email FROM Contact WHERE email =:invoice_customer_email LIMIT 1].id;
                }
                catch (Exception e) {}
                if(acct == NULL && con == NULL){
                    system.debug('BW: did not find acct/contact, looking for school obj');
                    try {
                        SchoolObj = [Select Id from School_Object__c WHERE Owner_Email__c =:invoice_customer_email 
                                                                        OR Stripe_Customer_ID__c =:customer_id Limit 1].id;
                    }
                    catch (Exception e) {}
                    if (SchoolObj <> NULL){
                        system.debug('BW: found school object, pulling account');
                        try {
                            acct = [SELECT id FROM Account where School_Object__c =:SchoolObj LIMIT 1].id;
                        }
                        catch (Exception e) {}
                    }
                }
            }
            System.Debug('>>>> results_acct '+ acct);
            System.Debug('>>>> results_con '+ con);
            System.Debug('>>>> results_cas '+ cas);
            System.Debug('>>>> results_school ' + SchoolObj);

            if(cas == null) {
                // Create new SFDC Case
                Case ca = new Case();
                ca.RecordTypeId = '0121I000000ODmUQAW';
                ca.OwnerId = '00G3u000002C69nEAC';
                ca.AccountId = acct;
                ca.ContactId = con;
                ca.Origin = 'Stripe';
                ca.Subject = 'Stripe invoice payment failed';
                ca.Stripe_customer_ID__c = customer_id;
                ca.Stripe_invoice_ID__c = invoice_id;
                ca.Stripe_invoice_email__c = invoice_customer_email;
                ca.Stripe_amount_due__c = Decimal.valueof(amount_due)/100;
                ca.Stripe_attempt_count__c = Decimal.valueof(attempt_count);
                ca.Stripe_failure_code__c = failure_code;
                ca.Stripe_failure_message__c = failure_message;
                ca.Stripe_reason__c = reason;
                ca.Stripe_seller_message__c = seller_message;
                if(ChargeType == 'CreditCard'){
                   ca.Stripe_funding__c = funding;
                   ca.Stripe_brand__c = brand;    
                } else {
                   ca.Stripe_funding__c = 'ACH Account';
                   ca.Stripe_brand__c = 'ACH Account';
                }

                insert ca;
            }
            else {
                // Update existing SFDC Case
                Case ca = [SELECT Id, Stripe_invoice_ID__c FROM Case 
                            WHERE Status != 'Closed' AND Status != 'Auto Closed' 
                              AND Stripe_invoice_ID__c =:invoice_id 
                            LIMIT 1];
                ca.Stripe_attempt_count__c = Decimal.valueof(attempt_count);
                update ca;
            }
        }
    }
}