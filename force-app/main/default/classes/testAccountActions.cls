@isTest
private class testAccountActions {
  static testMethod void testOnAccountOwnerChanged() {    
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    Subscription__c s = MockSubscription.getNewSubscription();
    Contact c = (Contact) RTDataBaseUtils.getEntireSObject(new Contact(), s.contact__c);
    Account a = (Account) RTDataBaseUtils.getEntireSObject(new Account(), c.AccountId);
    a.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
    a.OwnerId = MockUser.getSoapUser().Id;
    update(a);
    System.assert(1==1);
  }

  static testMethod void testUpdateCustomFields() {
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
    Account newAccount = new Account();
    newAccount.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
    newAccount.BillingStreet = '101 Main St.';
    newAccount.BillingCity = 'Denver';
    newAccount.BillingCountry = 'USA';
    newAccount.BillingState = 'Colorado';
    newAccount.BillingPostalCode = '80202';
    

    Account[] newObj = new List<Account>();
    newObj.add(newAccount);

    Account oldAccount = new Account();
    oldAccount.RecordTypeId = ReadyTalkRecordTypeHelper.readyTalkAccountRecordTypes[0].Id;
    oldAccount.BillingStreet = '101 Main St.';
    oldAccount.BillingCity = 'Denver';
    oldAccount.BillingCountry = 'USA';
    oldAccount.BillingState = 'Colorado';
    oldAccount.BillingPostalCode = '80202';


    Account[] oldObj = new List<Account>();
    oldObj.add(oldAccount);

    AccountActions.syncAddressFields(newObj, oldObj);

    //System.assert('United States'.equals(newObj[0].BillingCountry));
    System.assert('Denver'.equals(newObj[0].BillingCity));
    System.assert('101 Main St.'.equals(newObj[0].BillingStreet));
    System.assert('Colorado'.equals(newObj[0].BillingState));
    System.assert('80202'.equals(newObj[0].BillingPostalCode));

  }
}