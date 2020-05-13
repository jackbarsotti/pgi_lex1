public class ContactActions {

  public static void onContactDelete(List<Contact> newContacts, List<Contact> oldContacts){
    //No deletes for new contacts or bulk contact operations 
    if(newContacts==null || newContacts.size() > 1 || oldContacts==null || oldContacts.size() > 1)
      return;

    Contact newContact = newContacts.get(0);
    Contact oldContact = oldContacts.get(0);
    //COD-1376
    if(!ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(newContact.RecordTypeId)) {
          return;
    }
    //If it's not a delete, then return
    if(newContact.Inactive__c == null || newContact.Inactive__c==false)
      return;
    
    //If the incoming contact's status is 'Delete', then return
    if(newContact.Status__c != null && newContact.Status__c=='Delete')
      return;

    //If the old and new are the same, then return; failsafe
    if(newContact.Status__c == oldContact.Status__c && newContact.Inactive__c == oldContact.Inactive__c)
      return;

    //Delete the contact (and any Subscriptions hanging from it)
    ContactRepository contactRepository = new ContactRepository();
    contactRepository.cascadeDelete(newContact);
  }

  public static void syncAddressFields(Contact[] newContacts, Contact[] oldContacts) {
    //Integer i = 0;
    //String prevStdState = null;
    //String updatedStdState = null;
    //String prevCustomState = null;
    //String updatedCustomState = null;
    //for (Contact contact : newContacts) {
    //  if(!ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(contact.RecordTypeId)) {
    //      continue;
    //  }
    //  Contact oldContact = null;
    //    if (oldContacts != null) {
    //        oldContact = oldContacts[i];
    //    }
    //    //contact.MailingCountry = RTAddressUtils.normalizeCountry(contact.MailingCountry);
    //    //syncCountry(contact, oldContact);
    //    //syncState(contact, oldContact);
    //    //syncAddress1(contact, oldContact);
    //    //syncCity(contact, oldContact);
    //    //syncZip(contact, oldContact);
    //    i++;
    //  }
  }
  
  ///** 
  //* sets Contact.MailingCountry and Contact.Country__c to the last changed value.
  //*/
  //private static void syncCountry(Contact newContact, Contact oldContact) {
    
  //  //String prevStdVal = null;
  //  //String prevCustVal = null;
  //  //if (oldContact != null) {
  //  //  prevStdVal = oldContact.MailingCountry;
  //  //  prevCustVal = oldContact.Country__c;
  //  //}
  //  //String master = RTAddressUtils.getLastChanged(prevStdVal, newContact.mailingCountry, prevCustVal, newContact.Country__c);
    
  //  //newContact.MailingCountry = master;
  //  //newContact.Country__c = master;
  //}
  
  //private static void syncState(Contact newContact, Contact oldContact) {
  //  if ('UNITED STATES'.equals(newContact.MailingCountry) || 'CANADA'.equals(newContact.MailingCountry)) {
  //    RTAddressUtils.mapState(newContact.MailingState);
  //    //  String prevStdState = null;
  //    //  String prevCustomState = null;
  //    //  if (oldContact != null) {
  //    //      prevStdState = oldContact.MailingState;
  //    //      prevCustomState = oldContact.Mailing_State__c;  
  //    //  }
  //    //  String updatedStdState =  newContact.MailingState;
  //    //String updatedCustomState = newContact.Mailing_State__c;
  //    //String stateValue = RTAddressUtils.syncState(prevStdState, updatedStdState, prevCustomState, updatedCustomState);
  //    //// If we couldn't map it, then just leave it alone in both std and custom.
  //    //if (stateValue != null) {
  //    //  newContact.MailingState = stateValue;
  //    //  newContact.Mailing_State__c = stateValue;
  //    //}
  //  }
  //}   
    
  //private static void syncAddress1(Contact newContact, Contact oldContact) {
  //      String prevStdVal = null;
  //      String prevCustVal = null;
  //      if (oldContact != null) {
  //          prevStdVal = oldContact.MailingStreet;
  //          prevCustVal = oldContact.Mailing_Address_1__c;
  //      }
  //      String master = RTAddressUtils.getLastChanged(prevStdVal, newContact.MailingStreet, prevCustVal, newContact.Mailing_Address_1__c);
  //      newContact.MailingStreet = master;
  //      newContact.Mailing_Address_1__c = master;
  //}
  
  //private static void syncCity(Contact newContact, Contact oldContact) {
  //      String prevStdVal = null;
  //    String prevCustVal = null;
  //    if (oldContact != null) {
  //      prevStdVal = oldContact.MailingCity;
  //      prevCustVal = oldContact.Mailing_City__c;
  //    }
  //      String master = RTAddressUtils.getLastChanged(prevStdVal, newContact.MailingCity, prevCustVal, newContact.Mailing_City__c);
  //    newContact.MailingCity = master;
  //    newContact.Mailing_City__c = master;
  //}
    
  //private static void syncZip(Contact newContact, Contact oldContact) {
  //      String prevStdVal = null;
  //    String prevCustVal = null;
  //    if (oldContact != null) {
  //      prevStdVal = oldContact.MailingPostalCode;
  //      prevCustVal = oldContact.Mailing_Zip__c;
  //    }
  //    String master = RTAddressUtils.getLastChanged(prevStdVal, newContact.MailingPostalCode, prevCustVal, newContact.Mailing_Zip__c);
  //    newContact.MailingPostalCode = master;
  //    newContact.Mailing_Zip__c = master;
  //}
  
   public static void checkForEmailDupes(List<Contact> newContacts, List<Contact> oldContacts){

        System.debug('we done hit a trigger '+newContacts);
        Map<Contact, String> contactToEmail = new Map<Contact, String>();
        List<Contact> contactsFromAccountAdmin = new List<Contact>();
        Set<Contact> contactsToUpdate = new Set<Contact>();
        for (Contact c : newContacts){
          if(!ReadyTalkRecordTypeHelper.readyTalkContactRecordTypeIds.contains(c.RecordTypeId)) {
              continue;
          }
            if (c.Account_Admin__c){
              if(!String.isBlank(c.Email)) {
                contactToEmail.put(c, c.Email);
              }
            }
        }
System.debug('contact to email map ' +contactToEmail);
        if (contactToEmail.size() > 0){
          //select all the contacts with the same email
            contactsFromAccountAdmin = [SELECT email FROM Contact WHERE email IN :contactToEmail.values()];
 System.debug('contacts from accountadmin '+contactsFromAccountAdmin);
            if (contactsFromAccountAdmin.size() > contactToEmail.size()){//need more contacts returned than searched for for a duplicate
                for (Contact cOuter : contactsFromAccountAdmin){
                    for (Contact cInner : contactToEmail.keySet()){
                        if (cOuter.Id != cInner.Id && cOuter.Email == cInner.Email){
                            cOuter.Duplicate_Contact__c = true;
                            cInner.Duplicate_Contact__c = true;
                            cOuter.Do_Not_Sync_to_Marketo__c = true;
                            cInner.Do_Not_Sync_to_Marketo__c = true;
//                            contactsToUpdate.add(cOuter);
//                            contactsToUpdate.add(cInner);
                        }
                    }
                }
                //update new List<Contact>(contactsToUpdate);
            }
            //set duplicate contact = true on any contacts returned.
            //need to check if the list of contacts returned includes the current contact
            //perhaps depends on new or update?

        }
    }
}