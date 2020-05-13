@isTest
private class testDepartmentController {
    static {
        Test.startTest();
        PGITestUtilities.disableSalesWings();
        Test.stopTest();
        ApexPages.currentPage().getParameters().put('id', MockAccount.getNewAccount().id);
    }
    
    static testMethod void testConstruct() {
        DepartmentController d = new DepartmentController();
        System.assert(d!=null);        
        
        ApexPages.currentPage().getParameters().put('delID', MockDepartment.getNewDepartment().id);
        d = new DepartmentController();
        System.assert(d!=null);        
    }
    
    static testMethod void testCustomDelete() {
        ApexPages.currentPage().getParameters().put('delID', MockDepartment.getNewDepartment().id);
        ApexPages.currentPage().getParameters().put('retURL', '/'+MockContact.getNewContact().id);
        DepartmentController d = new DepartmentController();
        System.assert(d.customDelete()!=null);
    }
    
    static testMethod void testGetDependentPicklistItemsKitNumbers() {
        DepartmentController d = new DepartmentController();
        System.assert(d.getDependentPicklistItemsKitNumbers()!=null);
    }
    
    static testMethod void testSave() {
        DepartmentController d = new DepartmentController();
        System.assert(d.save()!=null);
    }
    
    static testMethod void testSaveThenNew() {
        DepartmentController d = new DepartmentController();
        System.assert(d.saveThenNew()!=null);
    }
    
    static testMethod void testCancelDelete() {
        DepartmentController d = new DepartmentController();
        System.assert(d.cancelDelete()!=null);
    }
}