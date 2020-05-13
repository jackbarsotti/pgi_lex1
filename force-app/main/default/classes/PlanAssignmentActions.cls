public with sharing class PlanAssignmentActions {

  /**
  * Rolls (moves) all PlanAssignments from one plan to another.
  * Should be governor safe
  * planAssignments: A List of PlanAssignment__c objects to move
  * rollToPlan: Plan__c object of the new plan
  * startDate: The date to end the old PlanAssignment and the date to start he new PlanAssignment
  */
  public static void rollPlanAssignmentsToNewPlan(List<PlanAssignment__c> planAssignments, Plan__c rollToPlan, Date startDate){
    //Process:
    //0. We cannot blindly end a plan assignment and start a new one, we need to validate first
    //1. Build a set of subscription__c ids that are in the planAssignments list
    //2. From those subscription__c records, retrieve all other planAssignments (to validate that there is no overlap)
    //3. For each planAssignment, validate, then add the ended planAssignment to a list and the new planAssignment to a separate list
    //4. Update and insert
    // Add all subscription__c ids into a collection
    Set<Id> subscriptionIds = new Set<Id>();
    for(PlanAssignment__c planAssignment : planAssignments){
      subscriptionIds.add(planAssignment.sObjectId__c);
    }

    //Select all PlanAssignments for all subscriptions that are in the PlanAssignments list
    //i.e. all PlanAssignment__c objects where sObjectId__c in set of planAssignments id's
    PlanAssignment planAssignmentRepo = new PlanAssignment();
    List<PlanAssignment__c> allPlanAssignments = planAssignmentRepo.getWhereSObjectIdInSet(subscriptionIds);

    Map<Id, List<PlanAssignment__c>> subscriptionIdToPlanAssignments = new Map<Id, List<PlanAssignment__c>>();
    for(PlanAssignment__c pa : allPlanAssignments){

      if(subscriptionIdToPlanAssignments.get(pa.sObjectId__c)==null)
        subscriptionIdToPlanAssignments.put(pa.sObjectId__c, new List<PlanAssignment__c>());
      else
        subscriptionIdToPlanAssignments.get(pa.sObjectId__c).add(pa);
    }

    //Two lists, one for plans to end, and one for new plans
    List<PlanAssignment__c> plansToEnd = new List<PlanAssignment__c>();
    List<PlanAssignment__c> plansToCreate = new List<PlanAssignment__c>();

    //Loop through PlanAssignments
    for(PlanAssignment__c planAssignment : planAssignments){
      //Validations: 
      //If PlanAssignment endDate != null, then continue (no need to end, it's already eneded)
      if(planAssignment.endDate__c != null){
        continue;
      }

      //Ensure that the new PlanAssignment will not overlap an existing PlanAssignment (disregard the current PlanAssignment)
      PlanAssignment.builderValidator validator = new PlanAssignment.builderValidator();
      validator.datesCannotOverlap(planAssignment, subscriptionIdToPlanAssignments.get(planAssignment.sObjectId__c));          

      //Actions:
      //End PlanAssignment as of startDate (skip standard validation)
      PlanAssignment__c planToEnd = (PlanAssignment__c) new PlanAssignment.builderValidator()
        .forObject(planAssignment)
        .set('endDate__c', startDate)
        .getObject();

      //Create new PlanAssignment with startDate (skip standard validation)
      PlanAssignment__c planToCreate = (PlanAssignment__c) new PlanAssignment.builderValidator()
        .forObject(new PlanAssignment__c())
        .set('name', rollToPlan.name)
        .set('plan__c', rollToPlan.id)
        .set('sObjectApiName__c', planAssignment.sObjectApiName__c)
        .set('sObjectId__c', planAssignment.sObjectId__c)
        .set('accessCode__c', planAssignment.accessCode__c)
        //.set('Contact__c', planAssignment.Contact__c)
        .set('startDate__c', startDate)
        .set('endDate__c', null)
        .getObject();

      plansToEnd.add(planToEnd);
      plansToCreate.add(planToCreate);    
    } 

    //Update items in plansToEnd
    Database.update(plansToEnd);

    //Insert items in plansToCreate
    Database.insert(plansToCreate);     
  }
}