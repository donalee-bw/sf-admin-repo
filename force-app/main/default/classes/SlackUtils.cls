global class SlackUtils {

    @future(callout=true)
    global static void PostSlackMessageCallout (String slackToken, String slackChannel, String slackText) {
        //Call out to see if this is running in a Sandbox
        Boolean isSandbox = false;
        String host = URL.getSalesforceBaseUrl().getHost();
        String server = host.substring(0,host.indexOf('.'));
        
        //all sandboxes, with mydomain, contain the '--' in the URL.  Setting boolean to TRUE
        if(server.contains('--')){
            system.debug('Running in Sandbox!');
            isSandbox = true;
        }
        
        // Set up the necessary components of the request URL
        String slackEndpoint = 'https://slack.com/api/chat.postMessage';

        // Building request URL
        if(!isSandbox){
            slackText = EncodingUtil.urlEncode(slackText, 'UTF-8');
            
            slackEndpoint = slackEndpoint +
            '?token=' + slackToken +
            '&channel=' + slackChannel +
            '&text=' + slackText;
            
            System.debug('>>>> END ' + slackEndpoint);

            Http h = new Http();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(slackEndpoint);
            req.setMethod('POST');

            HttpResponse res = new HttpResponse();
            res = h.send(req);
        } else {           
            slackText = 'Sandbox: ' + slackText;
            slackText = EncodingUtil.urlEncode(slackText, 'UTF-8');
            
            //response for BW
            slackEndpoint = slackEndpoint +
            '?token=' + slackToken +
            '&channel=' + 'U02QAQ83E6A' +
            '&text=' + slackText;
            Http h = new Http();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(slackEndpoint);
            req.setMethod('POST');

            HttpResponse res = new HttpResponse();
            res = h.send(req);
            
            //response for Jaime Hauk
            slackEndpoint = slackEndpoint +
            '?token=' + slackToken +
            '&channel=' + 'U029PPK1KUN' +
            '&text=' + slackText;
            Http h2 = new Http();
            
            HttpRequest req2 = new HttpRequest();
            req2.setEndpoint(slackEndpoint);
            req2.setMethod('POST');

            HttpResponse res2 = new HttpResponse();
            res2 = h2.send(req2);
            
            //response for Donalee Jones
            slackEndpoint = slackEndpoint +
            '?token=' + slackToken +
            '&channel=' + 'UCV9C8W77' +
            '&text=' + slackText;
            Http h3 = new Http();
            
            HttpRequest req3 = new HttpRequest();
            req3.setEndpoint(slackEndpoint);
            req3.setMethod('POST');

            HttpResponse res3 = new HttpResponse();
            res3 = h3.send(req3);

            //response for Pedro Eiras
            slackEndpoint = slackEndpoint +
            '?token=' + slackToken +
            '&channel=' + 'U04SH2XKF0B' +
            '&text=' + slackText;
            Http h5 = new Http();
            
            HttpRequest req5 = new HttpRequest();
            req5.setEndpoint(slackEndpoint);
            req5.setMethod('POST');

            HttpResponse res5 = new HttpResponse();
            res5 = h5.send(req5);         
            
        }
        
        System.debug('>>>> END ' + slackEndpoint);
        
    }
}