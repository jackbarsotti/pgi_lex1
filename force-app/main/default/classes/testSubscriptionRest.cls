@isTest
private with sharing class testSubscriptionRest {  

  private static SFPCTestHelper sfpcTestHelper;
  private static RestRequest req;
  private static RestResponse res;
  private static Contact c;
  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  private static void init(){
    
    sfpcTestHelper = new SFPCTestHelper();
    req = new RestRequest();
    res = new RestResponse();
    
    c = MockContact.getNewContact();
    
    sfpcTestHelper.createForAccount((Account) RTDatabaseUtils.getEntireSObject(new Account(), c.Account.Id));    
    req.requestBody = Blob.valueOf('{"contactId":"'+c.Id+'", "planName":"fooPlan", "accessCode":{"PortalAdmin__c": true, "collabAllowed__c": true, "Audio_subscription_size__c": "10"}}');
    RestContext.request = req;
    RestContext.response = res;    
    
  }  

  static testMethod void test_Save_With_Valid_Data() {
    init();
    SubscriptionRest.save();    
    String response = RestContext.response.responseBody.toString();
    System.debug(response);
    System.assert(!response.contains('error'));
  }

  static testMethod void test_Save_With_Invalid_Plan() {
    init();
    req.requestBody = Blob.valueOf('{"contactId":"'+c.Id+'", "planName":"invalidPlan", "accessCode":{"PortalAdmin__c": true, "collabAllowed__c": true, "Audio_subscription_size__c": "10"}}');
    SubscriptionRest.save();    
    String response = RestContext.response.responseBody.toString();
    System.debug(response);
    System.assert(response.contains('error'));
  }
}