public with sharing class LogDispositionUtilController {

    public class TaskWrapper{
        @AuraEnabled public String subject;
        @AuraEnabled public String disposition;
        @AuraEnabled public String whoId;
        @AuraEnabled public String whatId;
    }
    
    @AuraEnabled
    public static VoiceCall getVoiceCallRecord(String vendCallKey){
        try {
            List<VoiceCall> vcRec = [SELECT ID, RelatedRecordId, RelatedRecord.Name, CallType,ActivityId,CallDurationInSeconds,  FromPhoneNumber, ToPhoneNumber 
                                    FROM VoiceCall WHERE VendorCallKey =: vendCallKey LIMIT 1];
            if(!vcRec.isEmpty()){
                return vcRec[0];
            }else {
                return null;
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Boolean createTaskAndRelateVoiceCall(Map<String , Object> tskDetails , String voiceCallId){
        try{
            System.debug(tskDetails);
            System.debug(voiceCallId);

            Task tsk = new Task();
            tsk.TaskSubtype = 'Call';
               for(String abc : tskDetails.keySet()){
                   System.debug('key is ' + abc + ' and the value is ' + tskDetails.get(abc));
               }

           
            if(tskDetails.containsKey('subject') && tskDetails.get('subject') != null){
                tsk.Subject = (String) tskDetails.get('subject');
            }

            
            if(tskDetails.containsKey('disposition') && tskDetails.get('disposition') != null){
                tsk.Disposition__c = (String) tskDetails.get('disposition');
            }

            if(tskDetails.containsKey('ownerId') && tskDetails.get('ownerId') != null){
                String ownerIdStr = (String) tskDetails.get('ownerId');
                if(String.isNotBlank(ownerIdStr)){
                    tsk.OwnerId = (Id) ownerIdStr;
                }
            }

            
            if(tskDetails.containsKey('whoId') && tskDetails.get('whoId') != null){
                String whoIdStr = (String) tskDetails.get('whoId');
                if(String.isNotBlank(whoIdStr)){
                    tsk.WhoId = (Id) whoIdStr;
                }
            }

            if(tskDetails.containsKey('description') && tskDetails.get('description') != null){
                String description = (String) tskDetails.get('description');
                if(String.isNotBlank(description)){
                    tsk.Description = description;
                }
            }

            if(tskDetails.containsKey('status') && tskDetails.get('status') != null){
                String status = (String) tskDetails.get('status');
                if(String.isNotBlank(status)){
                    tsk.Status = status;
                }
            }

        if(tskDetails.containsKey('whatId') && tskDetails.get('whatId') != null){
            String whatIdStr = (String) tskDetails.get('whatId');
            if(String.isNotBlank(whatIdStr)){
                tsk.WhatId = (Id) whatIdStr;
            }
        }
            insert tsk;
            if(voiceCallId != null){
                VoiceCall vc = new VoiceCall(Id = voiceCallId, ActivityId = tsk.Id);
                update vc;
            }
            System.debug('success');
            return true;
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug('Error occured in create task and relate voice call method in log dispositon util controller');
            return false;

        }
    }


    @AuraEnabled(cacheable=true)
    public static List<String> getDispositionPicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldDesc = Task.Disposition__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldDesc.getPicklistValues()) {
            picklistValues.add(entry.getValue());
        }
        return picklistValues;
    }
}