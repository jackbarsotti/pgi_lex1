public with sharing class RTAccessCodeUtils {

  public static String getNewAccessCode(String phone) {
    String accessCode = '';
    List<Subscription__c> tempSubs = new Subscription__c[1];

    //Try using the first 7 digits of the phone number first (excluding area code)
    try {
      if (phone != null) {
        String noAreaCode = phone.replaceAll('\\(.*\\)|\\s|x|X|-|\\.', '').trim();
        accessCode = noAreaCode.substring(noAreaCode.length() - 7, noAreaCode.length());
        tempSubs = Database.query('select Name from Subscription__c where Inactive__c=false and Name = \'' + accessCode + '\'');
      }
    } catch (Exception e) {
      //Do nothing, either the Database query acted up, or the phone number was less than seven digits
      String noop = '';
    }

    //If the phone number fails, then pick a random 7 digit access code that isn't already in use
    while (!tempSubs.isEmpty() || accessCode.startsWith('0')) {
      Double rand = RTMathUtils.getRandomBetween(1000000, 9999999);
      accessCode = String.valueOf(rand.intValue());
      tempSubs = Database.query('select Name from Subscription__c where Inactive__c=false and Name = \'' + accessCode + '\'');
    }

    return accessCode;
  }

  public static String getNewPassCode() {
    return String.valueOf(RTMathUtils.getRandomBetween(1000, 9999).intValue());
  }

  public static String getValidNewPasscode(String accessCode) {
    Integer maxTries = 10000;
    for (Integer i = 0; i < maxTries; i++) {
      String possiblePasscode = getNewPassCode();
      if (ValidateSubscriptionFields.validatePassCodeAgainstAccessCode(possiblePasscode, accessCode)) {
        return possiblePasscode;
      }
    }
    return getNewPassCode();
  }

  public static Database.UpsertResult provision(Subscription__c s) {
    s.Provision__c = true;
    return Database.upsert(s);
  }

  public static void customDelete(Subscription__c sub) {
    if (!sub.Inactive__c) {
      sub.PortalAdmin__c = false;
      sub.Inactive__c = true;
      sub.Inactivated_By__c = Userinfo.getUserName();
    }

    if (sub.Date_Deleted__c == null) {
      // if it was already marked w/ a delete date, don't change it
      sub.Date_Deleted__c = Datetime.now();
    }

    if (sub.Status__c != 'Deleted') {
      // if it was already deleted, don't put it back into a deleting status.
      sub.Status__c = 'Deleting';
    }

    update(sub);
  }

  /**
   * Returns a list of active Subscriptions under a Contact
   */
  public static List<Subscription__c> getSubscriptionsByContact(Contact contact) {
    return (List<Subscription__c>) RTDatabaseUtils.getSObjectList('Subscription__c',
      'Id,Contact__c,Inactive__c,IsDeleted,Status__c,Billing_ID__c,Access_Code__c,Card_Name__c,Address_Line_1__c,Address_Line_2__c,City__c, State__c,Zip__c,Country__c',
      'where Contact__c = \'' + contact.id + '\' and Inactive__c=false');
  }


  /**
  * Abstracted save method that can be used from multiple classes (ugly, but it works)
  */
  public static Id saveAndProvisionSubscription(Subscription__c sub, Contact c, Account a, Boolean runCopyDown) {
    if(runCopyDown)
      copyFields(sub, c, a);

    ValidateSubscriptionFields.validate(sub);
    if(!ValidateSubscriptionFields.validateAccessCode(sub.name))
      sub.Name = RTAccessCodeUtils.getNewAccessCode(c.Phone);
    
    Database.UpsertResult result = RTAccessCodeUtils.provision(sub);

    if(result.isSuccess())
      return result.getId();

    return null;
  }

  /**
   * Copy fields from account/department/contact to the subscription object
   */
  public static void copyFields(Subscription__c sub, Contact c, Account a) {
    //Copy Account fields
    //Account a = (Account) RTDatabaseUtils.getEntireSObject(new Account(), c.AccountId);
    sub.OwnerID = a.OwnerID;
    sub.Recording_Allowed__c = a.Recording_Allowed__c;
    sub.Recording_Editing_Allowed__c = a.Recording_Editing_Allowed__c;
    sub.Account_Code_Prompt__c = a.Account_Codes__c;
    sub.Security_Passcode__c = a.Security_Option__c;
    sub.Quickstart__c = a.Quickstart__c;
    sub.voipAllowed__c = a.voipAllowed__c;
    sub.International_Dial_Out_Allowed__c = a.International_Dial_Out_Allowed__c;
    sub.Entry_Announcement__c = a.Entry_Announcement__c;
    sub.Moderator_Allowed__c = a.Moderator_Allowed__c;
    sub.Web_Conference_Allowed__c = a.Web_Conf_Allowed__c;
    sub.Slide_Presentation_Allowed__c = a.Slide_Presentation_Allowed__c;
    sub.App_Share_Allowed__c = a.App_Share_Allowed__c;
    sub.Auto_Delete_Slides__c = a.Auto_Delete_Slides__c;
    sub.Copresenter_Allowed__c = a.Copresenter_Allowed__c;
    sub.Archive_Period__c = a.Archive_Period__c;
    sub.Remote_Control_Allowed__c = a.Remote_Control_Allowed__c;
    sub.Video_Conferencing_Allowed__c = a.Video_Conferencing_Allowed__c;
    sub.Kit_Name__c = a.Kit_Name__c;
    sub.International_Kit_Number__c = a.Kit_Number__c;
    sub.Web_Subscription_Size__c = a.Default_Web_Subscription_Size__c;
    sub.Podcasting__c = a.Podcast__c;
    sub.Contact_Start_Page__c = a.Start_Page__c;
    sub.Send_Provisioning_Email__c = a.Send_Provisioning_Email__c;
    sub.Ship_To_Name__c = a.Ship_To_Name__c;
    sub.Send_Kit__c = a.Send_Welcome_Kit__c;
    sub.Audio_subscription_size__c = a.Audio_subscription_size__c == null ? '150' : a.Audio_subscription_size__c;

    sub.Add_l_Provisioning_Email_Addresses__c = a.Add_E_Mails__c;
    sub.Add_l_Provisioning_Emails__c = a.Check_Add_Emails__c;
    sub.Contact_Toll_Free_Number__c = a.Toll_Free_Number__c;
    sub.Contact_Toll_Number__c = a.Toll_Number__c;

    //Copy Department fields
    if (c.SF_Department_ID__c != null) {
      Department__c d = (Department__C) RTDatabaseUtils.getEntireSObject(new Department__c(), c.SF_Department_ID__c);
      if (d.Additional_email_addresses__c != null) {
        sub.Add_l_Provisioning_Email_Addresses__c = d.Additional_email_addresses__c;
        sub.Add_l_Provisioning_Emails__c = true;
      }

      sub.Contact_Start_Page__c = d.Start_Page__c;
      sub.Ship_To_Name__c = d.Ship_to_Name__c;
      sub.Send_Provisioning_Email__c = d.Send_provisioning_email__c;
      sub.Send_Kit__c = d.Send_Welcome_Kit__c;
    }

    //Copy Contact fields
    sub.Card_Name__c = c.FirstName + ' ' + c.LastName;
    sub.Subscription_Email__c = c.Email;
    sub.Contact__c = c.id;
    sub.Parent_Ind_ID__c = c.Individual_ID__c;
    if(!String.isBlank(c.MailingStreet)) {
      String[] splitAddress = c.MailingStreet.split('\n');
      if(splitAddress.size() > 0) {
        sub.Address_Line_1__c = splitAddress[0];
      } 
      if(splitAddress.size() > 1) {
        sub.Address_Line_2__c = splitAddress[1];
      }
    }
    sub.City__c = c.MailingCity;
    sub.State__c = c.MailingState;
    sub.Zip__c = c.MailingPostalCode;
    sub.Country__c = c.MailingCountry;
    sub.Ship_to_Name__c = sub.Ship_to_Name__c == null ? c.FirstName + ' ' + c.LastName : sub.Ship_to_Name__c;

    //Values that are still empty after trying to copy from Account/Department/Contact
    sub.Country__c = sub.Country__c == null ? 'United States' : sub.Country__c;

    //Default values
    sub.status__c = 'Not Provisioned';

    sub.Web_Sub_Default_Type__c = a.Web_Sub_Default_Type__c;
    sub.Web_Start_Date__c = Date.today();
    sub.RecordType = [select id, name from RecordType where SobjectType = 'Subscription__c' and name = 'Not Provisioned'];
    sub.Name = RTAccessCodeUtils.getNewAccessCode(c.Phone);
    sub.Passcode__c = RTAccessCodeUtils.getNewPassCode();
  }
}