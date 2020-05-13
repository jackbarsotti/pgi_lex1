@isTest
public class PlanRenewalEmailerSchedulableTest {
    
    @testsetup static void runRenewalTest(){
        
        Account accObj = new Account(Name = 'TestAcc',AutoRenewalEmail__c = true);
        Insert accObj;
        
        Package__c pkgObj = new Package__c(Name = 'Testpkg');
        Insert pkgObj;
        
        List<Plan__c> planList = new List<Plan__c>{
            new Plan__c(Name = 'TestPlan',quantity__c = 10,quantityStartDate__c = Date.today().addDays(-3),
                        billableType__c = 'ACCESS_CODE',account__c = accObj.Id,basePackage__c = pkgObj.Id,
                        startDate__c = Date.today().addDays(-3), endDate__c = null) };
                            Insert planList;
        
        RT_Product__c rtpObj = new RT_Product__c(Name = 'TestRTP',package__c = pkgObj.Id,Type__c = 'Account',
                                                 recurringChargeFrequency__c = 'ANNUALLY',recurringCharge__c = 10);
        Insert rtpObj;
        
        NegotiatedProduct__c npObj = new NegotiatedProduct__c(Name = 'TestNegstPrdt',account__c = accObj.Id,plan__c = planList[0].Id,
                                                              product__c = rtpObj.Id);
        Insert npObj;
        
        RecurringChargeOverride__c rcoObj = new RecurringChargeOverride__c(Name = 'TestRCO',negotiatedProduct__c = npObj.Id,
                                                                           baseProductRecurringCharge__c = 200, startDate__c = date.today(),recurringCharge__c = 30, recurringChargeFrequency__c = 'ANNUALLY');
        Insert rcoObj;
        
        Contact contObj = new Contact(Lastname = 'TestCont');
        Insert contObj;
        
        Subscription__c sObj = new Subscription__c(Name = 'TestSub',inactive__c = false,Contact__c = contObj.Id,
                                                   Security_Passcode__c = 'No security',Access_Code__c = '1234abcd');
        Insert sObj;
        
        PlanAssignment__c paObj = new PlanAssignment__c(Name = 'TestPA',accessCode__c = sObj.Id ,plan__c = planList[0].Id,
                                                        endDate__c = null,sObjectId__c = '01234abcde',startDate__c = date.today(),sObjectApiName__c = 'Contact' );
        Insert paObj; 
        
    }
    public static testMethod void testschedule() {	
        Test.StartTest();
        PlanRenewalEmailerSchedulable sh1 = new PlanRenewalEmailerSchedulable();
        String sch = '0 2 * * * ?';
        system.schedule('PlanRenewalEmailerSchedulable', sch, sh1);
        Test.stopTest();
    }
}