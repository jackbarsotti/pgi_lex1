@isTest
private class testFoxDenUserController {
  
  private static SFPCTestHelper sfpcTestHelper;


  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  private static void init(){        

    sfpcTestHelper = new SFPCTestHelper();
    sfpcTestHelper.createForAccount(MockAccount.getNewAccount());
    ApexPages.currentPage().getParameters().put('retURL', sfpcTestHelper.foxDenUser.Contact__c);
  }

/*  static testMethod void testConstruct() {
    init();
    FoxDenUserController c = new FoxDenUserController();
    System.assert(c!=null);
  } */

  static testMethod void testStandardConstruct() {
    init();
    FoxDenUserController c = new FoxDenUserController(new ApexPages.StandardController(sfpcTestHelper.foxDenUser));
    System.assert(c!=null);
  }

  static testMethod void testSave() {
    init();
    FoxDenUserController c = new FoxDenUserController(new ApexPages.StandardController(sfpcTestHelper.foxDenUser));
    c.planStartDate = Date.today().format();
    c.planId = sfpcTestHelper.fdPlan.Id;
    c.isDelete=false;
    c.save();    
    System.assert(c!=null);
  }
    static testMethod void testSaveNull() {
    init();
       
    FoxDenUserController c = new FoxDenUserController(new ApexPages.StandardController(sfpcTestHelper.foxDenUser));
    c.planStartDate ='';
    c.planId = null;
    c.save();    
  //  System.assert(c.planId==null);
  }
    static testMethod void testConstruct() {
        init();
        Contact c = new Contact();
        c.LastName = 'test Contact';
        INSERT c;
        
        FoxDen_User__c FUser = new FoxDen_User__c();
        FUser.Contact__c = c.Id;
        FUser.Email__c = 'vijay@raagvitech.com';
        FUser.Name = 'test';
        FUser.Status__c = 'Pending';
        INSERT FUser;
        FoxDenUser FUserController = new FoxDenUser();
        FUserController.findById(FUser.Id);
        FoxDenUser.builderValidator ObjFuser = new FoxDenUser.builderValidator();
        ObjFuser.validate(FUser);
        
       FoxDen_User__c objUser = [SELECT Id,Name FROM FoxDen_User__c WHERE Id=: FUser.Id];
        System.assertEquals(objUser.Name, 'test');
       
    } 
 /*  static testmethod void getAccountLevelPlansTest(){
         sfpcTestHelper sf = new SFPCTestHelper();
       sf.createForAccount(MockAccount.getNewAccount());
    } */  
    static testmethod void testCustomDelete(){
        init();
         Contact c = new Contact();
        c.LastName = 'test Contact';
        INSERT c;
        
        FoxDen_User__c FUser = new FoxDen_User__c();
        FUser.Contact__c = c.Id;
        FUser.Email__c = 'vijay@raagvitech.com';
        FUser.Name = 'test';
        FUser.Status__c = 'Pending';
        FUser.Inactive__c = true;
        FUser.Date_Deleted__c= null;
        INSERT FUser;
        FoxDenUserController.customDelete(FUser.Id);
      //   Test.startTest();
     //   FoxDenUser foxDenUserRepository = new FoxDenUser(); 
    //    FoxDen_User__c user = foxDenUserRepository.findById(FUser.id);
         
        
      //  FUser.stopTest();
        system.assertEquals('Pending',FUser.Status__c );
    }
    
    static testMethod void testgetUser(){
        init();
    FoxDenUserController c = new FoxDenUserController(new ApexPages.StandardController(sfpcTestHelper.foxDenUser));
        c.getUser();
        c.getUserId();
        c.getIsDelete();
        c.getContactId();
       System.assert(c!=null);
    } 
     static testmethod void testgetAccountLevelPlans(){
         FoxDenUserController f = new FoxDenUserController();
         f.getAccountLevelPlans();
     }
}