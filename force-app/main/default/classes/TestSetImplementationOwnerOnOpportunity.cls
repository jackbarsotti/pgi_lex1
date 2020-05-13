/*********************************************************************
Name : TestSetImplementationOwnerOnOpportunity
Created On : Dec 6, 2012  
Created By :  JP
Description : Test class to check functionality of trigger SetImplementationOwnerOnOpportunity on Implementation Service object
**********************************************************************/
@isTest(SeeAllData=true)
private class TestSetImplementationOwnerOnOpportunity{
    static testMethod void UnitTest_SetImplementationOwnerOnOpportunity() {
    
     User u=createUser();  
        System.runAs(u){
     Implementation_Services__c ImpSer= new Implementation_Services__c();
     
            Account acc= PGITestUtilities.createAccount(false);
            acc.Name='TestAccountSetImplementationOwnerOnOpportunity';
             acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'AL';
        acc.BillingPostalCode = '35630';
        acc.BillingStreet = '110 abc street';
            insert acc;
     
            /*Account acc= new Account();
            acc.Name='TestAccountSetImplementationOwnerOnOpportunity';
             acc.BillingCountryCode = 'US';
        acc.BillingStateCode = 'AL';
        acc.BillingPostalCode = '35630';
        acc.BillingStreet = '110 abc street';
            insert acc;*/
            
         Opportunity opp1 = PGITestUtilities.createOpportunity(acc, false);
          opp1.Name = 'test1';
          opp1.AccountId = acc.Id;
          opp1.CloseDate = system.today();
          opp1.StageName = 'Awareness';
          opp1.CurrencyIsoCode = 'USD';
          opp1.Products_of_Interest__c = 'Foxden';
          RecordType oppRecordtype = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name LIKE '%PGi%' LIMIT 1];
          opp1.recordtypeid = oppRecordtype.id;
          insert opp1;
            
         /*Opportunity opp1 = new Opportunity();
          opp1.Name = 'test1';
          opp1.AccountId = acc.Id;
          opp1.CloseDate = system.today();
          opp1.StageName = 'Awareness';
          opp1.CurrencyIsoCode = 'USD';
          opp1.Products_of_Interest__c = 'Foxden';
          insert opp1;*/
        
        opp1 = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opp1.Id];
        
         Product2 standardProduct = PGITestUtilities.getStdProduct();
         insert standardProduct;
         PricebookEntry standardPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct);
        standardPbe.UnitPrice = 10;
        insert standardPbe;
        Pricebook2 oppPb = [SELECT Id FROM PriceBook2 WHERE Id = :opp1.Pricebook2Id];
         PricebookEntry oppPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct, oppPb);
        oppPbe.UnitPrice = 10;
         insert oppPbe;
         OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(opp1.Id, oppPbe.Id);
         insert oli; 
     
        ImpSer.IST_Status__c='Open';
        ImpSer.Related_Opportunity__c=opp1.id;
        ImpSer.Implementation_Type__c ='Small Business <2K MMR';      
        ImpSer.Implementation_Owner__c = u.Id;
      
        
          test.startTest();
            insert ImpSer;
            test.stopTest();
        }
        }
    
     public static User createUser() {
        // need to change these values
        /*List<Profile> profiles = [select Id From Profile where Name = 'System Administrator' limit 1];
        String profileId = profiles.get(0).Id;
        User user = new User();
        user.Email = 'test@pgi.com';
        user.CommunityNickname = 'test@pgi.com';
        user.UserName = 'test@pgi.com.fulldata30';
        user.FirstName = 'Foo';
        user.LastName = 'Bar';
        user.Alias = 'foo';
        user.ProfileId = profileId;
        user.EmailEncodingKey = 'ISO-2022-JP';
        user.LanguageLocaleKey = 'ja';
        user.LocaleSidKey = 'ja_JP';
        user.TimeZoneSidKey = 'Asia/Tokyo';*/
        User user = PGITestUtilities.getTestUser();
        user.TESLA_SalesRep_Email__c ='testing1@testsite.com';
        user.TESLA_SALESMANAGER_ID__c='testsm1';
        user.User_Region__c='NA';
        user.Channel__c = 'None';
        insert user;
         System.debug('The user'+user.Profile_Name_Text__c);
        return user;
         
    }
}