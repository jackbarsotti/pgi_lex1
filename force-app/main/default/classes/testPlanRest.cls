@isTest(SeeAllData=true)
private with sharing class testPlanRest {  

  static{
    Pkg packageRepo = new Pkg();
    Schedule scheduleRepo = new Schedule();
    Product productRepo = new Product();
    String emailContext = '{"package":{"name":"Meeting Free Trial"}, "card":{"callMeAnchorText": "callme.readytalk.com", "callMeAnchorType": "callme", "callMeText": "Audio & Online Meetings", "renderVOIPLinkData": true }, "startButton":{"renderStartMeetingButton": true, "startMeetingButtonText": "Start My First Meeting Now"} }';
    Package__c pkg = packageRepo.savePackage('fooPackage', 'ACCESS_CODE', 'A test package', emailContext);
    Schedule__c schedule = scheduleRepo.saveSchedule('fooSchedule', 'A test schedule', 'Audio', Double.valueOf(100.0));
    RT_Product__c product = productRepo.saveProduct('fooProduct', pkg.Id, 49.00, 'INVOICE', schedule.Id, 0.00, 'WEB', true);    
    
   
    RestRequest req = new RestRequest(); 
    RestResponse res = new RestResponse();
    
    req.requestURI = '/services/apexrest/Plan';
    req.httpMethod = 'POST';
    RestContext.request = req;
    RestContext.response = res; 
  }  

  static testMethod void test_AddPlan_With_Invalid_Package() {
      Test.startTest();
    PlanRest.addPlan('fooAccountId', 'invalidPackage', '', '', '0');    
    String response = RestContext.response.responseBody.toString();
      Test.stopTest();
      
    System.assert(response.contains('error'));
  }
  static testMethod void test_AddPlan_With_Invalid_AccountId() {
      Test.startTest();
    PlanRest.addPlan('fooAccountId', 'fooPackage', '', '', '4');    
    String response = RestContext.response.responseBody.toString();
      Test.stopTest();
    System.assert(response.contains('error'));
      
  }

   static testMethod void test_AddPlan_With_Valid_Data() {
       Test.startTest();
    Account a = MockAccount.getNewAccount();
    
    PlanRest.addPlan(a.Id, 'fooPackage', '', '', '0'); 
   // PlanRest.addPlan(a.Id,pkg.Id,'fooPackage', today.format(), '', '',product );  
    String response = RestContext.response.responseBody.toString();
       Test.stopTest();
      //System.assert(!response.contains('error'));
  }
}