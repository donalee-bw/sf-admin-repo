@isTest
private class GenericEmailDomainTest {

	static testmethod void insertLeadandEmail() {
		// Create lead
		Lead l = new Lead();
		l.LastName = 'Williams';
		l.FirstName = 'Test';
		l.Company = 'Williams Inc';
		l.Email = 'dylanwilliams@mybrightwheel.com';
		insert l;

		l.Email = 'dylanwilliams@hotmail.com';
		update l;

		delete l;
	}
}