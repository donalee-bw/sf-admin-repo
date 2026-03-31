@isTest
public class LogDispositionUtilNewControllerTest {

    @isTest
    static void testCreateTaskAndRelateVoiceCall() {
        // 🔹 Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert con;

        // 🔹 Create VoiceCall (minimum required fields)
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

        // 🔹 Prepare task details map
        Map<String, Object> tskDetails = new Map<String, Object>{
            'subject' => 'Test Subject',
            'disposition' => 'Test Disposition',
            'ownerId' => UserInfo.getUserId(),
            'whoId' => con.Id,
            'whatId' => acc.Id,
            'description' => 'Test Description',
            'status' => 'Completed'
        };

        Test.startTest();
        Boolean result = LogDispositionUtilNewController.createTaskAndRelateVoiceCall(tskDetails, vc.Id);
        Test.stopTest();
    }

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
        VoiceCall result = LogDispositionUtilNewController.getVoiceCallRecord('TEST123');
        Test.stopTest();

    }

    @isTest
    static void testGetVoiceCallRecord_NoRecord() {
        Test.startTest();
        VoiceCall result = LogDispositionUtilNewController.getVoiceCallRecord('INVALID_KEY');
        Test.stopTest();

    }

    @isTest
    static void testGetDispositionPicklistValues() {
        Test.startTest();
        List<String> values = LogDispositionUtilNewController.getDispositionPicklistValues();
        Test.stopTest();

        System.assert(values.size() > 0, 'Disposition picklist should not be empty');
    }

    @isTest
    static void testGetStatusValues() {
        Test.startTest();
        List<String> values = LogDispositionUtilNewController.getStatusValues();
        Test.stopTest();

      
    }

    @isTest
    static void testGetLookupOptions() {
        Account acc = new Account(Name = 'Lookup Test Account');
        insert acc;

        List<String> objects = new List<String>{'Account'};

        Test.startTest();
        List<sObject> results = LogDispositionUtilNewController.getLookupOptions(objects);
        Test.stopTest();

        System.assert(results.size() > 0, 'Lookup results should not be empty');
    }

   @isTest
    static void testCreateTaskWithoutVoiceCall() {
        Map<String, Object> taskDetails = new Map<String, Object>();
        taskDetails.put('subject', 'No VoiceCall Task');
        taskDetails.put('status', 'Not Started');
        taskDetails.put('ownerId', UserInfo.getUserId());

        Test.startTest();
        Boolean result = LogDispositionUtilNewController.createTaskAndRelateVoiceCall(taskDetails, null);
        Test.stopTest();

    }
}