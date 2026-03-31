@isTest(SeeAllData=true)
private class EnhancedFieldHistoryPurgeTest {
    // NOTE: in order to be successful, some existing EHF records must exist as the class is pulling existing data vs creating its own.  
    // Also, may need to update the Flagged_for_purge_Process__c to be true for a subset of records.  
    
    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertEFH() {

        Test.startTest();
        // Schedule the test job
        EnhancedFieldHistoryPurgeScheduler reminder = new EnhancedFieldHistoryPurgeScheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        //String cronExp = '0 31 21 ? * *';
        //String jobID = System.schedule('Enhanced Field History Purge Scheduler TEST', cronExp, reminder);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}