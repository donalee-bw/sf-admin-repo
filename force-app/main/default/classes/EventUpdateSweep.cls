global class EventUpdateSweep implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {

      String query = 'SELECT id, LOGIC_trigger_counter__c ' +
                     'FROM Event ' +
                     'WHERE (RecordTypeId = \'0121I000000OF4pQAG\' OR RecordTypeId = \'0123u000000yyQhAAI\') ' +
                     'AND LOGIC_event_past_end_time__c = TRUE and LOGIC_mins_past_end_time__c < 61';

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