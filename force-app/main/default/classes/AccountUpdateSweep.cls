global class AccountUpdateSweep implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'SELECT id, LOGIC_Apex_counter__c FROM Account WHERE Move_to_Queue__c = TRUE';

      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> activeacct) {
    // process each batch of records

        for(Account a : activeacct){
            if(a.LOGIC_Apex_counter__c == null) {
               a.LOGIC_Apex_counter__c = 1;
            } else {
               a.LOGIC_Apex_counter__c = a.LOGIC_Apex_counter__c + 1;
            }
        }
        update(activeacct);
    }

    global void finish(Database.BatchableContext BC) {
            // execute any post-processing operations
    }
}