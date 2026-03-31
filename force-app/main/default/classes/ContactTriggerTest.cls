@isTest
public class ContactTriggerTest {
    @isTest static void test_ContactTrigger(){
		Contact con = new Contact(
        	LastName = 'Test'
        );
        insert con;
        
        con.FirstName = 'Justin';
        update con;
        delete con;
        undelete con;
        
    }
}