public class ValidateSubscriptionFields {

  public static void validate(Subscription__c s) {
    String message = '';
    
    if(s.Passcode__c != null && s.Passcode__c.length() > 9)
      message = message + 'Passcode cannot be longer than 9 digits.<br/>';

    if(message.length() > 0)
      throw new ConstructableException(message);
  }

  public static boolean validatePasscode(Subscription__c[] subs){
    boolean noInvalidPasscodes = true;
    for(Subscription__c sub: subs){
      if(!validatePassCodeAgainstAccessCode(sub.passcode__c, sub.name)){
        addErrorToPasscode(sub, 'You must set the Subscription accessCode(i.e. name) before you can validate a passcode');
        noInvalidPasscodes = false;
        continue;
      }
    }
    return noInvalidPasscodes;
  }

  public static boolean validateAccessCode(String accessCode){
    List<Subscription__c> tempSubs = new Subscription__c[1];
    tempSubs = Database.query('select Name from Subscription__c where Inactive__c=false and Name = \'' + accessCode + '\'');

    if(tempSubs.isEmpty())
      return true;
    else
      return false;
  }

  public static Boolean validatePassCodeAgainstAccessCode(String passCode, String accessCode){
    if((accessCode == null) || (accessCode.length() <  7)){
      return false;
    } else if(passCode == null){
      return false;
    } else if(passCode.length() < 4){
      return false;
    } else if(passCode.length() > 9){
      return false;
    } else if(Pattern.matches('^(0*|1*|2*|3*|4*|5*|6*|7*|8*|9*)$', passCode)){
      return false;
    } else if('0123456789'.contains(passCode) || '9876543210'.contains(passCode)){
      return false;
    } else if(accessCode.endsWith(passCode)){
      return false;
    }
    return true;
  }

  public static void addErrorToPasscode(Subscription__c sub, String errorMessage){
    sub.passcode__c.addError(errorMessage);
  }
}