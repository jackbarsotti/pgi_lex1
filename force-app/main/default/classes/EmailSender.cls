public class EmailSender {

  public static void sendToAccountOwner(Account[] accs, String subject, String body){
    for (Account a : accs){
      if (a != null) {
        try{            
          User u =  [SELECT Email, Name FROM User where ID = :a.OwnerId];
          String[] addresses = new String[] {u.Email};
          String accountName = a.Name;
          String accountNumber = a.AccountNumber;

          //Do replacements on subject and body
          subject = subject.replaceAll('\\$accountName', accountName);
          subject = subject.replaceAll('\\$accountNumber', accountNumber);
          body = body.replaceAll('\\$accountName', accountName);
          body = body.replaceAll('\\$accountNumber', accountNumber);

          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
          mail.setToAddresses(addresses);
          mail.setSubject(subject);
          mail.setUseSignature(false);
          mail.setPlainTextBody(body);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
          System.debug('E-mail sent');    
        }            
        catch (Exception e) {       
          System.debug('Exception Thrown!');        
        }
      }
    }
  }

  public static void sendToSubscriptionOwner(Subscription__c[] subs, String subject, String body){
    for (Subscription__c a : subs){
      if (a != null) {
        try{            
          User u =  [SELECT Email, Name FROM User where ID = :a.OwnerId];
          String[] addresses = new String[] {u.Email};
          String subscriptionName = a.Name;
          String subscriptionNumber = a.Card_Name__c;

          //Do replacements on subject and body
          subject = subject.replaceAll('\\$subscriptionName', subscriptionName);
          subject = subject.replaceAll('\\$subscriptionNumber', subscriptionNumber);
          body = body.replaceAll('\\$subscriptionName', subscriptionName);
          body = body.replaceAll('\\$subscriptionNumber', subscriptionNumber);

          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();            
          mail.setToAddresses(addresses);
          mail.setSubject(subject);
          mail.setUseSignature(false);
          mail.setPlainTextBody(body);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
          System.debug('E-mail sent');    
        }            
        catch (Exception e) {       
          System.debug('Exception Thrown!');        
        }
      }
    }
  }

  public static void sendErrorEmail(Exception e) {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setToAddresses(new String[] {RTConfig.SFDEVELOPER_EMAIL_ADDRESS});
    mail.setSubject(Site.getCurrentSiteUrl()+': The following error occurred');
    mail.setUseSignature(false);
    mail.setPlainTextBody(e.getMessage());
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });  
  }
}