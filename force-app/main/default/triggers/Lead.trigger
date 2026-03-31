//Lead Trigger - created 01-27-2022
//Objective:  Consolidate triggers on Lead object and introduce recursive checks to ensure efficiency of processing
//01-10-2025: Added logic for the Enhanced Field History package to be triggered

trigger Lead on Lead (before insert, before update, before delete, after delete, after insert, after undelete, after update) {
    
  if (Trigger.isBefore && checkRecursive.LeadTrigger_before_firstcall == false){
     
      if(Trigger.isInsert || Trigger.isUpdate){
           checkRecursive.LeadTrigger_before_firstcall = true;
          
            List<Generic_Email_Domain__c> ListOfGenericDomains = [Select Email_Domain__c from Generic_Email_Domain__c];          
            List<String> ListOfGenericDomainsString = new List<String>();
            for(Generic_Email_Domain__c ED : ListOfGenericDomains){
              ListOfGenericDomainsString.add(ED.Email_Domain__c);
            }
          
            for(Lead objLead : Trigger.New){
            //original code from GenericEmailDomain
            if(ListOfGenericDomainsString.contains(objLead.Email_Domain__c)){
                objLead.Generic_domain__c = True;
            } else {
                objLead.Generic_domain__c = False;
            }
            if(ListOfGenericDomainsString.contains(objLead.LOGIC_Organization_Email_domain__c)){
                objLead.LOGIC_Organization_Generic_domain__c = True;
            } else {
                objLead.LOGIC_Organization_Generic_domain__c = False;
            }    
          
            //original code from AreaCodeLookup trigger
            /*
            String strPhoneVal;
            String old_phone;
            Map<String, String> mapAreaCodeToState = new Map<String, String>();
              
            Try{
                    Lead old_lead = Trigger.oldMap.get(objLead.Id);
                    old_phone = old_lead.phone;
                    system.debug('>>>> ' + old_phone);
            } catch (Exception e){
                system.debug('>>>> error on the oldMap phone pull');
            }
                
            if(String.isBlank(objLead.State) && String.isNotBlank(objLead.Phone) && old_phone != objLead.Phone && String.isNotBlank(objLead.school_object__c)){
                // Clean up phone number
                strPhoneVal = objLead.Phone; strPhoneVal = strPhoneVal.replace('(', '');strPhoneVal = strPhoneVal.replace(')', '');
                strPhoneVal = strPhoneVal.replace('+', '');
                strPhoneVal = strPhoneVal.replace('-', '');
                strPhoneVal = strPhoneVal.replace(' ', '');
                system.debug('>>>> strip ' + strPhoneVal);

                if(strPhoneVal.startsWith('1')){
                    strPhoneVal = strPhoneVal.substring(1,strPhoneVal.length());
                    if(strPhoneVal.length() == 10){
                        strPhoneVal = strPhoneVal.left(3);
                        mapAreaCodeToState.put(strPhoneVal, '');
                    }
                }
                if(!strPhoneVal.startsWith('1') && strPhoneVal.length() == 10){
                     strPhoneVal = strPhoneVal.left(3);
                     mapAreaCodeToState.put(strPhoneVal, '');
                }
            }

            system.debug('>>>> map ' + mapAreaCodeToState);

            // Query only matching records
            if(!mapAreaCodeToState.isEmpty()){
                for(Area_code__c  objAC : [SELECT Id, Name, State_abbreviation__c 
                                             FROM Area_code__c  
                                            WHERE Name IN: mapAreaCodeToState.keySet()]){
                    mapAreaCodeToState.put(objAC.Name, objAC.State_abbreviation__c);
                }
            }

           system.debug('>>>> map pair ' + mapAreaCodeToState);

           // Update value that was mapped
           if(mapAreaCodeToState.containsKey(strPhoneVal)){
               objLead.State = mapAreaCodeToState.get(strPhoneVal);
               system.debug('>>>> map value ' + objLead.State);
           }*/
         
         }
       }  
      //01-10-2025: New code for the EnhancedFieldHistory for the After conditions 
      if(Trigger.isDelete)
            {
                EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Lead', trigger.old, 'Deleted');
            }
  } else if (Trigger.isAfter && checkRecursive.LeadTrigger_after_firstcall == false){
      
    //01-10-2025: New code for the EnhancedFieldHistory for the After conditions
    if(Trigger.isAfter)
      {
          if(Trigger.isUpdate)
          {
              EFH.API_EnhancedFieldHistory.api_createTrackingRecord('Lead', trigger.oldmap, trigger.new);
          } //Tracks Record creation
          if(Trigger.isInsert)
          {
              EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Lead', trigger.new, 'Created');
          }//Tracks Record Undelete
          if(Trigger.isUndelete)
          {
              EFH.API_EnhancedFieldHistory.api_createTrackingActionRecord('Lead', trigger.new, 'Undeleted');
          }        
      }      
    if (trigger.isAfter && trigger.isUpdate){
        checkRecursive.LeadTrigger_after_firstcall = true;
    //Code related to SYS-129 on streamlining Lead Conversions tied to same Organization__C
       for( Lead l : Trigger.new){
         List<id> leadId = new List<ID>();
         
         //Logic to ensure we are only calling for recently converted leads that are not contained in future class processing.  
         if(l.IsConverted == true && 
            l.LOGIC_Auto_Converted__c == false && 
            l.LOGIC_Bypass_Validation__c == false && 
            l.Organization__c != NULL ) {
                leadId.add(l.id);
            }  
           
           if(leadId.size()>0 && leadId != NULL 
             && System.IsBatch() == false && System.isFuture() == false){
             System.debug('--> Calling Future class for Lead Conversion.  Size: ' + leadId.size());  
             ConvertLeadsOrgFuture.ConvertLeadsFutureMethod(leadid);
         }
       }
    }
  }
}