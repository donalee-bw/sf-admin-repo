@isTest
public class OnboardingTriggerTest {

@IsTest
    Static void test_AccountTrigger(){
        Account acct = new Account(
            Name = 'test'
        );

        insert acct;

        Onboarding__c OB = new Onboarding__c(
            Account__c = acct.id,
            Multi_Site__c = FALSE
        );
        
        insert OB;
        
        OB.Multi_Site__c = TRUE;
        update OB;
        
        delete OB;
        undelete OB;        
    }
}