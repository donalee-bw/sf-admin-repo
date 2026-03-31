global class ContactSweepSheduler implements Schedulable{
    global void execute(SchedulableContext sc) {

        //call the batch class to be scheduled
        ContactSweep b = new ContactSweep();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,10);
    }
}