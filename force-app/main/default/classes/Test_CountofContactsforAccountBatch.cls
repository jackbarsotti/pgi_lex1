/*********************************************************************
Name : Test_CountofContactsforAccountBatch
Created On : Jul 11,2016
Created By : Archana Rajendran
Description : Test Class for CountofContactsforAccountBatch
**********************************************************************/

@isTest
private class Test_CountofContactsforAccountBatch {
    static testmethod void test() 
    {
       Account acc = PGITestUtilities.getAccountDetails();
       insert acc;
       Contact con = PGITestUtilities.getContactDetails(Acc.id);
       insert con;
       Account acc2 = PGITestUtilities.getAccountDetails();
       insert acc2;
       
       Test.startTest();
       CountofContactsforAccountBatch a = new CountofContactsforAccountBatch();
       Database.executeBatch(a);
       Test.stopTest();
       
       Account a1=[select id,no_of_contacts__c from account where id =: acc.id];
       System.assertEquals(a1.no_of_contacts__c,1); 
       Account a2=[select id,no_of_contacts__c from account where id =: acc2.id];
       System.assertEquals(a2.no_of_contacts__c,0); 
             
    }
}