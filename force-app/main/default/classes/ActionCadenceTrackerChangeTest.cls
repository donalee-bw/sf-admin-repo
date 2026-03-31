@isTest
public class ActionCadenceTrackerChangeTest {
    
    @isTest static void testActionCadenceEvent() {
        Test.enableChangeDataCapture();
        
        // Create mock CREATE change event
        EventBus.ChangeEventHeader createHeader = new EventBus.ChangeEventHeader();
        createHeader.recordIds = new List<String>{ '8HFR00000005BfAOAU' };
        createHeader.changeType='CREATE';
        createHeader.entityName='ActionCadence';
        createHeader.changeOrigin='user1-wsl';
        createHeader.transactionKey = 'key';
        createHeader.commitUser = 'user1';
        ActionCadenceTrackerChangeEvent createEvent = new ActionCadenceTrackerChangeEvent();
        createEvent.changeEventHeader = createHeader;
        createEvent.put('ActionCadenceId', '77CR0000000ENXAMA4');
        createEvent.put('State', 'Running');
        EventBus.publish(createEvent);
        Test.getEventBus().deliver();
        
        // Create mock UPDATE change event
        EventBus.ChangeEventHeader updateHeader = new EventBus.ChangeEventHeader();
        updateHeader.recordIds = new List<String>{ '8HFR00000005BfAOAU' };
        updateHeader.changeType='UPDATE';
        updateHeader.entityName='ActionCadence';
        updateHeader.changeOrigin='user1-wsl';
        updateHeader.transactionKey = 'key';
        updateHeader.commitUser = 'user1';
        ActionCadenceTrackerChangeEvent updateEvent = new ActionCadenceTrackerChangeEvent();
        updateEvent.changeEventHeader = updateHeader;
        updateEvent.put('State', 'Complete');
        EventBus.publish(updateEvent);
        Test.getEventBus().deliver();
    }  
}