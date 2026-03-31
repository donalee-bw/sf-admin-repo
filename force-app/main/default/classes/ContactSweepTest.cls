@isTest
private class ContactSweepTest {

    // Dummy CRON expression: midnight on March 4.
    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertcons() {
        // Create contacts
        List<Contact> lstcon = new List<Contact>();
        for(Integer i = 0 ; i<4 ; i++) {
            lstCon.add(new Contact(lastName = 'testLName'+i));
        }
        insert lstCon ;

        lstCon[0].LOGIC_Apex_counter__c = null;
        lstCon[0].email = 'test@test.com';
        lstCon[0].phone = '1234567890';
        lstCon[0].MailingState = 'Colorado';
        lstCon[1].LOGIC_Apex_counter__c = 3;
        lstCon[2].LOGIC_Apex_counter__c = 1;

        update lstCon;

        // Create a account
        Account a = new Account();
        a.name = 'Testing account';
        insert a;

        lstCon[0].accountid = a.id;

        update lstCon;


        Test.startTest();
        // Schedule the test job
        ContactSweepSheduler reminder = new ContactSweepSheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 31 21 ? * *';
        String jobID = System.schedule('Contact Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}