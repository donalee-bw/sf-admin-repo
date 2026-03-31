@isTest
private class RecycleLeadSweepTest {

    // Dummy CRON expression: midnight on March 4.
    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertleads() {       
        // Create a lead
        List<Lead> lstLead = new List<Lead>();
        for(Integer i = 0 ; i<4 ; i++) {
            lstLead.add(new Lead(lastName = 'testLName'+i , Company = 'Salesforce' , LeadSource = 'Web'));
        }
        insert lstLead ;

        lstLead[0].LOGIC_Recycled_Last_Transfer__c = date.parse('01/01/2021');

        update lstLead;

        
	    Test.startTest();

        // Schedule the test job
        RecycleLeadSweepSheduler reminder = new RecycleLeadSweepSheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 11 11 ? * *';
        String jobID = System.schedule('Recycled Lead Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        
        Test.stopTest();
    }
}