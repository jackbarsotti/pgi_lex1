public with sharing class ProvisioningEmailHelper {

  // if the AC is Active and a provisioning email hasn't been sent before, and Send Prov email checkbox is selected, 
  // then we need to send an email
  public static boolean needsProvisioningEmail(Subscription__c newVersion, Subscription__c oldVersion) {
    if (newVersion.Status__c == 'Active' 
      && (newVersion.Send_Provisioning_Email__c || newVersion.Add_l_Provisioning_Emails__c)
      && newVersion.ProvisioningEmailSent__c == null) {
        return true;
    }
    return false;
  }

  // Should abstract this later...
  public static boolean needsFoxDenProvisioningEmail(FoxDen_User__c newVersion, FoxDen_User__c oldVersion) {
    if(newVersion.Status__c == 'Active' && newVersion.ProvisioningEmailSent__c == null && newVersion.Password__c != null) {
      return true;
    }
    return false;
  }  

  // Should abstract this later...
  public static boolean needsS3ProvisioningEmail(S3User__c newVersion, S3User__c oldVersion) {
    if(newVersion.Status__c == 'Active' && newVersion.ProvisioningEmailSent__c == null && newVersion.Password__c != null && newVersion.PasswordChangeTicket__c != null) {
      return true;
    }
    return false;
  }    

  // Should abstract this later...
  public static boolean sendFoxDenProvisioningEmail(FoxDen_User__c foxDenUser, String templateUniqueName) {
    Contact contact = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), foxDenUser.Contact__c, ',Account.Id');
    Messaging.reserveSingleEmailCapacity(1);
    EmailTemplate template = [SELECT id from EmailTemplate where developerName = :templateUniqueName];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setTemplateId(template.Id);
    msg.setTargetObjectId(contact.Id);
    msg.setSenderDisplayName('FoxDen');
    msg.setWhatId(foxDenUser.Id);
    msg.setUseSignature(true);
    msg.setReplyTo('support@foxden.io');
    msg.setSaveAsActivity(true);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg}, true);
    return true;
  }

    // Should abstract this later...
  public static boolean sendS3ProvisioningEmail(S3User__c s3User, String templateUniqueName) {
    Contact contact = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), s3User.Contact__c, ',Account.Id');
    Messaging.reserveSingleEmailCapacity(1);
    EmailTemplate template = [SELECT id from EmailTemplate where developerName = :templateUniqueName];
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setTemplateId(template.Id);
    msg.setTargetObjectId(contact.Id);
    msg.setSenderDisplayName('ReadyTalk Illuminate');
    msg.setWhatId(s3User.Id);
    msg.setUseSignature(true);
    msg.setReplyTo('support@readytalk.com');
    msg.setSaveAsActivity(true);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg}, true);
    return true;
  }

  public static boolean sendProvisioningEmail(Subscription__c subscription, String templateUniqueName) {
    Contact contact = (Contact) RTDatabaseUtils.getEntireSObject(new Contact(), subscription.Contact__c, ',Account.Id');

    Messaging.reserveSingleEmailCapacity(1);
    
    EmailTemplate template = [SELECT id from EmailTemplate where developerName = :templateUniqueName];
    System.debug('Sending provisioning email template: ' + template.Id);
  
    List<String> addlEmails = new List<String>();
    if (subscription.Add_l_Provisioning_Emails__c) {
      addlEmails = splitAdditionalEmailAddresses(subscription.Add_l_Provisioning_Email_Addresses__c);
    }
    String currentContactEmail = null;
    Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
    msg.setTemplateId(template.Id);
    msg.setTargetObjectId(contact.Id);
    // msg.setSenderDisplayName('ReadyTalk Provisioning');
    msg.setOrgWideEmailAddressId('0D21B000000L0pu');
    msg.setWhatId(subscription.Id);
    msg.setUseSignature(true);
    msg.setReplyTo('provisioning@readytalk.com');
    msg.setSaveAsActivity(true);
    try {
      if (subscription.Send_Provisioning_Email__c) {
        if (!subscription.Subscription_Email__c.equals(contact.Email.trim())) {
          if(addlEmails.size() > 0)
            addlEmails.add(0, subscription.Subscription_Email__c);
          else
            addlEmails.add(subscription.Subscription_Email__c);
        }
      } else if (addlEmails.size() > 0) {
        // Salesforce requires that we set the TargetObjectId which it uses to set the toAddress to the contact.Email
        // In the case where the sub email is different from the contact or when we are only sending addl emails,
        // we set the contact email to the first email in the list and then set it back
        currentContactEmail = contact.Email;
        String newEmail = addlEmails.remove(0);
        contact.Email = newEmail;
        Update(contact);
      }
      if (addlEmails.size() > 0) {
        msg.setToAddresses(addlEmails);
      }
    
      Messaging.sendEmail(new Messaging.SingleEmailMessage[] {msg}, true);
    } finally {
      if (currentContactEmail != null) {
        contact.Email = currentContactEmail;
        Update(contact);
      }
    }

    subscription.ProvisioningEmailSent__c = Datetime.now();

    return true;
  }

  public static String[] splitAdditionalEmailAddresses(String addresses) {
    String cleaned = addresses.normalizeSpace();
    String[] simpleSplit = cleaned.split('[;,\\s\\n\\r\\t]', -1);
    String[] cleanedSplit = new List<String>();
    for (String current : simpleSplit) {
      if (current != null && current.length()>0) {
        cleanedSplit.add(current);
      }
    }
    return cleanedSplit;
  }
}