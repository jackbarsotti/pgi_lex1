public class SubscriptionTriggerHandler extends TriggerHandler {
  public SubscriptionTriggerHandler() {
    super('SubscriptionTriggerHandler');
  }
    protected override void beforeUpdate() {
        SubscriptionBeforeInsertBeforeUpdate();
        checkAudioPortChange();
    }
    protected override void afterInsert() {
        SubscriptionAfterInsertAfterUpdate();
    }
    protected override void afterUpdate() {
     	  SubscriptionAfterInsertAfterUpdate();
    }

    private void checkAudioPortChange() {
      for(Subscription__c sub: (List<Subscription__c>)Trigger.new) {
        Subscription__c oldSub = (Subscription__c)Trigger.oldMap.get(sub.Id);
        if(sub.Revert_Last_Subscription_Values__c == true) {
            sub.Revert_Last_Subscription_Values__c = false;
            sub.Audio_subscription_size__c = sub.Last_Number_of_Audio_Ports__c;
            sub.Last_Change_Date_for_Audio_Ports__c = null;
            sub.Last_Number_of_Audio_Ports__c = null;
        } else if(isChanged('Audio_subscription_size__c', sub)) {
          if(sub.Audio_subscription_size__c != sub.Last_Number_of_Audio_Ports__c) {
            sub.Last_Number_of_Audio_Ports__c = oldSub.Audio_subscription_size__c;
            sub.Last_Change_Date_for_Audio_Ports__c = System.today();
          } else {
            sub.Revert_Last_Subscription_Values__c = false;
            sub.Last_Change_Date_for_Audio_Ports__c = null;
            sub.Last_Number_of_Audio_Ports__c = null;
          }
        }
      }
    }

    private void SubscriptionBeforeInsertBeforeUpdate() {
    	Map<Id, Subscription__c> newSubsMap = (Map<Id,Subscription__c>)Trigger.newMap;
    	Map<Id, Subscription__c> oldSubsMap = (Map<Id,Subscription__c>)Trigger.oldMap;
    	Set<Id> newSubIds = newSubsMap.keySet();
    	for(Id updatedSub : newSubIds) {
      		System.debug('Checking if we should send an email... sub id ' + updatedSub);
      		try {
        		Boolean emailSent = SubscriptionActions.sendProvisioningEmailIfNeeded(newSubsMap.get(updatedSub), oldSubsMap.get(updatedSub));
        		if(emailSent) {
          			System.debug('Provisioning email sent for Suscription ' + updatedSub);
          			newSubsMap.get(updatedSub).ProvisioningEmailSent__c = Datetime.now();
        		}
      		} catch(EmailException e) {
        		for(Integer i = 0 ; i < e.getNumDml(); i++) {
          			newSubsMap.get(updatedSub).addError(' Please correct provisioning email address. ' + e.getDmlMessage(i));
        		}
        		return;

      		} catch (Exception e) {
        		newSubsMap.get(updatedSub).addError( ' ' + e.getMessage());
        		return;
      		}
    	}
    }

    private void SubscriptionAfterInsertAfterUpdate() {
    	//Update Plan Assignments after update
    	SubscriptionActions.updatePlanAssignments((Map<Id,Subscription__c>)Trigger.newMap, (Map<Id,Subscription__c>)Trigger.oldMap);
    	SubscriptionActions.updateRTEventNotes((Map<Id,Subscription__c>)Trigger.newMap, (Map<Id,Subscription__c>)Trigger.oldMap);
    }
}