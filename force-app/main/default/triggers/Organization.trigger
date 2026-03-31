trigger Organization on Organization__c (before insert, before update) {

 if(Trigger.isInsert || Trigger.isUpdate){
          
            List<Generic_Email_Domain__c> ListOfGenericDomains = [Select Email_Domain__c from Generic_Email_Domain__c];          
            List<String> ListOfGenericDomainsString = new List<String>();
            for(Generic_Email_Domain__c ED : ListOfGenericDomains){
              ListOfGenericDomainsString.add(ED.Email_Domain__c);
            }
          
            for(Organization__c OrgRec : Trigger.New){
            //original code from GenericEmailDomain
            if(ListOfGenericDomainsString.contains(OrgRec.LOGIC_Organization_Email_Domain2__c)){
                OrgRec.LOGIC_Organization_Generic_Domain__c = True;
              } else {
                OrgRec.LOGIC_Organization_Generic_Domain__c = False;
              }
            }
   }       

}