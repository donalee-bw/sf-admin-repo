@isTest
private class TaskArchiveDeleteInvocableTest{

    @isTest
    static void test_TaskArchiveDelete() {
        
        Lead ld = new Lead(
            firstName = 'Test',
            lastName = 'McTester',
            company = 'Salesforce'
        );

        insert ld;
        
        Task t1 = new Task(
             WhoId = ld.id,
             Subject = 'Testing Tester',
             Status = 'Open',
             Priority = 'Normal'
        );
        
        insert t1;

        Test.startTest();

        TaskArchiveDeleteInvocable.Request request = new TaskArchiveDeleteInvocable.Request();
        request.leadId = ld.id;

        List<TaskArchiveDeleteInvocable.Response> results = TaskArchiveDeleteInvocable.execute( new List<TaskArchiveDeleteInvocable.Request>{ request } );

        Test.stopTest();
    }
}