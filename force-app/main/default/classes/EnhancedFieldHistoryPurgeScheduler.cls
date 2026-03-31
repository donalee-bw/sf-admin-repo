global class EnhancedFieldHistoryPurgeScheduler implements Schedulable{
 global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        EnhancedFieldHistoryPurge p = new EnhancedFieldHistoryPurge();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(p,200);
    }
}