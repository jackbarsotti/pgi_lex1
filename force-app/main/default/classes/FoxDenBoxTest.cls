@isTest
private class FoxDenBoxTest {
 
    static testMethod void testConstruct() {
        Account acc = new Account();
        acc.Name = 'testAcc';
        INSERT acc;
        Package__c pkg = new Package__c();
        INSERT pkg;
        Plan__c plan = new Plan__c();
        plan.Name = 'FoxDen Connect In-Room System';
        plan.account__c = acc.Id;
        plan.billableType__c = 'ACCOUNT';
        plan.startDate__c = Date.newInstance(2019, 11, 19);
        plan.basePackage__c = pkg.Id;
        INSERT plan;
       FoxDenBox FBox = new FoxDenBox();
        FoxDen_Box__c testFoxDen = new FoxDen_Box__c();
        testFoxDen.Beacon_Minor_Value__c = 3;
        testFoxDen.Account__c = acc.Id;
        testFoxDen.Beacon_Id__c = 'test';
        testFoxDen.Beacon_Major_Value__c = 7;
        testFoxDen.Kiosk_Email__c = 'vijay@raagvitech.com';
        testFoxDen.Password__c = 'testPass';
        testFoxDen.sku__c = 'testUniqueKey';
        testFoxDen.Status__c = 'Active';
        INSERT testFoxDen;
        Id BoxId = testFoxDen.Id;
        
		//FBox.accountHasFoxDenAccountLicense(testFoxDen);
        FBox.findById(BoxId);
        FBox.getFoxDenBoxesWhereAccountIdIsNullAndActive();
        FBox.assignBox(acc.Id,testFoxDen);
      
       list<FoxDen_Box__c> foxDenBoxRepo = new list<FoxDen_Box__c>(); 
        foxDenBoxRepo.add(testFoxDen);
        
        FoxDenBox foxDenBoxRepotest = new FoxDenBox();
        List<Id> FoxIds = new List<Id>();
        for(FoxDen_Box__c box : foxDenBoxRepo){
            FoxIds.add(box.Id); 
        } 
        FBox.getFoxDenBoxesInSet(FoxIds);
        Plan__c ObjPlan = [SELECT Id,account__c,Name FROM Plan__c WHERE Id =: plan.Id];
        FoxDen_Box__c testBox = [SELECT Id,Account__c FROM FoxDen_Box__c WHERE Id =: testFoxDen.Id];
        System.assertEquals(ObjPlan.account__c, testBox.Account__c);
        System.assertEquals(ObjPlan.Name, 'FoxDen Connect In-Room System');
        
    }
}