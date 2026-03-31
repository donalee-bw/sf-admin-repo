/*
*********************************************************
Apex Class Name    : ContactTriggerHandler
Created Date       : 2/25/2025
@description       : This class provides methods to handle trigger events (update, insert, undelete, and delete) 
					 for Contact records.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
public class ContactTriggerHandler {
    
    // Called after an Contact is updated
    public void afterUpdate(List<Contact> newCons, Map<Id, Contact> oldConMap) {
        //Enhanced Field History tracking for record updates
        EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Contact', oldConMap, newCons);
    }
    
    // Called after an Contact is inserted
    public void afterInsert(List<Contact> newCons) {
        //Enhanced Field History tracking for record creation
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Contact', newCons, 'Created');
    }
    
    // Called after an Contact is undeleted
    public void afterUndelete(List<Contact> newCons) {
        //Enhanced Field History tracking for record undeletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Contact', newCons, 'Undeleted');
    }
    
    // Called before an Contact is deleted
    public void beforeDelete(Map<Id, Contact> oldConMap) {
        List<Contact> oldCons = oldConMap.values();
        //Enhanced Field History tracking for record deletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Contact', oldCons, 'Deleted');
    }  
}