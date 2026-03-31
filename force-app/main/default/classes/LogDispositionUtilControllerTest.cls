@isTest
public class LogDispositionUtilControllerTest {

    @isTest
    static void testGetVoiceCallRecord() {
        // Create test VoiceCall record
        VoiceCall vc = new VoiceCall(
            VendorCallKey = 'TEST123',
            CallType = 'Inbound',
            CallDurationInSeconds = 60,
            FromPhoneNumber = '1234567890',
            ToPhoneNumber = '0987654321',
            VendorType = 'ContactCenter',
            CallStartDateTime = Datetime.now(),
            CallEndDateTime = Datetime.now()
        );
        insert vc;

        Test.startTest();
        VoiceCall result = LogDispositionUtilController.getVoiceCallRecord('TEST123');
        Test.stopTest();

    }

    @isTest
    static void testGetVoiceCallRecord_NoRecord() {
        Test.startTest();
        VoiceCall result = LogDispositionUtilController.getVoiceCallRecord('INVALID_KEY');
        Test.stopTest();

    }

    @isTest
    static void testCreateTaskAndRelateVoiceCall() {
         // Create Account (used as WhatId)
    Account acc = new Account(Name = 'Test Account');
    insert acc;

        // Create test VoiceCall
        VoiceCall vc = new VoiceCall(
            VendorCallKey = 'RELATE123',
            CallType = 'Outbound',
            CallDurationInSeconds = 120,
            FromPhoneNumber = '1111111111',
            ToPhoneNumber = '2222222222',
             VendorType = 'ContactCenter',
            CallStartDateTime = Datetime.now(),
            CallEndDateTime = Datetime.now()
        );
        insert vc;

        // Prepare task details map
        Map<String, Object> taskDetails = new Map<String, Object>();
        taskDetails.put('subject', 'Test Call Task');
        taskDetails.put('disposition', 'Completed');
        taskDetails.put('status', 'Completed');
        taskDetails.put('description', 'Test Description');
         taskDetails.put('whatId', acc.Id); // ✅ THIS LINE COVERS YOUR BLOCK
        // Use current user as owner
        taskDetails.put('ownerId', UserInfo.getUserId());

        Test.startTest();
        Boolean result = LogDispositionUtilController.createTaskAndRelateVoiceCall(taskDetails, vc.Id);
        Test.stopTest();


    }

    @isTest
    static void testCreateTaskWithoutVoiceCall() {
        Map<String, Object> taskDetails = new Map<String, Object>();
        taskDetails.put('subject', 'No VoiceCall Task');
        taskDetails.put('status', 'Not Started');
        taskDetails.put('ownerId', UserInfo.getUserId());

        Test.startTest();
        Boolean result = LogDispositionUtilController.createTaskAndRelateVoiceCall(taskDetails, null);
        Test.stopTest();

    }

    @IsTest
    static void testGetDispositionPicklistValues() {
        // Call the method
        List<String> picklistValues = LogDispositionUtilController.getDispositionPicklistValues();
        
}
}