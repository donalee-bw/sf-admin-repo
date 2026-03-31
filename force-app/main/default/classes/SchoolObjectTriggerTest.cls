@isTest
private class SchoolObjectTriggerTest {
@IsTest
    Static void test_SchoolObjectTrigger(){
        School_Object__c school = new School_Object__c(
            Name = 'test',
            Brightwheel_School_UUID__c = '***********'
        );

        insert school;

        school.Billing_Version__c  = 'test';
        update school;
        
        delete school;
        undelete school;        
    }
    
}