@isTest
private class LicensesetEventHandler_Test {
    @isTest static void testLicensesetEventHandler(){
        PGITestUtilities.disableSalesWings();
        test.startTest();
        
        
        Account acc = new Account();
        acc.Name = 'Acc-ContactRoles';
        acc.Website='https://www.google.com';
        acc.Type='Direct';
        insert acc;
        Id RecordTypeId = [Select Id from RecordType Where DeveloperName='PGi_Contact' And SobjectType='Contact' limit 1].Id;
        // Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PGi_Contact').getRecordTypeId();
        Contact con = new Contact();
        //con.RecordTypeId=RecordTypeId;
        con.AccountId=acc.Id;
        con.LastName='Test';
        con.Email='Test@q.com';
        con.Title='Title';
        con.Language_Preference__c='FR';
        Insert con;
        Opportunity opporObj = new Opportunity();
        opporObj.AccountId =acc.Id;
        opporObj.Name='Test1';
        opporObj.Opportunity_Source_Open__c='Customer';
        opporObj.StageName='Prospecting';
        opporObj.CloseDate=Date.today();
        opporObj.Has_PGI_Contract__c =false;
        opporObj.Has_PGI_Contract__c =false;
        Insert opporObj;
        Licenseset__c licSet = new Licenseset__c();
        licSet.Name='Test01';
        licSet.Z_Source__c='eCommerce';
        licSet.CurrencyIsoCode='USD';
        licSet.CompanyID__c =null;
        licSet.Opportunity__c=opporObj.Id;
        licSet.HubID__c = null;
        licSet.Number_of_Licensed_Named_Users__c= 1;
        INSERT licSet;
        System.debug('licSet'+licSet);
        licSet.Admin_Text_Tag__c='Test';
        licSet.CompanyID__c ='CompanyTest';
        licSet.HubID__c = 'TestHub';
        UPDATE licSet;
        Asset objAsset = [Select Id,accountid from Asset];
        System.assertEquals(acc.Id,objAsset.accountid);
        test.stopTest();
    }
}