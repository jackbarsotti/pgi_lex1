@isTest
public class UpdatefromNetSuiteControllerTest {
@isTest
    static void test(){
        Test.startTest();
        	Account acc = new Account(Name='Test');
        	insert acc;
        	UpdatefromNetSuiteController.getAccountRecords(acc.Id);
        	UpdatefromNetSuiteController.updateAccountRecord(acc.Id);
        	System.assertEquals(true, [SELECT Id, NetSuite_Pull__c FROM Account WHERE Id =: acc.Id].NetSuite_Pull__c);
        	System.assertEquals(true, [SELECT Id, Celigo_Update__c FROM Account WHERE Id =: acc.Id].Celigo_Update__c);
        Test.stopTest();
    }
}