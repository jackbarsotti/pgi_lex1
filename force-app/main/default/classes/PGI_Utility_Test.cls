@isTest (seealldata=true)
private class PGI_Utility_Test {
    static testMethod void testPgiUtility() {
        PGITestUtilities.disableSalesWings();
        Account act = new account(Name = 'Test32',ABM_Last_PES__c='testData',ABM_PES_Last_Change_Date__c =Date.today(),Bill_Address_Verification__c =Date.today().AddDays(2), Z_Source__c = 'eCommerce');
        insert act;
        
        System.assert(act.id <> null);
        
        Contact ct = new Contact();
        ct.FirstName = 'klnasknjaskldasd';
        ct.LastName  = 'efoijasjkndalkmsd';
        ct.Phone     = '3819405828';
        ct.Email     = 'knasdlkmsdklgasd@premierglobal.com';
        ct.accountId = act.id;
        ct.License_Profile__c = true;
        insert ct;
        
        Contact ct2 = new Contact();
        ct2.FirstName = 'cjnasdnkjaklwflkf';
        ct2.LastName  = 'njifasoinawlrkalsd';
        ct2.Phone     = '1950247284';
        ct2.Email     = 'efkjnsdlkmsalmd@premierglobal.com';
        ct2.accountId = act.id;
        ct2.License_Profile__c = true;
        insert ct2;
        Lead ld = new Lead(
            FirstName = 'cjnkdfjnklknasjknfawbjkd',
            LastName = 'cansknjaeflkwanjkd',
            Phone = '1592839429',
            Email = 'jknasnkjaskdjnlasd@pgi.com',
            //ECommerce_Account_Number__c = 'Ecom-000000001',
            ECommerce_Convert__c = false,
            LeadSource = 'ECommerce Customer',
            Company = 'cjknasnlklkmasdjkbasd',
            Status = 'Qualifying',
            Street = '1500 cnasdjknawlkf',
            City = 'SanJose',
            State = 'California',
            StateCode = 'CA',
            PostalCode = '25859',
            Country = 'United States',
            CountryCode = 'US',
            Business_Type__c = 1,
            DoNotSolicit__c = true,
            Z_Source__c = 'eCommerce',
            Account_Type__c = 'Affinity'
        );
        
        insert ld;
        Opportunity oppor = new Opportunity();
        oppor.name = 'Test oppor-1';
        oppor.stagename = 'Awareness';
        oppor.closeDate= system.today().addDays(100);
        oppor.ECommerce_Account_Number__c = 'Ecom-000000001';
        oppor.accountid = act.id;
        oppor.Z_Source__c = 'eCommerce';
        oppor.Acct_Admin_Decison_Maker_Checked__c = 'Yes';
        insert oppor;
        // Insert offerings
        Licenseset__c licSet        = new Licenseset__c();
        licSet.Description__c       = 'Lic Set - 1';
        licSet.End_Date__c          = system.today().adddays(100);
        licSet.Lead__c              = ld.id;
        licSet.Line_Number__c       = 1;
        licSet.Number_of_Licensed_Named_Users__c = 1;
        licSet.Order_Number__c      = 1;
        licSet.Price__c             = 12.22;
        licSet.SKU__c               = 'SKU-000000001';
        licSet.Start_Date__c        = system.today();
        licSet.Subscription_License_Term_Months__c = 12;
        licSet.name                 = 'Lic Set -1';
        licSet.Opportunity__c=oppor.Id;
        licSet.Z_Source__c = 'eCommerce';    
        insert licSet;
        
        Set<String> fieldsToRemove = new  Set<String>();
        fieldsToRemove.add('ABM_Last_PES__c');
        List<Account> accList = new List<Account>();
        accList.add(act);
        PGI_Utility obj = new PGI_Utility();
        PGI_Utility.removeFields(accList,fieldsToRemove);
        Account a = [Select ABM_Last_PES__c from Account Where Name='Test32'];
        System.debug('The return list'+PGI_Utility.removeFields(accList,fieldsToRemove));
        system.assertEquals(Date.today().AddDays(2), PGI_Utility.findMinimumDate(accList,'Bill_Address_Verification__c'));
        system.assertEquals(Date.today(), PGI_Utility.findMaximumDate(accList,'ABM_PES_Last_Change_Date__c'));
        Date d= Date.today().addMonths(1);
        system.assertEquals(Date.newInstance(d.year(), d.month(), 1), PGI_Utility.startOfNextMonth(Date.today()));
        Date d1= Date.today();
        Integer daysInMonth = Date.daysInMonth(d1.year(), d1.month());
        system.assertEquals(Date.newInstance(d1.year(), d1.month(), daysInMonth), PGI_Utility.endOfMonth(Date.today()));
        system.assertEquals(null, PGI_Utility.startOfNextMonth(null));
        system.assertEquals(null, PGI_Utility.endOfMonth(null));
        system.assertEquals(null, PGI_Utility.startOfMonth(null));
        List<Licenseset__c> licensesetList = new List<Licenseset__c>();
        licensesetList.add(licSet);
        
        List<Asset> assetLst =new List<Asset>();
        assetLst.add(PGI_Utility.createOpporAsset(licensesetList)[0]);
       //System.debug('123'+PGI_Utility.createOpporAsset(licensesetList));
        system.assertEquals('Lic Set -1', assetLst[0].Name);
        List<opportunity> opprLst = new List<opportunity>();
        opprLst.add(oppor);
        Map<Id,Id> ldOpprIdMap = new Map<Id,Id>();
        ldOpprIdMap.put(ld.Id, oppor.Id);
        //PGI_Utility.createOpporLicenseSet(ldOpprIdMap);
        User currentUser = PGI_Utility.currentUser;
        Integer currentHourInGMT =PGI_Utility.hourInMT;
        list<Licenseset__c> licSetLst = new list<Licenseset__c>();
        licSetLst.add( PGI_Utility.createOpporLicenseSet(ldOpprIdMap)[0]);
        system.assertEquals(oppor.Id, licSetLst[0].opportunity__c);
    }
    
}