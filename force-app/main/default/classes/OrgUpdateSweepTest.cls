@isTest
private class OrgUpdateSweepTest {

    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertorg() {

        // Create Org
        Organization__c org = new Organization__c(
        name = 'test',
        Apex_last_updated_at__c = Datetime.now().addDays(-1)
        );
        insert org;

        Test.startTest();

        // Schedule the test job
        OrgUpdateSweepSchedulerAsc reminder = new OrgUpdateSweepSchedulerAsc();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 11 11 ? * *';
        String jobID = System.schedule('Organization Update Sweep Asc', cronExp, reminder);
        // Stopping the test will run the job synchronously

        // Schedule the test job
        OrgUpdateSweepSchedulerDesc reminder1 = new OrgUpdateSweepSchedulerDesc();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp1 = '0 21 21 ? * *';
        String jobID1 = System.schedule('Organization Update Sweep Desc', cronExp1, reminder1);
        // Stopping the test will run the job synchronously

        Test.stopTest();
    }
}