trigger AreaCodeLookup on Lead (before insert, before update) {
/*
    String strPhoneVal;
    String old_phone;
    Map<String, String> mapAreaCodeToState = new Map<String, String>();
   

    for(Lead objLead : Trigger.New)
        {
        Try{
            Lead old_lead = Trigger.oldMap.get(objLead.Id);
            old_phone = old_lead.phone;
            system.debug('>>>> ' + old_phone);
        }
        catch (Exception e) {
        }
            
        if(String.isBlank(objLead.State) && String.isNotBlank(objLead.Phone) && old_phone != objLead.Phone && String.isNotBlank(objLead.school_object__c))
            {
            // Clean up phone number
            strPhoneVal = objLead.Phone;
            strPhoneVal = strPhoneVal.replace('(', '');
            strPhoneVal = strPhoneVal.replace(')', '');
            strPhoneVal = strPhoneVal.replace('+', '');
            strPhoneVal = strPhoneVal.replace('-', '');
            strPhoneVal = strPhoneVal.replace(' ', '');
            system.debug('>>>> strip ' + strPhoneVal);

            if(strPhoneVal.startsWith('1'))
                {
                strPhoneVal = strPhoneVal.substring(1,strPhoneVal.length());
                if(strPhoneVal.length() == 10)
                    {
                    strPhoneVal = strPhoneVal.left(3);
                    mapAreaCodeToState.put(strPhoneVal, '');
                    }
                }
            if(!strPhoneVal.startsWith('1') && strPhoneVal.length() == 10)
                {
                strPhoneVal = strPhoneVal.left(3);
                mapAreaCodeToState.put(strPhoneVal, '');
                }
            }

    system.debug('>>>> map ' + mapAreaCodeToState);

    // Query only matching records
    if(!mapAreaCodeToState.isEmpty())
        {
        for(Area_code__c  objAC : [SELECT Id, Name, State_abbreviation__c FROM Area_code__c  WHERE Name IN: mapAreaCodeToState.keySet()])
            {
            mapAreaCodeToState.put(objAC.Name, objAC.State_abbreviation__c);
            }
        }

    system.debug('>>>> map pair ' + mapAreaCodeToState);

    // Update value that was mapped
    if(mapAreaCodeToState.containsKey(strPhoneVal))
        {
        objLead.State = mapAreaCodeToState.get(strPhoneVal);
        system.debug('>>>> map value ' + objLead.State);
        }
    }
    */
}