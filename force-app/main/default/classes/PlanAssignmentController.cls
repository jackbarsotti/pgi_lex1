global with sharing class PlanAssignmentController {  
  private final Id id;
  
  public PlanAssignmentController(ApexPages.StandardController controller) {
    SObject o = controller.getRecord();    

    if(o!=null)
      this.id = (Id)o.get('Id');
    else
      this.id = ApexPages.currentPage().getParameters().get('id');
  }

  /**
  * Returns all plan assignments for any object
  */
  @RemoteAction
  global static List<PlanAssignment__c> getPlanAssignments(String id) {
    PlanAssignment planAssignmentLookup = new PlanAssignment();
    return planAssignmentLookup.getBySObjectId(id);
  }

  /**
  * Returns true if none of the plan assignments have an end date of null
  */
  @RemoteAction 
  global static boolean hasNoFuturePlanAssignment(String id){
    PlanAssignment planAssignmentLookup = new PlanAssignment();
    List<PlanAssignment__c> planAssignments = planAssignmentLookup.getBySObjectId(id);

    for(PlanAssignment__c planAssignment : planAssignments){
      if(planAssignment.endDate__c==null){
        return false;
      }
    }

    return true;
  }

  public Id getId() {
    return this.id;
  }  
}