@RestResource(urlMapping = '/PlanAssignment/*')
global with sharing class PlanAssignmentRest {

  @HttpPost
  global static boolean addPlanAssignment(String subscriptionId, String startDate, String planName) {
    List<Plan__c> plans = AssignPlanController.getPlans(subscriptionId);
    String planId = null;

    for(Plan__c plan : plans){
      if(plan.Name == planName){
        planId = plan.Id;
      }
    }

    if(planId == null)
      throw new ValidationException('Cannot add plan assignment to subscription with Id: '+subscriptionId+' because plan with name: '+planName+' does not exist on this Account');

    AssignPlanController.assignPlan(subscriptionId, startDate, planId);

    return true;
  }
}