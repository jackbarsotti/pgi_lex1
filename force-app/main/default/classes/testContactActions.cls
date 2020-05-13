@isTest
class testContactActions {

    static testMethod void testSyncAddressCreateWithStdOnly() {
    	Contact newContact = new Contact();
      newContact.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
    	newContact.MailingStreet = '101 Main St.';
    	newContact.MailingCity = 'Denver';
    	newContact.MailingCountry = 'USA';
    	newContact.MailingState = 'Colorado';
    	newContact.MailingPostalCode = '80202';
    	
    	Contact[] newObj = new List<Contact>();
    	newObj.add(newContact);
    	
    	//ContactActions.syncAddressFields(newObj, null);
    	
    	//System.assert('UNITED STATES'.equals(newObj[0].MailingCountry));
    }
    
    //static testMethod void testUpdateStdFields() {
    //  Contact newContact = new Contact();
    //  newContact.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
    //  newContact.MailingStreet = '101 Main St.';
    //  newContact.MailingCity = 'Denver';
    //  newContact.MailingCountry = 'USA';
    //  newContact.MailingState = 'Colorado';
    //  newContact.MailingStateCode = 'CO';
    //  newContact.MailingPostalCode = '80202';
      
    //  Contact[] newObj = new List<Contact>();
    //  newObj.add(newContact);
      
    //  //Contact oldContact = new Contact();
    //  //oldContact.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkContactRecordTypes[0].Id;
    //  //oldContact.MailingStreet = '101 Main Street';
    //  //oldContact.MailingCity = 'Dallas';
    //  //oldContact.MailingCountry = 'USA';
    //  //oldContact.MailingState = 'TX';
    //  //oldContact.MailingPostalCode = '75230';
      
    //  Contact[] oldObj = new List<Contact>();
    //  oldObj.add(oldContact);
      
    //  //ContactActions.syncAddressFields(newObj, oldObj);
      
    //  //System.assert('UNITED STATES'.equals(newObj[0].MailingCountry));
    //  System.assert('Denver'.equals(newObj[0].MailingCity));
    //  System.assert('101 Main St.'.equals(newObj[0].MailingStreet));
    //  System.assert('CO'.equals(newObj[0].MailingStateCode));
    //  System.assert('80202'.equals(newObj[0].MailingPostalCode));   
      
    //}
}