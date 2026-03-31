global class GenericLeadSweepSheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        GenericLeadSweep b = new GenericLeadSweep();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,1);
    }
}