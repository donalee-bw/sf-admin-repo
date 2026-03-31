global class EventUpdateSweepDemo implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'SELECT Id, LOGIC_trigger_counter__c ' +
                     'FROM Event ' +
                     'where RecordTypeId <> \'0121I000000OF4kQAG\' and WhatId = null and who.type = \'Contact\' and sales_meeting__c = True and LOGIC_Mins_Past_Create_Time__c < 61';
                
      //system.debug('>>> query ' + query);
      return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Event> batchevent) {
    system.debug('>>> listBE ' + batchevent);

        // process each batch of records
        for(Event e : batchevent){
            if(e.LOGIC_trigger_counter__c == null) {
               e.LOGIC_trigger_counter__c = 1;
            } else {
               e.LOGIC_trigger_counter__c = e.LOGIC_trigger_counter__c + 1;
            }
        }
        update(batchevent);
    }

    global void finish(Database.BatchableContext BC) {
    // execute any post-processing operations
    }
}