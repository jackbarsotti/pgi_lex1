public class ValidateAccountFields {

  /**
  * SFB-2401 Validates Account Owner change (MAX-SIZE)
  */
  public static boolean validateAccessCodeCount(Account[] newaccs, Account[] oldaccs) {
    if(newaccs == null)
      return true;

    if(oldaccs == null)
      return true;

    boolean isAdministrator = RTDatabaseUtils.isAdministrator();

    Integer i = 0;
    for(Account a : newaccs){
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      Account b = oldaccs[i];
      
      //Long conditional:
      //Basically, if the user is not an administrator and Active_Access_Codes__c > limit of subscriptions and the OwnerId has changed, then add a page error.
      if(!timeFrameOKToBulkDelete && a.Active_Access_Codes__c != null && a.Active_Access_Codes__c > RTConfig.LIMIT_NUMBER_SUBSCRIPTIONS && b.OwnerId != null && a.OwnerId != null && a.OwnerId != b.OwnerId){
        a.addError('Due to the number of subscriptions to be altered (' + a.Active_Access_Codes__c + '), this action must be performed after working hours (after 4PM MT).');
        return false;
      }

      i = i + 1;
    }

    return true;
  }
  //returns a boolean - if during MT working hours - return false
  public static Boolean timeFrameOKToBulkDelete{ get{
    if(PGI_Utility.hourInMT >= 16 || PGI_Utility.hourInMT <= 8) {
      return true;
    }
    return false;
  }}
  
  /**
   * Validation for the Account Source (Data.com)
   */
  public static boolean validateAccountSource(Account[] newaccs) {
    if (newaccs == null)
      return true;
    
    for(Account a : newaccs) {
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      if('Data.com'.equals(a.AccountSource)) {
        a.addError('Cannot create accounts from Data.com');
        return false;
      }
    }
    
    return true;
  }

  /**
   * Validation for the Invoice Format
   */
  public static boolean validateInvoiceFormat(Account[] newaccs, Account[] oldaccs) {
    if(oldaccs == null)
      return true;

    for(Account a : newaccs) {
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      if(a.Invoice_Format__c == null) {
        //S1921: SF Validation Rule Needed on Invoice Format Field
        a.Invoice_Format__c.addError('An Invoice Format is required.');
        return false;
      }                
    }

    return true;
  }

  //SFB-841: Account must have Account Summary selected for report preferences
  public static boolean validateInvoiceTypes(List<Account> newaccs, List<Account> oldaccs){
    if(oldaccs == null || oldaccs.size() <= 0)
      return true;

    for(Account a : newaccs){
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      if(a.Invoice_Types__c == null){
        a.Invoice_Types__c.addError('Invoice Types field is required');
        return false;
      }

      //SFB-1249
      if(a.Send_ConfDetail_to_Contacts__c && !a.Invoice_Types__c.contains('Conference Detail')){
        a.Invoice_Types__c.addError('If Send Conf Detail Inv to Subscribers is checked, you must include Conference Details');
        return false;
      }
    }

    return true;
  }    

  //S3656: Validation for the Billing Country
  public static boolean validateBillingCountry(Account[] newaccs) {
    for (Account a : newaccs) {
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      if(a.Provisioned__c != null && a.Provisioned__c  
          && a.BillingCountry != null && (a.BillingCountryCode.equals('US') || a.BillingCountry.equals('CA')) 
          && String.isBlank(a.BillingStateCode) && String.isBlank(a.BillingState)) {

        a.BillingState.addError('A Billing State (US) or Province (Can) is required.');
        return false;
      }
    }

    return true;
  }

}