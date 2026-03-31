/*
*********************************************************
Apex Trigger Name  : AccountTrigger
Created Date       : 2/25/2025
@description       : This trigger delegates all processing for Account records to the AccountTriggerHandler Class
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   2/25/2025    Justin Strout                        Initial Implementation
*********************************************************
*/
trigger AccountTrigger on Account (after update, after insert, before delete, after undelete) {
    AccountTriggerHandler handler = new AccountTriggerHandler();
    
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