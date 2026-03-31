//Class called from other Apex Invocable classes to merge Leads / Contacts where the email ends with '1'
//Logic passes the object record from the invocable class to this class to do the query and merging of the SObjects
//This logic is separate from the invocable classes as there may be future needs to call merging logic from other sources

public without sharing class RecordMerge{
    public static void LeadMerge(List<Lead> listNew){
          
     for(Lead l : listNew){
        
        system.debug('--> Starting Apex Class: Email used: ' + l.email);
           String emailUpdated = l.email.removeEnd('1');
           List<Lead> updateLeads = new List<Lead>();
           ID tempPrevOwnerId = null;
           Boolean survivorQueueOwned = false;

           List<Lead> SameLeadList = [SELECT id, FirstName, LastName, Email, Phone
                                        FROM Lead 
                                       WHERE (email = :l.email OR
                                             email = :emailUpdated)
                                         AND IsDeleted = false
                                         AND IsConverted = false
                                       Order by CreatedDate Desc
                                       LIMIT 3];
         
           //a separate list needs to be pulled due to SF not allowing Owner.id in a merge call
           List<Lead> SameLeadOwnerList = [SELECT id, Owner.id
                                        FROM Lead 
                                       WHERE (email = :l.email OR
                                             email = :emailUpdated)
                                         AND IsDeleted = false
                                         AND IsConverted = false
                                       Order by CreatedDate Desc
                                       LIMIT 3];
         
           System.debug('--> Merge List: SameLeadList.size: ' + SameLeadList.size());
           
           if(sameLeadList.size()>0 && SameLeadList != NULL){
               Lead survivorLead = sameLeadList[0];
               if(sameLeadList[0].id == sameLeadOwnerList[0].id){                   
                   String sId = sameLeadOwnerList[0].Owner.id;
                   if(sID.startsWith('00G')){
                       survivorQueueOwned = true;   
                   }
               }
               List<Lead> mergeLead = new List<Lead>();
               if(sameLeadList.size()>1){
                   //match lead lists to ensure sorts are correct order
                   if(sameLeadList[1].id == sameLeadOwnerList[1].id && sameLeadOwnerList[1].Owner.Id != NULL){
                      String s = sameLeadOwnerList[1].Owner.Id;
                      //if the current survivor is Queue owned, but the 1 record is User owned, we want to swap them 
                      if(!s.startsWith('00G') && survivorQueueOwned == true){
                        Lead tempSurvivorLead = survivorLead;
                        survivorLead = sameLeadList[1];
                        mergeLead.add(tempSurvivorLead);
                        survivorQueueOwned = false;                          
                      } else {
                         mergeLead.add(sameLeadList[1]);  
                          if(!s.startsWith('00G')){
                            tempPrevOwnerId = sameLeadOwnerList[1].Owner.id;      
                          }
                      }
                           
                   }
                   
                  if(sameLeadList.size()>2){
                      //mergeLead.add(sameLeadList[2]);
                      //match lead lists to ensure sorts are correct order
                      if(sameLeadList[2].id == sameLeadOwnerList[2].id && sameLeadOwnerList[2].Owner.Id != NULL){
                          String s2 = sameLeadOwnerList[2].Owner.Id;
                          //if the current survivor is Queue owned, but the 2 record is User owned, we want to swap them
                          if(!s2.startsWith('00G') && survivorQueueOwned == true){
                             Lead tempSurvivorLead = survivorLead;
                             survivorLead = sameLeadList[2];
                             mergeLead.add(tempSurvivorLead);
                          } else {
                             mergeLead.add(sameLeadList[2]); 
                             if(!s2.startsWith('00G') && tempPrevOwnerId == Null){
                                tempPrevOwnerId = sameLeadOwnerList[2].Owner.Id;
                             }    
                          }
                      }
                  }
                   if(tempPrevOwnerId != NULL){
                       survivorLead.Previous_Lead_Owner__c = tempPrevOwnerId;
                       updateLeads.add(survivorLead);
                   }
               }
               
               
               if(mergeLead.size()>0 && mergeLead!= NULL){
                   system.debug('--> RecordMerge calling merge of : ' + survivorLead + ' & ' + mergeLead);
                   merge survivorLead mergeLead; 
               }            
           
               if(updateLeads.size()>0 && updateLeads != NULL){
                   update updateLeads;
               }
           }
    }  
  }
    
public static void ContactMerge(List<Contact> listNew){
          
     for(Contact c : listNew){
        
        system.debug('--> Starting Apex Class: Email used: ' + c.email);
           String emailUpdated = c.email.removeEnd('1');

           List<Contact> SameContactList = [SELECT FirstName, LastName, Email, Phone 
                                        FROM Contact 
                                       WHERE (email = :c.email OR
                                             email = :emailUpdated)
                                         AND IsDeleted = false
                                         AND AccountID = :c.AccountID
                                       Order by CreatedDate Desc
                                       LIMIT 3];
           System.debug('--> Merge List: SameContactList.size: ' + SameContactList.size());
           
           if(sameContactList.size()>0 && SameContactList != NULL){
               Contact survivorContact = sameContactList[0];
               List<Contact> mergeContact = new List<Contact>();
               if(sameContactList.size()>1){
                  mergeContact.add(sameContactList[1]);  
                  if(sameContactList.size()>2){
                     mergeContact.add(sameContactList[2]);
                  }
               }
               
               if(mergeContact.size()>0 && mergeContact!= NULL){
                   system.debug('--> RecordMerge calling merge of : ' + survivorContact + ' & ' + mergeContact);
                   checkRelatedAccts(survivorContact, mergeContact);
                   merge survivorContact mergeContact; 
               }            
           }
    }  
  }  
   public static void checkRelatedAccts(Contact survivorContact, List<Contact> mergeList){
      system.debug('--> RecordMerge starting check on related accounts');
      map<id,id> survivorRelatedAccts = new map<id,id>();
      List<Id> deletedACRIds          = new List<id>();
      
     List<AccountContactRelation> survivorACR = [SELECT Id, AccountId
                                                   FROM AccountContactRelation
                                                  WHERE ContactID = :survivorContact.id
                                                    AND IsDirect = false];
        
     if(survivorACR.size()>0 && survivorACR != NULL){
         for (AccountContactRelation a : survivorACR){
            system.debug('--> found survivor ACR: ' + a.Id); 
            survivorRelatedAccts.put(a.AccountId, a.Id);        
         }
         
         List<Id> mergeIds = new List<Id>();
         for (Contact c : mergeList){
             mergeIds.add(c.id);
         }
         
         List<AccountContactRelation> mergeACR = [SELECT id, AccountId, IsDirect
                                                    FROM AccountContactRelation
                                                   WHERE ContactId = :mergeIds];
         
         if(mergeACR.size()>0 && mergeACR != NULL){
             for (AccountContactRelation a : mergeACR){
                 system.debug('--> Found merge ACR: ' + a.id);
                 if(survivorRelatedAccts.containsKey(a.AccountId)){
                     if(a.IsDirect == false){
                        system.debug('--> found ACRs to delete: ' + survivorRelatedAccts.get(a.AccountId)); 
                        deletedACRIds.add(survivorRelatedAccts.get(a.AccountId));   
                 }
             }
         }
         if(deletedACRIds.size()>0 && deletedACRIds != NULL){
            System.debug('--> deleting ACR: ' + deletedACRIDs);
            List<AccountContactRelation> deleteACRs = [SELECT ID
                                                         FROM AccountContactRelation
                                                        WHERE id = :deletedACRIds];  
            delete deleteACRs;
         }
     }
    }
   }     
}