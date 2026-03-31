@isTest
private class AreaCodeLookupTest {

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
		insert l2;

	}

}