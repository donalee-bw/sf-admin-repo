@isTest
private class EventUpdateSweepDemoTest {

    // Dummy CRON expression
    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertobjects() {
        
        // Create user
        User u = new User();
        u.LastName = 'Williams';
        u.Email= 'standarduser@testorg.com';
        u.Username = 'standarduser_brightwheel@testorg.com';
        u.Alias = 'standt';
        //u.UserRoleId = r.id;
        u.ProfileId = '00e1I000000qsyPQAQ';
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        insert u;

        System.runAs (new User(Id = UserInfo.getUserId()) ) {

        // Create account
        Account a = new Account();
        a.Name = 'Williams Inc';
        insert a;

        // Create contact
        Contact c = new Contact();
        c.LastName = 'Williams';
        c.Accountid = c.id;
        insert c;

        // Create event
        Event e = new Event();
        e.OwnerId = u.id;
        e.subject = 'Test';
        e.WhoId = c.id;
        e.RecordTypeId = '0121I000000OF4pQAG';
        e.DurationInMinutes = 15;
        e.ActivityDateTime = system.now();
        insert e;
            
        system.debug('>>>>> Event ' + e);

        }


        Test.startTest();
        // Schedule the test job
        EventUpdateSweepDemoSheduler reminder = new EventUpdateSweepDemoSheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 31 21 ? * *';
        String jobID = System.schedule('Event Demo Update Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}