public class LeadActions {
  public static void syncAddressFields(Lead[] newLeads, Lead[] oldLeads) {
    //Integer i = 0;
    //String prevStdState = null;
    //String updatedStdState = null;
    //String prevCustomState = null;
    //String updatedCustomState = null;
    //for (Lead updated : newLeads) {
    //  if(!ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypeIds.contains(updated.RecordTypeId)) {
    //      continue;
    //  }
     //   Lead oldLead = null;
     //   if (oldLeads != null) {
     //     oldLead = oldLeads[i];
     //   }
     //   //syncCountry(updated, oldLead);
     //   //syncState(updated, oldLead);
     //   //syncAddress1(updated, oldLead);
     //   //syncCity(updated, oldLead);
     //   //syncZip(updated, oldLead);
     //   i++;
     // }
  }

  public static void setDefaultInvoiceTypes(List<Lead> newLeads) {
    for(Lead l : newLeads) {
      if(!ReadyTalkRecordTypeHelper.readyTalkLeadRecordTypeIds.contains(l.RecordTypeId)) {
          continue;
      }
      l.Invoice_Types__c = 'Account Summary; Department Summary; Access Code Summary; Access Code Detail';
      l.Invoice_Format__c= 'Email';
    }
  }

  //private static void syncCountry(Lead newLead, Lead oldLead) {
  //  //String prevStdVal = null;
  // // String prevCustVal = null;
  // // if (oldLead != null) {
  // //   prevStdVal = oldLead.Country;
  // //   prevCustVal = oldLead.Billing_Country__c;
  // // }
  //  //String master = RTAddressUtils.getLastChanged(prevStdVal, newLead.Country, prevCustVal, newLead.Billing_Country__c);
  //  newLead.Country = RTAddressUtils.normalizeCountry(newLead.Country);
  //  //newLead.Country = master;
  //  //newLead.Billing_Country__c = master;
  ////}
  //private static void syncState(Lead newLead, Lead oldLead) {
  //  if ('UNITED STATES'.equals(newLead.Country) || 'CANADA'.equals(newLead.Country)) {
  //    //String prevStdState = null;
  //    //String prevCustomState = null;
  //  //  if (oldLead != null) {
  //  //    prevStdState = oldLead.State;
  //  //    prevCustomState = oldLead.Billing_State__c; 
  //  //  }
  //  //  String updatedStdState =  newLead.State;
  //  //  String updatedCustomState = newLead.Billing_State__c;
  //  //  String stateValue = RTAddressUtils.syncState(prevStdState, updatedStdState, prevCustomState, updatedCustomState);
  //  //  // If we couldn't map it, then just leave it alone in both std and custom.
  //  //  if (stateValue != null) {
  //  //    newLead.State = stateValue;
  //  //    newLead.Billing_State__c = stateValue;
  //  //  }
  //  newLead.StateCode = RTAddressUtils.MapState(newLead.State);
  //  }
  //}   
  //private static void syncAddress1(Lead newLead, Lead oldLead) {
    //String prevStdVal = null;
    //String prevCustVal = null;
    //if (oldLead != null) {
    //  prevStdVal = oldLead.Street;
    //  prevCustVal = oldLead.Billing_Address_Line_1__c;
    //}
    //String master = RTAddressUtils.getLastChanged(prevStdVal, newLead.Street, prevCustVal, newLead.Billing_Address_Line_1__c);
    //newLead.Street = master;
    //StreetAddress splitAddress = RTAddressUtils.splitStreetAddress(master);
    //newLead.Billing_Address_Line_1__c = splitAddress.getAddress1();
    //if (splitAddress.getAddress2() != null) {
    //  newLead.Billing_Address_Line_2__c = splitAddress.getAddress2();
    //}
  //}
  
  //private static void syncCity(Lead newLead, Lead oldLead) {
  //    String prevStdVal = null;
  //    String prevCustVal = null;
  //    if (oldLead != null) {
  //      prevStdVal = oldLead.City;
  //      prevCustVal = oldLead.Billing_City__c;
  //    }
  //    String master = RTAddressUtils.getLastChanged(prevStdVal, newLead.City, prevCustVal, newLead.Billing_City__c);
  //    newLead.City = master;
  //    newLead.Billing_City__c = master;
  //} 
  //private static void syncZip(Lead newLead, Lead oldLead) {
  //    String prevStdVal = null;
  //    String prevCustVal = null;
  //    if (oldLead != null) {
  //      prevStdVal = oldLead.PostalCode;
  //      prevCustVal = oldLead.Billing_Zip__c;
  //    }
  //    String master = RTAddressUtils.getLastChanged(prevStdVal, newLead.PostalCode, prevCustVal, newLead.Billing_Zip__c);
  //    newLead.PostalCode = master;
  //    newLead.Billing_Zip__c = master;
  //}
  
}