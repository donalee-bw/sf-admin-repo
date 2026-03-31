/*
*********************************************************
Apex Class Name    : JungleGymCalloutQueueable
Created Date       : 5/5/2025
@description       : This queueable class sends Opportunity and Child Site data to the JungleGym platform. 
                     It runs in the background and handles the callout to an external system, using 
                     authorization and a JSON-formatted payload. The class supports both single-site and 
                     multi-site Opportunities, and includes error handling and debug logging to monitor 
                     the process and troubleshoot issues if needed.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   5/5/2025     Justin Strout                        Initial Implementation, Single Sites only
1.1   6/1/2025     Justin Strout                        Expanded functionality to process multi-site Opportunities
*********************************************************
*/

public class JungleGymCalloutQueueable implements Queueable, Database.AllowsCallouts {
    private List<JungleGymAccountCreationService.IJungleGymWrapper> wrappers;
    private String authKey;
    
    public JungleGymCalloutQueueable(List<JungleGymAccountCreationService.IJungleGymWrapper> wrappers, String authKey) {
        this.wrappers = wrappers;
        this.authKey  = authKey;
    }
    
    public void execute(QueueableContext ctx) {
        List<Map<String,Object>> records = new List<Map<String,Object>>();
        for (JungleGymAccountCreationService.IJungleGymWrapper wrap : wrappers) {
            records.add(wrap.toPayload());
        }
        String body = (records.size() == 1)
            ? JSON.serialize(records[0])
            : JSON.serialize(records);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://schools.sandbox.bwtest.net/integrations/salesforce/signup');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authKey);
        req.setBody(body);
        
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            
            System.debug(LoggingLevel.INFO, 'Callout succeeded');
            System.debug(LoggingLevel.INFO, '  Request Body : ' + req.getBody());  
            System.debug(LoggingLevel.INFO, '  Status Code : ' + res.getStatusCode());
            System.debug(LoggingLevel.INFO, '  Status      : ' + res.getStatus());
            System.debug(LoggingLevel.INFO, '  Response    : ' + res.getBody());
            
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Callout failed');
            System.debug(LoggingLevel.ERROR, '  Request Body   : ' + req.getBody());
            System.debug(LoggingLevel.ERROR, '  Error message  : ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '  Stack trace    : ' + e.getStackTraceString());
            System.debug(LoggingLevel.ERROR, '  Request endpoint: ' + req.getEndpoint());
            System.debug(LoggingLevel.ERROR, '  Request body    : ' + req.getBody());
        }
    } 
}