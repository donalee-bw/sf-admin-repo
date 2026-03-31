@isTest
public class CombinedFunnelTriggerTest {
@IsTest
    Static void test_CombinedFunnelTrigger(){
        Account acct = new Account(
            Name = 'test'
        );

        insert acct;

        Combined_Funnel__c CF = new Combined_Funnel__c(
            Account__c = acct.id,
            Billing_Status_at_CW__c = 'Opted In',
            Onboarding_Path__c = 'Combined'
            
        );
        
        insert CF;
        
        CF.Onboarding_Path__c = 'Standard';
        update CF;
        
        delete CF;
        undelete CF;        
    }
    
}