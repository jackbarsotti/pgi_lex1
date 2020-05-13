@isTest(SeeAllData=true)
private with sharing class testLeadRest {  

  //static{
  //  RestRequest req = new RestRequest(); 
  //  RestResponse res = new RestResponse();
  //  RestContext.request = req;
  //  RestContext.response = res;    
  //}  

  //static testMethod void test_Convert_With_Invalid_LeadId() {
  //  User testUser = TLS_TestDataFactory.createUser('System Administrator');
  //  testUser.FirstName = 'Inside';
  //  testUser.LastName = 'Sales';
  //  insert testUser;
  //  LeadRest.convert('badLeadId');
  //  String response = RestContext.response.responseBody.toString();
  //  System.assert(response == '{"errors":[{"detail":"Invalid id: badLeadId"}]}', response);
  //}

  //static testMethod void test_Convert_With_Valid_LeadId() {
  //  User testUser = TLS_TestDataFactory.createUser('System Administrator');
  //  testUser.FirstName = 'Inside';
  //  testUser.LastName = 'Sales';
  //  insert testUser;
  //  //RecordType ldRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Lead' AND Name LIKE '%ReadyTalk%' LIMIT 1];
  //  Lead l = new Lead(FirstName='Bob', LastName='Smith', Phone='303-209-1610', Company='Acme', No_of_Employees__c='100', Country='UNITED STATES', CountryCode='US', State='Colorado', StateCode='CO', Email='qa@readytalk.com');
  //  Database.SaveResult s = Database.insert(l);

  //  LeadRest.convert(s.getId());
  //  String response = RestContext.response.responseBody.toString();
  //  //System.assert(false, [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]);
  //  //System.assert(false, [SELECT Id from User where FirstName='Inside' and LastName='Sales' limit 1]);
  //  //System.assert(false, [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1].MasterLabel);
  //  System.assert(!response.contains('error'), response);
  //}
}