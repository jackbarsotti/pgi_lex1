@isTest
private class testContactChangeBillingDepartment {
    
    //private static ApexPages.StandardController controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Contact(), MockContact.getNewContact().Id));
    
    private static ApexPages.StandardController controller;

    static{
        PGITestUtilities.disableSalesWings();
        controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Contact(), MockContact.getNewContact().Id));
        ApexPages.currentPage().getParameters().put('id', ((Contact)controller.getRecord()).Id);
    }
    
    //ContactChangeBillingDepartmentController.ContactChangeBillingDepartmentController
    static testMethod void testConstruct() {
        ContactChangeBillingDepartmentController c = new ContactChangeBillingDepartmentController(controller);
        c.cancel();
        c.setContact((Contact)controller.getRecord());
        c.getContact();
    }
    
    //ContactChangeBillingDepartmentController.getDepartments
    static testMethod void testGetDepartments() {
        //Assert that we can call getDepartments
        ContactChangeBillingDepartmentController c = new ContactChangeBillingDepartmentController(controller);
        List<Department__c> departments = c.getDepartments();
        System.assert(departments != null);
    }
    
    //ContactChangeBillingDepartmentController.save
    static testMethod void testSave() {
        //Assert that we can call save
        ContactChangeBillingDepartmentController c = new ContactChangeBillingDepartmentController(controller);
        c.save();
    }
}