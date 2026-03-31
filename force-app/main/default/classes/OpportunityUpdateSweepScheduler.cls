global class OpportunityUpdateSweepScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        OpportunityUpdateSweep b = new OpportunityUpdateSweep ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,50);
    }
}