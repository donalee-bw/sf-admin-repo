/*
*********************************************************
Apex Class Name    : AccountTriggerHandler
Created Date       : 2/25/2025
@description       : This class provides methods to handle trigger events (update, insert, undelete, and delete) 
					 for Account records.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
public class AccountTriggerHandler {
    
    // Called after an Account is updated
    public void afterUpdate(List<Account> newActs, Map<Id, Account> oldActsMap) {
        //Enhanced Field History tracking for record updates
        EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Account', oldActsMap, newActs);
    }
    
    // Called after an Account is inserted
    public void afterInsert(List<Account> newActs) {
        //Enhanced Field History tracking for record creation
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Account', newActs, 'Created');
    }
    
    // Called after an Account is undeleted
    public void afterUndelete(List<Account> newActs) {
        //Enhanced Field History tracking for record undeletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Account', newActs, 'Undeleted');
    }
    
    // Called before an Account is deleted
    public void beforeDelete(Map<Id, Account> oldActsMap) {
        //Enhanced Field History tracking for record deletion
        List<Account> oldActs = oldActsMap.values();
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Account', oldActs, 'Deleted');
    }    
}