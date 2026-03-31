/*
*********************************************************
Apex Trigger Name  : CombinedFunnelTrigger
Created Date       : 2/25/2025
@description       : This trigger delegates all processing for Combined_Funnel__c records 
					 to the CombinedFunnelTriggerHandler Class
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
trigger CombinedFunnelTrigger on Combined_Funnel__c (after update, after insert, before delete, after undelete) {
    
    CombinedFunnelTriggerHandler handler = new CombinedFunnelTriggerHandler();
    
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