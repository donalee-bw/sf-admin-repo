global class AccountUpdateSweepScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        AccountUpdateSweep b = new AccountUpdateSweep ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,50);
    }
}