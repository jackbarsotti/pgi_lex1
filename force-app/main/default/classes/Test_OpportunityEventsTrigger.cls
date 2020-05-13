@isTest
public class Test_OpportunityEventsTrigger {
     @testSetup static void setup() {
         Test.startTest();
       PGITestUtilities.disableSalesWings();
       Test.stopTest();
    }
    static testMethod void noPGiContract() {
        /* Insert Acct */
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.Name = 'AcctWithoutContract';
        insert testAcct; 
        
        /* Insert Opp */
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'OppWithoutContract';
        testOppty.AccountId = testAcct.Id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        insert testOppty; 

        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = testOppty.Id;
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = testAcct.Id;
        insert testPGiContract;
        
        /* Insert Contact */
        Contact testCntc = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testCntc; 
        
        /* Insert Primary Contact Role */
        OpportunityContactRole testCntcRole = new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testCntc.Id, IsPrimary=true);
        insert testCntcRole; 
        
        /* Insert Opportunity Line Item */
        Product2 testProd = PGITestUtilities.getStdProduct();
        insert testProd;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProd);
        insert testPbe;
        OpportunityLineItem testOpli = PGITestUtilities.getOpportunityLineItemDetails(testOppty.Id, testPbe.Id);
        insert testOpli; 
        
        /* Start Test (to reset SF Limits) */
         Test.startTest(); 
        
        /* Change Opp Stage to Closed Won */
        testOppty.StageName = 'Closed Won';
        testOppty.Primary_Won_Reason__c = 'Other';
        testOppty.Other_Won_Reason__c = 'Test';
        update testOppty; 
        
        /* Check that Q/C wasn't Created */
        List<Quote> quotes = [SELECT Id, Name FROM Quote WHERE OpportunityId = :testOppty.Id];
        System.assert(quotes != null, 'Quotes List isn\'t null');
        System.assertEquals(0, quotes.size(), 'Quotes List has no records');

        Test.stopTest(); 
    }
    
    static testMethod void noESignature() {
        /* Insert Acct */
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.Name = 'AcctWithoutContract';
        insert testAcct; 
        
        /* Insert Opp */
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'OppWithoutContract';
        testOppty.AccountId = testAcct.Id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        insert testOppty; 

        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = testOppty.Id;
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = testAcct.Id;
        insert testPGiContract;
        
        /* Insert Contact */
        Contact testCntc = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testCntc; 
        
        /* Insert Primary Contact Role */
        OpportunityContactRole testCntcRole = new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testCntc.Id, IsPrimary=true);
        insert testCntcRole; 
        
        /* Insert Opportunity Line Item */
        Product2 testProd = PGITestUtilities.getStdProduct();
        insert testProd;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProd);
        insert testPbe;
        OpportunityLineItem testOpli = PGITestUtilities.getOpportunityLineItemDetails(testOppty.Id, testPbe.Id);
        insert testOpli; 
         
         Test.startTest();         
        /* Insert PGi Contract */
        CONMAN_Contract__c testContract = new CONMAN_Contract__c(Opportunity__c = testOppty.Id, Account_Name__c = testAcct.Id, Contracted_Term__c = 1, Contract_Source__c = 'iContract', Supersede_Existing_Agreements__c = true);
        insert testContract; 
        
        /* Insert License Sets for S4B */
        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        LicenseSet__c lic = new LicenseSet__c(Name='PGi Shared Audio for Skype For Business 50000', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        lics.add(lic);
        lic = new LicenseSet__c(Name='PGi Audio for Skype For Business 500', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        lics.add(lic);
        insert lics; 
        
        /* Start Test (to reset SF Limits) */
        
        
        /* Change Opp Stage to Closed Won */
        testOppty.StageName = 'Closed Won';
        testOppty.Primary_Won_Reason__c = 'Other';
        testOppty.Other_Won_Reason__c = 'Test';
        update testOppty; 
        
        /* Check that Dates, PDF URL are not set on PGi Contract*/
        testContract = [SELECT Id, OwnerId FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        List<CONMAN_Contract__c> contract = [SELECT Id, Related_Agreement__c, Contract_Source__c, Auto_Renewal__c, Company_s_Name__c,
                                              Auto_renewal_Interval_months__c, CEA_Date_Original__c, Agreement_Sales_Rep__c, Final_Sign_Date__c, 
                                              Service_Commencement_Date__c, Contract_Document_Status__c, Sales_Ops_Status__c 
                                              FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(testContract.OwnerId, contract.get(0).Agreement_Sales_Rep__c, 'Agreement Sales Rep is Contract Owner');
        System.assertEquals(testAcct.Name, contract.get(0).Company_s_Name__c, 'Company Name is from Account');
        System.assertEquals('Active', contract.get(0).Contract_Document_Status__c, 'PGiContract has Contract Document Status set to Active');
        System.assertEquals('Draft', contract.get(0).Sales_Ops_Status__c, 'PGiContract has Sales Ops Status set to Draft');
        System.assertEquals('iContract', contract.get(0).Contract_Source__c, 'PGiContract is from iContract');
        System.assertEquals(true, contract.get(0).Auto_Renewal__c, 'PGiContract has Auto-Renewal set');
        System.assertEquals(1, contract.get(0).Auto_renewal_Interval_months__c, 'PGiContract has Auto-Renewal Interval set to 1');
        System.assertEquals(null, contract.get(0).Final_Sign_Date__c,
                            'PGiContract has Signature Date set to null');
        System.assertEquals(null, contract.get(0).Service_Commencement_Date__c,
                            'PGiContract has Commencement Date set to null');
        System.assertEquals(null, contract.get(0).CEA_Date_Original__c,
                            'PGiContract has CEA Date set to null');
        
        Test.stopTest(); 
    }
    
   static testMethod void sla() {
        /* Insert Acct */
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.Name = 'AcctSLA';
        insert testAcct; 
        
        /* Insert Opp */
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'OppSLA';
        testOppty.AccountId = testAcct.Id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        insert testOppty; 

        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = testOppty.Id;
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = testAcct.Id;
        insert testPGiContract;
        
        /* Insert Contact */
        Contact testCntc = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testCntc; 
        
        /* Insert Primary Contact Role */
        OpportunityContactRole testCntcRole = new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testCntc.Id, IsPrimary=true);
        insert testCntcRole; 
        
        /* Insert Opportunity Line Item */
        Product2 testProd = PGITestUtilities.getStdProduct();
        insert testProd;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProd);
        insert testPbe;
        OpportunityLineItem testOpli = PGITestUtilities.getOpportunityLineItemDetails(testOppty.Id, testPbe.Id);
        insert testOpli; 
        
        /* Insert an EchoSign Agreement */
         echosign_dev1__SIGN_Agreement__c testESign = new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Opportunity__c = testOppty.Id,
                                                                                           echosign_dev1__SignedPDF__c = 'TEST URL');
         insert testESign;  
         Test.startTest(); 
        /* Insert PGi Contract */
        CONMAN_Contract__c testContract = new CONMAN_Contract__C(Opportunity__c = testOppty.Id, Account_Name__c = testAcct.Id, Contract_Source__c = 'iContract', Contract_Type__c = 'Subscription License Agreement', Contracted_Term__c = 24, Related_Agreement__c = testESign.Id, Supersede_Existing_Agreements__c = true);
        insert testContract; 
        
        /* Insert License Sets */
        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        LicenseSet__c lic = new LicenseSet__c(Name='License Set', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        lics.add(lic);
        insert lics; 
        
        /* Start Test (to reset SF Limits) */
       
        
        /* Change Opp Stage to Closed Won */
        testOppty.StageName = 'Closed Won';
        testOppty.Primary_Won_Reason__c = 'Other';
        testOppty.Other_Won_Reason__c = 'Test';
        update testOppty; 
        
        /* Check that SLA is set */
        testContract = [SELECT Id, OwnerId FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        List<CONMAN_Contract__c> contract = [SELECT Id, Related_Agreement__c, Contract_Type__c, Contract_Source__c, Auto_Renewal__c, Company_s_Name__c,
                                              Auto_renewal_Interval_months__c, CEA_Date_Original__c, Agreement_Sales_Rep__c, Final_Sign_Date__c, 
                                              Service_Commencement_Date__c, Contract_Document_Status__c, Sales_Ops_Status__c 
                                              FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(testContract.OwnerId, contract.get(0).Agreement_Sales_Rep__c, 'Agreement Sales Rep is Contract Owner');
        System.assertEquals(testAcct.Name, contract.get(0).Company_s_Name__c, 'Company Name is from Account');
        System.assertEquals('Active', contract.get(0).Contract_Document_Status__c, 'PGiContract has Contract Document Status set to Active');
        System.assertEquals('Draft', contract.get(0).Sales_Ops_Status__c, 'PGiContract has Sales Ops Status set to Draft');
        System.assertEquals('iContract', contract.get(0).Contract_Source__c, 'PGiContract is from iContract');
        System.assertEquals(true, contract.get(0).Auto_Renewal__c, 'PGiContract has Auto-Renewal set');
        System.assertEquals(24, contract.get(0).Auto_renewal_Interval_months__c, 'PGiContract has Auto-Renewal Interval set to 24');
        System.assertEquals(Date.today(), contract.get(0).Final_Sign_Date__c,
                            'PGiContract has Signature Date set to today');
        System.assertEquals(Date.today(), contract.get(0).Service_Commencement_Date__c,
                            'PGiContract has Commencement Date set to today');
        System.assertEquals(Date.today().addMonths(24).addDays(-1), contract.get(0).CEA_Date_Original__c,
                            'PGiContract has CEA Date set to 2 years - 1 day');
        System.assertEquals('Subscription License Agreement', contract.get(0).Contract_Type__c, 'PGiContract Type is SLA');
                   
        Test.stopTest(); 
    }
    
    static testMethod void slo() {
        
         
        /* Insert Acct */
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.Name = 'AcctSLO';
        insert testAcct;
        
         
        
        /* Insert Opp */
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'OppSLO';
        testOppty.AccountId = testAcct.Id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        insert testOppty; 
        
        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = testOppty.Id;
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = testAcct.Id;
        insert testPGiContract;
        Test.startTest();
        /* Insert Contact */
        Contact testCntc = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testCntc; 
        
        /* Insert Primary Contact Role */
        OpportunityContactRole testCntcRole = new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testCntc.Id, IsPrimary=true);
        insert testCntcRole; 
        
        /* Insert Opportunity Line Item */
        Product2 testProd = PGITestUtilities.getStdProduct();
        insert testProd;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProd);
        insert testPbe;
        OpportunityLineItem testOpli = PGITestUtilities.getOpportunityLineItemDetails(testOppty.Id, testPbe.Id);
        insert testOpli; 
        
        /* Insert an EchoSign Agreement */
        echosign_dev1__SIGN_Agreement__c testESign = new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Opportunity__c = testOppty.Id,
                                                                                           echosign_dev1__SignedPDF__c = 'TEST URL');
        insert testESign; 
        
        
        
        /* Insert PGi Contract */
        CONMAN_Contract__c testContract = new CONMAN_Contract__C(Opportunity__c = testOppty.Id, Account_Name__c = testAcct.Id,
                                                                 Contract_Source__c = 'iContract', Contract_Type__c = 'Subscription License Order', Contracted_Term__c = 36, Related_Agreement__c = testESign.Id, Supersede_Existing_Agreements__c = true);
        insert testContract; 
        
        /* Insert License Sets */
        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        LicenseSet__c lic = new LicenseSet__c(Name='License Set', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        lics.add(lic);
        insert lics; 
        
        /* Start Test (to reset SF Limits) */
       
        
        /* Change Opp Stage to Closed Won */
        testOppty.StageName = 'Closed Won';
        testOppty.Primary_Won_Reason__c = 'Other';
        testOppty.Other_Won_Reason__c = 'Test';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        update testOppty; 


        
        /* Check that SLA is set */
        testContract = [SELECT Id, OwnerId FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        List<CONMAN_Contract__c> contract = [SELECT Id, Related_Agreement__c, Contract_Type__c, Contract_Source__c, Auto_Renewal__c, Company_s_Name__c,
                                              Auto_renewal_Interval_months__c, CEA_Date_Original__c, Agreement_Sales_Rep__c, Final_Sign_Date__c, 
                                              Service_Commencement_Date__c, Contract_Document_Status__c, Sales_Ops_Status__c 
                                              FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(testContract.OwnerId, contract.get(0).Agreement_Sales_Rep__c, 'Agreement Sales Rep is Contract Owner');
        System.assertEquals(testAcct.Name, contract.get(0).Company_s_Name__c, 'Company Name is from Account');
        System.assertEquals('Active', contract.get(0).Contract_Document_Status__c, 'PGiContract has Contract Document Status set to Active');
        System.assertEquals('Draft', contract.get(0).Sales_Ops_Status__c, 'PGiContract has Sales Ops Status set to Draft');
        System.assertEquals('iContract', contract.get(0).Contract_Source__c, 'PGiContract is from iContract');
        System.assertEquals(true, contract.get(0).Auto_Renewal__c, 'PGiContract has Auto-Renewal set');
        System.assertEquals(36, contract.get(0).Auto_renewal_Interval_months__c, 'PGiContract has Auto-Renewal Interval set to 36');
        System.assertEquals(Date.today(), contract.get(0).Final_Sign_Date__c,
                            'PGiContract has Signature Date set to today');
        System.assertEquals(Date.today(), contract.get(0).Service_Commencement_Date__c,
                            'PGiContract has Commencement Date set to today');
        System.assertEquals(Date.today().addMonths(36).addDays(-1), contract.get(0).CEA_Date_Original__c,
                            'PGiContract has CEA Date set to 3 years - 1 day');
        System.assertEquals('Subscription License Order', contract.get(0).Contract_Type__c, 'PGiContract Type is SLO');
        
        Test.stopTest(); 
    }
    
     static testMethod void amendment() {
        /* Insert Acct */
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.Name = 'AcctAmendment';
        insert testAcct; 
        
           
        /* Insert Opp */
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.Name = 'OppAmendment';
        testOppty.AccountId = testAcct.Id;
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.Competitor_s__c = 'Other';
        testOppty.Incumbent__c = 'Other';
        insert testOppty; 

        CONMAN_Contract__c testPGiContract = new CONMAN_Contract__c();
        testPGiContract.Opportunity__c = testOppty.Id;
        testPGiContract.Contract_Start_Date__c = System.Today();
        testPGiContract.Contract_Renewal_Date__c = System.Today();
        testPGiContract.Has_Attachment__c = true;
        testPGiContract.Account_Name__c = testAcct.Id;
        insert testPGiContract;
        Test.startTest();
        /* Insert Contact */
        Contact testCntc = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testCntc; 
        
        /* Insert Primary Contact Role */
        OpportunityContactRole testCntcRole = new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testCntc.Id, IsPrimary=true);
        insert testCntcRole; 
        
        /* Insert Opportunity Line Item */
        Product2 testProd = PGITestUtilities.getStdProduct();
        insert testProd;
        PricebookEntry testPbe = PGITestUtilities.CreatePriceBookEntryForProduct(testProd);
        insert testPbe;
        OpportunityLineItem testOpli = PGITestUtilities.getOpportunityLineItemDetails(testOppty.Id, testPbe.Id);
        insert testOpli; 
         
        /* Insert an EchoSign Agreement */
         echosign_dev1__SIGN_Agreement__c testESign = new echosign_dev1__SIGN_Agreement__c(echosign_dev1__Opportunity__c = testOppty.Id,
                                                                                           echosign_dev1__SignedPDF__c = 'TEST URL');
        insert testESign;   
        
        /* Insert PGi Contract */
        CONMAN_Contract__c testContract = new CONMAN_Contract__C(Opportunity__c = testOppty.Id, Account_Name__c = testAcct.Id,
                                                                 Contract_Source__c = 'iContract', Contract_Type__c = 'Amendment', Contracted_Term__c = 36, Related_Agreement__c = testESign.Id, Service_Commencement_Date__c = Date.today().addDays(-1), Supersede_Existing_Agreements__c = true);
        insert testContract; 
         
        /* Insert License Sets */
        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        LicenseSet__c lic = new LicenseSet__c(Name='License Set', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        lics.add(lic);
        insert lics; 
        
        /* Start Test (to reset SF Limits) */
       
        
        /* Change Opp Stage to Closed Won */
        testOppty.StageName = 'Closed Won';
        testOppty.Primary_Won_Reason__c = 'Other';
        testOppty.Other_Won_Reason__c = 'Test';
        testOppty.Product__c = 'Web: GlobalMeet';
        testOppty.Opportunity_Deal_Type__c = 'New Business';
        testOppty.Channel__c = 'Cloud';
        update testOppty; 
        
        /* Check that Amendment is set */
        testContract = [SELECT Id, OwnerId FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        List<CONMAN_Contract__c> contract = [SELECT Id, Related_Agreement__c, Contract_Type__c, Contract_Source__c, Auto_Renewal__c, Company_s_Name__c,
                                              Auto_renewal_Interval_months__c, CEA_Date_Original__c, Agreement_Sales_Rep__c, Final_Sign_Date__c, 
                                              Service_Commencement_Date__c, Contract_Document_Status__c, Sales_Ops_Status__c 
                                              FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals(testContract.OwnerId, contract.get(0).Agreement_Sales_Rep__c, 'Agreement Sales Rep is Contract Owner');
        System.assertEquals(testAcct.Name, contract.get(0).Company_s_Name__c, 'Company Name is from Account');
        System.assertEquals('Active', contract.get(0).Contract_Document_Status__c, 'PGiContract has Contract Document Status set to Active');
        System.assertEquals('Draft', contract.get(0).Sales_Ops_Status__c, 'PGiContract has Sales Ops Status set to Draft');
        System.assertEquals('iContract', contract.get(0).Contract_Source__c, 'PGiContract is from iContract');
        System.assertEquals(true, contract.get(0).Auto_Renewal__c, 'PGiContract has Auto-Renewal set');
        System.assertEquals(36, contract.get(0).Auto_renewal_Interval_months__c, 'PGiContract has Auto-Renewal Interval set to 36');
        System.assertEquals(Date.today(), contract.get(0).Final_Sign_Date__c,
                            'PGiContract has Signature Date set to today');
        System.assertEquals(Date.today().addDays(-1), contract.get(0).Service_Commencement_Date__c,
                            'PGiContract has Commencement Date set to today');
        System.assertEquals(Date.today().addMonths(36).addDays(-2), contract.get(0).CEA_Date_Original__c,
                            'PGiContract has CEA Date set to 3 years - 1 day');
        System.assertEquals('Amendment', contract.get(0).Contract_Type__c, 'PGiContract Type is Amendment');
                           
        Test.stopTest(); 
    }
    
}