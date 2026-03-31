@isTest
public class WorkQueueControllerTest {

    @isTest
    static void testGetPendingCadenceSteps_NoData() {
        Test.startTest();
        List<WorkQueueController.CadenceGroupWrapper> results =
            WorkQueueController.getPendingCadenceSteps('LastModifiedDate');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should return empty list when no cadence tasks');
    }

    @isTest
    static void testGetPendingCadenceSteps_WithData() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'LeadUser',
            Company = 'Test Daycare',
            Phone = '(555) 123-4567'
        );
        insert testLead;

        Task cadenceTask = new Task(
            Subject = 'Call: Call 3 - Double Tap, Sales - IB 21 Day - Demo Chase Me - Lead, Test LeadUser, Test Daycare',
            TaskSubtype = 'Cadence',
            Status = 'Open',
            WhoId = testLead.Id,
            ActivityDate = Date.today().addDays(-5),
            OwnerId = UserInfo.getUserId()
        );
        insert cadenceTask;

        Test.startTest();
        List<WorkQueueController.CadenceGroupWrapper> results =
            WorkQueueController.getPendingCadenceSteps('LastModifiedDate');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one cadence group');
        System.assertEquals('Sales - IB 21 Day - Demo Chase Me - Lead', results[0].cadenceName);
        System.assertEquals(1, results[0].totalCount);
        System.assertEquals(1, results[0].stepGroups.size());
        System.assertEquals('Call 3 - Double Tap', results[0].stepGroups[0].stepName);
        System.assertEquals('Call', results[0].stepGroups[0].stepType);
        System.assertEquals(5, results[0].stepGroups[0].targets[0].daysOverdue);
        System.assertEquals('Test LeadUser', results[0].stepGroups[0].targets[0].targetName);
        System.assertEquals('Test Daycare', results[0].stepGroups[0].targets[0].organizationName);
    }

    @isTest
    static void testGetPendingCadenceSteps_NullSortField() {
        Test.startTest();
        List<WorkQueueController.CadenceGroupWrapper> results =
            WorkQueueController.getPendingCadenceSteps(null);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
    }

    @isTest
    static void testWrapperClasses() {
        WorkQueueController.StepTargetWrapper target = new WorkQueueController.StepTargetWrapper();
        target.taskId = 'test123';
        target.targetId = '00Q000000000001';
        target.targetName = 'Test Lead';
        target.targetType = 'Lead';
        target.organizationName = 'Test Company';
        target.phone = '(555) 123-4567';
        target.stepType = 'Call';
        target.stepName = 'Make a Call';
        target.daysOverdue = 5;
        target.lastModifiedDate = Datetime.now();
        target.cadenceName = 'Sales - Cold';

        System.assertEquals('Test Lead', target.targetName);
        System.assertEquals(5, target.daysOverdue);

        WorkQueueController.StepGroupWrapper stepGroup = new WorkQueueController.StepGroupWrapper();
        stepGroup.stepName = 'Make a Call';
        stepGroup.stepType = 'Call';
        stepGroup.count = 1;
        stepGroup.targets = new List<WorkQueueController.StepTargetWrapper>{ target };

        System.assertEquals(1, stepGroup.count);
        System.assertEquals(1, stepGroup.targets.size());

        WorkQueueController.CadenceGroupWrapper cadenceGroup = new WorkQueueController.CadenceGroupWrapper();
        cadenceGroup.cadenceName = 'Sales - Cold';
        cadenceGroup.totalCount = 1;
        cadenceGroup.stepGroups = new List<WorkQueueController.StepGroupWrapper>{ stepGroup };

        System.assertEquals('Sales - Cold', cadenceGroup.cadenceName);
        System.assertEquals(1, cadenceGroup.totalCount);
    }
}