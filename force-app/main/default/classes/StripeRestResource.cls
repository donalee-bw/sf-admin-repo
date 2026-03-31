/* - Site SandBox webhooks: https://dylanbox-mybrightwheel.cs90.force.com/Stripe/
   - Site Production: https://mybrightwheel.secure.force.com/Stripe/
   - Relative endpoint: /services/apexrest/

   Sand - https://dylanbox-mybrightwheel.cs90.force.com/Stripe/services/apexrest/invoice
   Prod - https://mybrightwheel.secure.force.com/Stripe/services/apexrest/invoice
*/

@RestResource(urlMapping = '/invoice/*')
global class StripeRestResource {

    @HttpPost
    global static String doPost() {
        // Retrieve the Stripe signature from header
        String stripe_signature = RestContext.request.headers.get('Stripe-Signature');
        //System.Debug('>>>> stripe_signature ' + stripe_signature);

        // Retrieve the JSON body
        String jsonbody = RestContext.request.requestBody.toString();
        System.debug('>>>> jbody' + jsonbody);

        RestResponse res = RestContext.response;

        // Map values from Stripe signature header
        Map<String, String> stripe_map = new Map<String, String>();
        List<String> stripe_split = stripe_signature.split(',');
        //System.debug('>>>> split' + stripe_split);

        for (String s : stripe_split) {
            List<String> temp = s.split('=');
            stripe_map.put(temp[0], temp[1]);
        }
        //System.debug('>>>> map ' + stripe_map);
        //System.debug('>>>> map ' + stripe_map.values());

        // Values from Map for signed payload
        String t_value = stripe_map.get('t');
        String v1_value = stripe_map.get('v1');
        //System.debug('>>>> values ' + t_value +' '+ v1_value);

        // Verify the signature using 'hmacSHA256'. Webhook key stored in a SFDC Custom Setting
        String StripeWebHook = [select key__c from StripeWebHook__c].key__c;
        Blob signedPayload = Crypto.generateMac('hmacSHA256', Blob.valueOf(t_value+'.'+jsonbody), Blob.valueOf(StripeWebHook));
        //System.debug('>>>> signedpayload ' + t_value +'.'+ jsonbody);

        // Encode Payload using Hex to convert back to a string
        String encodedPayloadhex = EncodingUtil.convertToHex(signedPayload);
        //System.Debug('>>>> encodedPayloadhex ' + encodedPayloadhex);

        // Return status code based on whether signed payload matches or not
        Boolean statusCode = encodedPayloadhex == v1_value;
        System.Debug('>>>> statusCode ' + statusCode);

        /* // Time stamp diff work for additional security (not in use)
        // Now() in Epoch long
        Datetime dt = Datetime.now();
        Long l = dt.getTime();

        // Convert t_value to Epoch long
        Long long_t_value = Integer.valueOf(t_value);
        Long long_t_value_full = long_t_value * 1000;

        // Difference in timestamps
        Long time_diff = (l - long_t_value_full);
        System.debug('>>>> time_diff ' + time_diff);
        */

        if(statusCode) {
            // Use deserializer and Map JSON body
            Map<String, Object> hookmap = (Map<String, Object>)JSON.deserializeUntyped(jsonbody);
            //System.Debug('>>>> hookmap ' + hookmap);
            //System.Debug('>>>> hookmap keys ' + hookmap.keySet());

            // Stripe failed payment
            if(String.valueOf(hookmap.get('type')) == 'invoice.payment_failed') {

                // Make maps to drill into data sets of stripe webhook JSON body
                Map<String, Object> dataresults = (Map<String, Object>) hookmap.get('data');
                Map<String, Object> dataresults2 = (Map<String, Object>) dataresults.get('object');

                // Data from Stripe web hook
                String invoice_id = String.valueOf(dataresults2.get('id'));
                String amount_due = String.valueOf(dataresults2.get('amount_due'));
                String attempt_count = String.valueOf(dataresults2.get('attempt_count'));
                String charge_id = String.valueOf(dataresults2.get('charge'));
                String customer_id = String.valueOf(dataresults2.get('customer'));
                String invoice_customer_email  = String.valueOf(dataresults2.get('customer_email'));

                System.Debug('>>>> results_invoice '+ invoice_id +' '+ customer_id +' '+ charge_id +' '+ invoice_customer_email +' '+ amount_due +' '+ attempt_count);

                //StripeCallouts.StripeCalls(amount_due, attempt_count, customer_id, charge_id, invoice_customer_email, invoice_id);

                System.Debug('>>>> Signature verified');
                res.statusCode = 200;
                res.responseBody = Blob.valueOf('Accepted: Signature verified');
                System.debug('>>>> Response...' + res);
                return '200 Accepted: Signature verified';
            }

            // Stripe ACH creation and verification 
            if(String.valueOf(hookmap.get('type')) == 'customer.source.created' || String.valueOf(hookmap.get('type')) == 'customer.source.updated') {
                // Make maps to drill into data sets of stripe webhook JSON body
                Map<String, Object> dataresults = (Map<String, Object>) hookmap.get('data');
                Map<String, Object> dataresults2 = (Map<String, Object>) dataresults.get('object');

                // Data from Stripe web hook
                String customer_id = String.valueOf(dataresults2.get('customer'));
                String fingerprint = String.valueOf(dataresults2.get('fingerprint'));
                String ba_id = String.valueOf(dataresults2.get('id'));
                String ba_status = String.valueOf(dataresults2.get('status'));
                String ba_object = String.valueOf(dataresults2.get('object'));

                System.Debug('>>>> results_bank '+ customer_id +' '+ fingerprint +' '+ ba_id +' '+ ba_status+' '+ ba_object);

                // Stripe source is bank account
                if(ba_object == 'bank_account') {
                    StripeAchCallouts.StripeAchCalls(customer_id, fingerprint, ba_id, ba_status, ba_object);

                    System.Debug('>>>> Signature verified');
                    res.statusCode = 200;
                    res.responseBody = Blob.valueOf('Accepted: Signature verified');
                    System.debug('>>>> Response...' + res);
                    return '200 Accepted: Signature verified';
                }    
            }
        }    

        System.Debug('>>>> Verifying signature fail');
        res.statusCode = 401;
        res.responseBody = Blob.valueOf('Unauthorized: Verifying signature fail');
        System.debug('>>>> Response...' + res);
        return '401 Unauthorized: Verifying signature fail';
    }
}