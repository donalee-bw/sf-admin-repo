/*
*********************************************************
Apex Class Name    : JungleGymAccountCreationService
Created Date       : 5/5/2025
@description       : This class handles the preparation and submission of data from Opportunities and Child Site 
records to the JungleGym platform. It collects key details from Salesforce, including related
Account and Contact information, and organizes them into a format needed for external processing. 
The class is designed to work with both single-site and multi-site Opportunities, 
and it can be triggered from a Flow. 
Once the data is ready, it’s sent in the background using a queueable job.
@author            : Justin Strout
Modification Log:
Ver   Date         Author                               Modification
1.0   5/5/2025     Justin Strout                        Initial Implementation, Single Sites only
1.1   6/1/2025     Justin Strout						Expanded functionality to process multi-site Opportunities
*********************************************************
*/
public class JungleGymAccountCreationService {
    public interface IJungleGymWrapper {
        Map<String,Object> toPayload();
    }
    
    // 1) Opportunity wrapper 
    public class JungleGymOpportunityWrapper implements IJungleGymWrapper {
        private Opportunity opp;
        public JungleGymOpportunityWrapper(Opportunity o) {
            this.opp = o;
        }
        public Map<String,Object> toPayload() {
            return JungleGymPayloadBuilder.buildFrom(opp);
        }
    }
    
    // 2) Child-Site wrapper must carry both the child site creation record and its Contact:
    public class JungleGymChildSiteWrapper implements IJungleGymWrapper {
        private Child_Site_Creation__c cs;
        private Contact con;
        public JungleGymChildSiteWrapper(
            Child_Site_Creation__c cs,
            Contact con
        ) {
            this.cs  = cs;
            this.con = con;
        }
        public Map<String,Object> toPayload() {
            return JungleGymPayloadBuilder.buildFrom(cs, con);
        }
    }
    
    
    // Wrapper for passing record IDs from Flow
    public class RecordRef {
        @InvocableVariable(label='Record Id' required=true)
        public Id recordId;
    }
    
    @InvocableMethod(label='Process JungleGym Records'
                     description='Called from Opportunity or Child-Site flow')
    public static void processRecords(List<RecordRef> inputs) {
        
        // 1) Bucket IDs by sObjectType
        Map<Schema.SObjectType, List<Id>> idsByType = new Map<Schema.SObjectType, List<Id>>();
        for (RecordRef rr : inputs) {
            Schema.SObjectType t = rr.recordId.getSObjectType();
            if (!idsByType.containsKey(t)) {
                idsByType.put(t, new List<Id>());
            }
            idsByType.get(t).add(rr.recordId);
        }
        
        // 2) Prepare wrappers list
        List<IJungleGymWrapper> wrappers = new List<IJungleGymWrapper>();
        
        // 3) Opportunities
        List<Opportunity> opps = new List<Opportunity>();
        if (idsByType.containsKey(Opportunity.sObjectType)) {
            opps = [
                SELECT Id, AccountId, Account.Name, Opportunity.Multi_Site__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry, Account.Capacity__c, Account.Brightwheel_School_UUID__c, Account.bw_Organization_UUID__c, Account.bw_School_UUID__c,
                Contact__c, Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.Phone, Contact__r.US_Time_Zone__c, Contact__r.Normalized_Phone__c,
                Capacity__c, Name, Subscription__c, Amount, Billing_Intervals__c, First_Bill_Date__c, Promo_code__c, ACH_Fee_Structure__c, ACH_Fee_Flat__c, ACH_Fee_Variable__c, ACH_Fee_Max__c, HelloSign_Payment_Processing_Fee__c, Center_Type__c,
                Owner.Email, Organization_Id__c, Number_of_Schools__c, Exists_In_JG__c, JG_Identification_Reason__c, Closed_Won_School_ID__c, SaaS_Offline_Payer__c, Site_Add_Details__c, Exists_In_JG_Override__c
                FROM Opportunity
                WHERE Id IN :idsByType.get(Opportunity.sObjectType)
            ];
            for (Opportunity o : opps) {
                wrappers.add(new JungleGymOpportunityWrapper(o));
            }
        }
        
        // 4) Child Sites + Contacts
        if (idsByType.containsKey(Child_Site_Creation__c.sObjectType)) {
            List<Child_Site_Creation__c> sites = [
                SELECT Id, Child_Site_Name__c,
                Original_CW_Opportunity__r.Multi_Site__c, Street_Address__c, City__c, State_Province__c, Zip_Postal_Code__c, Country__c,
                Contact__c, Capacity__c, Original_CW_Opportunity__r.Subscription__c, Amount__c, Original_CW_Opportunity__r.Billing_Intervals__c, 
                First_Bill_Date__c, Original_CW_Opportunity__r.Promo_code__c, Original_CW_Opportunity__r.ACH_Fee_Structure__c, 
                Original_CW_Opportunity__r.ACH_Fee_Flat__c, Original_CW_Opportunity__r.ACH_Fee_Variable__c, Original_CW_Opportunity__r.ACH_Fee_Max__c,
                Original_CW_Opportunity__r.HelloSign_Payment_Processing_Fee__c, Center_Type__c, Original_CW_Opportunity__r.Closed_Won_School_ID__c,
                Original_CW_Opportunity__r.Owner.Email, Original_CW_Opportunity__r.Organization_Id__c,Original_CW_Opportunity__r.AccountId, 
                Original_CW_Opportunity__r.Account.bw_Organization_UUID__c, Original_CW_Opportunity__r.Account.bw_School_UUID__c, Original_CW_Opportunity__r.Exists_In_JG__c,
                Original_CW_Opportunity__r.JG_Identification_Reason__c, Original_CW_Opportunity__r.SaaS_Offline_Payer__c, Original_CW_Opportunity__r.Site_Add_Details__c,Original_CW_Opportunity__r.Exists_In_JG_Override__c
                FROM Child_Site_Creation__c
                WHERE Id IN :idsByType.get(Child_Site_Creation__c.sObjectType)
            ];
            // bulk-collect and query Contacts
            Set<Id> contactIds = new Set<Id>();
            for (Child_Site_Creation__c cs : sites) {
                if (cs.Contact__c != null) {
                    contactIds.add(Id.valueOf(cs.Contact__c));
                }
            }
            //since Contact on Child Site Creation is text not a lookup, we need to query the contact separately
            Map<Id,Contact> contactsById = new Map<Id,Contact>(
                [SELECT Id, FirstName, LastName, Email, Normalized_Phone__c, US_Time_Zone__c
                 FROM Contact
                 WHERE Id IN :contactIds]
            );
            // build wrappers
            for (Child_Site_Creation__c cs : sites) {
                Contact con = contactsById.get(Id.valueOf(cs.Contact__c));
                wrappers.add(new JungleGymChildSiteWrapper(cs, con));
            }
        }
        
        // 5) Auth key + enqueue 
        String authKey = [SELECT Key__c FROM JGAuth__c LIMIT 1].Key__c;
        System.enqueueJob(new JungleGymCalloutQueueable(wrappers, authKey));
    }
    
}