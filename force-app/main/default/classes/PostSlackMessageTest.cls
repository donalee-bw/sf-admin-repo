@isTest
public class PostSlackMessageTest {

    static testMethod PostSlackMessage.Message createMessage() {

    	PostSlackMessage.Message messageTest = new PostSlackMessage.Message();

        messageTest.text = 'Hello this is a test';
        messageTest.token = 'x1234-1234567890-asdf';

        return messageTest;
    }

    static testMethod List<PostSlackMessage.Message> createMessages() {

        List<PostSlackMessage.Message> mList = new List<PostSlackMessage.Message>();
        Integer i;

        for(i = 0; i < 50; i++) {

            PostSlackMessage.Message messageTest = new PostSlackMessage.Message();

    	    messageTest.text = 'Hello this is a test';
        	messageTest.token = 'x1234-1234567890-asdf';

            mList.add(messageTest);
        }
        return mList;
    }

    static testMethod void singlePost() {

        List<PostSlackMessage.Message> mList = new List<PostSlackMessage.Message>();
        PostSlackMessage.Message m = createMessage();

        mList.add(m);

        Test.setMock(HttpCalloutMock.class, new PostSlackMessageTestMock.SuccessfulResponseMock());

        Test.startTest();
        PostSlackMessage.PostSlackMessage(mList);
        Test.stopTest();
    }

    static testMethod void multiplePost() {

        List<PostSlackMessage.Message> mList = createMessages();
        String exceptionMessage;

        Test.setMock(HttpCalloutMock.class, new PostSlackMessageTestMock.SuccessfulResponseMock());

        Test.startTest();
        PostSlackMessage.PostSlackMessage(mList);
        Test.stopTest();
    }
}