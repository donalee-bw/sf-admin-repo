@isTest
global class StripeCallMockTest {

    global class SuccessfulResponseMock implements HttpCalloutMock {

        global HttpResponse respond(HttpRequest request) {

            String body =
            '{' +
                '"amount": 10001,' +
                '"failure_code": "card_declined",' +
                '"failure_message": "Your card was declined.",' +
                '"metadata":{' +
                    '"account_type":"Organization",' +
                    '"uuid":"1234-5678-9000",' +
                    '"organization_id":"abcd-efgh-ijkl"' +
                '},' +
                '"outcome": {' +
                    '"reason": "generic_decline",' +
                    '"seller_message": "The bank did not return any further details with this decline."' +
                '},' +
                '"payment_method_details": {' +
                   '"card": {' +
                        '"brand": "visa",' +
                        '"funding": "credit"' +
                    '}' +
                '}' +
            '}';

            HttpResponse res = new HttpResponse();
            res.setBody(body);
            res.setStatus('TESTER');
            res.setStatusCode(200);
            return res;
        }
    }
}