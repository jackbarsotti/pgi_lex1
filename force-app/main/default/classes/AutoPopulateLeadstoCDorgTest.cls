@isTest
public class AutoPopulateLeadstoCDorgTest {
    // static void  testautoPopulateLeadtoCDOrg(){
    @testSetup static void setup() {
        
        Id pgiRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
        User u = [select id , name from user where name = 'Wesley x-Lucas' limit 1];
        List<Lead> leadList = new List<Lead>{new Lead(LastName = 'TestLead',LeadSource = 'ECommerce Customer',Company = 'RRleadassignment',
                                                      CurrencyIsoCode = 'USD',Status = 'New',CreatedbyId = u.Id,   
                                                      Phone = '1592839429',Email = 'testlead@gmail.com',
                                                      RecordTypeId = pgiRecordTypeIdLead) };
                                                          
                                                          Insert leadList;
    }
    static testMethod  void  testautoPopulateLeadtoCDOrg(){
        Test.startTest(); 
        
        Test.stopTest();
    }
    
    
}