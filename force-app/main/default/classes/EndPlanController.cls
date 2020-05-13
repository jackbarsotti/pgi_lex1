global with sharing class EndPlanController extends BaseController {
  private Id accountId;   
  private Id planId;

  public EndPlanController(ApexPages.StandardController controller) {
    this.accountId = ApexPages.currentPage().getParameters().get('id');    
    this.planId = ApexPages.currentPage().getParameters().get('planId');
  }

  /**
  * Return a plan; look up by Id
  */
  @RemoteAction
  global static Plan__c getPlan(String planId){
    Plan planLookup = new Plan();
    return planLookup.getById(planId);
  }

  /**
  * Return the number of access codes on a plan
  */
  @RemoteAction
  global static Integer findNumberOnPlan(String accountId, String planId) {
    Plan planLookup = new Plan();
    return planLookup.getActiveAccessCodes(planId);    
  }

  /**
  * Returns all plans, except the planId provided
  */
  @RemoteAction
  global static List<Plan__c> getPlans(String accountId, String planId){
    List<Plan__c> returnPlans = new List<Plan__c>();    
    Plan planLookup = new Plan();

    List<Plan__c> plans = planLookup.getPlansByAccountIdAndBillableType(accountId, 'ACCESS_CODE');     
    for(Plan__c plan : plans){
      if(plan.id != planId && plan.endDate__c == null){
        returnPlans.add(plan);
      }
    }

    return returnPlans;
  }

  /**
  * End a plan
  */
  @RemoteAction
  global static void endPlan(String planId, String planEndDate, String rollToPlanId) {
    //Validations:
    //Validate the planId
    if(planId==null || planId.trim().length()<=0)
      throw new ValidationException('Please select a product to end.');

    //Validate the planEndDate
    if(planEndDate==null || planEndDate.trim().length()<=0)
      throw new ValidationException('Please specify a Product End Date.');

    Date endDate = null;
    try{
      endDate = Date.parse(planEndDate);
    }
    catch(Exception e){
      throw new ValidationException('A valid end date must be specified.');
    }

    //Get the plan to delete
    Plan planLookup = new Plan();
    Plan__c plan = planLookup.getById(planId);
    Boolean isDefaultPlan = plan.isDefault__c;

    if(plan.startDate__c.daysBetween(endDate) <0 )
      throw new ValidationException('End date of the product cannot be before the start date.');

    //Validate that no plan assignments exist with a starting date that is after the end date.
    PlanAssignment planAssignmentLookup = new PlanAssignment();
    List<PlanAssignment__c> planAssignments = planAssignmentLookup.getByPlanId(planId);
    for(PlanAssignment__c planAssignment : planAssignments){
      if(endDate.daysBetween(planAssignment.startDate__c) > 0){        
        throw new ValidationException('Cannot end product! Object of type '+planAssignment.sObjectApiName__c+' with id ' +planAssignment.sObjectId__c+' is scheduled to start after the plan end date!');
      }
    }

    //Update the plan -- set the isDefault flag to false (if it's set)
    new Plan.builderValidator()
      .forObject(plan)
      .set('endDate__c', endDate)
      .set('isDefault__c', isDefaultPlan==true ? false : false)
      .buildAndValidate()
      .save(); 
 
    //If rollToPlanId is null, then we are done, no need to update plan assignments
    if(rollToPlanId==null){
      return;
    }

    Plan__c rollToPlan = planLookup.getById(rollToPlanId);

    //Validate that the plan end date is greater than or equal to the start date of the rollToPlan start
    if(endDate.daysBetween(rollToPlan.startDate__c) > 0)
      throw new ValidationException('End date cannot be before the product start date.'); 

    //Otherwise, we must update the plan, and all plan assignments, and start new ones
    PlanAssignmentActions.rollPlanAssignmentsToNewPlan(planAssignments, rollToPlan, endDate);

  }

  public String getPlanId() {
    return this.planId;
  }

  public String getAccountId() {
    return this.accountId;
  } 
}