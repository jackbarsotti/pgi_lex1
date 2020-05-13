@isTest
private class testAddPlanController {

  private static ApexPages.StandardController controller;
  private static SFPCTestHelper sfpcTestHelper;
  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  private static void init(){       
    controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), MockAccount.getNewAccount().Id));
    sfpcTestHelper = new SFPCTestHelper();
    sfpcTestHelper.createForAccount((Account)controller.getRecord());
  }

  //AddPlanController.AddPlanController
  static testMethod void testConstruct() {
    init();
    //Assert that we can construct a new AddPlanController and call getters
    AddPlanController c = new AddPlanController(controller);
    c.packageSelect();
    c.getAccountId();
    c.getAssignedPackage();
    c.getAssignedPlan();
    c.getProductsWithCustomSchedules();
    c.getQuantityEnabled();
    System.assert(c != null);
  }

  //AddPlanController.getPackageItems
  static testMethod void testGetPackageItems() {
    init();
    //Simple assertion to make sure we can make a call to getPackageItems()
    AddPlanController c = new AddPlanController(controller);
    System.assert(c.getPackageItems() != null);
  }

  //AddPlanController.getProducts
  static testMethod void testGetProducts() {
    init();
    //Assert that we can call getPRoducts() method
    AddPlanController c = new AddPlanController(controller);
    System.assert(c.getProducts() != null);
  }

  //AddPlanController.addPlan
  static testMethod void testAddPlan() {
    init();
    //Assert that adding a fresh plan returns true
    String accountId = ((Account)controller.getRecord()).Id;
    String packageId = sfpcTestHelper.unassignedPackage2.Id;
    System.assert(AddPlanController.addPlan(accountId, packageId, 'A Plan','INVOICE', '4/1/2013', null, null, null, '{"products":['+
      '{"productName":"A Product", "id":"'+sfpcTestHelper.unassignedProduct.Id+'","singleCharge":"0.00", "recurringCharge":"50.00", "recurringChargeFrequency":"INVOICE", "schedule":"'+sfpcTestHelper.schedule.name+'"}'+
    ']}'));
  }

  static testMethod void testAddPlanQuantityValidations() {
    init();
    //Assert that adding a fresh plan returns true
    String accountId = ((Account)controller.getRecord()).Id;
    String packageId = sfpcTestHelper.quantityPkg.Id;
    try {
      AddPlanController.addPlan(accountId, packageId, 'A Plan','INVOICE', '4/1/2013', null, null, null, '{"products":['+
              '{"productName":"A Product", "id":"'+sfpcTestHelper.unassignedProduct.Id+'","singleCharge":"0.00", "recurringCharge":"50.00", "recurringChargeFrequency":"INVOICE", "schedule":"'+sfpcTestHelper.schedule.name+'"}'+
              ']}');
    } catch (Exception e) {
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: Quantity is a required field.') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }

    try {
      AddPlanController.addPlan(accountId, packageId, 'A Plan','INVOICE', '4/1/2013', null, '0', null, '{"products":['+
              '{"productName":"A Product", "id":"'+sfpcTestHelper.unassignedProduct.Id+'","singleCharge":"0.00", "recurringCharge":"50.00", "recurringChargeFrequency":"INVOICE", "schedule":"'+sfpcTestHelper.schedule.name+'"}'+
              ']}');
    } catch (Exception e) {
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: Quantity must be greater than 0.') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }

  }
}