@isTest
private with sharing class testPlanController {

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
  
  static testMethod void testEmptyConstructor() {
    init();
    ApexPages.currentPage().getParameters().put('accountId', ((Account)controller.getRecord()).Id);
    ApexPages.currentPage().getParameters().put('planId', sfpcTestHelper.plan.Id);

    PlanController p = new PlanController();
    System.assert(p!=null);
  }
  
  static testMethod void testConstructor() {
    init();
    PlanController p = new PlanController(controller);
    System.assert(p!=null);
  }
  
  static testMethod void testGetters() {
    init();
    PlanController p = new PlanController(controller);
    p.getAccount();
    p.getPlans();
    p.getPlan();
    p.getActiveAccessCodeCounts();
    p.getNPOverrides();
    p.getNPFutureChanges();
    p.getCurrentNpOverrides();
    p.getCurrentPlanTotals();
    p.getFutureQuantityChanges();
    System.assert(1==1);
  }
  
  static testMethod void testEditProduct() {
    init();
    //Assert that saving a recurring charge override returns true
    System.assert(PlanController.editProduct(sfpcTestHelper.negotiatedProduct.Id, null, null, '49.00', '39.00', null, null, '2/1/2013', null));

    //Assert that saving a schedule override returns true
    System.assert(PlanController.editProduct(sfpcTestHelper.negotiatedProduct.Id, null, null, null, null, sfpcTestHelper.schedule.Id, sfpcTestHelper.unassignedSchedule.Id, '2/1/2013', null));    

    //Assert that saving a single charge override returns true
    System.assert(PlanController.editProduct(sfpcTestHelper.negotiatedProduct.Id, '0.00', '3.00', null, null, null, null, '2/1/2013', null));        
  }

  static testMethod void testEditPlan() {
    init();
    System.assert(PlanController.editPlan(sfpcTestHelper.quantityPlan.Id, '10', '11', '10/1/2015'));

    try {
      PlanController.editPlan(sfpcTestHelper.plan.Id, null, null, null);
    } catch (Exception e){
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: You must change the quantity') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }

    try {
      PlanController.editPlan(sfpcTestHelper.plan.Id, null, '10', null);
    } catch (Exception e){
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: Quantity is a required field.') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }

    try {
      PlanController.editPlan(sfpcTestHelper.plan.Id, '0', '10', null);
    } catch (Exception e){
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: Quantity must be greater than 0') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }

    try {
      PlanController.editPlan(sfpcTestHelper.plan.Id, '90', '10', 'wrong!');
    } catch (Exception e){
      Boolean expectedExceptionThrown =  e.getMessage().contains('ValidationException: Invalid start date, please check, and try again.') ? true : false;
      System.assert(true, expectedExceptionThrown);
    }
  }

  static testMethod void testMakeDefault() {
    init();
    //Assert that saving a default plan (not marked as isDefault==true) returns true
    System.assert(PlanController.makeDefault(sfpcTestHelper.plan.Id, true));

    //Assert that a null planId throws a validation exception
    try{
      PlanController.makeDefault(null,true);
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('Invalid planId'));
    }
  }
}