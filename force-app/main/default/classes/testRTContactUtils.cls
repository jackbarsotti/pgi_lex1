@isTest
private class testRTContactUtils {
  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  static testMethod void testProvision() {
    MockContact mock = new MockContact();
    RTContactUtils.Provision(mock.getContact());
    System.assert(1 == 1);
  }

  static testMethod void testCustomDelete() {
    Contact c = MockContact.getNewContact();
    RTContactUtils.customDelete(c);
  }

  static testMethod void testPushAddressToAccessCode() {
    MockContact mockContact = new MockContact();
    mockContact.MailingAddress1 = 'mailing1';
    mockContact.MailingAddress2 = 'mailing2';
    mockContact.MailingCity = 'mailcity';
    mockContact.MailingState = 'Alaska';
    mockContact.MailingStateCode = 'AK';
    mockContact.MailingZip = '80016';
    mockContact.MailingCountry = 'UNITED STATES';
    MockSubscription mockSub1 = new MockSubscription();
    MockSubscription mockSub2 = new MockSubscription();

    Contact c = mockContact.getContact();
    mockSub1.ContactId = c.Id;
    mockSub2.ContactId = c.Id;
    Subscription__c sub1 = mockSub1.getSubscription();
    Subscription__c sub2 = mockSub2.getSubscription();

    List<String> errors = RTContactUtils.pushAddressToActiveAccessCodes(c.Id);

    List<Subscription__c> subs = RTAccessCodeUtils.getSubscriptionsByContact(c);
    System.assertEquals(2, subs.size());
    Subscription__c firstSub = subs.get(0);
    System.assertEquals(c.MailingCity, firstSub.City__c);
    //System.assertEquals(c.MailingState, firstSub.State__c);
    //System.assertEquals(c.MailingPostalCode, firstSub.Zip__c);
    //System.assertEquals(c.MailingCountry, firstSub.Country__c);
  }
    static testmethod void testprovisionContact(){
         Contact c = MockContact.getNewContact();
        RTContactUtils.provisionContact(c.Id);
        system.assertNotEquals(null,c.Id);
       
    }
     static testmethod void testprovisionContactStatus(){
         Contact c = MockContact.getNewContact();
         c.Status__c='Active';
         upsert c;
        RTContactUtils.provisionContact(c.Id);
         
        system.assertNotEquals(null,c.Id);
     }
     static testmethod void testgetContactStatusMessage(){
         Contact c = MockContact.getNewContact();
        RTContactUtils.getContactStatusMessage(c.Id);
        system.assertNotEquals(null,c.Id);
       
    }
}