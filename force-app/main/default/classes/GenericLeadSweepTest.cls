@isTest
private class GenericLeadSweepTest {

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

        lstLead[0].LOGIC_Apex_counter__c = null;
        lstLead[0].Phone = '1234567890';
        lstLead[0].Email = 'Test@test.com';
        lstLead[0].State = 'Colorado';
        lstLead[1].LOGIC_Apex_counter__c = 102;
        lstLead[2].LOGIC_Apex_counter__c = 1;

        update lstLead;


        Test.startTest();

        // Schedule the test job
        GenericLeadSweepSheduler reminder = new GenericLeadSweepSheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 11 11 ? * *';
        String jobID = System.schedule('Generic Lead Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        
        Test.stopTest();
    }
}