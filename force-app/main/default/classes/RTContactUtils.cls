global with sharing class RTContactUtils {

  public RTContactUtils(ApexPages.StandardController controller) {
  }

  /**
  * "Deletes" a Contact record (i.e. sets fields to send delete messages)
  *
  */
  public static void customDelete(Contact c) {
    if (!c.Inactive__c) {
      c.Inactive__c = true;
      c.Inactivated_By__c = Userinfo.getUserName();
    }

    if (c.Date_Deleted__c == null) {
      // if it was already marked w/ a delete date, don't change it
      c.Date_Deleted__c = Datetime.now();
    }

    if (c.Status__c != 'Deleted') {
      // if it was already deleted, don't put it back into a deleting status.
      c.Status__c = 'Deleting';
    }

    update(c);
  }

  /**
  * Provision a Contact
  *
  */
  public static Database.UpsertResult provision(Contact c) {
    c.Status__c = 'Pending';
    c.Provisioned__c = true;
    return Database.upsert(c);
  }  

  public static Id saveAndProvisionContact(Contact c, Department__c d, Account a, Boolean runCopyDown) {
    if(runCopyDown && d == null)
      copyAccountFieldsToContact(a,c);
    else if(runCopyDown && d != null)
      copyDepartmentFieldsToContact(d, c);

    ValidateContactFields.validateOnSave(c);
    
    Database.UpsertResult result = provision(c);

    if(result.isSuccess())
      return result.getId();
    else
      throw new ValidationException('Unable to provision contact; error: '+result.getErrors());

    return null;
  } 

  /**
  * Static method that provisions a Contact
  * 
  * returns true if the contact was provisioned successfully, throws ValidationException otherwise
  */
  @RemoteAction
  global static boolean provisionContact(String contactId){
    Contact c = (Contact)RTDatabaseUtils.getEntireSObject(new Contact(), contactId);
    try{
      RTContactUtils.provision(c);  
    }
    catch(Exception e){
      throw new ValidationException('An error occured while provisioning this contact: '+e.getMessage());
    }
    return true;  
  }   

  /**
  * Static method to return the Contact status
  * 
  * returns A string that represents the current state of the Contact
  */
  @RemoteAction
  global static String getContactStatusMessage(String contactId){
    Contact con = (Contact)RTDatabaseUtils.getEntireSObject(new Contact(), contactId);
    String status = con.Status__c;
    
    if(status == null || status.equals('New') || status.equals('Not Provisioned'))
      return 'NeedsProvisioning';    
    
    if(status.equals('Active') || status.equals('Provisioned'))
      return 'Active';
    else if(status.equals('Pending'))
      return status;
    else if(status.contains('Del'))
      return 'Del';    
    else if(status.contains('Error'))
      return 'Error';
    else
      return 'Unknown';
  }  

  /**
   * Takes the address from the contact and updates all active Access Codes to have the
   * same address.
   *
   * returns List of subscription ids that errored out.
   */
  public static List<String> pushAddressToActiveAccessCodes(String contactId) {
    Contact contact = [SELECT Id, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id = :contactId];
    if (contact == null) {
      throw new NotFoundException('No contact found with id ' + contactId);
    }

    List<Subscription__c> activeAccessCodes = RTAccessCodeUtils.getSubscriptionsByContact(contact);
    List<String> errored = new List<String>();

    if (activeAccessCodes != null && activeAccessCodes.size() > 0) {
      for (Subscription__c accessCode : activeAccessCodes) {
        if(!String.isBlank(contact.MailingStreet)) {
          String[] splitAddress = contact.MailingStreet.split('\n');
          if(splitAddress.size() > 0) {
            accessCode.Address_Line_1__c = splitAddress[0];
          } 
          if(splitAddress.size() > 1) {
            accessCode.Address_Line_2__c = splitAddress[1];
          }
        }
        accessCode.city__c = contact.MailingCity;
        accessCode.state__c = contact.MailingState;
        accessCode.zip__c = contact.MailingPostalCode;
        accessCode.country__c = contact.MailingCountry;
      }

      Database.SaveResult[] results = Database.update(activeAccessCodes, true);
      Integer i = 0;
      for (Database.SaveResult error : results) {
        if (!error.isSuccess()) {
          // have to index back to original record because SF doesn't return
          // id of failed updates.
          errored.add(activeAccessCodes.get(i).Id);
        }
        i++;
      }
    }
    return errored;
  }

  /**
   * Copy fields from the Account to this Contact
   */
  public static void copyAccountFieldsToContact(Account a, Contact c) {
    c.AccountId = a.id;
    c.Parent_Org_ID__c = a.Org_ID__c;
    c.OwnerID = a.OwnerID;
    c.MailingStreet = a.BillingStreet;
    c.MailingCity = a.BillingCity;
    c.MailingState = a.BillingState;
    c.MailingStateCode = a.BillingStateCode;
    c.MailingPostalCode = a.BillingPostalCode;
    c.MailingCountry = a.BillingCountry;
    c.MailingCountryCode = a.BillingCountryCode;
    
    //boolean billingAsShipping = a.Use_Billing_Info_as_Shipping_Info__c;

    //if(billingAsShipping) {
    
    //  //c.Mailing_Address_1__c = a.Billing_Street_Address_1__c;
      //c.Mailing_Address_2__c = a.Billing_Street_Address_2__c;
      //c.Mailing_City__c = a.Billing_City__c;
      //c.Mailing_State__c = a.Billing_State__c;
      //c.Mailing_Zip__c = a.Billing_Zip__c;
      //c.Country__c = a.Billing_Country__c;
    //} 
    //else {
     
      //c.Mailing_Address_1__c = a.Shipping_Address_1__c;
      //c.Mailing_Address_2__c = a.Shipping_Address_2__c;
      //c.Mailing_City__c = a.Shipping_City__c;
      //c.Mailing_State__c = a.Shipping_State__c;
      //c.Mailing_Zip__c = a.Shipping_Zip__c;
      //c.Country__c = a.Shipping_Country__c;
    //}

    //Default values
    //c.RecordType = [select id, name from RecordType where SobjectType = 'Contact' and name = 'Not Provisioned'];
    c.RT_Contact_Type__c = 'Not Provisioned';
    c.Billing_ID__c = a.id;
    c.Status__c = 'Not Provisioned';
  }

  /**
   * Copy fields from the Department to this Contact
   */
  public static void copyDepartmentFieldsToContact(Department__c d, Contact c) {
    Account a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), d.Parent_Account__c);    
    copyAccountFieldsToContact(a, c);

    c.SF_Department_ID__c = d.id;
    c.Parent_Org_ID__c = d.Org_ID__c;
    c.AccountId = d.Parent_Account__c;
    c.Department_Parent__c = d.id;
    c.MailingStreet = d.Shipping_Address__c;
    if(!String.isBlank(d.Shipping_Address_2__c)) {
      c.MailingStreet += d.Shipping_Address_2__c;  
    } 
    c.MailingCity = d.City__c;
    c.MailingState = d.State__c;
    c.MailingPostalCode = d.Postal_Code__c;
    c.MailingCountry = d.Country__c;

    //Default values
    //c.RecordType = [select id, name from RecordType where SobjectType = 'Contact' and name = 'Not Provisioned'];
    c.RT_Contact_Type__c = 'Not Provisioned';
    c.Status__c = 'Not Provisioned';
  }
}