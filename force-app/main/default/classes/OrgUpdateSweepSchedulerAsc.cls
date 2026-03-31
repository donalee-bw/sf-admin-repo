global class OrgUpdateSweepSchedulerAsc implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        OrgUpdateSweepAsc b = new OrgUpdateSweepAsc ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1);
    }
}