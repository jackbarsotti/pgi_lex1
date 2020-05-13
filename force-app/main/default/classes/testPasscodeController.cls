@isTest
private class testPasscodeController {
  private static ApexPages.StandardController controller;

  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  static testMethod void callGetPassCodeTest(){
    controller = new ApexPages.StandardController(RTDatabaseUtils.getEntireSObject(new Subscription__c(), MockSubscription.getNewSubscription().Id));
    new PasscodeController(controller);
    testGetPasscode();
  }

  @Future(callout=true) static void testGetPasscode() {  
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Map<String,Object> res = PasscodeController.getPasscode(((Subscription__c)controller.getRecord()).Id);

    // Verify response received contains fake values
    System.assertEquals('bar', res.get('foo')); 
    //RT-310 code to increase code coverage 
    PasscodeController getSubId = new PasscodeController(controller); 
    getSubId.getSubscriptionId();  
  }
}