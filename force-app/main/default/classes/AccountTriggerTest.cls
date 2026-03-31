@isTest
private class AccountTriggerTest {
@IsTest
    Static void test_AccountTrigger(){
        Account acct = new Account(
            Name = 'test'
        );

        insert acct;

        acct.customer_type__c = 'Single-Site';
        update acct;
        
        delete acct;
        undelete acct;        
    }
    
}