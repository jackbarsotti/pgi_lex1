public class ValidateOtherChargeCreditFields {

  public static boolean validateChargeCredit(OtherChargeCredit__c otherChargeCredit){

    //Description cannot be > 100 characters
    if(otherChargeCredit.Description__c != null && otherChargeCredit.Description__c.length() > 100) {
      otherChargeCredit.addError('Description cannot be longer than 100 characters.  Currently, the description contains '+otherChargeCredit.Description__c.length()+' characters.');
      return false;
    }

    //Cannot be a $0 value
    if(otherChargeCredit.ChargeOrCredit__c == 0){
      otherChargeCredit.addError('Charge/(Credit) cannot be $0');
      return false;
    }

    //If Product starts with "Credit", then ensure the amount is negative
    if(otherChargeCredit.Product__c.startsWith('Credit') && otherChargeCredit.ChargeOrCredit__c > 0) {
      otherChargeCredit.addError('All credits must be a negative amount.');
      return false;
    }

    //Anything else is a charge, ensure the amount is positive
    if(!otherChargeCredit.Product__c.startsWith('Credit') && otherChargeCredit.ChargeOrCredit__c < 0) {
      otherChargeCredit.addError('All charges must be a positive amount.');
      return false;
    }


    return true;
  } 
}