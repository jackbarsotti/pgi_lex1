@isTest
private class FoxDenBoxControllerTest {
    
    private static ApexPages.StandardController controller = new ApexPages.StandardController(new FoxDen_Box__c());
    
    static testMethod void testConstruct() {
       FoxDenBoxController b = new FoxDenBoxController(controller);
       b.getBox();
       b.getBoxId();
       b.getIsDelete();
    }    
    static testMethod void testcustomDelete() {
       
        FoxDen_Box__c testFoxDen = new FoxDen_Box__c();
        testFoxDen.Beacon_Minor_Value__c = 3;
        testFoxDen.Beacon_Id__c = 'test';
        testFoxDen.Beacon_Major_Value__c = 7;
        testFoxDen.Kiosk_Email__c = 'vijay@raagvitech.com';
        testFoxDen.Password__c = 'testPass';
        testFoxDen.sku__c = 'testUniqueKey';
        testFoxDen.Status__c = 'Active';
        INSERT testFoxDen;
        String BoxId = testFoxDen.Id;
       FoxDenBoxController.customDelete(BoxId);
        FoxDen_Box__c Box = [SELECT Id,Status__c FROM FoxDen_Box__c WHERE Id =: testFoxDen.Id];
            System.assertEquals(Box.Status__c, 'Deleting');
        
    }   
}