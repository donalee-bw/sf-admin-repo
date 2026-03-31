/*
*********************************************************
Apex Class Name    : CombinedFunnelTriggerHandler
Created Date       : 2/25/2025
@description       : This class provides methods to handle trigger events (update, insert, undelete, and delete) 
					 for Combined_Funnel__c records.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
public class CombinedFunnelTriggerHandler {
    
    // Called after a Combined Funnel is updated
    public void afterUpdate(List<Combined_Funnel__c> newCFs, Map<Id, Combined_Funnel__c> oldCFMap) {
        //Enhanced Field History tracking for record updates
        EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Combined_Funnel__c', oldCFMap, newCFs);
    }
    
    // Called after an Combined Funnel is inserted
    public void afterInsert(List<Combined_Funnel__c> newCFs) {
        //Enhanced Field History tracking for record creation
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Combined_Funnel__c', newCFs, 'Created');
    }
    
    // Called after an Combined Funnel is undeleted
    public void afterUndelete(List<Combined_Funnel__c> newCFs) {
        //Enhanced Field History tracking for record undeletion
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Combined_Funnel__c', newCFs, 'Undeleted');
    }
    
    // Called before an Combined Funnel is deleted
    public void beforeDelete(Map<Id, Combined_Funnel__c> oldCFMap) {
        //Enhanced Field History tracking for record deletion
        List<Combined_Funnel__c> oldCFs = oldCFMap.values();
        EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Combined_Funnel__c', oldCFs, 'Deleted');
    }  
}