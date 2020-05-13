global with sharing class AssignPlanController {  
  private final Id objectId;
  
  public AssignPlanController(ApexPages.StandardController controller) {
    SObject o = controller.getRecord();    

    if(o!=null)
      this.objectId = (Id)o.get('Id');
    else
      this.objectId = ApexPages.currentPage().getParameters().get('id');
  }

  /**
  * Returns all plan assignments by salesforceId
  */
  @RemoteAction
  global static List<PlanAssignment__c> getPlanAssignments(String objectId) {
    PlanAssignment planAssignmentLookup = new PlanAssignment();
    return planAssignmentLookup.getBySObjectId(objectId);
  }

  /**
  * Returns plans that this account has setup that are assignable
  */
  @RemoteAction
  global static List<Plan__c> getPlans(String objectId) {
    Plan planLookup = new Plan();

    try{
      String sObjectApiName = Id.valueOf(objectId).getSObjectType().getDescribe().getName();

      if(sObjectApiName == 'Subscription__c'){
        Subscription__c sub = (Subscription__c) [select id, Contact__r.Account.Id from Subscription__c where id =: objectId];  
        return planLookup.getPlansByAccountIdAndBillableType(sub.Contact__r.Account.Id, 'ACCESS_CODE');
      }
      else if(sObjectApiName == 'FoxDen_User__c'){
        FoxDen_User__c user = (FoxDen_User__c) [select id, Contact__r.Account.Id from FoxDen_User__c where id =: objectId];  
        return planLookup.getPlansByAccountIdAndBillableType(user.Contact__r.Account.Id, 'FOXDEN_USER');
      }
      else if(sObjectApiName == 'S3User__c'){
        S3User__c user = (S3User__c) [select id, Contact__r.Account.Id from S3User__c where id =: objectId];  
        return planLookup.getPlansByAccountIdAndBillableType(user.Contact__r.Account.Id, 'S3_USER');
      }      
    }
    catch(Exception e){
      throw new ValidationException('A problem occured while retreiving plans for this Account: '+e.getMessage());
    }
    
    return null;    
  }

  /**
  * Remote action to end the latest plan assignment (if there is on), and start a new one.
  */
  @RemoteAction 
  global static void assignPlan(String objectId, String sDate, String rollToPlanId) {
    //Validations

    //Ensure the start date is parseable
    Date startDate = null;
    try{
      startDate = Date.parse(sDate);
    }
    catch(Exception e){
      throw new ValidationException('Invalid start date, please check, and try again.');
    }    
    
    PlanAssignment planAssignmentRepo = new PlanAssignment();
    PlanAssignment__c latestAssignment = planAssignmentRepo.getLatestPlanAssignmentBySObjectId(objectId);

    //Ensure that the start date falls between the plan start/end dates
    Plan planLookup = new Plan();
    Plan__c rollToPlan = planLookup.getById(rollToPlanId);

    if(!RTUtils.dateInRange(startDate, rollToPlan.startDate__c, rollToPlan.endDate__c))
      throw new ValidationException('Start Date conflicts with the product '+rollToPlan.name+' start/end date(s), please check, and try again.<br/> -'+rollToPlan.name+' start: '+rollToPlan.startDate__c+' end: '+rollToPlan.endDate__c);

    if(latestAssignment != null){
      //End the latest plan assignment
      new PlanAssignment.builderValidator()
        .forObject(latestAssignment)
        .set('endDate__c', startDate)
        .buildAndValidate()
        .save();   
    }

    String sObjectApiName = '';

    try{
      sObjectApiName = Id.valueOf(objectId).getSObjectType().getDescribe().getName();
    }
    catch(Exception e){
      throw new ValidationException('Invalid object type, please check, and try again.');
    }


    //Create the new plan assignment
    planAssignmentRepo.savePlanAssignment(rollToPlan.name, rollToPlan.id, sObjectApiName, objectId, startDate, rollToPlan.endDate__c);
  }

  /**
  * Returns true if none of the plan assignments have an end date of null
  */
  @RemoteAction 
  global static boolean hasNoFuturePlanAssignment(String objectId){
    PlanAssignment planAssignmentLookup = new PlanAssignment();
    List<PlanAssignment__c> planAssignments = planAssignmentLookup.getBySObjectId(objectId);
    for(PlanAssignment__c planAssignment : planAssignments){
      if(planAssignment.endDate__c==null)
        return false;
    }

    return true;
  }
      
  public Id getObjectId() {
    return this.objectId;
  }
    
}