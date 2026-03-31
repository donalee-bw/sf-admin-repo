global class RecycleLeadSweepSheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        RecycleLeadSweep b = new RecycleLeadSweep();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,20);
    }
}