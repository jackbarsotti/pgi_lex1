@isTest(SeeAllData=true)
private with sharing class testEndPlanController {

  private static ApexPages.StandardController controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Account(), MockAccount.getNewAccount().Id));
  private static SFPCTestHelper sfpcTestHelper = new SFPCTestHelper();

  static{
    PGITestUtilities.disableSalesWings();
    sfpcTestHelper.createForAccount((Account)controller.getRecord());
  }  

  //EndPlanController.EndPlanController
  static testMethod void testConstructor() {
    EndPlanController c = new EndPlanController(controller);
    c.getPlanId();
    c.getAccountId();
    System.assert(c != null);
  }

  //EndPlanController.getPlan
  static testMethod void testGetPlan() {
    Plan__c plan = EndPlanController.getPlan(sfpcTestHelper.plan.Id);
    System.assert(plan != null);
  }

  //EndPlanController.findNumberOnPlan
  static testMethod void testFindNumberOnPlan() {
    Integer numOnPlan = EndPlanController.findNumberOnPlan(((Account)controller.getRecord()).Id, sfpcTestHelper.plan.Id);
    System.assert(numOnPlan != null);
  }

  //EndPlanController.getPlans
  static testMethod void testGetPlans() {
    List<Plan__c> plans = EndPlanController.getPlans(((Account)controller.getRecord()).Id, sfpcTestHelper.plan.Id);
    System.assert(plans != null);
  }

  //EndPlanController.endPlan
  static testMethod void testEndPlan() {
    //Assert that we can end a plan
    EndPlanController.endPlan(sfpcTestHelper.plan.Id, '2/1/3013', sfpcTestHelper.unassignedPlan.Id);

    //Assert that a bad planId throws an error
    try{
      EndPlanController.endPlan(null, '2/1/2013', sfpcTestHelper.unassignedPlan.Id);
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('Please select a product to end'));
    }

    //Assert that a null end date throws an error
    try{
      EndPlanController.endPlan(sfpcTestHelper.plan.Id, null, sfpcTestHelper.unassignedPlan.Id);      
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('Please specify a Product End Date'));
    }

    //Assert that a bad end date throws an error
    try{
      EndPlanController.endPlan(sfpcTestHelper.plan.Id, 'fooEndDate', sfpcTestHelper.unassignedPlan.Id);      
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('A valid end date must be specified'));
    }    
  }
}