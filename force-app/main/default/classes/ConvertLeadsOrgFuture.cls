//ConvertLeadsOrgFuture - created 01-27-2022
//Objective:  Replace ConvertLeadsOrg class into a future method to reduce the automation in a single call for a converted lead
//The original process was converting the lead and all leads tied to the org, which would hit the limit on CPU time.  
//Future class will be able to process more lead conversion tied to org without timeouts

global class ConvertLeadsOrgFuture {
    @future
    public static void ConvertLeadsFutureMethod(List<Id> inputLeadIds){
        List<Id> orgIds = new List<id>();
        List<Lead> leadsToConvert = new List<Lead>();
        List<Account> acct = new List<Account>();
        List<Lead> updateLeads = new List<Lead>();
        Map<Id,Id> MapofOrg_Account = new Map<Id,Id>();
        Map<Id,Id> MapofOrg_AccountOwner = new Map<Id,Id>();
        
        //Passed from Lead trigger
        If(inputLeadIds.size()>0 && inputLeadIds != NULL){
            system.debug('--> starting future class with Lead: ' + inputLeadIds);
            List<Lead> convertedLeads = [SELECT Id, Organization__c, IsConverted, LOGIC_Auto_Converted__c, LOGIC_Bypass_Validation__c
                                           FROM Lead
                                          WHERE Id = :inputLeadIds];
            
            if(convertedLeads.size()>0 && convertedLeads != NULL){
                for(Lead L : convertedLeads){
                    orgIds.add(L.Organization__c);
                }   
            }
            
            System.debug('--> Org size: ' + orgIds.size());
            
            if(orgIds.size()>0 && orgIds != NULL){
                //pulling all leads tied to org to convert along with original lead
                leadsToConvert = [SELECT Id, Organization__c, email, phone, LOGIC_Auto_Converted__c, LOGIC_Bypass_Validation__c,
                                  OwnerId, Owner.IsActive
                                    FROM Lead
                                   WHERE Organization__c = :orgIds
                                     AND IsConverted = false
                                   ORDER BY Organization__c];
                System.debug('--> leadsToCovert size: ' + leadsToConvert.size());
                
                acct = [SELECT Id, Organization__c, Ownerid, Owner.IsActive
                          FROM account
                         WHERE Organization__c = :orgIds];
                
                System.debug('--> acct size: ' + acct.size());
                
                if(acct.size()>0 && acct != NULL){
                    //finding account tied to org so that we can tie the other converted leads to same account
                    for(Account a : acct){
                        if(a.Owner.IsActive == true){
                           MapofOrg_Account.put(a.Organization__c, a.id);
                           MapofOrg_AccountOwner.put(a.Organization__c, a.OwnerId);
                        } else {
                           MapofOrg_Account.put(a.Organization__c, a.id);
                           MapofOrg_AccountOwner.put(a.Organization__c, '0053u0000035xeBAAQ'); 
                        }   
                    }
                }
            }
            
            if(leadsToConvert.size()>0 && leadsToConvert != Null){
                //updating the flags on the newly converted leads to ensure automation does not kick off also in lead trigger
                for (Lead l3 : leadsToConvert){
                    If(l3.Owner.IsActive == false || l3.OwnerId.GetSobjectType() == Group.SObjectType ){
                        l3.OwnerId = '0053u0000035xeBAAQ';
                    }
                    l3.LOGIC_Bypass_Validation__c = true;
                    l3.LOGIC_Auto_Converted__c = true;
                    updateLeads.add(l3);
                }
            }
            
            if(updateLeads.size()>0 && updateLeads != NULL){
                update updateLeads;
            }
                        
            if(leadsToConvert.size()>0 && leadsToConvert != NULL){
                //actual conversion logic
                system.debug('--> starting to build lead convert method');
                Database.leadConvert lc = new Database.leadConvert();
                LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                              FROM LeadStatus
                                             WHERE IsConverted=true
                                             LIMIT 1];
                
                for(Lead l2 : leadsToConvert){
                    lc.setLeadId(l2.id);
                    lc.setDoNotCreateOpportunity(true);
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    if(MapofOrg_Account.containskey(l2.Organization__c)){
                        lc.accountId = MapofOrg_Account.get(l2.Organization__c);
                        lc.ownerid   = MapofOrg_AccountOwner.get(l2.Organization__c);
                    } else {
                        lc.accountid = null;
                    }
                    
                    system.debug('--> setLeadId: ' + lc.LeadId);
                    system.debug('--> setDoNotCreateOpportunity: ' + lc.DoNotCreateOpportunity);
                    system.debug('--> setConvertedStatus: ' + lc.ConvertedStatus);
                    system.debug('--> accountId: ' + lc.accountId);
                    system.debug('--> ownerId: ' + lc.ownerId);
                    
                    system.debug('--> converting now');
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    
                    System.debug('--> conversion result: ' + lcr.getErrors());
                    
                }
            }
        }
    }

}