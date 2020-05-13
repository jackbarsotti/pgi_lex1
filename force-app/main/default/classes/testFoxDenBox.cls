@isTest
private class testFoxDenBox {
 
    static testMethod void testConstruct() {
        Account acc = PGITestUtilities.createAccount(true);
        // INSERT acc;
       FoxDenBox FBox = new FoxDenBox();
        FoxDen_Box__c testFoxDen = new FoxDen_Box__c();
        testFoxDen.Beacon_Minor_Value__c = 3;
        testFoxDen.Account__c = acc.Id;
        testFoxDen.Beacon_Id__c = 'test';
        testFoxDen.Beacon_Major_Value__c = 7;
        testFoxDen.Kiosk_Email__c = 'vijay@test.com';
        testFoxDen.Password__c = 'testPass';
        testFoxDen.sku__c = 'testUniqueKey';
        testFoxDen.Status__c = 'Active';
        INSERT testFoxDen;
        Id BoxId = testFoxDen.Id;
        
		//FBox.accountHasFoxDenAccountLicense(testFoxDen);
        FBox.findById(BoxId);
        FBox.getFoxDenBoxesWhereAccountIdIsNullAndActive();
        
    }    
   
}