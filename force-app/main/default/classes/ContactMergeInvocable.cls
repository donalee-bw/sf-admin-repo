//Class called from Flow to merge Contacts where the email ends with '1'
//Logic passes the email1 Contact id from flow to this class, which calls the RecordMerge.ContactMerge class
//Similar logic on Lead under LeadMergeInvocable and RecordMerge.LeadMerge classes

public with sharing class ContactMergeInvocable {
    public class ContactMerge {
        @InvocableVariable(
            label='Contact ID to Merge' 
            description='Id of the Contact to merge'
            required=true)
        public ID ContactMergeID;
   }
      
    public class ContactMergeResults {
        @InvocableVariable (
           Label='Merge ID')
        public ID ContactMergeID;
    }  
    
   @InvocableMethod(
     label = 'Merge Contacts'
   )
        
    public static List<ContactMergeResults> mergeContacts (List<ContactMergeResults> requests){
     
        //retrieve the Contact id from the Flow
        List<id> MergeIDs = new List<ID>(); 
        for (ContactMergeResults request : requests){
           System.debug('--> Starting Apex call from Flow:  ContactMergeID: ' + request.ContactMergeID);
           MergeIDs.add(request.ContactMergeID);
        }
        
        List<Contact> initialContact = [SELECT ID, Email, AccountID
                              FROM Contact
                             WHERE ID = :MergeIDs];
        
        //Logic to remove the '1' from the email at the end
        for (Contact c : initialContact){
            String emailUpdated = c.email.removeEnd('1');
            c.email = emailUpdated;
        }   
        
        //Update the record and call the RecordMerge class to do the actual merging by email address
        if(initialContact.size()<>0 && initialContact != Null){
           update initialContact;
           RecordMerge.ContactMerge(initialContact);  
        }      
        return requests;
    }
}