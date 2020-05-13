trigger SubscriptionBeforeInsertBeforeUpdate on Subscription__c (before insert, before update) {
  if (Trigger.isUpdate) {
    Map<Id, Subscription__c> newSubsMap = Trigger.newMap;
    Map<Id, Subscription__c> oldSubsMap = Trigger.oldMap;
    Set<Id> newSubIds = newSubsMap.keySet();
    for (Id updatedSub : newSubIds) {
      System.debug('Checking if we should send an email... sub id ' + updatedSub);
      try {
        Boolean emailSent = SubscriptionActions.sendProvisioningEmailIfNeeded(newSubsMap.get(updatedSub), oldSubsMap.get(updatedSub));
        if (emailSent) {
          System.debug('Provisioning email sent for Suscription ' + updatedSub);
          newSubsMap.get(updatedSub).ProvisioningEmailSent__c = Datetime.now();
        }
      } catch (EmailException e) {
        for (Integer i = 0 ; i < e.getNumDml(); i++) {
          newSubsMap.get(updatedSub).addError(' Please correct provisioning email address. ' + e.getDmlMessage(i));
        }
        return;

      } catch (Exception e) {
        newSubsMap.get(updatedSub).addError( ' ' + e.getMessage());
        return;
      }
    }
  }
}