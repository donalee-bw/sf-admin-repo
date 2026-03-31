@isTest
private class SigmaEmbedClass_OppTest {
   static testMethod void StripeWebhookTestCreated() {
 
        // Test User
        //User u = new User();
        //u.lastname = 'test account';
        
        //insert u;
        
       
       // Test Account object
        Account a = new Account();
        a.name = 'test account';
        insert a;

        // Test Contact object
        Contact c = new Contact();
        c.LastName = 'McTtester';
        c.FirstName = 'Test';
        c.AccountId = a.id;
        c.Email = 'contact.testing@test.com';
        insert c;
    
    	//Test Opportunity object
    	Opportunity o = new Opportunity();
        o.name = 'Test Opportunity';
        o.stagename = 'New';
        o.closedate = date.today();
        insert o;
        
       
       SigmaEmbedClass_Opportunity mycontroller = new SigmaEmbedClass_Opportunity();
       mycontroller = new SigmaEmbedClass_Opportunity();
       mycontroller.embed_path= 'test.com';
       mycontroller.embed_user = 'test@gmail.com'; 
       mycontroller.embed_account = a.id; 
       
       string myURL;
       
       mycontroller.getGenerateIframeUrl();
       
   } 
}