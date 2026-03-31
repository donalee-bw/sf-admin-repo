global class GenericLeadSweep implements Database.Batchable<sObject> {
    
     // Start QueryLocator
     global Database.QueryLocator start(Database.BatchableContext BC) {

     String query = 'SELECT id, LOGIC_Apex_counter__c ' +
                    'FROM Lead ' +
                    'WHERE LOGIC_Apex_counter__c = 102';

     return Database.getQueryLocator(query);
    }

    // Execute processing each batch of records
    global void execute(Database.BatchableContext BC, List<Lead> activelead) {
    // system.debug('>>> listBL ' + activelead);

        for(Lead l : activelead){
            if(l.LOGIC_Apex_counter__c == null) {
               l.LOGIC_Apex_counter__c = 1;
               } else {
               l.LOGIC_Apex_counter__c = l.LOGIC_Apex_counter__c + 1;
               }
        }
        update(activelead);
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext BC) {
    }
}