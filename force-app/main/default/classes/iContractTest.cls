@isTest
public class iContractTest {
     @TestSetup
    static void makeData(){
        PGITestUtilities.disableSalesWings();
        Country__c us = new Country__c(Name = 'United States', Region__c = 'US');
        Country__c can = new Country__c(Name = 'Canada', Region__c = 'CAN');
        insert new List<Country__c>{us, can};
    }
    static testMethod void testConstruct(){
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
        iContract.getContract(testContract.Id);
    }
    static testMethod void addRemoveDefaultVerbiage_US(){
        List<PGIServicesInformation__c> terms = new List<PGIServicesInformation__c>();
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date',
            Order__c=1,
            Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Specific_Product_Family_Usage__c ='UCaaS',
            Region__c='US', Unique_ID__c='100'));
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date CAN',
            Order__c=1,
            Agreement_Type__c='Amendment',Language__c = 'en_US',                                                
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='200'));
        terms.add(new PGIServicesInformation__c(Name='Recitals',
            Order__c=2,
            Agreement_Type__c='Amendment',Language__c = 'en_US',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='300'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement Amendment',
            Order__c=1,
            Agreement_Type__c='Amendment',Language__c = 'en_US',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='400'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area Amendment',
            Order__c=1,
            Agreement_Type__c='Amendment',Language__c = 'en_US',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='500'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes SG',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='600'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes CAN',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='700'));
        terms.add(new PGIServicesInformation__c(Name='Rate Modification Agreement US',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='800'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='900'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='110'));
        terms.add(new PGIServicesInformation__c(Name='Term SG',
            Order__c=2,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='120'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='130'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='140'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='150'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='160'));
        insert terms;

        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testContact;

        insert new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        insert testContract;

        Test.startTest();

        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(5, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());
        //
        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Rate Modification Amendment';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(2, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Subscription License Agreement';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(5, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());
        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Amendment';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(4, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());

        Test.stopTest();
    }

    static testMethod void addRemoveDefaultVerbiage_CAN(){
        List<PGIServicesInformation__c> terms = new List<PGIServicesInformation__c>();
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='100'));
        terms.add(new PGIServicesInformation__c(Name='Parties, Underlying Agreement & Amendment Effective Date CAN',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='200'));
        terms.add(new PGIServicesInformation__c(Name='Recitals',
            Order__c=2,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='300'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement Amendment',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='400'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area Amendment',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Amendment',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='500'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes SG',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='600'));
        terms.add(new PGIServicesInformation__c(Name='Services & Pricing Schedule Billing Footnotes CAN',
            Order__c=100,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement;Amendment;Rate Modification Amendment',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='700'));
        terms.add(new PGIServicesInformation__c(Name='Rate Modification Agreement US',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Rate Modification Amendment',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='800'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='900'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='110'));
        terms.add(new PGIServicesInformation__c(Name='Term SG',
            Order__c=2,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='120'));
        terms.add(new PGIServicesInformation__c(Name='Acknowledgement',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Intro',
            Region__c='US;CAN', Unique_ID__c='130'));
        terms.add(new PGIServicesInformation__c(Name='Signing Area',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order;Subscription License Agreement',
            Section__c='Signature',
            Region__c='US;CAN', Unique_ID__c='140'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='150'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='160'));
        insert terms;

        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        testContact.MailingCountry = 'Canada';
        insert testContact;

        insert new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        insert testContract;

        Test.startTest();

        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(5, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());
    
        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Rate Modification Amendment';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(2, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Subscription License Agreement';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(5, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());
        iContract.deleteVerbiage(testContract.Id);

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Amendment';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        System.assertEquals(5, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());

        Test.stopTest();
    }

    static testMethod void addRemoveDefaultVerbiage_US_SRT_SLO_UC(){
        List<PGIServicesInformation__c> terms = new List<PGIServicesInformation__c>();
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='SRT iContract SLO ENG'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='SRT iContract SLO ENG UC'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='110'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='SRT iContract SLA ENG'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='SRT iContract SLA ENG UC'));
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract CAN SLA',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Agreement',
            Section__c='Intro',
            Region__c='CAN', Unique_ID__c='160'));
        insert terms;

        List<Offerings__c> offrs = new List<Offerings__c>();
        offrs.add(new Offerings__c(Name='Offr1', Unique_ID__c='Offr1', Family__c='UCaaS;Collaboration'));
        offrs.add(new Offerings__c(Name='Offr2', Unique_ID__c='Offr2', Family__c='Collaboration'));
        insert offrs;

        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testContact;

        insert new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        insert testContract;
        
        INSERT new LicenseSet__c(Name='Test1', Price__c=58.54, CurrencyIsoCode='USD', Enterprise_Name__c=offrs.get(0).Id, Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);

        Test.startTest();
        List<CONMAN_Contract_Verbiage__c> verbs;

        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, verbs.size());
        System.assertEquals('Services, Rates and Terms iContract SLO', verbs.get(0).Name);

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Subscription License Agreement';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, verbs.size());
        System.assertEquals('Services, Rates and Terms iContract SLA', verbs.get(0).Name);

        DELETE [SELECT Id, Name FROM LicenseSet__c WHERE PGi_Contract__c = :testContract.Id];
        INSERT new LicenseSet__c(Name='Test1', Price__c=58.54, CurrencyIsoCode='USD', Enterprise_Name__c=offrs.get(1).Id, Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Subscription License Order';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, verbs.size());
        System.assertEquals('Services, Rates and Terms iContract SLO', verbs.get(0).Name);

        delete [SELECT Id FROM CONMAN_Contract_Verbiage__c];
        testContract.Contract_Type__c = 'Subscription License Agreement';
        UPDATE testContract;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, verbs.size());
        System.assertEquals('Services, Rates and Terms iContract SLA', verbs.get(0).Name);
        
        Test.stopTest();
    }

    static testMethod void addRemoveMinCommitVerbiage(){
        INSERT new PGIServicesInformation__c(Name='Minimum Commitment', Language__c = 'en_US',
                                             Content_RTF__c='[CommitmentAmount] / [Reoccurence]', Order__c=100, Agreement_Type__c='Subscription License Order', Section__c='Pre-Intro Table', Region__c='US;CAN', Unique_ID__c='mc');

        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        INSERT testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        INSERT testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        INSERT testContact;

        INSERT new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        testContract.Contracted_Term__c = 12;
        testContract.Contracted_Frequency__c = 1;
        testContract.Contracted_Commit_Frequency__c = 1;
        testContract.Language__c = 'en_US';
        INSERT testContract;
        

        Rate__c commitRate = new Rate__c(Unique_ID__c='commit', Type__c='Commit', Name='Commitment');
        INSERT commitRate;

        Test.startTest();

        List<Associated_Rate__c> ARs = new List<Associated_Rate__c>();
        ARs.add(new Associated_Rate__c(Override__c=1000, Rate__c=commitRate.Id, CurrencyIsoCode='USD'));
        ARs.add(new Associated_Rate__c(Override__c=200, Rate__c=commitRate.Id, CurrencyIsoCode='USD'));
        ARs.add(new Associated_Rate__c(Override__c=3300, Rate__c=commitRate.Id, CurrencyIsoCode='USD'));

        iContract.addRemoveMinCommitVerbiage(testContract.Id, ARs);

        List<CONMAN_Contract_Verbiage__c> Vs = [SELECT Id, Verbiage__c FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, Vs.size(), 'One verbiage added');
        System.assertEquals('USD 4500.00 / month', Vs.get(0).Verbiage__c, 'Verbiage text correct');

        testContract = [SELECT Id, New_Minimum_Commitment__c FROM CONMAN_Contract__c WHERE Id = :testContract.Id];
        System.assertEquals('USD 4500.00 / month for 1 year', testContract.New_Minimum_Commitment__c, 'Contract field correct');
        Test.stopTest();
    }

    static testMethod void addRemoveVerbiageForOffering(){
        List<Contract_Terms__c> terms = new List<Contract_Terms__c>();
        terms.add(new Contract_Terms__c(Name='Terms1', Unique_ID__c='100', Language__c = 'en_US'));
        terms.add(new Contract_Terms__c(Name='Terms2', Unique_ID__c='200', Language__c = 'en_US'));
        terms.add(new Contract_Terms__c(Name='Terms3', Unique_ID__c='300', Language__c = 'en_US'));
        insert terms;

        List<Offerings__c> offrs = new List<Offerings__c>();
        offrs.add(new Offerings__c(Name='Offr1', Unique_ID__c='Offr1'));
        offrs.add(new Offerings__c(Name='Offr2', Unique_ID__c='Offr2'));
        insert offrs;

        List<Offerings_Contract_Term__c> octs = new List<Offerings_Contract_Term__c>();
        octs.add(new Offerings_Contract_Term__c(Contract_General_Content__c=terms.get(0).Id, Offerings__c=offrs.get(0).Id, Unique_ID__c='OCT1.1', Order__c=1, Agreement_Type__c='Amendment'));
        octs.add(new Offerings_Contract_Term__c(Contract_General_Content__c=terms.get(0).Id, Offerings__c=offrs.get(0).Id, Unique_ID__c='OCT1.2', Order__c=1, Agreement_Type__c='Subscription License Order'));
        octs.add(new Offerings_Contract_Term__c(Contract_General_Content__c=terms.get(1).Id, Offerings__c=offrs.get(1).Id, Unique_ID__c='OCT2', Order__c=1, Agreement_Type__c='Subscription License Order'));
        insert octs;
        System.debug('=0==>'+octs[0]);
        System.debug('=1==>'+octs[1]);
        System.debug('==2=>'+octs[2]);
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testContact;

        insert new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        insert testContract;

        Test.startTest();

        Set<Id> offrIds = new Set<Id>();
        offrIds.add(offrs.get(0).Id);
        offrIds.add(offrs.get(1).Id);
        
        iContract.addRemoveVerbiageForOffering(testContract.Id, offrIds);
        System.assertEquals(2, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());

        insert new CONMAN_Contract_Verbiage__c(Name='Resold', Contract_Product_Verbiage__c=terms.get(2).Id, PGi_Contract__c=testContract.Id);
        iContract.addRemoveVerbiageForOffering(testContract.Id, offrIds);
        System.assertEquals(2, [SELECT Id FROM CONMAN_Contract_Verbiage__c WHERE PGi_Contract__c = :testContract.Id].size());
        iContract.getPageUserIPAddress();
        Test.stopTest();
    }

    static testMethod void deleteLicensesAndRates(){
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;

        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        lics.add(new LicenseSet__c(Name='Test1', Price__c=58.54, CurrencyIsoCode='USD', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id));
        lics.add(new LicenseSet__c(Name='Test2', CurrencyIsoCode='USD', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id));
        lics.add(new LicenseSet__c(Name='Test3', CurrencyIsoCode='USD', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id));
        lics.add(new LicenseSet__c(Name='Test4', CurrencyIsoCode='USD', Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id));
        insert lics;

        Test.startTest();

        System.assertEquals(4, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :testContract.Id].size(), 'LicenseSets exist');
        iContract.deleteLicensesAndRates(testContract.Id);
        System.assertEquals(0, [SELECT Id FROM LicenseSet__c WHERE PGi_Contract__c = :testContract.Id].size(), 'LicenseSets deleted');

        Test.stopTest();
    }

    static testMethod void dealDeskUpdatedFloors(){
        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;
        
        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;
        
        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        insert testContract;
        Offerings__c offObj = new Offerings__c(Name='Offr1', Unique_ID__c='Offr1', Order__c=23, Require_Rates_to_Add_Terms__c=true);
        INSERT offObj;
        LicenseSet__c lic = new LicenseSet__c(Name='Test', Enterprise_Name__c= offobj.Id, Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);
        List<LicenseSet__c> lics = new List<LicenseSet__c>();
        lics.add(lic);
        insert lics;
        
        List<Associated_Rate__c> ars = new List<Associated_Rate__c>();
        ars.add(new Associated_Rate__c(Name='Should not change: Override', LicenseSet__c=lic.Id,
                                       Override__c=0.05, Sales_Rep__c=0.04, RVP__c=0.03, SVP__c=0.02));
        ars.add(new Associated_Rate__c(Name='SVP Should change: Override', LicenseSet__c=lic.Id,
                                       Override__c=0.05, Sales_Rep__c=0.07, RVP__c=0.06, SVP__c=0.06));
        ars.add(new Associated_Rate__c(Name='RVP Should change: Override', LicenseSet__c=lic.Id,
                                       Override__c=0.05, Sales_Rep__c=0.07, RVP__c=0.06, SVP__c=0.02));
        ars.add(new Associated_Rate__c(Name='SR Should change: Override', LicenseSet__c=lic.Id,
                                       Override__c=0.05, Sales_Rep__c=0.06, RVP__c=0.03, SVP__c=0.02));
        insert ars;
        
        Test.startTest();
        
        testContract.Deal_Desk_Approved__c = true;
        testContract.Product_Details_Were_Manually_Changed__c = 'No';
		testContract.T_Cs_Were_Manually_Changed__c = 'No';
        update testContract;
        iContract.handleTerms(testContract.Id);
        Test.stopTest();
        
        ars = [SELECT Id, Name,
               Override__c, Sales_Rep__c, RVP__c, SVP__c
               FROM Associated_Rate__c WHERE LicenseSet__c = :lic.Id];
        integer matchedAssociatedRates = 4;
        for (Associated_Rate__c ar : ars) {
            if (ar.Name.equals('Should not change: Override')) {
                System.assertEquals(0.04, ar.Sales_Rep__c, 'Sales Rep limit unchanged');
                System.assertEquals(0.03, ar.RVP__c, 'RVP limit unchanged');
                System.assertEquals(0.02, ar.SVP__c, 'SVP limit unchanged');
                matchedAssociatedRates--;
            } else if (ar.Name.equals('SVP Should change: Override')) {
                System.assertEquals(0.05, ar.Sales_Rep__c, 'Sales Rep limit changed');
                System.assertEquals(0.05, ar.RVP__c, 'RVP limit changed');
                System.assertEquals(0.05, ar.SVP__c, 'SVP limit unchanged');
                matchedAssociatedRates--;
            } else if (ar.Name.equals('RVP Should change: Override')) {
                System.assertEquals(0.05, ar.Sales_Rep__c, 'Sales Rep limit changed');
                System.assertEquals(0.05, ar.RVP__c, 'RVP limit changed');
                System.assertEquals(0.02, ar.SVP__c, 'SVP limit unchanged');
                matchedAssociatedRates--;
            } else if (ar.Name.equals('SR Should change: Override')) {
                System.assertEquals(0.05, ar.Sales_Rep__c, 'Sales Rep limit changed');
                System.assertEquals(0.03, ar.RVP__c, 'RVP limit unchanged');
                System.assertEquals(0.02, ar.SVP__c, 'SVP limit unchanged');
                matchedAssociatedRates--;
            }
        }
        System.assertEquals(0, matchedAssociatedRates, 'Failed to match each Associated Rate by name');
    }
    /**
    RT-298: Test method for filtering verbiages. based on the family field
    */
    static testMethod void addRemoveDefaultVerbiage_FamilyFilter(){
        List<PGIServicesInformation__c> terms = new List<PGIServicesInformation__c>();
        terms.add(new PGIServicesInformation__c(Name='Services, Rates and Terms iContract SLO',
            Order__c=1,Language__c = 'en_US',
            Agreement_Type__c='Subscription License Order',
            Section__c='Intro',
            Region__c='US', Unique_ID__c='SRT iContract SLO ENG',
            Specific_Product_Family_Usage__c = 'Webcast;UCaaS'));
        
        insert terms;

        List<Offerings__c> offrs = new List<Offerings__c>();
        offrs.add(new Offerings__c(Name='Offr1', Unique_ID__c='Offr1', Family__c='UCaaS;Collaboration'));
        offrs.add(new Offerings__c(Name='Offr2', Unique_ID__c='Offr2', Family__c='Collaboration'));
        insert offrs;

        Account testAcct = PGITestUtilities.getAccountDetails();
        testAcct.NumberOfEmployees = 1000;
        insert testAcct;

        Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
        testOppty.StageName = 'Awareness';
        testOppty.CloseDate = Date.today().addDays(1);
        testOppty.AccountId = testAcct.Id;
        testOppty.Pricebook2Id = Test.getStandardPricebookId();
        insert testOppty;

        Contact testContact = PGITestUtilities.getContactDetails(testAcct.Id);
        insert testContact;

        insert new OpportunityContactRole(OpportunityId=testOppty.Id, ContactId=testContact.Id, IsPrimary=true, Role='Agreement Signer');

        CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
        testContract.Contract_Type__c = 'Subscription License Order';
        insert testContract;
        
        INSERT new LicenseSet__c(Name='Test1', Price__c=58.54, CurrencyIsoCode='USD', Enterprise_Name__c=offrs.get(0).Id, Opportunity__c=testOppty.Id, PGi_Contract__c=testContract.Id);

        Test.startTest();
        List<CONMAN_Contract_Verbiage__c> verbs;
        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name, Contract_General_Content__r.Specific_Product_Family_Usage__c 
                FROM CONMAN_Contract_Verbiage__c 
                WHERE PGi_Contract__c = :testContract.Id];
        System.assertEquals(1, verbs.size());
        System.assertEquals(verbs.get(0).Contract_General_Content__r.Specific_Product_Family_Usage__c, 'UCaaS;Webcast');
        
        //Testing for existing Record with matching family
        PGIServicesInformation__c pgiRec = new PGIServicesInformation__c(Name='Recitals',
            Order__c=2,
            Agreement_Type__c='Amendment',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='300',
            Specific_Product_Family_Usage__c = 'Webcast;UCaaS');
        INSERT pgiRec;

        CONMAN_Contract_Verbiage__c conmanRec = new CONMAN_Contract_Verbiage__c();
        conmanRec.PGi_Contract__c = testContract.Id;
        conmanRec.Contract_General_Content__c = pgiRec.Id;
        INSERT conmanRec;

        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name, Contract_General_Content__r.Specific_Product_Family_Usage__c 
                FROM CONMAN_Contract_Verbiage__c 
                WHERE PGi_Contract__c = :testContract.Id];

        System.assertEquals(1, verbs.size());
        System.assertEquals(verbs.get(0).Contract_General_Content__r.Specific_Product_Family_Usage__c, 'UCaaS;Webcast');

        //Testing for existing Record without matching family
        PGIServicesInformation__c pgiRecwithoutMatch = new PGIServicesInformation__c(Name='Terms',
            Order__c=1,
            Agreement_Type__c='Amendment',
            Section__c='Pre-Intro Table',
            Region__c='US;CAN', Unique_ID__c='303',
            Specific_Product_Family_Usage__c = 'Webcast');
        INSERT pgiRecwithoutMatch;

        CONMAN_Contract_Verbiage__c conmanRecwithoutMatch = new CONMAN_Contract_Verbiage__c();
        conmanRecwithoutMatch.PGi_Contract__c = testContract.Id;
        conmanRecwithoutMatch.Contract_General_Content__c = pgiRecwithoutMatch.Id;
        INSERT conmanRecwithoutMatch;

        iContract.addRemoveDefaultVerbiage(testContract.Id);
        verbs = [SELECT Id, Name, Contract_General_Content__r.Specific_Product_Family_Usage__c 
                FROM CONMAN_Contract_Verbiage__c 
                WHERE PGi_Contract__c = :testContract.Id];

        System.assertEquals(1, verbs.size());
        System.assertEquals(verbs.get(0).Contract_General_Content__r.Specific_Product_Family_Usage__c, 'UCaaS;Webcast');

        Test.stopTest();
    }
    // Public static testMethod void testUpdateOpportunity(){
    //   Account testAcct = PGITestUtilities.getAccountDetails();
    //     testAcct.NumberOfEmployees = 1000;
    //     insert testAcct;
        
    //     Opportunity testOppty = PGITestUtilities.getOpportunityDetails();
    //     testOppty.StageName = 'Awareness';
    //     testOppty.CloseDate = Date.today().addDays(1);
    //     testOppty.AccountId = testAcct.Id;
    //     testOppty.Pricebook2Id = Test.getStandardPricebookId();
    //     insert testOppty;
        
    //     CONMAN_Contract__c testContract = PGITestUtilities.getConManContractDetails(testAcct.Id, testOppty.Id);
    //     insert testContract;
    //     iContract.updateOpportunity(testContract.Id);
    //     Opportunity oppObj = [SELECT StageName FROM Opportunity WHERE id =: testOppty.Id];
    //     System.assertEquals(oppObj.StageName, 'Closed Pending Approval');
    // }
}