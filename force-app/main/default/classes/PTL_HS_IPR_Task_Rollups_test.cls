@isTest
private class PTL_HS_IPR_Task_Rollups_test {

    static testmethod void insertLeadandTask() {
		// Create lead
		Lead l = new Lead();
		l.LastName = 'Williams';
		l.FirstName = 'Test';
		l.Company = 'Williams Inc';
		insert l;

		// Create tasks
		Task t = new Task();
		t.Subject = '123';
		t.Status = 'Open';
		t.Priority = 'Normal';
		t.Whoid = l.id;
        t.RecordTypeId = '0121I000000OEYAQA4';
		insert t;

        t.Status = 'Completed';
		update t;

		Task t1 = new Task();
		t1.Subject = '234';
		t1.Status = 'Open';
		t1.Priority = 'Normal';
		t1.Whoid = l.id;
        t.RecordTypeId = '0121I000000OEvZQAW';
		insert t1;

		t1.Status = 'Completed';
		update t1;
        
	    t.Status = 'Open';
		update t;
		delete t;

    }

    static testmethod void insertContactandTask() {

		// Create contact
		Contact c = new Contact();
		c.LastName = 'Myers';
		insert c;

		// Create tasks
		Task t = new Task();
		t.Subject = '123';
		t.Status = 'Open';
		t.Priority = 'Normal';
		t.Whoid = c.id;
        t.RecordTypeId = '0121I000000OEYAQA4';
		insert t;

		Task t1 = new Task();
		t1.Subject = '234';
		t1.Status = 'Open';
		t1.Priority = 'Normal';
		t1.Whoid = c.id;
        t.RecordTypeId = '0121I000000OEvZQAW';
		insert t1;

        t.Status = 'Completed';
		update t;

		t1.Status = 'Completed';
		update t1;
        
        t.Status = 'Open';
		update t;
		delete t;
    }
}