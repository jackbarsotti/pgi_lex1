trigger S3UserAfterInsertAfterUpdate on S3User__c(after insert, after update) {
  if(Trigger.isUpdate) {
    Map<Id, S3User__c> newMap = Trigger.newMap;
    Map<Id, S3User__c> oldMap = Trigger.oldMap;
    Set<Id> newIds = newMap.keySet();
    Set<Id> needsUpdate = new Set<Id>();

    for (Id targetId : newIds) {
      System.debug('Checking if we should send an email... S3 User Id ' + targetId);
      try {
        Boolean emailSent = S3UserActions.sendProvisioningEmailIfNeeded(newMap.get(targetId), oldMap.get(targetId));
        if(emailSent) {          
          needsUpdate.add(targetId);                    
        }
      } 
      catch(EmailException e) {
        for(Integer i = 0 ; i < e.getNumDml(); i++) {
          newMap.get(targetId).addError(' Please correct provisioning email address. ' + e.getDmlMessage(i));
        }
        return;

      } 
      catch(Exception e) {
        newMap.get(targetId).addError(' ' + e.getMessage());
        return;
      }
    }

    if(needsUpdate.size() > 0){
      List<S3User__c> itemsToUpdate = [Select Id, ProvisioningEmailSent__c from S3User__c where id in :needsUpdate];
      for(S3User__c f : itemsToUpdate){
        f.ProvisioningEmailSent__c = Datetime.now();
      }
      update(itemsToUpdate);
    }
  }
}