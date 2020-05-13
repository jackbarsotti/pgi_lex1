@isTest
private class testAccessCodeController {
    
    static {
         PGITestUtilities.disableSalesWings();
        ApexPages.currentPage().getParameters().put('id', MockContact.getNewContact().id);
    }

    static testMethod void testConstructStandardController() {
        Subscription__c s = MockSubscription.getNewSubscription();
        ApexPages.Standardcontroller sc  = new Apexpages.Standardcontroller(s);
        CreateCase noConstructCtr = new CreateCase();
        AccessCodeController c = new AccessCodeController(sc);
        System.assert(c!=null);
    }
    
    static testMethod void testConstruct() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c!=null);
    }
       
    static testMethod void testCheckContactStatus() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.checkContactStatus()==null);        
    }
    
    static testMethod void testCheckContactStatusDeleted() {
        ApexPages.currentPage().getParameters().put('delID',MockSubscription.getNewSubscription().id);
        AccessCodeController c = new AccessCodeController();
        System.assert(c.checkContactStatus()!=null);
    }
    
    static testMethod void testGetDependentPicklistItemsToll() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.getDependentPicklistItemsToll()!=null);
    }
    
    static testMethod void testGetPicklistItemsTollFree() {
    	AccessCodeController c = new AccessCodeController();
    	System.assert(c.getPicklistItemsTollFree() != null);
    }
    
    static testMethod void testGetDependentPicklistItemsKit() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.getDependentPicklistItemsKit()!=null);
    }
    
    static testMethod void testPollContactStatus() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.pollContactStatus()==null);
    }
    
    static testMethod void testGetSubscription() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.getSubscription()!=null);
    }
       
    static testMethod void testGetWaitDialog() {
        AccessCodeController c = new AccessCodeController();
        c.setWaitDialogContent();
        System.assert(c.getWaitDialog()!=null);        
    }
    
    static testMethod void testGetAdministratorInformationTitle() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.getAdministratorInformationTitle()!=null);
    }
    
    static testMethod void testSave() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.save()==null);
    }
    
    static testMethod void testSaveThenNew() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.saveThenNew()!=null);
    }

    // static testMethod void testgetstatusmessage() {
    //     AccessCodeController c = new AccessCodeController();
    //     String subId = c.getSubscriptionId();
    //     System.assert(AccessCodeController.getStatusMessage(subId) != null);
    // }

    static testMethod void testrestore() {
        AccessCodeController c = new AccessCodeController();
        String subId = c.getSubscriptionId();
        System.assert(AccessCodeController.restore(subId)!=null);
    }
    
    static testMethod void testCustomDelete() {
        ApexPages.currentPage().getParameters().put('delID',MockSubscription.getNewSubscription().id);
        AccessCodeController c = new AccessCodeController();
        System.assert(c.customDelete()!=null);
    }
    
    static testMethod void testGotoEdit() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.gotoEdit()!=null);
    }
    
    static testMethod void testgetAccountLevelPlans() {
        AccessCodeController c = new AccessCodeController();
        System.assert(c.getAccountLevelPlans()!=null);
    }
    static testMethod void testSetIsValidContact() {
        AccessCodeController c = new AccessCodeController();
        c.setIsValidContact(true);
        System.assert(c.isValidContact()==true);        
    }
    
}