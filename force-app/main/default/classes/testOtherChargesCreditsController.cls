@isTest
private class testOtherChargesCreditsController {
    private static ApexPages.StandardController controller;
    
    static {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Test.stopTest();
        controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new OtherChargeCredit__c(), MockOtherChargeCredit.getNewOtherChargeCredit().id));
        ApexPages.currentPage().getParameters().put('id', MockOtherChargeCredit.getNewOtherChargeCredit().id);        
    }
    
    static testMethod void testConstruct() {
        OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c!=null);
    }
    
    static testMethod void testSave() {
        OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c.save()!=null);
    }
    
    static testMethod void testCustomDelete() {
        OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c.customDelete()!=null);
    }
    
   static testMethod void testCheckBilledStatus() {
      //  OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
   //     System.assert(c.checkBilledStatus()==null);
        
  //      ApexPages.currentPage().getParameters().put('delID', MockOtherChargeCredit.getNewOtherChargeCredit().id);
       OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c.checkBilledStatus()==null); 
    } 
    
    static testMethod void testGetOtherChargeCredit() {
        OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c.getOtherChargeCredit()!=null);        
    }
    
    static testMethod void testGoBack() {
        OtherChargesCreditsController c = new OtherChargesCreditsController(controller);
        System.assert(c.goBack()!=null);        
    }

    
}