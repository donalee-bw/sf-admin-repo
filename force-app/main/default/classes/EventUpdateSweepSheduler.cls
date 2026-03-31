global class EventUpdateSweepSheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        EventUpdateSweep b = new EventUpdateSweep();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,20);
    }
}