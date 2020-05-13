public class AccountActions {

  public static void onAccountOwnerChanged(List<Account> newaccs, List<Account> oldaccs) {
    if (oldaccs == null)
      return;

    if (newaccs.size() > 1 || oldaccs.size() > 1)
      return;

    Integer i = 0;
    for (Account a : newaccs) {
      Account b = oldaccs[i];
      //COD-1376 - record type filter
      if (b.OwnerId != null && a.OwnerId != null && a.OwnerId != b.OwnerId && ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        System.enqueueJob(new CascadeAccountOwner('Execute', a.id, b.OwnerId, a.OwnerId));        
      }
      i = i + 1;
    }
  }

  public static void copyBillingAddressToShippingAddress(List<Account> newaccs, List<Account> oldaccs){
    for(Account a : newaccs){
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(a.RecordTypeId)) {
        continue;
      }
      ////if (a.Use_Billing_Info_as_Shipping_Info__c){
      //  //a.Shipping_Address_1__c = a.Billing_Street_Address_1__c;
      //  //a.Shipping_Address_2__c = a.Billing_Street_Address_2__c;
      //  //a.Shipping_City__c = a.Billing_City__c;
      //  //a.Shipping_State__c = a.Billing_State__c;
      //  //a.Shipping_Zip__c = a.Billing_Zip__c;
      //  //a.Shipping_Country__c = a.Billing_Country__c;
      //  a.ShippingStreet = a.BillingStreet;
      //  a.ShippingCity = a.BillingCity;
      //  a.ShippingState = a.BillingState;
      //  a.ShippingPostalCode = a.BillingPostalCode;
      //  a.ShippingCountry = a.BillingCountry;
        
      //}
    }
  }

  /**
  * ---------------- Street Sync for Data.com ----------------------
  */
  public static void syncAddressFields(Account[] newAccounts, Account[] oldAccounts) {
    Integer i = 0;
    String prevStdState = null;
    String updatedStdState = null;
    String prevCustomState = null;
    String updatedCustomState = null;
    for (Account updated : newAccounts) {
      //COD-1376
      if(!ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypeIds.contains(updated.RecordTypeId)) {
        continue;
      }
      Account oldAccount = null;
      if (oldAccounts != null) {
        oldAccount = oldAccounts[i];
      }
      syncCountry(updated, oldAccount);
      //syncState(updated, oldAccount);
      //syncAddress1(updated, oldAccount);
      //syncCity(updated, oldAccount);
      //syncZip(updated, oldAccount);
      i++;
    }
  }


  private static void syncCountry(Account newAccount, Account oldAccount) {
    //String prevStdVal = null;
    //String prevCustVal = null;
    //if (oldAccount != null) {
    //  prevStdVal = oldAccount.BillingCountry;
    //  prevCustVal = oldAccount.Billing_Country__c;
    //}
    //String master = RTAddressUtils.getLastChanged(prevStdVal, newAccount.BillingCountry, prevCustVal, newAccount.Billing_Country__c);
    //master = ;
    //newAccount.BillingCountry = RTAddressUtils.normalizeCountry(newAccount.BillingCountry);
    //newAccount.Billing_Country__c = master;
  }

  //private static void syncState(Account newAccount, Account oldAccount) {
  //  if ('UNITED STATES'.equals(newAccount.BillingCountry) || 'CANADA'.equals(newAccount.BillingCountry)) {
  //    //String prevStdState = null;
  //    //String prevCustomState = null;
  //    //if (oldAccount != null) {
  //    //  prevStdState = oldAccount.BillingState;
  //    //  prevCustomState = oldAccount.Billing_State__c;
  //    //}
  //    //String updatedStdState =  newAccount.BillingState;
  //    //String updatedCustomState = newAccount.Billing_State__c;
  //    //String stateValue = RTAddressUtils.syncState(prevStdState, updatedStdState, prevCustomState, updatedCustomState);
  //    // If we couldn't map it, then just leave it alone in both std and custom.
  //    //if (stateValue != null) {
  //      //newAccount.BillingStateCode = RTAddressUtils.MapState(newAccount.BillingState);
  //      //newAccount.Billing_State__c = stateValue;
  //    //}
  //  }
  //}

  //private static void syncAddress1(Account newAccount, Account oldAccount) {
  //  String prevStdVal = null;
  //  String prevCustVal = null;
  //  if (oldAccount != null) {
  //    prevStdVal = oldAccount.BillingStreet;
  //    prevCustVal = oldAccount.Billing_Street_Address_1__c;
  //  }
  //  String master = RTAddressUtils.getLastChanged(prevStdVal, newAccount.BillingStreet, prevCustVal, newAccount.Billing_Street_Address_1__c);
  //  newAccount.BillingStreet = master;
  //  newAccount.Billing_Street_Address_1__c = master;
  //}

  //private static void syncCity(Account newAccount, Account oldAccount) {
  //  String prevStdVal = null;
  //  String prevCustVal = null;
  //  if (oldAccount != null) {
  //    prevStdVal = oldAccount.BillingCity;
  //    //prevCustVal = oldAccount.Billing_City__c;
  //  }
  //  String master = RTAddressUtils.getLastChanged(prevStdVal, newAccount.BillingCity, prevCustVal, newAccount.Billing_City__c);
  //  newAccount.BillingCity = master;
  //  newAccount.Billing_City__c = master;
  //}

  //private static void syncZip(Account newAccount, Account oldAccount) {
  //  String prevStdVal = null;
  //  //String prevCustVal = null;
  //  if (oldAccount != null) {
  //    prevStdVal = oldAccount.BillingPostalCode;
  //    //prevCustVal = oldAccount.Billing_Zip__c;
  //  }
  //  String master = RTAddressUtils.getLastChanged(prevStdVal, newAccount.BillingPostalCode, prevCustVal, newAccount.Billing_Zip__c);
  //  newAccount.BillingPostalCode = master;
  //  //newAccount.Billing_Zip__c = master;
  //}
}