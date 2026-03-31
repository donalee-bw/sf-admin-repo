/*
*********************************************************
Apex Class Name    : OnboardingAttemptTriggerHandler
Created Date       : 2/25/2025
@description       : This class provides methods to handle trigger events (update, insert, undelete, and delete) 
					 for Onboarding_Attempt__c records.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
public class OnboardingAttemptTriggerHandler {
    
    // Called after an Onboarding_Attempt__c is updated
    public void afterUpdate(List<Onboarding_Attempt__c> newOAs, Map<Id, Onboarding_Attempt__c> oldOAsMap) {
        //Enhanced Field History tracking for record updates
        EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Onboarding_Attempt__c', oldOAsMap, newOAs);
    }
    
    // Called after an Onboarding_Attempt__c is inserted
    public void afterInsert(List<Onboarding_Attempt__c> newOAs) {
        //Enhanced Field History tracking for record creation
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding_Attempt__c', newOAs, 'Created');
    }
    
    // Called after an Onboarding_Attempt__c is undeleted
    public void afterUndelete(List<Onboarding_Attempt__c> newOAs) {
        //Enhanced Field History tracking for record undeletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding_Attempt__c', newOAs, 'Undeleted');
    }
    
    // Called before an Onboarding_Attempt__c is deleted
    public void beforeDelete(Map<Id, Onboarding_Attempt__c> oldOAsMap) {
        //Enhanced Field History tracking for record deletion
        List<Onboarding_Attempt__c> newOAs = oldOAsMap.values();
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding_Attempt__c', newOAs, 'Deleted');
    }    
}