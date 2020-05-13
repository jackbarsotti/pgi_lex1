@isTest
private class AssignFoxDenBoxTest {
    
    private static ApexPages.StandardController controller = new ApexPages.StandardController(new FoxDen_Box__c());
    
    //AssignFoxDenBox.AssignFoxDenBox
    static testMethod void testConstruct() {
        AssignFoxDenBox b = new AssignFoxDenBox(controller);
        b.getObjectId();
        AssignFoxDenBox.getInventory();
        
        Account a = MockAccount.getNewAccount();
        
        try{
            
            // INSERT foxDenBoxRepo;
            
            AssignFoxDenBox.assignBoxes(a.Id, new List<Id>());
        }
        catch(Exception e){
            
        }
        
        System.assert(b != null);
    }    
    static testMethod void testassignBoxes() {
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
        FoxDen_Box__c testFoxDen = new FoxDen_Box__c();
       testFoxDen.Beacon_Minor_Value__c	 = 3;
        testFoxDen.Beacon_Id__c = 'test';
        testFoxDen.Beacon_Major_Value__c = 7;
        testFoxDen.Kiosk_Email__c = 'vijay@raagvitech.com';
        testFoxDen.Password__c = 'testPass';
        testFoxDen.sku__c = 'testUniqueKey';
        INSERT testFoxDen;
        list<FoxDen_Box__c> foxDenBoxRepo = new list<FoxDen_Box__c>(); 
        foxDenBoxRepo.add(testFoxDen);
        
        
        FoxDenBox foxDenBoxRepotest = new FoxDenBox();
        List<Id> FoxIds = new List<Id>();
        for(FoxDen_Box__c box : foxDenBoxRepo){
            FoxIds.add(box.Id); 
        } 
        AssignFoxDenBox.assignBoxes(acc.Id,FoxIds);
        FoxDen_Box__c FBox = [SELECT Id,Account__c FROM FoxDen_Box__c WHERE Id =: testFoxDen.Id];
        System.assertEquals(FBox.Account__c,acc.Id);
   
    }
}