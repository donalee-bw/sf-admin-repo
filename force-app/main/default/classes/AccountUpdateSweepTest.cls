@isTest
private class AccountUpdateSweepTest {

    // Because this is a test, job executes
    // immediately after Test.stopTest().

    static testmethod void insertaccount() {

        // Create User
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
        Alias = 'standt',
        Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8',
        LastName='Testing',
        LanguageLocaleKey='en_US',
        LocaleSidKey='en_US',
        ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName
        );

        // The following code runs as user 'u'
        System.runAs(u) {
              System.debug('>>>> Current User: ' + UserInfo.getUserName());
              System.debug('>>>> Current Profile: ' + UserInfo.getProfileId());
              System.debug('>>>> Current ID: ' + UserInfo.getUserId());

        // Create accounts
        List<account> lstAcct = new List<account>();
            for(Integer i = 0 ; i<10 ; i++) {
                lstAcct.add(new Account(Name = 'testAName'+i));
            }
        insert lstAcct ;

        // Update accounts
        lstAcct[0].LOGIC_Apex_counter__c = 2;
        lstAcct[0].type = 'Prospect';
        lstAcct[0].ownerid = u.Id;
        update lstAcct;

        lstAcct[0].Last_Transfer_Date__c  = Date.valueOf('2020-12-26');
        update lstAcct;

        lstAcct[1].type = 'Prospect';
        lstAcct[1].ownerid = u.Id;
        update lstAcct;

        lstAcct[1].Last_Transfer_Date__c  = Date.valueOf('2020-12-26');
        update lstAcct;

        // Debug
        List<Account> query = [SELECT id, name, Type, ADMIN_Open_SaaS_Opps_Count__c, OwnerId, Last_Sales_Event__c, Last_Sales_Task__c, Last_Transfer_Date__c FROM Account WHERE name = 'testAName0'];
        system.debug('>>>> ' + query);
        }


        Test.startTest();
        // Schedule the test job
        AccountUpdateSweepScheduler reminder = new AccountUpdateSweepScheduler();
        // Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
        String cronExp = '0 31 21 ? * *';
        String jobID = System.schedule('Account Update Sweep', cronExp, reminder);
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}