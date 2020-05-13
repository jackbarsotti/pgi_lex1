@isTest
private class testValidateContactFields {

  /**
  * A lot of Assertions
  * NOTE: These are in reverse order from how they appear in ValidateContactFields method.
  */
  static testMethod void testValidate() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    Contact c = MockContact.getNewContact();
    c.MailingCountry = 'UNITED STATES';
    c.Account.Status__c = 'Active';

    //Assert that a bad phone # throws an exception
    c.Phone = '13032091756';
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Phone in the United States may not begin with a "1", "800", "866", "877" or "888"'));
    }    

    //Assert that a null zip code throws an exception
    c.MailingPostalCode = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Zip Code is required on Contact'));
    }

    //Assert that a null state throws an exception
    c.MailingState = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('State is required on Contact'));
    }

    //Assert that a null country throws an exception
    c.MailingCountry = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Country is required on Contact'));
    }    

    //Assert that a null mailing city throws an exception
    c.MailingCity = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('City is required on Contact'));
    }  

    //Assert that a null addresss1 throws an exception
    c.MailingStreet = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Street Address is required on Contact'));
    }

    //Assert that a null email address throws an exception
    c.Email = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Email is required on Contact'));
    }         

    //Assert that a null LastName throws an exception
    c.LastName = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Last Name is required on Contact'));
    } 

    //Assert that a null FirstName throws an exception
    c.FirstName = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('First Name is required on Contact'));
    }  

    //Assert that a null Phone throws an exception
    c.Phone = null;
    try{
      ValidateContactFields.validate(c);
    }
    catch(ConstructableException ce){
      System.assert(ce.getMessage().contains('Phone Number is required on Contact'));
    }          

    //Assert that a non-active Status throws an exception
    c.Account.Status__c = 'New';
    try{
      ValidateContactFields.validate(c);
    }
    catch(AccountNotActiveException ce){
      System.assert(ce.getMessage().contains('Account must be provisioned prior to provisioning a contact/subscription'));
    }         
  }
}