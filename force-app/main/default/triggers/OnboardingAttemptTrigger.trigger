trigger OnboardingAttemptTrigger on Onboarding_Attempt__c (after update, after insert, before delete, after undelete) {
    OnboardingAttemptTriggerHandler handler = new OnboardingAttemptTriggerHandler();
    
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            handler.afterInsert(Trigger.new);
        }
        if (Trigger.isUndelete) {
            handler.afterUndelete(Trigger.new);
        }
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            handler.beforeDelete(Trigger.oldMap);
        }
    }
}