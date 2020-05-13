@isTest
public class CreateCampaignHistoryFromLeadTest {
    @testSetup static void setup() {
        PGITestUtilities.disableSalesWings();
        Id pgiRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PGi Leads').getRecordTypeId();
        
        List<Lead> leadList = new List<Lead>{new Lead(LastName = 'TestLead',LeadSource = 'ECommerce Customer',Company = 'testlead',
                                                      CurrencyIsoCode = 'USD',Status = 'New',   
                                                      Omniture_Campaign_Code_Copy__c = 'TestOCcode',Email = 'testlead@gmail.com',
                                                      RecordTypeId = pgiRecordTypeIdLead,Omniture_Campaign_Code__c = 'GREEN') };
                                                          
        Insert leadList;
        
        List<Campaign> cmgnList = new List<Campaign>{
            new Campaign(Name = 'testCmpn',IsActive = true) };
                Insert cmgnList;

        List<CampaignMember> cmList = new List<CampaignMember>	{
            new CampaignMember(status = 'Opened',CampaignId = cmgnList[0].Id,LeadId = leadList[0].Id) };
                Insert cmList;

        List<Omniture_Campaign_Code__c> occList = new List<Omniture_Campaign_Code__c>{
            new Omniture_Campaign_Code__c(campaign__c = cmgnList[0].id ,omniture_campaign_code__c = 'TestOCCode')};
                Insert occList;
    }
    static testMethod  void  testCreateCampaignHistoryFromLead(){
        Test.startTest(); 
		Lead lObj = [Select id,status,lastname from Lead where LastName = 'TestLead' limit 1];
        lObj.status = 'Open';
        Update lObj;
        Test.stopTest();
    }
}