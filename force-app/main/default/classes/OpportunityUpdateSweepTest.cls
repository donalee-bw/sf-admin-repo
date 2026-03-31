@isTest
private class OpportunityUpdateSweepTest {

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    // public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void InsertAcctandOp() {
        // Create accounts
        List<account> lstAcct = new List<account>();
        for(Integer i = 0 ; i<10 ; i++) {
            lstAcct.add(new Account(Name = 'testAName'+i));
        }
        insert lstAcct ;
        
        lstAcct[1].Last_Sales_Event__c = Date.today()-2;
        lstAcct[1].Last_Sales_Task__c = Date.today()-2;
        update lstAcct[1];
        
        lstAcct[2].Last_Sales_Event__c = Date.today()-2;
        lstAcct[2].Last_Sales_Task__c = Date.today()-2;
        update lstAcct[2];
        
        
        // Create opportunity
		Opportunity o1 = new Opportunity();
        o1.RecordTypeId = '0123u000000aNBg';
        o1.Name = 'Test Opportunity 1';
        o1.StageName = 'Evaluation';
        o1.AccountId = lstAcct[1].id;
        o1.CloseDate = Date.today()-10;
        insert o1;
        
		Opportunity o2 = new Opportunity();
        o2.RecordTypeId = '0123u000000aNBg';
        o2.Name = 'Test Opportunity 2';
        o2.StageName = 'Evaluation';
        o2.AccountId = lstAcct[2].id;
        o2.CloseDate = Date.today()-10;
        o2.LOGIC_Apex_counter__c = 1;
        insert o2;
        
        
        Test.startTest();
        // Schedule the test job
        OpportunityUpdateSweepScheduler reminder = new OpportunityUpdateSweepScheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 31 21 ? * *';
        String jobID = System.schedule('Opportunity Update Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}