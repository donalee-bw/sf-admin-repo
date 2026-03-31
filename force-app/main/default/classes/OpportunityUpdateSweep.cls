global class OpportunityUpdateSweep implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'SELECT id, LOGIC_Apex_counter__c FROM Opportunity WHERE RecordTypeId IN (\'0123u000000aNBgAAM\', \'0123u000000FT4KAAW\') and Sales_Neglected__c = TRUE';


      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> SaaSOp) {
    // process each batch of records

        for(Opportunity o : SaaSOp){
            if(o.LOGIC_Apex_counter__c == null) {
               o.LOGIC_Apex_counter__c = 1;
            } else {
               o.LOGIC_Apex_counter__c = o.LOGIC_Apex_counter__c + 1;
            } 
        }
        update(SaaSOp);
    }

    global void finish(Database.BatchableContext BC) {
            // execute any post-processing operations
    }
}