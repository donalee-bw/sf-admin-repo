@isTEst
private class OrgTrigTest {
 
  static testmethod void insertOrgandEmail() {
    // Create lead
    
    Generic_Email_Domain__c GED = new Generic_Email_Domain__c();
    GED.Email_Domain__c = 'hotmail.com';
    insert GED;
      
    Organization__c o = new Organization__c();
    //o.Company = 'Williams Inc';
    o.Outbound_Email__c = 'dylanwilliams@hotmail.com';
    insert o;

    o.Outbound_Email__c = 'dylanwilliams2@hotmail.com';
    update o;

    delete o;
  }
}