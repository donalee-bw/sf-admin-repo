global class OrgUpdateSweepDesc implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'SELECT id, LOGIC_Apex_counter__c ' +
                     'FROM Organization__c ORDER BY Apex_last_updated_at__c DESC LIMIT 5000';

      //system.debug('>>> query ' + query);
      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Organization__c> batchevent) {
    system.debug('>>> listBE ' + batchevent);

        // process each batch of records
        for(Organization__c o : batchevent){
            if(o.LOGIC_Apex_counter__c == null) {
               o.LOGIC_Apex_counter__c = 1;
            } else {
               o.LOGIC_Apex_counter__c = o.LOGIC_Apex_counter__c + 1;
            }
        }
        update(batchevent);
    }

    global void finish(Database.BatchableContext BC) {
    // execute any post-processing operations
    }
}