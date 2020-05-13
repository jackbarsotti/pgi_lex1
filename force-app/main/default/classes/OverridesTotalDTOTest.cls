@isTest
public class OverridesTotalDTOTest {
    //test addRecurringCharge
    static testmethod void testaddRecurringCharge(){
         Account accObj = new Account(Name = 'TestAcc',AutoRenewalEmail__c = true);
        Insert accObj;
        
        Package__c pkgObj = new Package__c(Name = 'Testpkg');
       	Insert pkgObj;
        
        List<Plan__c> planList = new List<Plan__c>{
            new Plan__c(Name = 'TestPlan',quantity__c = 10,quantityStartDate__c = Date.today().addDays(-3),
                        billableType__c = 'ACCESS_CODE',account__c = accObj.Id,basePackage__c = pkgObj.Id,
                        startDate__c = Date.today().addDays(-3), endDate__c = null) }; 
                            Insert planList;
        
         NegotiatedProduct__c npObj = new NegotiatedProduct__c(Name = 'TestNegstPrdt',account__c = accObj.Id,plan__c = planList[0].Id);  //, product__c = rtpObj.Id);
        Insert npObj;
        List<RecurringChargeOverride__c> rcoobjList = new List<RecurringChargeOverride__c>{
            new RecurringChargeOverride__c(Name = 'test0',baseProductRecurringCharge__c = 10, 
                                           negotiatedProduct__c = npObj.Id,recurringCharge__c = 0, startDate__c = date.today()),
                new RecurringChargeOverride__c(Name = 'test1',baseProductRecurringCharge__c = 10, 
                                           negotiatedProduct__c = npObj.Id, recurringCharge__c = 10, startDate__c = date.today()) };
                    INSERT rcoobjList;
        
      Test.startTest();
        OverridesTotalDTO obj = new OverridesTotalDTO();
        obj.addRecurringCharge(rcoobjList[0]);
        obj.addRecurringCharge(rcoobjList[1]);
        System.assertEquals(10.00, [SELECT id,recurringCharge__c FROM RecurringChargeOverride__c WHERE name = 'test1'].recurringCharge__c);
        Test.stopTest();
    }
    //test addSingleCharge
    static testmethod void testaddSingleCharge(){
        
         Account accObj = new Account(Name = 'TestAcc',AutoRenewalEmail__c = true);
        Insert accObj;
        
        Package__c pkgObj = new Package__c(Name = 'Testpkg');
       	Insert pkgObj;
        
        List<Plan__c> planList = new List<Plan__c>{
            new Plan__c(Name = 'TestPlan',quantity__c = 10,quantityStartDate__c = Date.today().addDays(-3),
                        billableType__c = 'ACCESS_CODE',account__c = accObj.Id,basePackage__c = pkgObj.Id,
                        startDate__c = Date.today().addDays(-3), endDate__c = null) }; 
                            Insert planList;
        
         NegotiatedProduct__c npObj = new NegotiatedProduct__c(Name = 'TestNegstPrdt',account__c = accObj.Id,plan__c = planList[0].Id);  //, product__c = rtpObj.Id);
        Insert npObj;
        
        List<SingleChargeOverride__c> scoobjList = new List<SingleChargeOverride__c>{
            new SingleChargeOverride__c(Name = 'test0',baseProductSingleCharge__c = 10,singleCharge__c = 0, 
                                           negotiatedProduct__c = npObj.Id, startDate__c = date.today()),
                new SingleChargeOverride__c(Name = 'test1',baseProductSingleCharge__c = 10, singleCharge__c = 10,
                                           negotiatedProduct__c = npObj.Id, startDate__c = date.today()) };
                    INSERT scoobjList;
        
      Test.startTest();
        OverridesTotalDTO obj = new OverridesTotalDTO();
        obj.addSingleCharge(scoobjList[0]);
        obj.addSingleCharge(scoobjList[1]);
        System.assertEquals(10.00, [SELECT id,singleCharge__c FROM SingleChargeOverride__c WHERE name = 'test1'].singleCharge__c);
       Test.stopTest();
    }
}