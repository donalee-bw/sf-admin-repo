public class AgentOutboundNumberPreferenceService {
    @AuraEnabled
    public static Boolean saveSelectedOutboundNumber(String selectedNumber) {
        try { 
            Id currentUserId = UserInfo.getUserId();
            Boolean localPresenceSelected = false;
            if(selectedNumber == 'OWN'){
                localPresenceSelected = false;
            }else if(selectedNumber == 'LOCAL_PRESENCE'){
                localPresenceSelected = true;
            }

            Contact_Center_Agent_Preference__c pref = new Contact_Center_Agent_Preference__c(
                Agent__c = currentUserId,
                Agent_User_Id__c = currentUserId,
                Apply_Local_Presence__c = localPresenceSelected
                //Selected_Number__c = selectedNumber
            );
            
            upsert pref Agent_User_Id__c;
            
            return true;
            
        } catch (Exception e) {
            System.debug('Error updating agent preference');
            System.debug(e.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static Contact_Center_Agent_Preference__c getAgentCallCenterNumber(){
        try{
            Id currentuserId = UserInfo.getUserId();
            Contact_Center_Agent_Preference__c u = [SELECT Id, Contact_Center_Number__c , Apply_Local_Presence__c FROM Contact_Center_Agent_Preference__c WHERE Agent__c = :currentUserId LIMIT 1];
            if (u == null) {
                return null;
            }
            return u;
        }catch(Exception e){
            return null;
        }
        
        
    }
}