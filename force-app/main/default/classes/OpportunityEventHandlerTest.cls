@isTest
private class OpportunityEventHandlerTest {
    @testSetup static void setup()
    {
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
        
        Opportunity oppor = new Opportunity();
        oppor.name = 'Test oppor-1';
        oppor.stagename = 'Awareness';
        oppor.ECommerce_Convert__c=false;
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
        Asset assetObj = new Asset();
        assetObj.Name='Test';
        assetObj.Opportunity__c = oppor.Id;
        assetObj.AccountId=act.Id;   
        assetObj.ContactId=ct2.Id;
        Insert assetObj;
        
    }
    
    static testMethod void testBeforeInsert() {
        Test.startTest();
        Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
        //Validate assert If required
        oppr.stagename = 'Closed Pending Approval';
        Update oppr;
        OpportunityEventHandler.skipExecution = false;
        oppr.ECommerce_Convert__c=true;
        oppr.stagename = 'Closed Won';
        Update oppr;
       Test.stopTest();
    }
    static testMethod void testAfterUpdate() {
        Test.startTest();
        Account a= [Select Id from Account Where Name='Test32'];
        Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(a.Id, oppr.Id);
        testContract.Contract_Source__c='iContract';
        testContract.Account_s_Agreement_Name__c='Test';
        testContract.Service_Commencement_Date__c=Date.today();
        testContract.Contracted_Term__c=null;
        Insert testContract;
        oppr.stagename = 'Closed Pending Approval';
        OpportunityEventHandler.skipExecution = false;
        oppr.ECommerce_Convert__c=true;
        Update oppr;
        oppr.stagename = 'Closed Won';
        Update oppr;
        CONMAN_Contract__c testContract1 =[Select Id,Account_s_Agreement_Name__c,Company_s_Name__c,Sales_Ops_Status__c,Contract_Document_Status__c from CONMAN_Contract__c Where Contract_Source__c='iContract'];
        System.debug('The CONMAN_Contract__c123'+testContract1);
        System.assertEquals(testContract.Account_s_Agreement_Name__c, testContract1.Account_s_Agreement_Name__c);
        System.assertEquals('Draft', testContract1.Sales_Ops_Status__c);
        System.assertEquals('Active', testContract1.Contract_Document_Status__c);
        Test.stopTest();
    }
    static testMethod void testAfterUpdateNull() {
        Test.startTest();
        Account a= [Select Id from Account Where Name='Test32'];
        Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
        echosign_dev1__SIGN_Agreement__c es = new echosign_dev1__SIGN_Agreement__c();
        es.echosign_dev1__Status__c = 'Signed';
        INSERT es;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(a.Id, oppr.Id);
        testContract.Contract_Source__c='iContract';
        testContract.Account_s_Agreement_Name__c=null;
        testContract.Service_Commencement_Date__c=Date.today();
        testContract.Contracted_Term__c=2;
        testContract.Related_Agreement__c=es.Id;
        testContract.Service_Commencement_Date__c=null;   
        Insert testContract;
        oppr.stagename = 'Closed Pending Approval';
        Update oppr;
        OpportunityEventHandler.skipExecution = false;
        oppr.stagename = 'Closed Won';
        oppr.ECommerce_Convert__c=true;
        Update oppr;
        CONMAN_Contract__c testContract1 =[Select Id,Account_s_Agreement_Name__c,Service_Commencement_Date__c,Auto_Renewal__c,Company_s_Name__c,Sales_Ops_Status__c,Contract_Document_Status__c from CONMAN_Contract__c Where Contract_Source__c='iContract'];
        System.assertEquals('Test32', testContract1.Company_s_Name__c);
        System.assertEquals(true, testContract1.Auto_Renewal__c);
        System.assertEquals(Date.today().format(), testContract1.Service_Commencement_Date__c.format());
        Test.stopTest();
    }
    static testMethod void testAfterUpdatevalidateRampDates() {
        Test.startTest();
        User u = [Select Id from User Where Id=:UserInfo.getUserId()];
        System.runAs(u){
            PermissionSet ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'GCS_Read_Write_Ramp_Dates' limit 1].Id;
            insert sea;
            Account a= [Select Id from Account Where Name='Test32'];
            Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
            Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
            oppr.stagename = 'Closed Pending Approval';
            update oppr;
            // oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
            // System.assertNotEquals('Closed Won', oppr.StageName);
            // OpportunityEventHandler.skipExecution = false;
            // oppr.ECommerce_Convert__c=true;
            // oppr.stagename = 'Closed Won';
            // update oppr;
           Test.stopTest();
        }  
    }
    static testMethod void testAfterUpdatevalidateRampDatesException() {
        Test.startTest();
        User u = [Select Id from User Where Id=:UserInfo.getUserId()];
        System.runAs(u){
            try{
                PermissionSet ps = new PermissionSet();
                ps.Name = 'Test';
                ps.Label = 'Test';
                insert ps;
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = UserInfo.getUserId();
                psa.PermissionSetId = ps.Id;
                insert psa;
                SetupEntityAccess sea = new SetupEntityAccess();
                sea.ParentId = ps.Id;
                sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'GCS_Read_Write_Ramp_Dates' limit 1].Id;
                insert sea;
                Account a= [Select Id from Account Where Name='Test32'];
                Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
                Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
                Product2 standardProduct = PGITestUtilities.getStdProduct();
                insert standardProduct;
                PricebookEntry standardPbe = PGITestUtilities.CreatePriceBookEntryForProduct(standardProduct);
                insert standardPbe;
                OpportunityLineItem oli = PGITestUtilities.getOpportunityLineItemDetails(oppr.Id, standardPbe.Id);
                oli.Existing_Service__c = false;
                insert oli; 
                oppr.stagename = 'Closed Pending Approval';
                Update oppr;
                OpportunityEventHandler.skipExecution = false;
                oppr.ECommerce_Convert__c=true;
                oppr.stagename = 'Closed Won';
                update oppr;
            }
            Catch(Exception e){
                // System.assert(e.getMessage().contains('Before setting Probability % to 80 or higher or Status to Closed Pending Approval, both Initial Bill Date and 100% Ramp Date on the product screen are required for any product that is not an Existing Service'));
                
            }
        }  
        Test.stopTest();
    }
    static testMethod void testUpdateOppFields() {
        Test.startTest();
        User u = [Select Id from User Where Id=:UserInfo.getUserId()];
        Set<Id> ownerId = new Set<Id>();
        ownerId.add(u.Id);
        System.runAs(u){
            Set<Id> closeOppId = new Set<Id>();
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
            oppr.stagename = 'Closed Pending Approval';
            oppr.OwnerId=u.Id;
            Update oppr;
            OpportunityEventHandler.skipExecution = false;
            oppr.ECommerce_Convert__c=true;
            oppr.stagename = 'Closed Won';
            update oppr;
            closeOppId.add(oppr.Id);
            oppList.add(oppr);   
            OpportunityEventHandler.UpdateOppFields(ownerId, oppList);    
            OpportunityEventHandler.addExistingOppLineItem(closeOppId);
           
        }
        Test.stopTest();
    } 
        static testMethod void testDeleteLicenseSet() {
            Test.startTest();
        Licenseset__c licenceSetObj = [Select Id ,Opportunity__c from Licenseset__c];
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
        oppList.add(oppr);
        OpportunityEventHandler.deleteOpporLicenseSets(oppList);
        Licenseset__c deletedliscSet = [SELECT Id, IsDeleted FROM Licenseset__c WHERE Z_Source__c = 'eCommerce' ALL ROWS];
        System.assertEquals(true, deletedliscSet.IsDeleted);
        Test.stopTest();
    }
    static testMethod void testDeleteAsset() {
        Test.startTest();
        Asset aseetObj = [Select Id,Opportunity__c from Asset];
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppr = [Select Id ,name,stagename,ECommerce_Convert__c,closeDate,ECommerce_Account_Number__c,Accountid,Z_Source__c,Acct_Admin_Decison_Maker_Checked__c from opportunity Where Name='Test oppor-1'];
        oppList.add(oppr);
        OpportunityEventHandler.deleteOpporLicenses(oppList);
        Asset deletedAsset = [SELECT Id, IsDeleted FROM Asset WHERE Name='Test' ALL ROWS];
        System.assertEquals(true, deletedAsset.IsDeleted);
        Test.stopTest();
    }
}