@isTest
private class testValidateSubscriptionFields {
    private static List<Subscription__c> newList;
    private static List<Subscription__c> oldList;
    
    static {
        PGITestUtilities.disableSalesWings();
        MockSubscription mock = new MockSubscription();
        mock.Promotion = '30 day free web trial';
        mock.WebSubDefaultType = 'Web Meeting';
        mock.BillingID = 123456;
        
        MockSubscription badMock = new MockSubscription();
        badMock.WebStartDate = Date.newInstance(1960, 1, 2); 
        badMock.BillingID = 123456;

        newList = new List<Subscription__c>();
        newList.add((Subscription__c) RTDatabaseUtils.getEntireSObject(new Subscription__c(), mock.getSubscription().id));
        //newList.add((Subscription__c) RTDatabaseUtils.getEntireSObject(new Subscription__c(), badMock.getSubscription().id));

        oldList = new List<Subscription__c>();
        oldList.add(MockSubscription.getNewSubscription());        
    }
    
    /*
    static testMethod void testValidateWebRateStartDate() {
        System.assert(ValidateSubscriptionFields.validateWebRateStartDate(newList, oldList) == true);
    }
    
    static testMethod void testValidateFreeTrial() {
        System.assert(ValidateSubscriptionFields.validateFreeTrial(newList, oldList) == true);
    }
    */
    
    static testMethod void testValidPasscodes(){
      String beginningPasscode = newList[0].passcode__c;
      newList[0].passcode__c = '123589';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '1221';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '0199';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '9900';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '0128';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '3789';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '1112';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '2212';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '0003';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
      newList[0].passcode__c = '0998';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == true);
 
      newList[0].passcode__c = newList[0].name.substring(4);
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = newList[0].name.substring(3);
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = newList[0].name;
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '1111';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '2222';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '3333';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '4444';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '5555';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '6666';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '7777';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '8888';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '9999';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '0000';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '0123';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '3456';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '6789';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '012345678';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '9876';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '3210';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);
      newList[0].passcode__c = '5432';
      System.assert(ValidateSubscriptionFields.validatePasscode(newList) == false);

      newList[0].passcode__c = beginningPasscode;
    }
}