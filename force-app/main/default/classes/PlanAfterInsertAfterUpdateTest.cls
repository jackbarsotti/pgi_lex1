@IsTest
public class PlanAfterInsertAfterUpdateTest {
    @testsetup static void testPlanafterinsertandUpdate(){
        
        Account accObj = new Account(Name = 'TestAcc');
        Insert accObj;
        Package__c pkgObj = new Package__c(Name = 'Testpkg');
        Insert pkgObj;
        List<Plan__c> planList = new List<Plan__c>{new Plan__c(Name = 'TestPlan',quantity__c = 10,quantityStartDate__c = date.parse('11/26/2019'),
                                                              billableType__c = 'Account',account__c = accObj.Id,
                                                              basePackage__c = pkgObj.Id,startDate__c = date.parse('11/26/2019')) };
        Insert planList;
        Plan__c updatepkgObj  = new Plan__c(Id = planList[0].Id,quantity__c = 20);
        Update updatepkgObj;
    }
    static testmethod void testplan(){
        Test.startTest();
        System.assertEquals(10, [Select Id,quantity__c from PlanQuantityHistory__c limit 1].quantity__c);
        Test.stopTest();
    }
}