@isTest
public with sharing class ContactTriggerTest {
    static testMethod void test() {
        Test.startTest();
        Contact con = new Contact();
        con.LastName = 'Test Trigger';
        insert con;
        Test.stopTest();
    } 
}