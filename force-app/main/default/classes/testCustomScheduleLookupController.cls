@isTest(SeeAllData=true)
public with sharing class testCustomScheduleLookupController {
    private static ApexPages.StandardController controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), MockAccount.getNewAccount().Id));
    private static SFPCTestHelper sfpcTestHelper = new SFPCTestHelper();
    static{
        PGITestUtilities.disableSalesWings();
        sfpcTestHelper.createForAccount((Account)controller.getRecord());
    }
    
    static testMethod void testConstructor() {
        Account account = (Account) controller.getRecord();
        System.currentPageReference().getParameters().put('accountId', account.id);
        
        CustomScheduleLookupController c = new CustomScheduleLookupController();
        System.assert(c!=null);
        
        c = new CustomScheduleLookupController(controller);
        System.assert(c!=null);
    }
    
    //CustomScheduleLookupController.makeDefault
    static testMethod void testMakeDefault() {
        //Assert that makeDefault returns true (after making the custom schedule default)
        System.assert(CustomScheduleLookupController.makeDefault(sfpcTestHelper.customSchedule.Id, true));
    }
    
    static testMethod void testSearch() {
        Account account = (Account) controller.getRecord();
        System.currentPageReference().getParameters().put('accountId', account.id);
        
        CustomScheduleLookupController c = new CustomScheduleLookupController(controller);
        
        //Frivolous test to assure that the returned PageReference is null
        System.assert(c.search() == null);
    }  
    
    static testMethod void testGetters() {
        Account account = (Account) controller.getRecord();
        System.currentPageReference().getParameters().put('accountId', account.id);
        
        CustomScheduleLookupController c = new CustomScheduleLookupController();
        System.currentPageReference().getParameters().put('frm', 'frm');
        System.currentPageReference().getParameters().put('txt', 'txt');
        System.assert(c.getFormTag() == 'frm');
        System.assert(c.getTextBox() == 'txt');
    }  
}