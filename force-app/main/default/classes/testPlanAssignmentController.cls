@isTest
private class testPlanAssignmentController {  
  private static ApexPages.StandardController controller;

  static testMethod void test_Constructor() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    controller = new ApexPages.StandardController(MockFoxDenUser.getNewFoxDenUser());
    PlanAssignmentController c = new PlanAssignmentController(controller);
    System.assert(c != null);
    System.assert(c.getId() != null);
  }

  static testMethod void test_getPlanAssignments() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    controller = new ApexPages.StandardController(MockFoxDenUser.getNewFoxDenUser());
    List<PlanAssignment__c> planAssignments = PlanAssignmentController.getPlanAssignments(((FoxDen_User__c)controller.getRecord()).Id);
    System.assert(planAssignments.size()==0);
  }

  static testMethod void test_hasNoFuturePlanAssignment() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    controller = new ApexPages.StandardController(MockFoxDenUser.getNewFoxDenUser());
    Boolean hasNoFuture = PlanAssignmentController.hasNoFuturePlanAssignment(((FoxDen_User__c)controller.getRecord()).Id);
    System.assert(hasNoFuture);
  }
}