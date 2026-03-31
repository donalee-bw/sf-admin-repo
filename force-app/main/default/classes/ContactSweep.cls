global class ContactSweep implements Database.Batchable<sObject> {

     // Start QueryLocator
     global Database.QueryLocator start(Database.BatchableContext BC) {

     String query = 'SELECT id, LOGIC_Apex_counter__c ' +
                    'FROM Contact ' +
                    'WHERE Organization__c = null';

     return Database.getQueryLocator(query);
    }

    // Execute processing each batch of records
    global void execute(Database.BatchableContext BC, List<Contact> activecon) {
    // system.debug('>>> listBL ' + activelead);

        for(Contact c : activecon){
            if(c.LOGIC_Apex_counter__c == null) {
               c.LOGIC_Apex_counter__c = 1;
               } else {
               c.LOGIC_Apex_counter__c = c.LOGIC_Apex_counter__c + 1;
               }
        }
        update(activecon);
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext BC) {
    }
}