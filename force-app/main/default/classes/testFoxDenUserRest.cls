@isTest
private with sharing class testFoxDenUserRest {    
  @TestSetup
  static void makeData(){
    Test.startTest();
    PGITestUtilities.disableSalesWings();
    Test.stopTest();
  }
  private static void init(){        

    SFPCTestHelper sfpcTestHelper = new SFPCTestHelper();
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();            
    Contact c = MockContact.getNewContact();
    sfpcTestHelper.createForAccount((Account) RTDatabaseUtils.getEntireSObject(new Account(), c.Account.Id));    
    req.requestBody = Blob.valueOf('{"contactId":"'+c.Id+'", "planName":"fooPlan", "foxdenUser":{"Email__c": "qa@readytalk.com"}}');
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
    Contact c = MockContact.getNewContact();
    RestContext.request.requestBody = Blob.valueOf('{"contactId":"'+c.Id+'", "planName":"invalidPlan", "foxdenUser":{"Email__c": "qa@readytalk.com"}}');
    SubscriptionRest.save();    
    String response = RestContext.response.responseBody.toString();
    System.debug(response);
    System.assert(response.contains('error'));
  }
}