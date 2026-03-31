@isTEst
private class LeadTrigTest {
 static testmethod void insertLeadwithphone() {
    //Create school
    School_Object__c s = new School_Object__c();
    s.Account_Name__c = 'Dylan School';
        s.Owner_Email__c = 'test@test.com';
    s.Brightwheel_School_UUID__c = '123a';
    insert s;

    //Craete area code
    Area_code__c a = new Area_code__c();
    a.Name = '717';
    a.State_abbreviation__c = 'PA';
    insert a;

    // Create lead
    Lead l = new Lead();
    l.LastName = 'Williams';
    l.FirstName = 'Test';
    l.Company = 'Williams Inc';
    l.Email = 'dylanwilliams@mybrightwheel.com';
    l.Phone = '+1(717) 555-5555';
    l.School_object__c = s.id;
    insert l;

        Lead l2 = new Lead();
    l2.LastName = 'Williams';
    l2.FirstName = 'Test';
    l2.Company = 'Williams Inc.';
    l2.Email = 'dylanwilliams1@mybrightwheel.com';
    l2.Phone = '(717) 555-5556';
    l2.School_object__c = s.id;
    l2.Email_2__c = 'test@yahoo.com';
    insert l2;
    

    
    test.startTest();
     l.phone = '+1(717) 555-5556';
     update l;
    
     l2.phone = '+1(717) 555-5558';
     l2.Email_2__c = 'test123@yahoo.com';
     update l2;
   

  
     delete l;
     delete l2;
    test.stopTest();

    

  }
  
  static testmethod void insertLeadandEmail() {
    // Create lead
    
    Generic_Email_Domain__c GED = new Generic_Email_Domain__c();
    GED.Email_Domain__c = 'hotmail.com';
    insert GED;
      
    Lead l = new Lead();
    l.LastName = 'Williams';
    l.FirstName = 'Test';
    l.Company = 'Williams Inc';
    l.Email = 'dylanwilliams@hotmail.com';
    insert l;

    l.Email = 'dylanwilliams2@hotmail.com';
    update l;

    delete l;
  }
}