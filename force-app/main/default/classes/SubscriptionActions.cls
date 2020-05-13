public class SubscriptionActions {

  /**
  * Update plan assignments when a Subscription__c record is updated.
  */
  public static void updatePlanAssignments(Map<Id, Subscription__c> newSubsMap, Map<Id, Subscription__c> oldSubsMap){
    //Perform 1 SOQL query that retrieves PlanAssignments for every Subscription__c in newsubs
    Set<Id> newSubIds = newSubsMap.keySet();
    PlanAssignment planAssignmentRepository = new PlanAssignment();
    List<PlanAssignment__c> planAssignments = planAssignmentRepository.getWhereSObjectIdInSet(newSubIds);

    //Update all of the planAssignments
    Database.update(planAssignments);
  }

  /**
  * Update all related RTEvent Coordinator_Notes_New__c and Event_Manager_Notes_New__c when a Subscription__c record is updates
  */
  public static void updateRTEventNotes(Map<Id, Subscription__c> newSubsMap, Map<Id, Subscription__c> oldSubsMap){
    Set<Id> newSubIds = newSubsMap.keySet();

    if(newSubIds.size() > 0){
      //Get all of the RTEvent__c objects under this subscription(s)
      List<RTEvent__c> events = (List<RTEvent__c>) [select Coordinator_Notes_New__c, Event_Manager_Notes_New__c, Access_Code__c from RTEvent__c where Access_Code__c in :newSubIds];
      
      //Modify the values
      for(RTEvent__c event : events){
        event.Coordinator_Notes_New__c = newSubsMap.get(event.Access_Code__c).Coordinator_Notes_New__c;
        event.Event_Manager_Notes_New__c = newSubsMap.get(event.Access_Code__c).Event_Manager_Notes_New__c;
      }

      //Update all of the events
      Database.update(events);
    }
  }

  /**
  * Determines whether or not subscriptions need to get a provisioning email
  */
  public static boolean sendProvisioningEmailIfNeeded(Subscription__c newSub, Subscription__c oldSub) {
    if(ProvisioningEmailHelper.needsProvisioningEmail(newSub, oldSub)) {
      Contact contact = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), newSub.Contact__c, ',Account.Id');
      Account acct = (Account) RTDatabaseUtils.getEntireSObject(new Account(), contact.Account.Id);
      
      String templateDevName = 'Provisioning_BBS';
      if(acct.Provisioning_Email_Template_Override__c != null) {
        EmailTemplate template = [SELECT Id, DeveloperName from EmailTemplate where Name = :acct.Provisioning_Email_Template_Override__c];
        if(template != null) {
          templateDevName = template.DeveloperName;
        } else {
          newSub.addError('Invalid Provisioning Email Template specified for Account.');
        }
      }
    
      return ProvisioningEmailHelper.sendProvisioningEmail(newSub, templateDevName);
    } else {
      return false;
    }
  }  
}