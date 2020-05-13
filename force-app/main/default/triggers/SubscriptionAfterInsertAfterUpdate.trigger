trigger SubscriptionAfterInsertAfterUpdate on Subscription__c (after insert, after update) {      

  //Update Plan Assignments after update
  if(Trigger.isUpdate){
    SubscriptionActions.updatePlanAssignments(Trigger.newMap, Trigger.oldMap);
    SubscriptionActions.updateRTEventNotes(Trigger.newMap, Trigger.oldMap);
  }  
}