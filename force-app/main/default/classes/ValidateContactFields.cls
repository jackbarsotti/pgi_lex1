public class ValidateContactFields {

  /**
   * Validation for Contact fields when provisioning
   */
  public static void validate(Contact c) {
    String message = '';

    //S2983: Do not allow user to provision contact if Account is Not Active
    if(!c.Account.Status__c.equals('Active'))
      throw new AccountNotActiveException('Account must be provisioned prior to provisioning a contact/subscription.');

    if(c.Phone == null)
      message = message + 'Phone Number is required on Contact.<br/>';
    if(c.FirstName == null)
      message = message + 'First Name is required on Contact.<br/>';
    if(c.LastName == null)
      message = message + 'Last Name is required on Contact.<br/>';
    if(c.Email == null)
      message = message + 'Email is required on Contact.<br/>';
    if(c.MailingStreet == null)
      message = message + 'Street Address is required on Contact.<br/>';
    if(c.MailingCity == null)
      message = message + 'City is required on Contact.<br/>';
    if(c.MailingCountry == null)
      message = message + 'Country is required on Contact.<br/>';
    if(c.MailingCountry != null && (c.MailingCountry.equals('UNITED STATES') || c.MailingCountry.equals('CANADA')) && c.MailingState == null)
      message = message + 'State is required on Contact.<br/>';
    if(c.MailingCountry != null && (c.MailingCountry.equals('UNITED STATES') || c.MailingCountry.equals('CANADA')) && c.MailingPostalCode == null)
      message = message + 'Zip Code is required on Contact.<br/>';


    if(c.MailingCountry != null && c.MailingCountry.equals('UNITED STATES') && c.Phone != null && (
        c.Phone.startsWith('(1') || 
        c.Phone.startsWith('(800') ||
        c.Phone.startsWith('(866') ||
        c.Phone.startsWith('(877') || 
        c.Phone.startsWith('(888') ||
        c.Phone.startsWith('1') || 
        c.Phone.startsWith('800') ||
        c.Phone.startsWith('866') ||
        c.Phone.startsWith('877') || 
        c.Phone.startsWith('888')                 
    )) {
      message = message + 'Phone in the United States may not begin with a "1", "800", "866", "877" or "888"<br/>';
    }

    if(message.length() > 0)
      throw new ConstructableException(message);
  }
  public static void validateOnSave(Contact c) {
    if(c.FirstName.length() + c.LastName.length() > 48)
      throw new ConstructableException('Length of First Name and Last Name cannot be greater than 48 characters.  Current length is: '+c.FirstName.length() + c.LastName.length());
  }
}