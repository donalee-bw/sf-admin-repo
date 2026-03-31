global class EventUpdateSweepDemoSheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        EventUpdateSweepDemo b = new EventUpdateSweepDemo();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,20);
    }
}