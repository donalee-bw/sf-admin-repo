global class OrgUpdateSweepSchedulerDesc implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        OrgUpdateSweepDesc b = new OrgUpdateSweepDesc ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1);
    }
}