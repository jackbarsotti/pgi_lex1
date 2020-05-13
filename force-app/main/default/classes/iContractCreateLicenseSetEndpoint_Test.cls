@isTest
public class iContractCreateLicenseSetEndpoint_Test {
    
    static testMethod void TestingCreateLicenseSet(){
        Opportunity opp  = new Opportunity();
        opp.Name = 'Tereh';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today();
        insert opp;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, opp.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=24,
                                  Product_Name__c='Microsoft Lync Online Services',Price__c=58.54,Opportunity__c=opp.Id,
                                  Payment_Plan__c='Monthly',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
    }
    
    static testMethod void TestingCreateLicenseSetMSLV(){
        Opportunity opp  = new Opportunity();
        opp.Name = 'Tereh';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today();
        insert opp;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, opp.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=24,
                                  Product_Name__c='Microsoft Lync Online Services',Price__c=0,Opportunity__c=opp.Id,
                                  Payment_Plan__c='Monthly',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
    }
    
    static testMethod void TestingCreateLicenseSetNotNlScbNus(){
        Opportunity opp  = new Opportunity();
        opp.Name = 'Tereh';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today();
        insert opp;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, opp.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,Number_of_Licensed_Named_Users__c=1,
                                  Product_Name__c='Test LS',Price__c=0,Opportunity__c=opp.Id,
                                  Payment_Plan__c='Monthly',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
    }
    
    static testMethod void TestingCreateLicenseSetReturn(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Annual',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
        
    }
    
    static testMethod void TestingCreateLicenseSetOverride(){
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        insert testOppty;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=24,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=testOppty.Id,
                                  Payment_Plan__c='Monthly',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070,Override__c=0.010));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
    }
    
    static testMethod void TestingCreateLicenseSetNoDefault(){
        Opportunity opp  = new Opportunity();
        opp.Name = 'Tereh';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today();
        insert opp;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, opp.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=opp.Id,
                                  Payment_Plan__c='Monthly',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0,Override__c=0.050));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
        
    }
    
    static testMethod void TestingCreateLicenseSet2(){
        Opportunity opp  = new Opportunity();
        opp.Name = 'Tereh';
        opp.StageName = 'Awareness';
        opp.CloseDate = date.today();
        insert opp;
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, opp.Id);
        insert testContract;
        
        List<LicenseSet__c> lcs = new List<LicenseSet__c>();
        lcs.add(new LicenseSet__c(Name='Test LS',Subscription_License_Term_Months__c=12,
                                  Product_Name__c='Test LS',Price__c=58.54,Opportunity__c=opp.Id,
                                  Payment_Plan__c='Annual',
                                  PGi_Contract__c=testContract.Id));
        
        List<Associated_Rate__c> asscRt = new List<Associated_Rate__c>();
        asscRt.add(new Associated_Rate__c(Rate_Name__c='Arate',Sales_Rep__c=0.050,Default__c=0.070));
        List<List<Associated_Rate__c>> asscRts = new List<List<Associated_Rate__c>>();
        asscRts.add(asscRt);
        
        Test.startTest();
        System.assertEquals(iContract.SUCCESS, iContractCreateLicenseSetEndpoint.createLicenseSet(testContract.Id, lcs, asscRts));
        Test.stopTest();
    }
}