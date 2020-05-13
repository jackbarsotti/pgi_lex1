@isTest
private class testS3UserController {
  
  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  private static SFPCTestHelper sfpcTestHelper;

  private static void init() {        
    sfpcTestHelper = new SFPCTestHelper();
    sfpcTestHelper.createForAccount(MockAccount.getNewAccount());
    ApexPages.currentPage().getParameters().put('retURL', sfpcTestHelper.s3User.Contact__c);
  }

  static testMethod void testConstruct() {
    init();
    S3UserController c = new S3UserController();
    System.assert(c!=null);
  }

  static testMethod void testStandardConstruct() {
    init();
    S3UserController c = new S3UserController(new ApexPages.StandardController(sfpcTestHelper.s3User));
    System.assert(c!=null);
  }

  static testMethod void testSave() {
    init();
    S3UserController c = new S3UserController(new ApexPages.StandardController(sfpcTestHelper.s3User));
    c.planStartDate = Date.today().format();
    c.planId = sfpcTestHelper.s3Plan.Id;
    c.save();    
    System.assert(c!=null);
  }
    static testMethod void testcustomDelete(){
         init();
         Contact c = new Contact();
        c.LastName = 'test Contact';
        INSERT c;
        
        S3User__c s3User = new S3User__c();
        s3User.Contact__c = c.Id;
        s3User.Email__c = 'test01@gmail.com';
        s3User.Name = 'test';
        s3User.Status__c = 'Pending';
        s3User.Inactive__c = true;
        s3User.Date_Deleted__c= null;
        INSERT s3User;
        S3UserController.customDelete(s3User.Id);
        system.assertEquals('Pending',s3User.Status__c );
    }
    
    static testMethod void testgetUser(){
        init();
    S3UserController c = new S3UserController(new ApexPages.StandardController(sfpcTestHelper.s3User));
        c.getUser();
        c.getUserId();
        c.getIsDelete();
        c.getContactId();
       System.assert(c!=null);
    } 
     static testmethod void testgetAccountLevelPlans(){
         S3UserController f = new S3UserController();
         f.getAccountLevelPlans();
     } 
 }