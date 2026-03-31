//Class called from Flow to merge Leads where the email ends with '1'
//Logic passes the email Lead id from flow to this class, which calls the RecordMerge.LeadMerge class
//Similar logic on Contact under ContactMergeInvocable and RecordMerge.ContactMerge classes

public with sharing class LeadMergeInvocable {
    public class LeadMerge {
        @InvocableVariable(
            label='Lead ID to Merge' 
            description='Id of the Lead to merge'
            required=true)
        public ID LeadMergeID;
   }
      
    public class LeadMergeResults {
        @InvocableVariable (
           Label='Merge ID')
        public ID LeadMergeID;
    }  
    
   @InvocableMethod(
     label = 'Merge Leads'
   )
        
    public static List<LeadMergeResults> mergeLeads (List<LeadMergeResults> requests){
     
        //retrieve the Contact id from the Flow
        List<id> MergeIDs = new List<ID>(); 
        for (LeadMergeResults request : requests){
           System.debug('--> Starting Apex call from Flow:  LeadMergeID: ' + request.LeadMergeID);
           MergeIDs.add(request.LeadMergeID);
        }
        
        List<Lead> initialLead = [SELECT ID, Email
                              FROM Lead
                             WHERE ID = :MergeIDs];
        
        //Logic to remove the '1' from the email at the end
        for (Lead l : initialLead){
            String emailUpdated = l.email.removeEnd('1');
            l.email = emailUpdated;
        }   
        
        //Update the record and call the RecordMerge class to do the actual merging by email address
        if(initialLead.size()<>0 && initialLead != Null){
           update initialLead;
           RecordMerge.LeadMerge(initialLead);  
        }
           
        return requests;
    }
}