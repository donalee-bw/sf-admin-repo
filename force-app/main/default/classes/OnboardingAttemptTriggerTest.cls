@isTest
public class OnboardingAttemptTriggerTest {
@IsTest
    Static void test_CombinedFunnelTrigger(){
        Account acct = new Account(
            Name = 'test'
        );

        insert acct;

        Onboarding_Attempt__c OA = new Onboarding_Attempt__c(
            Account__c = acct.id
            
        );
        
        insert OA;
        
        OA.Brightwheel_School_UUID_Stamp__c  = '********';
        update OA;
        
        delete OA;
        undelete OA;        
    }
    
}