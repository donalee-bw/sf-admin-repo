global class OrgUpdateSweepScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        OrgUpdateSweep b = new OrgUpdateSweep ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,5);
    }
}