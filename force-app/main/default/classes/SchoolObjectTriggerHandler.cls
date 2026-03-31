/*
*********************************************************
Apex Class Name    : SchoolObjectTriggerHandler
Created Date       : 2/25/2025
@description       : This class provides methods to handle trigger events (update, insert, undelete, and delete) 
					 for School_Object__c records.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
public class SchoolObjectTriggerHandler {
    
    // Called after a School Object is updated
    public void afterUpdate(List<School_Object__c> newSchools, Map<Id, School_Object__c> oldSchoolsMap) {
        //Enhanced Field History tracking for record updates
        EFH.API_EnhancedFieldHistory.api_createTrackingRecord('School_Object__c', oldSchoolsMap, newSchools);
    }
    
    // Called after a School Object is inserted
    public void afterInsert(List<School_Object__c> newSchools) {
        //Enhanced Field History tracking for record creation
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('School_Object__c', newSchools, 'Created');
    }
    
    // Called after a School Object is undeleted
    public void afterUndelete(List<School_Object__c> newSchools) {
        //Enhanced Field History tracking for record undeletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('School_Object__c', newSchools, 'Undeleted');
    }
    
    // Called before a School Object is deleted
    public void beforeDelete(Map<Id, School_Object__c> oldSchoolsMap) {
        //Enhanced Field History tracking for record deletion
        List<School_Object__c> oldSchools = oldSchoolsMap.values();
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('School_Object__c', oldSchools, 'Deleted');
    }
}