@isTest
private class testAssignPlanController {
  
  private static ApexPages.StandardController controller;
  private static SFPCTestHelper sfpcTestHelper;
  static{
    PGITestUtilities.disableSalesWings();
    
    controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Subscription__c(), MockSubscription.getNewSubscription().Id, ',Contact__r.Account.Id'));
    sfpcTestHelper = new SFPCTestHelper();
    sfpcTestHelper.createForAccount((Account) RTDatabaseUtils.getEntireSObject(new Account(), ((Subscription__c)controller.getRecord()).Contact__r.Account.Id));
  }

  //AssignPlanController.AssignPlanController
  static testMethod void testConstruct() {
    PGITestUtilities.disableSalesWings();
    AssignPlanController c = new AssignPlanController(controller);
    c.getObjectId();
    System.assert(c != null);
  }

  //AssignPlanController.getPlanAssignments
  static testMethod void testGetPlanAssignments() {
    PGITestUtilities.disableSalesWings();
    List<PlanAssignment__c> planAssignments = AssignPlanController.getPlanAssignments(((Subscription__c)controller.getRecord()).Id);
    System.assert(planAssignments != null);
  }

  //AssignPlanController.getPlans
  static testMethod void testGetPlans() {
    PGITestUtilities.disableSalesWings();
    List<Plan__c> plans = AssignPlanController.getPlans(((Subscription__c)controller.getRecord()).Id);
    System.assert(plans != null);
  }

  //AssignPlanController.assignPlan
  static testMethod void testAssignPlan() {
    PGITestUtilities.disableSalesWings();
    //Assert that assign plan doesn't throw an exception
    AssignPlanController.assignPlan(((Subscription__c)controller.getRecord()).Id, '2/1/2013', sfpcTestHelper.plan.Id);

    //Assert that once a plan is assigned, that it cannot be re-assigned for the same date range
  //  AssignPlanController.assignPlan(((Subscription__c)controller.getRecord()).Id, '2/1/2013', sfpcTestHelper.plan.Id);

    //Assert that assign plan with a bad date throws an exception
    try{
      AssignPlanController.assignPlan(((Subscription__c)controller.getRecord()).Id, '2/1/BadDate', sfpcTestHelper.plan.Id);
    }
    catch(ValidationException ve){
      System.assert(ve.getMessage().contains('Invalid start date'));
    }
  }

  //AssignPlanController.hasNoFuturePlanAssignment
  static testMethod void hasNoFuturePlanAssignment() {
    PGITestUtilities.disableSalesWings();
    Boolean tf = AssignPlanController.hasNoFuturePlanAssignment(((Subscription__c)controller.getRecord()).Id);
    System.assert(tf != null);
  }
}