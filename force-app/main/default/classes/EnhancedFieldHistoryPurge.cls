global class EnhancedFieldHistoryPurge implements Database.Batchable<sObject>{

      // Start QueryLocator
     global Database.QueryLocator start(Database.BatchableContext BC) {

     String query = 'SELECT id, Flagged_for_Purge_Process__c ' +
                    'FROM EFH__Enhanced_Field_History__c ' +
                    'WHERE Flagged_for_Purge_Process__c = TRUE';

     return Database.getQueryLocator(query);
    }

    // Execute processing each batch of records
    global void execute(Database.BatchableContext BC, List<EFH__Enhanced_Field_History__c> activecon) {
    // system.debug('>>> listBL ' + activelead);

        delete(activecon);
    }

    // execute any post-processing operations
    global void finish(Database.BatchableContext BC) {
    }

}