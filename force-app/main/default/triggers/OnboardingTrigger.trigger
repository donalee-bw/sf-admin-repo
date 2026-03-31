trigger OnboardingTrigger on Onboarding__c (after update, after insert, before delete, after undelete) {
        if(Trigger.isAfter)
        {
            if(Trigger.isUpdate)
            {
                EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Onboarding__c', trigger.oldmap, trigger.new);
            } //Tracks Record creation
            if(Trigger.isInsert)
            {
                EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding__c', trigger.new, 'Created');
            }//Tracks Record Undelete
            if(Trigger.isUndelete)
            {
                EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding__c', trigger.new, 'Undeleted');
            }
            
        }    
        
        if(Trigger.isBefore)
        {
            //Tracks Record deletion
            if(Trigger.isDelete)
            {
                EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Onboarding__c', trigger.old, 'Deleted');
            }
            
        }   
}