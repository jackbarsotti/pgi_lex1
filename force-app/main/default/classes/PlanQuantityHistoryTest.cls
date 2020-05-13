@isTest
public class PlanQuantityHistoryTest {
    @testSetup static void setup(){
        Package__c packageObj = new Package__c();
        packageObj.Name='TestPackage';
        Insert packageObj;
        Account ac = new Account();
        ac.Name='Ac1';
        insert ac;
        Plan__c planObj = new Plan__c();
        planObj.Name = 'TestPlan';
        planObj.billableType__c='ACCOUNT';
        planObj.startDate__c=Date.today();
        planObj.endDate__c=Date.today().addDays(2);
        planObj.account__c=ac.Id;
        planObj.basePackage__c=packageObj.Id;
        Insert planObj;
        PlanQuantityHistory__c planQuanHistoryObj = new PlanQuantityHistory__c();
        planQuanHistoryObj.Plan__c=planObj.Id;
        planQuanHistoryObj.quantity__c = 10;
        planQuanHistoryObj.startDate__c=Date.today();
        planQuanHistoryObj.Name = 'Test1';
        Insert planQuanHistoryObj;
    }
    static  testmethod void testContactRepositoryById(){
        Plan__c planObj =[Select Id from PLan__c Where Name = 'TestPlan'];
       PlanQuantityHistory__c planQuantityHistoryObj =[Select Id,Name,Plan__c,quantity__c,startDate__c,LastModifiedById,LastModifiedDate from PlanQuantityHistory__c]; 
    	PlanQuantityHistory obj = new PlanQuantityHistory();
       List<PlanQuantityHistory__c> planQuantityHistoryLst = obj.getPlanQuantityHistorysByPlanId(planObj.Id);
        System.assertEquals(planQuantityHistoryObj.quantity__c, planQuantityHistoryLst[0].quantity__c);
        System.assertEquals(planQuantityHistoryObj.LastModifiedDate, planQuantityHistoryLst[0].LastModifiedDate);
 		System.assertEquals(planQuantityHistoryObj.startDate__c, planQuantityHistoryLst[0].startDate__c);
    }
}