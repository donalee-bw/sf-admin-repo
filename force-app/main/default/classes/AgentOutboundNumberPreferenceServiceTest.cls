@isTest
public class AgentOutboundNumberPreferenceServiceTest {


    @isTest
    static void testSaveSelectedOutboundNumber_OWN() {

        User use = [SELECT Id FROM User LIMIT 1];

            Test.startTest();

            Boolean result = AgentOutboundNumberPreferenceService.saveSelectedOutboundNumber('OWN');
          Boolean result1 = AgentOutboundNumberPreferenceService.saveSelectedOutboundNumber('LOCAL_PRESENCE');
             Contact_Center_Agent_Preference__c result2 =
                AgentOutboundNumberPreferenceService.getAgentCallCenterNumber();

            Test.stopTest();
      
    }
   
}